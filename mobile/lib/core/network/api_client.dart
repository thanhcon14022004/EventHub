import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../storage/token_storage.dart';

class ApiClient {
  late final Dio dio;

  ApiClient({String? baseUrl}) {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 3),
        receiveTimeout: const Duration(seconds: 3),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await TokenStorage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) {
          // Log or handle global unauthorized error
          if (error.response?.statusCode == 401) {
            // Optional: TokenStorage.clear();
          }
          return handler.next(error);
        },
      ),
    );
  }

  /// Helper to extract clean error message
  static String formatError(dynamic error) {
    if (error is DioException) {
      if (error.response?.data != null) {
        final data = error.response!.data;
        if (data is Map && data.containsKey('message')) {
          return data['message'].toString();
        } else if (data is String) {
          return data;
        }
      }
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng.';
        case DioExceptionType.connectionError:
          return 'Không thể kết nối đến máy chủ backend tại ${ApiConstants.baseUrl}.';
        case DioExceptionType.badResponse:
          final code = error.response?.statusCode;
          return 'Lỗi máy chủ ($code): ${error.response?.statusMessage ?? "Đã xảy ra lỗi"}';
        default:
          return 'Đã xảy ra lỗi không xác định.';
      }
    }
    return error.toString();
  }
}
