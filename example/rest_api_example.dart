import 'package:steward/steward.dart';
import 'package:steward/middlewares.dart';

/// Example REST API demonstrating Steward's features
/// This example shows:
/// - Request body parsing (JSON)
/// - Query parameters
/// - Security headers
/// - Rate limiting
/// - CORS
/// - Error handling
/// - Different response types

Future main() async {
  final router = Router();

  // Apply global middleware
  router.use(SecurityHeadersMiddleware());
  router.use(RequestIdMiddleware());
  router.use(CorsMiddleware(
    allowOrigin: ['*'],
    allowMethods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowHeaders: ['Content-Type', 'Authorization'],
  ));

  // Health check endpoint
  router.get('/health', (Context context) async {
    return Response.Ok('OK');
  });

  // Example: Query parameters
  router.get('/api/search', (Context context) async {
    final query = context.request.queryParams['q'] ?? '';
    final page = int.tryParse(context.request.queryParams['page'] ?? '1') ?? 1;
    final limit = int.tryParse(context.request.queryParams['limit'] ?? '10') ?? 10;

    return Response.Json(
      _JsonResponse({
        'query': query,
        'page': page,
        'limit': limit,
        'results': ['Item 1', 'Item 2', 'Item 3'],
      }),
    );
  });

  // Example: JSON body parsing and validation
  router.post('/api/users', (Context context) async {
    try {
      final body = await context.request.json();
      
      // Validate required fields
      if (!body.containsKey('name') || !body.containsKey('email')) {
        return Response.BadRequest('Name and email are required');
      }

      // Simulate user creation
      final user = {
        'id': DateTime.now().millisecondsSinceEpoch,
        'name': body['name'],
        'email': body['email'],
        'createdAt': DateTime.now().toIso8601String(),
      };

      return Response.Created(user.toString());
    } catch (e) {
      return Response.BadRequest('Invalid JSON body');
    }
  });

  // Example: Path parameters
  router.get('/api/users/:id', (Context context) async {
    final id = context.request.pathParams['id'];
    
    if (id == null) {
      return Response.BadRequest('User ID is required');
    }

    // Simulate user lookup
    final user = {
      'id': id,
      'name': 'John Doe',
      'email': 'john@example.com',
    };

    return Response.Json(_JsonResponse(user));
  });

  // Example: Rate limited endpoint
  router.get('/api/limited', (Context context) async {
    return Response.Ok('This endpoint is rate limited');
  }, middleware: [
    RateLimitMiddleware(maxRequests: 5, window: Duration(minutes: 1))
  ]);

  // Example: Different response types
  router.get('/api/status/:code', (Context context) async {
    final code = int.tryParse(context.request.pathParams['code'] ?? '200') ?? 200;

    switch (code) {
      case 200:
        return Response.Ok('Success');
      case 201:
        return Response.Created('Resource created');
      case 204:
        return Response.NoContent();
      case 400:
        return Response.BadRequest('Bad request');
      case 401:
        return Response.Unauthorized('Unauthorized');
      case 403:
        return Response.Forbidden('Forbidden');
      case 404:
        return Response.NotFound('Not found');
      case 409:
        return Response.Conflict('Conflict');
      case 422:
        return Response.UnprocessableEntity('Unprocessable entity');
      case 429:
        return Response.TooManyRequests('Too many requests');
      case 500:
        return Response.InternalServerError('Internal server error');
      case 502:
        return Response.BadGateway('Bad gateway');
      case 503:
        return Response.ServiceUnavailable('Service unavailable');
      default:
        return Response(code, body: 'Status code: $code');
    }
  });

  // Example: Error handling
  router.get('/api/error', (Context context) async {
    throw Exception('Something went wrong!');
  });

  // Example: Headers
  router.get('/api/headers', (Context context) async {
    final userAgent = context.request.header('User-Agent') ?? 'Unknown';
    final contentType = context.request.contentType?.mimeType ?? 'Unknown';
    
    return Response.Ok('User-Agent: $userAgent\nContent-Type: $contentType');
  });

  // Start the application
  final app = App(router: router, environment: Environment.other);
  return app.start();
}

// Helper class for JSON responses
class _JsonResponse implements Jsonable {
  final Map<String, dynamic> data;

  _JsonResponse(this.data);

  @override
  Map<String, dynamic> toJson() => data;
}
