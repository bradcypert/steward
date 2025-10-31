import 'dart:io';
import 'package:test/test.dart';
import 'package:steward/steward.dart';
import 'package:steward/middlewares.dart';

void main() {
  group('SecurityHeadersMiddleware', () {
    test('should add default security headers', () async {
      final middleware = SecurityHeadersMiddleware();
      final handler = middleware((context) async => Response.Ok('test'));
      
      final mockContext = _MockContext();
      final response = await handler(mockContext);
      
      expect(response.headers['X-Frame-Options'], equals(['DENY']));
      expect(response.headers['X-Content-Type-Options'], equals(['nosniff']));
      expect(response.headers['X-XSS-Protection'], equals(['1; mode=block']));
      expect(response.headers['Referrer-Policy'], equals(['no-referrer']));
      expect(response.headers['Strict-Transport-Security']?[0], 
             contains('max-age=31536000'));
    });

    test('should allow customizing frame options', () async {
      final middleware = SecurityHeadersMiddleware(frameOptions: 'SAMEORIGIN');
      final handler = middleware((context) async => Response.Ok('test'));
      
      final mockContext = _MockContext();
      final response = await handler(mockContext);
      
      expect(response.headers['X-Frame-Options'], equals(['SAMEORIGIN']));
    });

    test('should allow disabling HSTS', () async {
      final middleware = SecurityHeadersMiddleware(includeHsts: false);
      final handler = middleware((context) async => Response.Ok('test'));
      
      final mockContext = _MockContext();
      final response = await handler(mockContext);
      
      expect(response.headers['Strict-Transport-Security'], isNull);
    });

    test('should add CSP when provided', () async {
      final csp = "default-src 'self'";
      final middleware = SecurityHeadersMiddleware(contentSecurityPolicy: csp);
      final handler = middleware((context) async => Response.Ok('test'));
      
      final mockContext = _MockContext();
      final response = await handler(mockContext);
      
      expect(response.headers['Content-Security-Policy'], equals([csp]));
    });
  });

  group('RateLimitMiddleware', () {
    test('should allow requests under the limit', () async {
      final middleware = RateLimitMiddleware(
        maxRequests: 5,
        window: Duration(seconds: 60),
      );
      final handler = middleware((context) async => Response.Ok('success'));
      
      final mockContext = _MockContext();
      
      // Make 5 requests - all should succeed
      for (var i = 0; i < 5; i++) {
        final response = await handler(mockContext);
        expect(response.statusCode, equals(200));
      }
    });

    test('should block requests over the limit', () async {
      final middleware = RateLimitMiddleware(
        maxRequests: 3,
        window: Duration(seconds: 60),
      );
      final handler = middleware((context) async => Response.Ok('success'));
      
      final mockContext = _MockContext();
      
      // Make 3 successful requests
      for (var i = 0; i < 3; i++) {
        final response = await handler(mockContext);
        expect(response.statusCode, equals(200));
      }
      
      // 4th request should be rate limited
      final blockedResponse = await handler(mockContext);
      expect(blockedResponse.statusCode, equals(429));
      expect(blockedResponse.body, contains('Too many requests'));
    });

    test('should add rate limit headers', () async {
      final middleware = RateLimitMiddleware(maxRequests: 10);
      final handler = middleware((context) async => Response.Ok('success'));
      
      final mockContext = _MockContext();
      final response = await handler(mockContext);
      
      expect(response.headers['X-RateLimit-Limit'], equals(['10']));
      expect(response.headers['X-RateLimit-Remaining'], isNotNull);
    });
  });

  group('RequestIdMiddleware', () {
    test('should add request ID header to response', () async {
      final middleware = RequestIdMiddleware();
      final handler = middleware((context) async => Response.Ok('test'));
      
      final mockContext = _MockContext();
      final response = await handler(mockContext);
      
      expect(response.headers['X-Request-ID'], isNotNull);
      expect(response.headers['X-Request-ID']?[0], isNotEmpty);
    });

    test('should use custom header name', () async {
      final middleware = RequestIdMiddleware(headerName: 'X-Trace-ID');
      final handler = middleware((context) async => Response.Ok('test'));
      
      final mockContext = _MockContext();
      final response = await handler(mockContext);
      
      expect(response.headers['X-Trace-ID'], isNotNull);
    });

    test('should use custom generator', () async {
      final middleware = RequestIdMiddleware(
        generator: () => 'custom-id-123',
      );
      final handler = middleware((context) async => Response.Ok('test'));
      
      final mockContext = _MockContext();
      final response = await handler(mockContext);
      
      expect(response.headers['X-Request-ID'], equals(['custom-id-123']));
    });
  });
}

// Mock Context for testing
class _MockContext implements Context {
  final Request _request = _MockRequest();
  
  @override
  Request get request => _request;
  
  @override
  T? read<T>(String key) => null;
  
  @override
  clone() => _MockContext();
}

// Mock Request for testing
class _MockRequest extends Request {
  _MockRequest() : super(request: _MockHttpRequest());
}

// Mock HttpRequest for testing
class _MockHttpRequest implements HttpRequest {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
  
  @override
  HttpConnectionInfo? get connectionInfo => _MockConnectionInfo();
}

// Mock ConnectionInfo for testing  
class _MockConnectionInfo implements HttpConnectionInfo {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
  
  @override
  InternetAddress get remoteAddress => InternetAddress('127.0.0.1');
}
