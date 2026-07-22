import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
