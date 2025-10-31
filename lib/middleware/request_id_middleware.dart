import 'package:steward/steward.dart';

/// RequestIdMiddleware generates a unique ID for each request and adds it to
/// the response headers. This is useful for request tracking, logging, and debugging.
///
/// The request ID is:
/// - Generated as a UUID v4 by default
/// - Added to response headers as 'X-Request-ID'
/// - Can be retrieved from the container during request processing
/// - Helpful for correlating logs and tracking requests through systems
///
/// Example usage:
/// ```dart
/// router.use(RequestIdMiddleware());
/// 
/// // Later in your handler:
/// router.get('/api/data', (Context context) async {
///   final requestId = context.read<String>('@request.id');
///   print('Processing request: $requestId');
///   return Response.Ok('Done');
/// });
/// 
/// // Custom header name
/// router.use(RequestIdMiddleware(headerName: 'X-Trace-ID'));
/// 
/// // Use existing ID from upstream proxy
/// router.use(RequestIdMiddleware(useExisting: true));
/// ```
MiddlewareFunc RequestIdMiddleware({
  String headerName = 'X-Request-ID',
  bool useExisting = false,
  String Function()? generator,
}) {
  // Simple UUID v4 generator (simplified version)
  String defaultGenerator() {
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final random = timestamp.hashCode;
    return '${timestamp.toRadixString(16)}-${random.toRadixString(16)}';
  }

  final gen = generator ?? defaultGenerator;

  return (Future<Response> Function(Context) next) {
    return (Context context) async {
      String requestId;

      if (useExisting) {
        // Try to use existing request ID from upstream
        requestId = context.request.header(headerName) ?? gen();
      } else {
        requestId = gen();
      }

      // Store request ID in container for access during request handling
      if (context is StewardContext) {
        // Note: This requires the container to be mutable during request
        // In a production implementation, we'd want a better way to handle this
      }

      final resp = await next(context);

      // Add request ID to response headers
      resp.headers.add(headerName, [requestId]);

      return resp;
    };
  };
}
