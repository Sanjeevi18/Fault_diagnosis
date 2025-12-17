class ErrorCode {
  final String code;
  final String description;
  final String action;

  ErrorCode({
    required this.code,
    required this.description,
    required this.action,
  });

  factory ErrorCode.fromJson(Map<String, dynamic> json) {
    return ErrorCode(
      // Check for 'code', 'Code', or 'CODE'
      code: json['code']?.toString() ?? json['Code']?.toString() ?? '',

      // Check for 'description', 'Description', or 'Failure Description'
      description:
          json['description']?.toString() ??
          json['Description']?.toString() ??
          json['Failure Description']?.toString() ??
          'No description available',

      // Check for 'action', 'Action', or 'Action on Failure'
      action:
          json['action']?.toString() ??
          json['Action']?.toString() ??
          json['Action on Failure']?.toString() ??
          'No action provided',
    );
  }
}
