import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexavault/models/file_asset.dart';
import 'package:nexavault/providers/agentic_provider.dart';

/// FileRepositoryNotifier
///
/// The global state manager that drives the "Detect-Reason-Act" loop.
/// Uses the Notifier pattern (Riverpod 3.0+).
class FileRepositoryNotifier extends Notifier<List<FileAsset>> {
  @override
  List<FileAsset> build() {
    return [];
  }

  /// Registers a new file, triggers AI reasoning, and updates the bucket state.
  Future<void> addNewFile(String fileName, Uint8List? fileBytes) async {
    // ─── DETECT ──────────────────────────────────────────────────────────────
    final newFileId = DateTime.now().millisecondsSinceEpoch.toString();
    final newFile = FileAsset(
      id: newFileId,
      name: fileName,
      isProcessing: true,
    );
    state = [...state, newFile];

    // ─── EXTRACT TEXT ─────────────────────────────────────────────────────────
    String textSnippet;
    if (fileBytes != null && fileName.toLowerCase().endsWith('.pdf')) {
      final pdfParser = ref.read(pdfParserProvider);
      final extracted = pdfParser.extractTextFromBytes(fileBytes);
      textSnippet = extracted ??
          'Could not extract text from PDF. File name for context: $fileName';
    } else {
      textSnippet =
          'Non-PDF file. Using file name for classification: $fileName';
    }

    state = state.map((f) {
      return f.id == newFileId ? f.copyWith(snippet: textSnippet) : f;
    }).toList();

    // ─── REASON ──────────────────────────────────────────────────────────────
    final agentService = ref.read(agenticServiceProvider);
    final result =
        await agentService.analyzeAndAllocate(fileName, textSnippet);

    // ─── ACT ─────────────────────────────────────────────────────────────────
    state = state.map((file) {
      if (file.id != newFileId) return file;
      return file.copyWith(
        isProcessing: false,
        category: result['category'] as String?,
        confidence: result['confidence'] as int?,
        quadrant: result['quadrant'] as EisenhowerQuadrant?,
        taskAction: result['action'] as String?,
      );
    }).toList();
  }
}

/// Global provider for the file repository state.
final fileRepositoryProvider =
    NotifierProvider<FileRepositoryNotifier, List<FileAsset>>(
  FileRepositoryNotifier.new,
);
