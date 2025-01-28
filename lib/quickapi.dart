import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

class QuickApi {
  final String baseUrl;
  final Map<String, String>? defaultHeaders;
  final Duration timeoutDuration;
  final int retryCount;
  final Duration retryDelay;
  final Duration cacheDuration;
  final List<QuickApiInterceptor> interceptors;
  final void Function(String)? logger;

  final Map<String, _CachedResponse> _cache = {};

  QuickApi({
    required this.baseUrl,
    this.defaultHeaders,
    this.timeoutDuration = const Duration(seconds: 30),
    this.retryCount = 3,
    this.retryDelay = const Duration(seconds: 2),
    this.cacheDuration = const Duration(minutes: 5),
    this.interceptors = const [],
    this.logger,
  });

  // GET Request with interceptors
  Future<dynamic> typeGet(String endpoint, {Map<String, String>? headers, bool useCache = true}) async {
    return _executeWithInterceptors(
      endpoint: endpoint,
      method: 'GET',
      requestHandler: () => _getRequest(endpoint, headers, useCache),
    );
  }

  // POST Request with interceptors
  Future<dynamic> typePost(String endpoint, dynamic body, {Map<String, String>? headers}) async {
    return _executeWithInterceptors(
      endpoint: endpoint,
      method: 'POST',
      requestHandler: () => _postRequest(endpoint, body, headers),
    );
  }

  // PUT Request with interceptors
  Future<dynamic> typePut(String endpoint, dynamic body, {Map<String, String>? headers}) async {
    return _executeWithInterceptors(
      endpoint: endpoint,
      method: 'PUT',
      requestHandler: () => _putRequest(endpoint, body, headers),
    );
  }

  // DELETE Request with interceptors
  Future<dynamic> typeDelete(String endpoint, {Map<String, String>? headers}) async {
    return _executeWithInterceptors(
      endpoint: endpoint,
      method: 'DELETE',
      requestHandler: () => _deleteRequest(endpoint, headers),
    );
  }

  // Multipart POST request (File Upload)
  Future<dynamic> typePostMultipart(String endpoint, Map<String, String> fields, List<http.MultipartFile> files, {Map<String, String>? headers}) async {
    return _executeWithInterceptors(
      endpoint: endpoint,
      method: 'POST',
      requestHandler: () => _postMultipartRequest(endpoint, fields, files, headers),
    );
  }

