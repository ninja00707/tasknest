import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'package:tasknest/core/constant/api_constant.dart';
import 'package:tasknest/core/routes/routes_name.dart';
import 'package:tasknest/data/datasource/localstorage/sharedpreferences.dart';
import 'package:flutter/material.dart';

class ApiClient {
  late Dio dio;
  static BuildContext? _context;

  static void setContext(BuildContext context) {
    _context = context;
  }

  ApiClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    // Add request interceptor to attach token
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await LocalStorageService().getToken();

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          return handler.next(options);
        },
        onError: (error, handler) async {
          // Handle 401 Unauthorized responses
          if (error.response?.statusCode == 401) {
            // Clear token and redirect to login
            await LocalStorageService().clearToken();
            
            if (_context != null && _context!.mounted) {
              _context!.go(RouteNames.login);
            }
            
            return handler.reject(error);
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
      
      if (response.statusCode == 401) {
        await LocalStorageService().clearToken();
        if (_context != null && _context!.mounted) {
          _context!.go(RouteNames.login);
        }
        throw Exception('Session expired. Please login again.');
      }
      
      if (response.statusCode != null && response.statusCode! >= 400) {
        final message = response.data is Map ? response.data['message'] : null;
        throw Exception(message ?? 'Error: ${response.statusCode}');
      }

      return response.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      }
      throw Exception(e.response?.data['message'] ?? e.message ?? 'An error occurred');
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

      if (response.statusCode == 401) {
        await LocalStorageService().clearToken();
        if (_context != null && _context!.mounted) {
          _context!.go(RouteNames.login);
        }
        throw Exception('Session expired. Please login again.');
      }
      
      if (response.statusCode != null && response.statusCode! >= 400) {
        final message = response.data is Map ? response.data['message'] : null;
        throw Exception(message ?? 'Error: ${response.statusCode}');
      }

      return response.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      }
      throw Exception(e.response?.data['message'] ?? e.message ?? 'An error occurred');
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

      if (response.statusCode == 401) {
        await LocalStorageService().clearToken();
        if (_context != null && _context!.mounted) {
          _context!.go(RouteNames.login);
        }
        throw Exception('Session expired. Please login again.');
      }
      
      if (response.statusCode != null && response.statusCode! >= 400) {
        final message = response.data is Map ? response.data['message'] : null;
        throw Exception(message ?? 'Error: ${response.statusCode}');
      }

      return response.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      }
      throw Exception(e.response?.data['message'] ?? e.message ?? 'An error occurred');
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

      if (response.statusCode == 401) {
        await LocalStorageService().clearToken();
        if (_context != null && _context!.mounted) {
          _context!.go(RouteNames.login);
        }
        throw Exception('Session expired. Please login again.');
      }
      
      if (response.statusCode != null && response.statusCode! >= 400) {
        final message = response.data is Map ? response.data['message'] : null;
        throw Exception(message ?? 'Error: ${response.statusCode}');
      }

      return response.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      }
      throw Exception(e.response?.data['message'] ?? e.message ?? 'An error occurred');
    }
  }
}
