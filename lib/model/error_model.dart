class ErrorCode {
  final String code;
  final String description;
  final String action;
  final String category; // New field

  ErrorCode({
    required this.code,
    required this.description,
    required this.action,
    required this.category,
  });

  factory ErrorCode.fromJson(Map<String, dynamic> json) {
    return ErrorCode(
      // Handles 'code', 'Code', or 'CODE'
      code: json['code']?.toString() ?? json['Code']?.toString() ?? '',

      // Handles various description keys
      description:
          json['description']?.toString() ??
          json['Description']?.toString() ??
          json['Failure Description']?.toString() ??
          'No description available',

      // Handles various action keys
      action:
          json['action']?.toString() ??
          json['Action']?.toString() ??
          json['Action on Failure']?.toString() ??
          'No action provided',

      // NEW: Handles category mapping
      category:
          json['category']?.toString() ??
          json['Category']?.toString() ??
          'Uncategorized',
    );
  }
}
