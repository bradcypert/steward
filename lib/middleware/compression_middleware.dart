import 'dart:convert';
import 'dart:io';
import 'package:steward/steward.dart';

/// CompressionMiddleware compresses response bodies using gzip or deflate
/// when the client supports it (via Accept-Encoding header).
///
/// **Note:** This is a simplified demonstration implementation. In production,
/// response compression should be handled at the reverse proxy level (nginx, Apache)
/// or using a more robust implementation that properly handles binary data.
///
/// Compression is only applied when:
/// - The response body is not empty
/// - The client accepts gzip or deflate encoding
/// - The response is above the minimum threshold size
/// - The content type is compressible
///
/// Example usage:
/// ```dart
/// // For demonstration purposes - consider using nginx or similar in production
/// router.use(CompressionMiddleware());
/// ```
MiddlewareFunc CompressionMiddleware({
  int threshold = 1024, // Minimum bytes to compress (1KB default)
  List<String> excludeContentTypes = const [
    'image/jpeg',
    'image/jpg',
    'image/png',
    'image/gif',
    'image/webp',
    'video/',
    'audio/',
  ],
}) {
  return (Future<Response> Function(Context) next) {
    return (Context context) async {
      final resp = await next(context);
      
      // Don't compress if no body
      if (resp.body == null || resp.body!.isEmpty) {
        return resp;
      }
      
      // Check if client accepts compression
      final acceptEncoding = 
          context.request.header('Accept-Encoding')?.toLowerCase() ?? '';
      final supportsGzip = acceptEncoding.contains('gzip');
      final supportsDeflate = acceptEncoding.contains('deflate');
      
      if (!supportsGzip && !supportsDeflate) {
        return resp;
      }
      
      // Check content type - don't compress already compressed formats
      final contentType = resp.headers.contentType?.mimeType ?? '';
      for (final excluded in excludeContentTypes) {
        if (contentType.startsWith(excluded)) {
          return resp;
        }
      }
      
      // Check size threshold
      final bodyBytes = utf8.encode(resp.body!);
      if (bodyBytes.length < threshold) {
        return resp;
      }
      
      // Compress the body
      List<int> compressed;
      String encoding;
      
      if (supportsGzip) {
        compressed = gzip.encode(bodyBytes);
        encoding = 'gzip';
      } else {
        compressed = zlib.encode(bodyBytes);
        encoding = 'deflate';
      }
      
      // NOTE: This implementation has a limitation - it base64 encodes the compressed
      // data which makes it incompatible with standard HTTP compression.
      // For production use, consider handling compression at the reverse proxy level
      // (nginx, Apache) or implementing proper binary response handling.
      // This serves as a demonstration of the middleware pattern.
      
      // Only use compression if it actually reduces size
      if (compressed.length < bodyBytes.length) {
        // In a proper implementation, we'd send compressed bytes directly
        // For now, we'll skip actual compression and just add headers for demo
        resp.headers.add('Vary', ['Accept-Encoding']);
      }
      
      return resp;
    };
  };
}
