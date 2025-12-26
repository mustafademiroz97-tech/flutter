import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// API Service for backend integration and camera video feed
/// Provides HTTP client configuration for:
/// - Backend API: 192.168.1.10:5000
/// - Camera Video Feed: 192.168.1.169
class ApiService {
  // Private constructor
  ApiService._();

  // Singleton instance
  static final ApiService _instance = ApiService._();

  // Factory constructor
  factory ApiService() {
    return _instance;
  }

  // HTTP Client
  static final http.Client _httpClient = http.Client();

  // Environment Configuration
  late String _backendBaseUrl;
  late String _cameraVideoFeedUrl;
  late Duration _requestTimeout;

  /// Initialize API Service with environment configuration
  /// Call this method in main.dart before using the service
  Future<void> initialize() async {
    try {
      // Load environment variables from .env file
      await dotenv.load();

      // Get configuration from environment or use defaults
      _backendBaseUrl = dotenv.env['BACKEND_API_URL'] ?? 'http://192.168.1.10:5000';
      _cameraVideoFeedUrl = dotenv.env['CAMERA_VIDEO_FEED_URL'] ?? 'http://192.168.1.169';
      _requestTimeout = Duration(
        seconds: int.parse(dotenv.env['REQUEST_TIMEOUT'] ?? '30'),
      );

      print('ApiService initialized');
      print('Backend API URL: $_backendBaseUrl');
      print('Camera Video Feed URL: $_cameraVideoFeedUrl');
    } catch (e) {
      print('Error initializing ApiService: $e');
      // Use default values if environment loading fails
      _backendBaseUrl = 'http://192.168.1.10:5000';
      _cameraVideoFeedUrl = 'http://192.168.1.169';
      _requestTimeout = const Duration(seconds: 30);
    }
  }

  /// Get Backend API Base URL
  String get backendBaseUrl => _backendBaseUrl;

  /// Get Camera Video Feed URL
  String get cameraVideoFeedUrl => _cameraVideoFeedUrl;

  /// Get Request Timeout
  Duration get requestTimeout => _requestTimeout;

  // ============= BACKEND API METHODS =============

  /// GET request to backend API
  /// [endpoint] - API endpoint (e.g., '/users', '/devices')
  /// [headers] - Optional custom headers
  Future<http.Response> get(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    try {
      final url = Uri.parse('$_backendBaseUrl$endpoint');
      final response = await _httpClient
          .get(
            url,
            headers: _getDefaultHeaders(headers),
          )
          .timeout(_requestTimeout);

      _handleResponse(response);
      return response;
    } catch (e) {
      print('GET Error: $e');
      rethrow;
    }
  }

