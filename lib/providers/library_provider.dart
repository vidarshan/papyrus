import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

/// A PDF that has been uploaded and indexed in Firestore under
/// `users/{uid}/pdfs/{id}`, with its bytes in Firebase Storage at
/// [storagePath]. Unlike [DevicePdf], this survives app restarts.
class LibraryPdf {
  LibraryPdf({
    required this.id,
    required this.name,
    required this.size,
    required this.storagePath,
    this.createdAt,
    this.lastMessageAt,
    this.messageCount = 0,
    this.lastMessagePreview,
  });

  factory LibraryPdf.fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return LibraryPdf(
      id: doc.id,
      name: (data['name'] as String?) ?? 'Untitled.pdf',
      size: (data['size'] as num?)?.toInt() ?? 0,
      storagePath: data['storagePath'] as String,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      lastMessageAt: (data['lastMessageAt'] as Timestamp?)?.toDate(),
      messageCount: (data['messageCount'] as num?)?.toInt() ?? 0,
      lastMessagePreview: data['lastMessagePreview'] as String?,
    );
  }

  final String id;
  final String name;
  final int size;
  final String storagePath;
  final DateTime? createdAt;
  final DateTime? lastMessageAt;
  final int messageCount;
  final String? lastMessagePreview;
}

/// Streams the signed-in user's persisted PDF library from Firestore, so
/// previously uploaded PDFs and their chat progress survive app restarts.
/// Used by both [HomeTab] and [LibraryTab].
class LibraryProvider extends ChangeNotifier {
  List<LibraryPdf> pdfs = [];
  bool isLoading = true;
  String? error;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;

  void init() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      isLoading = false;
      notifyListeners();
      return;
    }

    _subscription = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('pdfs')
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            pdfs = snapshot.docs.map(LibraryPdf.fromDoc).toList();
            isLoading = false;
            error = null;
            notifyListeners();
          },
          onError: (_) {
            error = 'Could not load your library.';
            isLoading = false;
            notifyListeners();
          },
        );
  }

  /// Renames [pdf] in place. A no-op if [newName] is blank or unchanged.
  Future<void> renamePdf(LibraryPdf pdf, String newName) async {
    final trimmed = newName.trim();
    if (trimmed.isEmpty || trimmed == pdf.name) return;

    final uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('pdfs')
        .doc(pdf.id)
        .update({'name': trimmed});
  }

  /// Deletes [pdf]'s Firestore doc, its messages subcollection (Firestore
  /// doesn't cascade-delete subcollections on its own) and its Storage
  /// object. The Storage delete is best-effort: by the time it runs, the
  /// Firestore doc that drives the visible library is already gone, so a
  /// failure there is a silent cleanup miss rather than a user-facing error.
  Future<void> deletePdf(LibraryPdf pdf) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final pdfRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('pdfs')
        .doc(pdf.id);

    final messages = await pdfRef.collection('messages').get();
    final batch = FirebaseFirestore.instance.batch();
    for (final doc in messages.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(pdfRef);
    await batch.commit();

    try {
      await FirebaseStorage.instance.ref(pdf.storagePath).delete();
    } catch (_) {
      // Best-effort cleanup - see doc comment above.
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
