import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final apiClientProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.open5e.com/v2/',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Accept': 'application/json',
      },
    ),
  );

  // Add logging interceptor for debugging and auditability
  dio.interceptors.add(LogInterceptor(
    requestHeader: false,
    responseHeader: false,
    requestBody: false,
    responseBody: false,
    error: true,
  ));

  return dio;
});
