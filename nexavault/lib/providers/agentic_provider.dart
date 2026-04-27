import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexavault/services/agentic_allocator_service.dart';
import 'package:nexavault/services/pdf_parser_service.dart';

/// Provider for the AI Allocation Service.
/// The service reads its own configuration from the .env file at construction.
final agenticServiceProvider = Provider<AgenticAllocatorService>((ref) {
  return AgenticAllocatorService();
});

/// Provider for the PDF text extraction service.
final pdfParserProvider = Provider<PdfParserService>((ref) {
  return PdfParserService();
});
