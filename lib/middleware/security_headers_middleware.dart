import 'package:steward/steward.dart';

/// SecurityHeadersMiddleware adds common security headers to responses.
/// This helps protect against common web vulnerabilities.
///
/// Default headers set:
/// - X-Frame-Options: DENY (prevents clickjacking)
/// - X-Content-Type-Options: nosniff (prevents MIME type sniffing)
/// - X-XSS-Protection: 1; mode=block (enables XSS filtering in older browsers)
/// - Strict-Transport-Security: max-age=31536000; includeSubDomains (enforces HTTPS)
/// - Referrer-Policy: no-referrer (controls referrer information)
///
/// Example usage:
/// ```dart
/// router.use(SecurityHeadersMiddleware());
/// ```
///
/// Customize headers:
/// ```dart
/// router.use(SecurityHeadersMiddleware(
///   frameOptions: 'SAMEORIGIN',
///   includeHsts: false,
/// ));
/// ```
MiddlewareFunc SecurityHeadersMiddleware({
  String frameOptions = 'DENY',
  String contentTypeOptions = 'nosniff',
  String xssProtection = '1; mode=block',
  bool includeHsts = true,
  int hstsMaxAge = 31536000,
  bool hstsIncludeSubDomains = true,
  String referrerPolicy = 'no-referrer',
  String? contentSecurityPolicy,
}) {
  return (Future<Response> Function(Context) next) {
    return (Context context) async {
      final resp = await next(context);

      // X-Frame-Options: Prevents clickjacking attacks
      resp.headers.add('X-Frame-Options', [frameOptions]);

      // X-Content-Type-Options: Prevents MIME type sniffing
      resp.headers.add('X-Content-Type-Options', [contentTypeOptions]);

      // X-XSS-Protection: Enables XSS filtering (legacy, but still useful)
      resp.headers.add('X-XSS-Protection', [xssProtection]);

      // Referrer-Policy: Controls referrer information
      resp.headers.add('Referrer-Policy', [referrerPolicy]);

      // Strict-Transport-Security: Enforces HTTPS connections
      if (includeHsts) {
        final hstsValue = hstsIncludeSubDomains
            ? 'max-age=$hstsMaxAge; includeSubDomains'
            : 'max-age=$hstsMaxAge';
        resp.headers.add('Strict-Transport-Security', [hstsValue]);
      }

      // Content-Security-Policy: Additional layer of security
      if (contentSecurityPolicy != null) {
        resp.headers.add('Content-Security-Policy', [contentSecurityPolicy]);
      }

      return resp;
    };
  };
}
