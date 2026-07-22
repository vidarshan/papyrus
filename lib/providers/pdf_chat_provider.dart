import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

enum ChatRole { user, model }

class ChatMessage {
  ChatMessage({required this.role, required this.text});

  final ChatRole role;
  final String text;
}

/// Drives a Gemini chat session scoped to a single PDF, sent via Firebase
/// AI Logic so no API key is embedded in the app. Messages are persisted to
/// Firestore under `users/{uid}/pdfs/{pdfId}/messages` so a conversation
/// survives app restarts; reopening a previously-chatted PDF replays that
/// history into a freshly primed [ChatSession] instead of starting over.
class PdfChatProvider extends ChangeNotifier {
  PdfChatProvider({required this.pdfId, required this.fileName});

  final String pdfId;
  final String fileName;
  late final ChatSession _chat;
  bool _documentSent = false;

  // Points Gemini at the PDF's existing Cloud Storage for Firebase location
  // instead of embedding the raw bytes in the request. Firebase AI Logic
  // reads gs:// URLs directly, which avoids the ~20MB inline-request-body
  // limit that was breaking uploads for larger PDFs ("terminated by server").
  String get _fileUri =>
      'gs://${FirebaseStorage.instance.bucket}/users/$_uid/pdfs/$pdfId.pdf';

  final List<ChatMessage> messages = [];
  bool isLoading = false;
  String? error;

  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  CollectionReference<Map<String, dynamic>> get _messagesRef =>
      FirebaseFirestore.instance
          .collection('users')
          .doc(_uid)
          .collection('pdfs')
          .doc(pdfId)
          .collection('messages');

  DocumentReference<Map<String, dynamic>> get _pdfRef => FirebaseFirestore
      .instance
      .collection('users')
      .doc(_uid)
      .collection('pdfs')
      .doc(pdfId);

  /// Loads any previously persisted messages for this PDF. If none exist,
  /// starts a fresh chat and sends the automatic summary prompt (as before).
  /// Otherwise primes a [ChatSession] with the stored history - re-including
  /// the PDF as a [FileData] reference on the first turn, since the session
  /// has no memory of the document unless it's physically present in that
  /// primed history - and skips the summary prompt.
  Future<void> init() async {
    isLoading = true;
    notifyListeners();

    final snapshot = await _messagesRef.orderBy('createdAt').get();
    final stored = snapshot.docs
        .map(
          (doc) => ChatMessage(
            role: doc['role'] == 'user' ? ChatRole.user : ChatRole.model,
            text: doc['text'] as String,
          ),
        )
        .toList();

    if (stored.isEmpty) {
      _chat = FirebaseAI.googleAI()
          .generativeModel(model: 'gemini-2.5-flash')
          .startChat();
      await sendMessage('Please give me a brief summary of this document.');
      return;
    }

    // Drop a trailing, unanswered user turn (e.g. the app was killed after
    // it was persisted but before Gemini's reply came back) - it would
    // break the strict user/model alternation a primed history expects. It's
    // still added to `messages` below so the user can see and resend it.
    final history = List<ChatMessage>.from(stored);
    if (history.isNotEmpty && history.last.role == ChatRole.user) {
      history.removeLast();
    }

    final primedHistory = <Content>[];
    for (var i = 0; i < history.length; i++) {
      final message = history[i];
      if (i == 0) {
        primedHistory.add(
          Content('user', [
            FileData('application/pdf', _fileUri),
            TextPart(message.text),
          ]),
        );
      } else if (message.role == ChatRole.user) {
        primedHistory.add(Content.text(message.text));
      } else {
        primedHistory.add(Content.model([TextPart(message.text)]));
      }
    }

    _chat = FirebaseAI.googleAI()
        .generativeModel(model: 'gemini-2.5-flash')
        .startChat(history: primedHistory);
    _documentSent = true;
    messages.addAll(stored);
    isLoading = false;
    notifyListeners();
  }

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || isLoading) return;

    messages.add(ChatMessage(role: ChatRole.user, text: trimmed));
    isLoading = true;
    error = null;
    notifyListeners();

    await _messagesRef.add({
      'role': 'user',
      'text': trimmed,
      'createdAt': FieldValue.serverTimestamp(),
    });

    final includeDocument = !_documentSent;
    final parts = <Part>[
      if (includeDocument) FileData('application/pdf', _fileUri),
      TextPart(trimmed),
    ];

    try {
      final response = await _chat.sendMessage(Content.multi(parts));
      if (includeDocument) _documentSent = true;
      final replyText = response.text ?? "I couldn't generate a response.";
      messages.add(ChatMessage(role: ChatRole.model, text: replyText));

      await _messagesRef.add({
        'role': 'model',
        'text': replyText,
        'createdAt': FieldValue.serverTimestamp(),
      });
      await _pdfRef.update({
        'lastMessageAt': FieldValue.serverTimestamp(),
        'messageCount': FieldValue.increment(2),
        'lastMessagePreview': replyText.length > 120
            ? '${replyText.substring(0, 120)}…'
            : replyText,
      });
    } catch (e, stackTrace) {
      debugPrint('Gemini request failed: $e\n$stackTrace');
      error = 'Gemini request failed: $e';
    }

    isLoading = false;
    notifyListeners();
  }
}
