import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:nexavault/models/file_asset.dart';
import 'package:nexavault/services/mock_agentic_service.dart';
import 'package:nexavault/utils/constants.dart';

/// AgenticAllocatorService
///
/// The central reasoning brain of the "Detect-Reason-Act" loop.
/// This service:
///   1. Reads environment variables at construction time.
///   2. Decides whether to use the REAL Gemini 1.5 Flash API or the
///      MockAgenticAllocatorService, based on .env configuration.
///   3. Exposes a single unified method: [analyzeAndAllocate].
class AgenticAllocatorService {
  final bool _useMock;
  final MockAgenticAllocatorService _mockService;
  GenerativeModel? _realModel;

  AgenticAllocatorService()
      : _mockService = MockAgenticAllocatorService(),
        _useMock = _shouldUseMock() {
    if (!_useMock) {
      // Only instantiate the real Gemini model if we have a valid key
      final apiKey = dotenv.env['GEMINI_API_KEY']!;
      _realModel = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
        ),
      );
    }

    print(
        '[AgenticAllocatorService] Initialized. Mode: ${_useMock ? "MOCK" : "REAL (Gemini 1.5 Flash)"}');
  }

  /// Determines whether the mock service should be used based on the .env file.
  static bool _shouldUseMock() {
    final useMockFlag = dotenv.env['USE_MOCK_AGENT']?.toLowerCase();
    final apiKey = dotenv.env['GEMINI_API_KEY'];

    // Use mock if flag is explicitly set, or API key is missing/dummy
    final bool flagSaysMock = useMockFlag == 'true';
    final bool keyIsMissing =
        apiKey == null || apiKey.isEmpty || apiKey == 'dummy_api_key';

    return flagSaysMock || keyIsMissing;
  }

  /// MAIN ENTRY POINT: Analyzes a file and autonomously allocates it to a Mission Bucket and Eisenhower Quadrant.
  Future<Map<String, dynamic>> analyzeAndAllocate(
      String fileName, String fileSnippet) async {
    if (_useMock) {
      return _mockService.analyzeAndAllocate(fileName, fileSnippet);
    }
    return _realGeminiReason(fileName, fileSnippet);
  }

  /// AGENTIC RAG SEARCH: Performs a semantic lookup.
  Future<String> searchAndQuery(String query, List<FileAsset> currentAssets) async {
    if (_useMock) {
      return _mockService.searchAndQuery(query, currentAssets);
    }
    // RAG Implementation would go here (using embeddings or context-injection)
    return _mockService.searchAndQuery(query, currentAssets); 
  }

  /// Calls the real Gemini 1.5 Flash API with a structured prompt.
  Future<Map<String, dynamic>> _realGeminiReason(
      String fileName, String fileSnippet) async {
    final prompt = '''
You are an intelligent file router and task prioritizer for NexaVault.
Analyze the following file name and content snippet.

1. Determine the single most appropriate Mission Category:
[Surplus Assets, Critical Needs, Logistics & Routing, Miscellaneous]

2. Categorize it into an Eisenhower Matrix Quadrant (0 to 3):
- 0: Urgent & Important (Do First)
- 1: Not Urgent & Important (Schedule)
- 2: Urgent & Not Important (Delegate)
- 3: Not Urgent & Not Important (Eliminate)

3. Provide a short "task_action" recommendation (max 10 words).

Return a valid JSON object with exactly these keys:
  - "category": string
  - "confidence": integer (1-100)
  - "quadrant_index": integer (0, 1, 2, or 3)
  - "task_action": string

File Name: $fileName
Content Snippet: $fileSnippet
''';

    try {
      final response =
          await _realModel!.generateContent([Content.text(prompt)]);

      if (response.text != null) {
        final data = jsonDecode(response.text!) as Map<String, dynamic>;
        final String cat = data['category'] ?? 'Miscellaneous';
        final int conf = (data['confidence'] as num?)?.toInt() ?? 0;
        final int quadIndex = (data['quadrant_index'] as num?)?.toInt() ?? 3;
        final String action = data['task_action'] ?? 'Review asset.';

        final quad = EisenhowerQuadrant.values[quadIndex.clamp(0, 3)];

        // Validate category and confidence threshold
        if (conf < 40 || !AppConstants.missionBucketCategories.contains(cat)) {
          return {
            'category': 'Agent Requires Review', 
            'confidence': conf,
            'quadrant': EisenhowerQuadrant.notUrgentNotImportant,
            'action': 'Awaiting human review'
          };
        }
        return {
          'category': cat, 
          'confidence': conf,
          'quadrant': quad,
          'action': action
        };
      }
      throw Exception('Gemini returned null response text.');
    } catch (e) {
      print('[AgenticAllocatorService] Gemini API error: $e');
      return {
        'category': 'Agent Requires Review', 
        'confidence': 0,
        'quadrant': EisenhowerQuadrant.notUrgentNotImportant,
        'action': 'Error in reasoning.'
      };
    }
  }
}
