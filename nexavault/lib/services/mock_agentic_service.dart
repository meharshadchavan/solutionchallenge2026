import 'dart:math';
import 'package:nexavault/models/file_asset.dart';

/// MockAgenticAllocatorService
///
/// A fully self-contained mock that simulates the Gemini AI reasoning engine.
/// This service is activated when:
///   - USE_MOCK_AGENT=true in .env, OR
///   - GEMINI_API_KEY is missing/set to "dummy_api_key"
///
/// It uses heuristic keyword matching + simulated network latency to convincingly
/// mimic the real Gemini response, allowing full UI testing without any credentials.
class MockAgenticAllocatorService {
  final _random = Random();

  // Keyword signatures for each bucket category.
  // The mock "reasons" by scanning the fileName + snippet for these signals.
  static const Map<String, List<String>> _categoryKeywords = {
    'Surplus Assets': [
      'food', 'water', 'donation', 'surplus', 'inventory', 'warehouse', 'idle', 'supplies', 'leftovers', 'overstock', 'donor',
    ],
    'Critical Needs': [
      'shelter', 'hospital', 'crisis', 'urgent', 'demand', 'need', 'required', 'casualty', 'disaster', 'relief', 'shortage',
    ],
    'Logistics & Routing': [
      'transport', 'van', 'truck', 'fleet', 'route', 'delivery', 'driver', 'shipping', 'manifest', 'dispatch',
    ],
    'Miscellaneous': [
      // Default — anything that doesn't strongly hit the above
    ],
  };

  /// Simulates the analyzeAndAllocate call with realistic delay (800ms–2.2s).
  ///
  /// Returns a Map with 'category' and 'confidence' identical to the real service contract.
  Future<Map<String, dynamic>> analyzeAndAllocate(
      String fileName, String fileSnippet) async {
    // Simulate variable network latency of the Gemini API
    final delayMs = 800 + _random.nextInt(1400); // 800ms to 2200ms
    await Future.delayed(Duration(milliseconds: delayMs));

    final combined = '${fileName.toLowerCase()} ${fileSnippet.toLowerCase()}';

    // Score each category by counting keyword hits
    final scores = <String, int>{};
    for (final entry in _categoryKeywords.entries) {
      final category = entry.key;
      final keywords = entry.value;
      scores[category] = keywords.where((kw) => combined.contains(kw)).length;
    }

    // Find the best-matching category
    final bestCategory = scores.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;

    final bestScore = scores[bestCategory] ?? 0;

    // Calculate a realistic confidence score
    int confidence;
    if (bestScore == 0) {
      // No keywords matched → low confidence → "Agent Requires Review"
      confidence = 15 + _random.nextInt(20); // 15–35%
    } else if (bestScore == 1) {
      confidence = 45 + _random.nextInt(20); // 45–65%
    } else if (bestScore == 2) {
      confidence = 68 + _random.nextInt(15); // 68–83%
    } else {
      confidence = 84 + _random.nextInt(16); // 84–99%
    }

    // Determine Eisenhower Quadrant
    EisenhowerQuadrant quadrant;
    if (combined.contains('exam') || combined.contains('deadline') || combined.contains('urgent') || combined.contains('identity')) {
      quadrant = EisenhowerQuadrant.urgentImportant;
    } else if (combined.contains('project') || combined.contains('research') || combined.contains('study')) {
      quadrant = EisenhowerQuadrant.notUrgentImportant;
    } else if (combined.contains('notice') || combined.contains('invoice')) {
      quadrant = EisenhowerQuadrant.urgentNotImportant;
    } else {
      quadrant = EisenhowerQuadrant.notUrgentNotImportant;
    }

    // Apply the same confidence threshold as the real service
    if (confidence < 40) {
      return {
        'category': 'Agent Requires Review', 
        'confidence': confidence,
        'quadrant': EisenhowerQuadrant.notUrgentNotImportant,
        'action': 'Awaiting human review'
      };
    }

    return {
      'category': bestCategory, 
      'confidence': confidence,
      'quadrant': quadrant,
      'action': 'Priority: ${quadrant.name}'
    };
  }

  /// MOCK RAG SEARCH: Performs a semantic lookup against currently indexed snippets.
  Future<String> searchAndQuery(String query, List<FileAsset> currentAssets) async {
    await Future.delayed(const Duration(milliseconds: 1500));
    
    // Simple heuristic: find assets that match query keywords
    final queryWords = query.toLowerCase().split(' ');
    final matches = currentAssets.where((asset) {
      final text = '${asset.name} ${asset.snippet}'.toLowerCase();
      return queryWords.any((word) => word.length > 3 && text.contains(word));
    }).toList();

    if (matches.isEmpty) {
      return "Agent Insight: I couldn't find specific details regarding '$query' in your Vault. Try uploading more context!";
    }

    final topMatch = matches.first;
    return "Based on your asset '${topMatch.name}', here is the Agent's analysis: The document refers to ${topMatch.category ?? 'general topics'} and is categorized as ${topMatch.quadrantLabel}. Recommendation: Address this during your next deep-work session.";
  }
}
