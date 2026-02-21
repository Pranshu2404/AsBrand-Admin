class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;

  ApiResponse({required this.success, required this.message, this.data});

  factory ApiResponse.fromJson(
      Map<String, dynamic> json,
      T Function(Object? json)? fromJsonT,
      ) =>
      ApiResponse(
        success: json['success'] == true,
        message: json['message'] is String
            ? json['message'] as String
            : json['message']?.toString() ?? '',
        data: (json['data'] != null && fromJsonT != null) ? fromJsonT(json['data']) : null,
      );
}
