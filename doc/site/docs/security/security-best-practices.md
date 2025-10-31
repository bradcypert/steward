---
sidebar_position: 6
---

# Security Best Practices

Security is critical for any web application. Steward provides several tools and best practices to help secure your application.

## Security Headers

Use the `SecurityHeadersMiddleware` to automatically add important security headers to all responses:

```dart
import 'package:steward/middlewares.dart';

router.use(SecurityHeadersMiddleware());
```

This adds the following headers by default:
- `X-Frame-Options: DENY` - Prevents clickjacking attacks
- `X-Content-Type-Options: nosniff` - Prevents MIME type sniffing
- `X-XSS-Protection: 1; mode=block` - Enables XSS filtering
- `Strict-Transport-Security: max-age=31536000; includeSubDomains` - Enforces HTTPS
- `Referrer-Policy: no-referrer` - Controls referrer information

### Customizing Security Headers

```dart
router.use(SecurityHeadersMiddleware(
  frameOptions: 'SAMEORIGIN',  // Allow framing from same origin
  includeHsts: false,          // Disable HSTS if not using HTTPS
  contentSecurityPolicy: "default-src 'self'", // Add CSP
));
```

## Rate Limiting

Protect your endpoints from abuse with rate limiting:

```dart
// Global rate limit: 100 requests per minute
router.use(RateLimitMiddleware());

// Custom rate limit for sensitive endpoints
router.post('/api/login', loginHandler, middleware: [
  RateLimitMiddleware(maxRequests: 5, window: Duration(minutes: 1))
]);
```

### Custom Rate Limit Keys

By default, rate limiting is per IP address. You can customize this:

```dart
router.use(RateLimitMiddleware(
  keyGenerator: (context) {
    // Rate limit by user ID instead of IP
    return context.read('@user.id') ?? 'anonymous';
  }
));
```

## CORS Configuration

Configure Cross-Origin Resource Sharing (CORS) properly:

```dart
router.use(CorsMiddleware(
  allowOrigin: ['https://yourdomain.com'],
  allowMethods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowHeaders: ['Content-Type', 'Authorization'],
));
```

**Security Note:** Avoid using `allowOrigin: ['*']` in production unless your API is truly public.

## Input Validation

Always validate user input before processing:

```dart
router.post('/api/users', (Context context) async {
  try {
    final body = await context.request.json();
    
    // Validate required fields
    if (!body.containsKey('email') || !body.containsKey('password')) {
      return Response.BadRequest('Email and password are required');
    }
    
    // Validate email format
    final email = body['email'] as String;
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return Response.UnprocessableEntity('Invalid email format');
    }
    
    // Validate password strength
    final password = body['password'] as String;
    if (password.length < 8) {
      return Response.UnprocessableEntity('Password must be at least 8 characters');
    }
    
    // Process valid input...
    return Response.Created('User created');
  } catch (e) {
    return Response.BadRequest('Invalid request body');
  }
});
```

## Security Checklist

- [ ] Enable SecurityHeadersMiddleware
- [ ] Configure CORS properly (no wildcards in production)
- [ ] Implement rate limiting on public endpoints
- [ ] Use HTTPS in production
- [ ] Validate all user input
- [ ] Hash passwords with strong algorithms
- [ ] Use environment variables for secrets
- [ ] Implement authentication and authorization
- [ ] Add request size limits
- [ ] Enable logging and monitoring
- [ ] Keep dependencies up to date
- [ ] Perform regular security audits

## Additional Resources

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Dart Security Documentation](https://dart.dev/guides/security)
- [Content Security Policy Guide](https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP)
