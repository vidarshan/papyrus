import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

enum PdfUploadStatus { idle, uploading, uploaded, failed }

/// A PDF found on the device, either via the Android MediaStore scan
/// ([contentUri] set) or picked manually through the file picker
/// ([filePath] set).
class DevicePdf {
  DevicePdf({
    required this.id,
    required this.name,
    required this.size,
    this.dateModified,
    this.contentUri,
    this.filePath,
  });

  final String id;
  final String name;
  final int size;
  final DateTime? dateModified;
  final String? contentUri;
  final String? filePath;
}

class DevicePdfsProvider extends ChangeNotifier {
  static const _channel = MethodChannel('papyrus/device_pdfs');

  List<DevicePdf> pdfs = [];
  bool isLoading = false;
  bool permissionDenied = false;
  bool permissionPermanentlyDenied = false;
  // Whether this device is old enough (Android <=12L) that the legacy
  // READ_EXTERNAL_STORAGE permission still works and the MediaStore scan is
  // worth running. On 13+ that permission isn't declared (see
  // AndroidManifest.xml) and MediaStore can only see the app's own files, so
  // there's nothing useful to scan for - the file picker (browseForPdfs) is
  // the only real way to add PDFs there.
  bool needsLegacyStorage = false;
  String? error;
  final Map<String, PdfUploadStatus> uploadStatus = {};
  // Maps a local DevicePdf.id to the Firestore doc id it was indexed under,
  // once ensureUploaded has resolved one (so re-tapping the same file in the
  // same session doesn't re-upload or re-query Firestore for it).
  final Map<String, String> uploadedPdfId = {};

  Future<void> init() async {
    if (Platform.isAndroid) {
      await loadDevicePdfs();
    }
  }

  Future<void> loadDevicePdfs() async {
    isLoading = true;
    error = null;
    permissionDenied = false;
    permissionPermanentlyDenied = false;
    notifyListeners();

    needsLegacyStorage =
        await _channel.invokeMethod<bool>('needsLegacyStoragePermission') ??
        false;
    if (!needsLegacyStorage) {
      isLoading = false;
      notifyListeners();
      return;
    }

    final status = await Permission.storage.request();
    if (!status.isGranted) {
      isLoading = false;
      permissionDenied = true;
      permissionPermanentlyDenied = status.isPermanentlyDenied;
      notifyListeners();
      return;
    }

    try {
      final raw = await _channel.invokeMethod<List<Object?>>('listPdfs');
      pdfs = (raw ?? [])
          .cast<Map<Object?, Object?>>()
          .map(
            (m) => DevicePdf(
              id: m['uri'] as String,
              name: (m['name'] as String?) ?? 'Untitled.pdf',
              size: (m['size'] as num?)?.toInt() ?? 0,
              dateModified: m['dateModified'] != null
                  ? DateTime.fromMillisecondsSinceEpoch(
                      m['dateModified'] as int,
                    )
                  : null,
              contentUri: m['uri'] as String,
            ),
          )
          .toList();
    } catch (e) {
      error = 'Could not read PDFs from this device.';
    }

    isLoading = false;
    notifyListeners();
  }

  /// Lets the user pick PDFs through the system file/document picker.
  /// This is the only option on iOS (and other non-Android platforms),
  /// and a manual fallback on Android when a PDF isn't picked up by the
  /// MediaStore scan.
  Future<void> browseForPdfs() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true,
    );
    if (result == null) return;

    final picked = result.files
        .where((f) => f.path != null)
        .map(
          (f) => DevicePdf(
            id: f.path!,
            name: f.name,
            size: f.size,
            filePath: f.path,
          ),
        );

    final existingIds = pdfs.map((p) => p.id).toSet();
    pdfs = [...pdfs, ...picked.where((p) => !existingIds.contains(p.id))];
    notifyListeners();
  }

  /// Reads the raw bytes of [pdf], whether it came from the MediaStore scan
  /// (`content://` URI, read via the platform channel) or the file picker
  /// (a real filesystem path).
  Future<Uint8List> readBytes(DevicePdf pdf) async {
    if (pdf.contentUri != null) {
      final bytes = await _channel.invokeMethod<Uint8List>('readBytes', {
        'uri': pdf.contentUri,
      });
      return bytes!;
    }
    return File(pdf.filePath!).readAsBytes();
  }

  /// Uploads [pdf] to Firebase Storage and indexes it in Firestore under
  /// `users/{uid}/pdfs`, returning the persisted doc id. If this exact file
  /// (by name + size) was already indexed - in this session or a previous
  /// one - reuses that doc instead of uploading a duplicate copy. Pass
  /// [bytes] if already read (e.g. to open a chat) to avoid reading the
  /// file twice.
  Future<String> ensureUploaded(DevicePdf pdf, {Uint8List? bytes}) async {
    final cached = uploadedPdfId[pdf.id];
    if (cached != null) return cached;

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final pdfsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('pdfs');

    final existing = await pdfsRef
        .where('name', isEqualTo: pdf.name)
        .where('size', isEqualTo: pdf.size)
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) {
      final id = existing.docs.first.id;
      uploadedPdfId[pdf.id] = id;
      uploadStatus[pdf.id] = PdfUploadStatus.uploaded;
      notifyListeners();
      return id;
    }

    uploadStatus[pdf.id] = PdfUploadStatus.uploading;
    notifyListeners();

    try {
      final docRef = pdfsRef.doc();
      final storagePath = 'users/$uid/pdfs/${docRef.id}.pdf';
      await FirebaseStorage.instance
          .ref(storagePath)
          .putData(bytes ?? await readBytes(pdf));
      await docRef.set({
        'name': pdf.name,
        'size': pdf.size,
        'storagePath': storagePath,
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessageAt': null,
        'messageCount': 0,
        'lastMessagePreview': null,
      });
      uploadedPdfId[pdf.id] = docRef.id;
      uploadStatus[pdf.id] = PdfUploadStatus.uploaded;
      notifyListeners();
      return docRef.id;
    } catch (e) {
      uploadStatus[pdf.id] = PdfUploadStatus.failed;
      notifyListeners();
      rethrow;
    }
  }

  /// Fire-and-forget upload for the per-row cloud icon in LibraryTab; errors
  /// are reflected via [uploadStatus] rather than thrown, since no caller
  /// awaits a result here.
  Future<void> uploadPdf(DevicePdf pdf) async {
    try {
      await ensureUploaded(pdf);
    } catch (_) {
      // Status already set to failed inside ensureUploaded.
    }
  }
}
