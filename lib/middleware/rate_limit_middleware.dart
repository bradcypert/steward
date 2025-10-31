import 'dart:collection';
import 'package:steward/steward.dart';

/// Entry representing a request timestamp and count for rate limiting
class _RateLimitEntry {
  final Queue<DateTime> requests = Queue<DateTime>();
  
  void addRequest() {
    requests.add(DateTime.now());
  }
  
  void cleanOldRequests(Duration window) {
    final cutoff = DateTime.now().subtract(window);
    while (requests.isNotEmpty && requests.first.isBefore(cutoff)) {
      requests.removeFirst();
    }
  }
  
  int get count => requests.length;
}

/// RateLimitMiddleware limits the number of requests from a client within a time window.
/// Uses a sliding window algorithm to track requests.
///
/// By default, it allows 100 requests per minute per IP address.
///
/// Example usage:
/// ```dart
/// // Allow 10 requests per 30 seconds
/// router.use(RateLimitMiddleware(maxRequests: 10, window: Duration(seconds: 30)));
/// 
/// // Different limits for different routes
/// router.get('/api/heavy', handler, middleware: [
///   RateLimitMiddleware(maxRequests: 5, window: Duration(minutes: 1))
/// ]);
/// ```
///
/// When rate limit is exceeded, returns a 429 Too Many Requests response.
MiddlewareFunc RateLimitMiddleware({
  int maxRequests = 100,
  Duration window = const Duration(minutes: 1),
  String Function(Context)? keyGenerator,
  String message = 'Too many requests, please try again later.',
}) {
  final storage = <String, _RateLimitEntry>{};
  
  // Default key generator uses IP address
  final genKey = keyGenerator ?? (Context context) {
    return context.request.request.connectionInfo?.remoteAddress.address ?? 'unknown';
  };

  return (Future<Response> Function(Context) next) {
    return (Context context) async {
      final key = genKey(context);
      
      // Get or create entry for this key
      final entry = storage.putIfAbsent(key, () => _RateLimitEntry());
      
      // Clean old requests outside the window
      entry.cleanOldRequests(window);
      
      // Check if limit exceeded
      if (entry.count >= maxRequests) {
        final resp = Response.TooManyRequests(message);
        resp.headers.add('X-RateLimit-Limit', [maxRequests.toString()]);
        resp.headers.add('X-RateLimit-Remaining', ['0']);
        resp.headers.add('Retry-After', [window.inSeconds.toString()]);
        return resp;
      }
      
      // Calculate remaining before adding this request
      final remaining = maxRequests - entry.count - 1;
      
      // Add this request
      entry.addRequest();
      
      // Process the request
      final resp = await next(context);
      
      // Add rate limit headers to response
      resp.headers.add('X-RateLimit-Limit', [maxRequests.toString()]);
      resp.headers.add('X-RateLimit-Remaining', [remaining.toString()]);
      
      return resp;
    };
  };
}
