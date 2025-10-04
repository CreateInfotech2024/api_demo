class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;
  final String? message;
  final DateTime timestamp;

  ApiResponse({
    required this.success,
    this.data,
    this.error,
    this.message,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory ApiResponse.success(T data, {String? message}) {
    return ApiResponse<T>(
      success: true,
      data: data,
      message: message,
    );
  }

  factory ApiResponse.error(String error, {String? message}) {
    return ApiResponse<T>(
      success: false,
      error: error,
      message: message,
    );
  }

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJson,
  ) {
    try {
      if (json.containsKey('error')) {
        return ApiResponse.error(
          json['error'] as String,
          message: json['message'] as String?,
        );
      }

      final data = json['data'] != null ? fromJson(json['data']) : null;
      return ApiResponse.success(
        data as T,
        message: json['message'] as String?,
      );
    } catch (e) {
      return ApiResponse.error(
        'Failed to parse response: $e',
      );
    }
  }

  Map<String, dynamic> toJson(Object? Function(T) toJson) {
    return {
      'success': success,
      'data': data != null ? toJson(data as T) : null,
      'error': error,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'ApiResponse{success: $success, data: $data, error: $error, message: $message}';
  }
}