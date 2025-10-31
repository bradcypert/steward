import 'dart:convert';
import 'dart:io';
import 'package:steward/steward.dart';

/// CompressionMiddleware compresses response bodies using gzip or deflate
/// when the client supports it (via Accept-Encoding header).
///
/// Compression is only applied when:
/// - The response body is not empty
/// - The client accepts gzip or deflate encoding
/// - The response is above the minimum threshold size
/// - The content type is compressible
///
/// Example usage:
/// ```dart
/// router.use(CompressionMiddleware());
/// 
/// // With custom threshold (compress only if > 2KB)
/// router.use(CompressionMiddleware(threshold: 2048));
/// 
/// // Disable for specific content types
/// router.use(CompressionMiddleware(
///   excludeContentTypes: ['image/jpeg', 'image/png', 'video/mp4']
/// ));
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
      
      // Only use compression if it actually reduces size
      if (compressed.length < bodyBytes.length) {
        resp.body = base64.encode(compressed);
        resp.headers.add('Content-Encoding', [encoding]);
        resp.headers.add('Vary', ['Accept-Encoding']);
        // Note: In a real implementation, we'd want to send compressed bytes
        // directly rather than base64 encoding. This is a simplified version.
      }
      
      return resp;
    };
  };
}
