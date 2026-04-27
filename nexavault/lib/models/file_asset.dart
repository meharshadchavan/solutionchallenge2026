enum EisenhowerQuadrant {
  urgentImportant,    // Do First
  notUrgentImportant, // Schedule
  urgentNotImportant, // Delegate
  notUrgentNotImportant // Eliminate
}

class FileAsset {
  final String id;
  final String name;
  final String? snippet;     // First 500 words or summary
  final String? category;    // The 'Mission Bucket' Category
  final int? confidence;     // AI Confidence Score (1-100)
  final bool isProcessing;   // True if the Agent reasoning is in progress
  final DateTime uploadedAt;
  
  // Eisenhower Matrix data
  final EisenhowerQuadrant? quadrant;
  final String? taskAction; // The Agent's recommendation (e.g., "Review by Monday")

  FileAsset({
    required this.id,
    required this.name,
    this.snippet,
    this.category,
    this.confidence,
    this.isProcessing = false,
    this.quadrant,
    this.taskAction,
    DateTime? uploadedAt,
  }) : uploadedAt = uploadedAt ?? DateTime.now();

  FileAsset copyWith({
    String? id,
    String? name,
    String? snippet,
    String? category,
    int? confidence,
    bool? isProcessing,
    EisenhowerQuadrant? quadrant,
    String? taskAction,
    DateTime? uploadedAt,
  }) {
    return FileAsset(
      id: id ?? this.id,
      name: name ?? this.name,
      snippet: snippet ?? this.snippet,
      category: category ?? this.category,
      confidence: confidence ?? this.confidence,
      isProcessing: isProcessing ?? this.isProcessing,
      quadrant: quadrant ?? this.quadrant,
      taskAction: taskAction ?? this.taskAction,
      uploadedAt: uploadedAt ?? this.uploadedAt,
    );
  }
  
  String get quadrantLabel {
    if (quadrant == null) return "Pending Analysis";
    switch (quadrant!) {
      case EisenhowerQuadrant.urgentImportant:
        return "Do First";
      case EisenhowerQuadrant.notUrgentImportant:
        return "Schedule";
      case EisenhowerQuadrant.urgentNotImportant:
        return "Delegate";
      case EisenhowerQuadrant.notUrgentNotImportant:
        return "Eliminate";
    }
  }
}