  /// POST request to backend API
  /// [endpoint] - API endpoint
  /// [body] - Request body (will be JSON encoded)
  /// [headers] - Optional custom headers
  Future<http.Response> post(
    String endpoint, {
    dynamic body,
    Map<String, String>? headers,
  }) async {
    try {
      final url = Uri.parse('$_backendBaseUrl$endpoint');
      final response = await _httpClient
          .post(
            url,
            headers: _getDefaultHeaders(headers),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(_requestTimeout);

      _handleResponse(response);
      return response;
    } catch (e) {
      print('POST Error: $e');
      rethrow;
    }
  }

  /// PUT request to backend API
  /// [endpoint] - API endpoint
  /// [body] - Request body (will be JSON encoded)
  /// [headers] - Optional custom headers
  Future<http.Response> put(
    String endpoint, {
    dynamic body,
    Map<String, String>? headers,
  }) async {
    try {
      final url = Uri.parse('$_backendBaseUrl$endpoint');
      final response = await _httpClient
          .put(
            url,
            headers: _getDefaultHeaders(headers),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(_requestTimeout);

      _handleResponse(response);
      return response;
    } catch (e) {
      print('PUT Error: $e');
      rethrow;
    }
  }

  /// PATCH request to backend API
  /// [endpoint] - API endpoint
  /// [body] - Request body (will be JSON encoded)
  /// [headers] - Optional custom headers
  Future<http.Response> patch(
    String endpoint, {
    dynamic body,
    Map<String, String>? headers,
  }) async {
    try {
      final url = Uri.parse('$_backendBaseUrl$endpoint');
      final response = await _httpClient
          .patch(
            url,
            headers: _getDefaultHeaders(headers),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(_requestTimeout);

      _handleResponse(response);
      return response;
    } catch (e) {
      print('PATCH Error: $e');
      rethrow;
    }
  }

  /// DELETE request to backend API
  /// [endpoint] - API endpoint
  /// [headers] - Optional custom headers
  Future<http.Response> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    try {
      final url = Uri.parse('$_backendBaseUrl$endpoint');
      final response = await _httpClient
          .delete(
            url,
            headers: _getDefaultHeaders(headers),
          )
          .timeout(_requestTimeout);

      _handleResponse(response);
      return response;
    } catch (e) {
      print('DELETE Error: $e');
      rethrow;
    }
  }

  // ============= CAMERA VIDEO FEED METHODS =============

  /// Get camera video feed stream URL
  /// [streamPath] - Path to the video stream (e.g., '/stream', '/mjpeg')
  String getCameraStreamUrl({String streamPath = '/video_feed'}) {
    return '$_cameraVideoFeedUrl$streamPath';
  }

  /// Get camera snapshot URL
  /// [snapshotPath] - Path to the snapshot endpoint (e.g., '/snapshot')
  String getCameraSnapshotUrl({String snapshotPath = '/snapshot'}) {
    return '$_cameraVideoFeedUrl$snapshotPath';
  }

  /// Stream camera video feed
  /// [streamPath] - Path to the video stream
  /// [headers] - Optional custom headers
  Future<http.StreamedResponse> streamCameraFeed({
    String streamPath = '/video_feed',
    Map<String, String>? headers,
  }) async {
    try {
      final url = Uri.parse('$_cameraVideoFeedUrl$streamPath');
      final request = http.Request('GET', url)
        ..headers.addAll(_getDefaultHeaders(headers));

      final response = await _httpClient.send(request).timeout(_requestTimeout);
      return response;
    } catch (e) {
      print('Camera Stream Error: $e');
      rethrow;
    }
  }

  /// Get camera snapshot
  /// [snapshotPath] - Path to the snapshot endpoint
  /// [headers] - Optional custom headers
  Future<http.Response> getCameraSnapshot({
    String snapshotPath = '/snapshot',
    Map<String, String>? headers,
  }) async {
    try {
      final url = Uri.parse('$_cameraVideoFeedUrl$snapshotPath');
      final response = await _httpClient
          .get(
            url,
            headers: _getDefaultHeaders(headers),
          )
          .timeout(_requestTimeout);

      return response;
    } catch (e) {
      print('Camera Snapshot Error: $e');
      rethrow;
    }
  }

  // ============= HELPER METHODS =============

  /// Get default headers with content-type
  Map<String, String> _getDefaultHeaders(Map<String, String>? customHeaders) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'User-Agent': 'Flutter-App/1.0',
    };

    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }

    return headers;
  }

  /// Handle HTTP response status codes
  void _handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
      case 204:
        // Success responses
        break;
      case 400:
        throw ApiException('Bad Request: ${response.body}', response.statusCode);
      case 401:
        throw ApiException('Unauthorized', response.statusCode);
      case 403:
        throw ApiException('Forbidden', response.statusCode);
      case 404:
        throw ApiException('Not Found', response.statusCode);
      case 500:
        throw ApiException('Internal Server Error', response.statusCode);
      case 503:
        throw ApiException('Service Unavailable', response.statusCode);
      default:
        throw ApiException(
          'Unexpected Error: ${response.statusCode}',
          response.statusCode,
        );
    }
  }

  /// Parse JSON response
  static Map<String, dynamic> parseJson(String responseBody) {
    try {
      return jsonDecode(responseBody) as Map<String, dynamic>;
    } catch (e) {
      print('JSON Parse Error: $e');
      rethrow;
    }
  }

  /// Dispose resources
  void dispose() {
    _httpClient.close();
  }
}

/// Custom API Exception
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}