  // Core method for GET request
  Future<dynamic> _getRequest(String endpoint, Map<String, String>? headers, bool useCache) async {
    final cacheKey = _getCacheKey(endpoint, headers);

    // Check cache
    if (useCache && _cache.containsKey(cacheKey)) {
      final cachedResponse = _cache[cacheKey]!;
      if (DateTime.now().isBefore(cachedResponse.expiry)) {
        logger?.call('Cache Hit: $endpoint');
        return cachedResponse.data;
      } else {
        logger?.call('Cache Expired: $endpoint');
        _cache.remove(cacheKey);
      }
    }

    // Network request
    final url = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await http.get(url, headers: {...?defaultHeaders, ...?headers}).timeout(timeoutDuration);

      // Cache response if successful
      if (response.statusCode >= 200 && response.statusCode < 300) {
        _cache[cacheKey] = _CachedResponse(
          data: jsonDecode(response.body),
          expiry: DateTime.now().add(cacheDuration),
        );
        logger?.call('Cache Updated: $endpoint');
      }

      return _processResponse(response);
    } on TimeoutException {
      throw TimeoutError(endpoint);
    } on http.ClientException {
      throw NetworkError(endpoint);
    }
  }

  // Core method for POST request
  Future<dynamic> _postRequest(String endpoint, dynamic body, Map<String, String>? headers) async {
    final url = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await http.post(
        url,
        headers: {...?defaultHeaders, ...?headers, 'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(timeoutDuration);

      return _processResponse(response);
    } on TimeoutException {
      throw TimeoutError(endpoint);
    } on http.ClientException {
      throw NetworkError(endpoint);
    }
  }

  // Core method for PUT request
  Future<dynamic> _putRequest(String endpoint, dynamic body, Map<String, String>? headers) async {
    final url = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await http.put(
        url,
        headers: {...?defaultHeaders, ...?headers, 'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(timeoutDuration);

      return _processResponse(response);
    } on TimeoutException {
      throw TimeoutError(endpoint);
    } on http.ClientException {
      throw NetworkError(endpoint);
    }
  }

  // Core method for DELETE request
  Future<dynamic> _deleteRequest(String endpoint, Map<String, String>? headers) async {
    final url = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await http.delete(
        url,
        headers: {...?defaultHeaders, ...?headers},
      ).timeout(timeoutDuration);

      return _processResponse(response);
    } on TimeoutException {
      throw TimeoutError(endpoint);
    } on http.ClientException {
      throw NetworkError(endpoint);
    }
  }

  // Core method for multipart POST request
  Future<dynamic> _postMultipartRequest(String endpoint, Map<String, String> fields, List<http.MultipartFile> files, Map<String, String>? headers) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final request = http.MultipartRequest('POST', uri)
      ..headers.addAll({...?defaultHeaders, ...?headers})
      ..fields.addAll(fields)
      ..files.addAll(files);

    try {
      final response = await request.send().timeout(timeoutDuration);

      final responseStream = await http.Response.fromStream(response);
      return _processResponse(responseStream);
    } on TimeoutException {
      throw TimeoutError(endpoint);
    } on http.ClientException {
      throw NetworkError(endpoint);
    }
  }

  // Interceptor wrapper
  Future<dynamic> _executeWithInterceptors({
    required String endpoint,
    required String method,
    required Future<dynamic> Function() requestHandler,
  }) async {
    RequestContext context = RequestContext(endpoint: endpoint, method: method);
    for (final interceptor in interceptors) {
      await interceptor.onRequest(context);
    }

    try {
      final response = await requestHandler();

      ResponseContext responseContext = ResponseContext(
        endpoint: endpoint,
        method: method,
        data: response,
      );

      for (final interceptor in interceptors) {
        await interceptor.onResponse(responseContext);
      }

      return response;
    } catch (error) {
      if (error is QuickApiError) {
        logger?.call('QuickApiError: $error');
      } else {
        logger?.call('Unhandled Error: $error');
      }
      rethrow;
    }
  }

  // Process HTTP response
  dynamic _processResponse(http.Response response) {
    final statusCode = response.statusCode;

    if (statusCode >= 200 && statusCode < 300) {
      try {
        return jsonDecode(response.body);
      } catch (_) {
        return response.body; // Handle non-JSON responses
      }
    } else if (statusCode >= 500) {
      throw ServerError(response.statusCode, response.body);
    } else if (statusCode >= 400) {
      throw ClientError(response.statusCode, response.body);
    } else {
      throw UnknownError(response.statusCode, response.body);
    }
  }

  // Generate cache key
  String _getCacheKey(String endpoint, Map<String, String>? headers) {
    final headerString = headers?.entries.map((e) => '${e.key}:${e.value}').join('&') ?? '';
    return '$endpoint?$headerString';
  }
}

// Abstract class for API errors
abstract class QuickApiError implements Exception {
  final String message;
  QuickApiError(this.message);

  @override
  String toString() => message;
}

// Specific error classes
class TimeoutError extends QuickApiError {
  TimeoutError(String endpoint) : super('Timeout occurred for endpoint: $endpoint');
}

class NetworkError extends QuickApiError {
  NetworkError(String endpoint) : super('Network error occurred for endpoint: $endpoint');
}

class ServerError extends QuickApiError {
  final int statusCode;
  ServerError(this.statusCode, String body) : super('Server error $statusCode: $body');
}

class ClientError extends QuickApiError {
  final int statusCode;
  ClientError(this.statusCode, String body) : super('Client error $statusCode: $body');
}

class UnknownError extends QuickApiError {
  final int statusCode;
  UnknownError(this.statusCode, String body) : super('Unknown error $statusCode: $body');
}

// Context for request/response passed to interceptors
class RequestContext {
  final String endpoint;
  final String method;
  Map<String, dynamic> data = {};

  RequestContext({
    required this.endpoint,
    required this.method,
  });
}

class ResponseContext {
  final String endpoint;
  final String method;
  dynamic data;

  ResponseContext({
    required this.endpoint,
    required this.method,
    this.data,
  });
}

// Interceptor interface
abstract class QuickApiInterceptor {
  Future<void> onRequest(RequestContext context);
  Future<void> onResponse(ResponseContext context);
}

// Private class for cache
class _CachedResponse {
  final dynamic data;
  final DateTime expiry;

  _CachedResponse({
    required this.data,
    required this.expiry,
  });
}
