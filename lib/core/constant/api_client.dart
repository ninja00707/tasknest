import 'package:dio/dio.dart';
import 'package:tasknest/core/constant/api_constant.dart';
import 'package:flutter/foundation.dart';
import 'package:tasknest/core/routes/routes_name.dart';
import 'package:tasknest/data/datasource/localstorage/sharedpreferences.dart';
import 'package:tasknest/core/routes/app_router.dart';

class ApiClient {
  late Dio dio;

  // Singleton instance
  static final ApiClient _instance = ApiClient._internal();

  // To prevent multiple redirects if many requests fail at once
  bool _isRedirecting = false;

  factory ApiClient() {
    return _instance;
  }

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // Add request interceptor to attach token
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await LocalStorageService().getToken();

          if (kDebugMode) {
            debugPrint('ApiClient Interceptor: Request to ${options.path}');
            debugPrint('ApiClient Interceptor: Retrieved token: $token');
          }

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          if (kDebugMode)
            debugPrint(
              'ApiClient Interceptor: Request headers: ${options.headers}',
            );
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          final path = error.requestOptions.path;
          final isAuthRoute =
              path.contains(ApiConstants.login) ||
              path.contains(ApiConstants.register);

          // Only handle 401 as "Session Expired" if NOT on an auth route
          if (error.response?.statusCode == 401 && !isAuthRoute) {
            if (_isRedirecting) return handler.next(error);
            _isRedirecting = true;
            if (kDebugMode) {
              debugPrint(
                'ApiClient Interceptor: 401 Unauthorized for ${error.requestOptions.path}',
              );
              debugPrint('Response body: ${error.response?.data}');
            }

            await LocalStorageService().clearToken();

            // Use the global appRouter directly to avoid context errors
            appRouter.go(RouteNames.login);
            _isRedirecting = false;

            return handler.reject(
              DioException(
                requestOptions: error.requestOptions,
                error: 'Session expired. Please login again.',
              ),
            );
          }

          if (kDebugMode) {
            debugPrint('ApiClient Interceptor: Error: ${error.message}');
            debugPrint(
              'ApiClient Interceptor: Response body: ${error.response?.data}',
            );
          }
          return handler.next(error);
        },
      ),
    );
  }

  /// GET
  Future<dynamic> get(String path, {Map<String, dynamic>? queryParams}) async {
    try {
      final response = await dio.get(path, queryParameters: queryParams);
      return response.data;
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// POST
  Future<dynamic> post(
    String path, {
    dynamic body,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final response = await dio.post(
        path,
        data: body,
        queryParameters: queryParams,
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// PATCH
  Future<dynamic> patch(
    String path, {
    dynamic body,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final response = await dio.patch(
        path,
        data: body,
        queryParameters: queryParams,
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// DELETE
  Future<dynamic> delete(
    String path, {
    dynamic body,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final response = await dio.delete(
        path,
        data: body,
        queryParameters: queryParams,
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// Safely extracts error messages from DioException
  String _handleError(DioException e) {
    // Prioritize custom error message from interceptor (e.g., "Session expired")
    if (e.error is String) {
      return e.error.toString();
    }
    // Check if the server returned a JSON error object
    if (e.response?.data is Map) {
      final data = e.response!.data as Map;
      // Common backend error structures
      return data['message']?.toString() ??
          data['error']?.toString() ??
          data['msg']?.toString() ??
          'An error occurred';
    }
    // Fallback to default Dio message
    return e.message ?? 'An unexpected error occurred';
  }
}
