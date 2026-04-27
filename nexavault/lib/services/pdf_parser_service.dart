import 'dart:typed_data';
import 'package:syncfusion_flutter_pdf/pdf.dart';

/// PdfParserService
///
/// Handles Stage 1 of the "Detect" phase: Given a file's raw bytes,
/// uses the Syncfusion PDF SDK to extract actual text content.
/// The first 500 words are then passed to the Gemini reasoning engine.
class PdfParserService {
  /// Extracts the first [wordLimit] words from a PDF file's binary content.
  ///
  /// Returns null if the file is not a valid PDF, is encrypted/corrupted,
  /// or if text extraction yields nothing (e.g., a scanned image PDF).
  String? extractTextFromBytes(Uint8List pdfBytes, {int wordLimit = 500}) {
    try {
      // Load the PDF document from raw bytes (no disk I/O needed)
      final PdfDocument document = PdfDocument(inputBytes: pdfBytes);
      final PdfTextExtractor extractor = PdfTextExtractor(document);

      final StringBuffer buffer = StringBuffer();

      // We iterate through pages until we have enough words or reach the end
      for (int i = 0; i < document.pages.count; i++) {
        final String pageText = extractor.extractText(startPageIndex: i);
        buffer.write('$pageText ');

        // Break early if we already have enough words to reason with
        final wordCount = buffer.toString().trim().split(RegExp(r'\s+')).length;
        if (wordCount >= wordLimit) break;
      }

      document.dispose(); // Always dispose to free memory

      final allWords = buffer.toString().trim().split(RegExp(r'\s+'));
      if (allWords.isEmpty || (allWords.length == 1 && allWords.first.isEmpty)) {
        return null; // No readable text found (likely a scanned image PDF)
      }

      // Return only up to the word limit joined back as a string
      return allWords.take(wordLimit).join(' ');
    } catch (e) {
      // Returns null on any parse error — the caller will use a fallback snippet
      print('[PdfParserService] Failed to extract text: $e');
      return null;
    }
  }
}
