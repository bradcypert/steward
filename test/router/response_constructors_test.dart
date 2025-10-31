import 'package:test/test.dart';
import 'package:steward/steward.dart';

void main() {
  group('Response New Constructors', () {
    test('Response.NoContent should create 204 response', () {
      final response = Response.NoContent();
      
      expect(response.statusCode, equals(204));
    });

    test('Response.Conflict should create 409 response', () {
      final response = Response.Conflict('Resource conflict');
      
      expect(response.statusCode, equals(409));
      expect(response.body, equals('Resource conflict'));
    });

    test('Response.UnprocessableEntity should create 422 response', () {
      final response = Response.UnprocessableEntity('Validation failed');
      
      expect(response.statusCode, equals(422));
      expect(response.body, equals('Validation failed'));
    });

    test('Response.TooManyRequests should create 429 response', () {
      final response = Response.TooManyRequests('Rate limit exceeded');
      
      expect(response.statusCode, equals(429));
      expect(response.body, equals('Rate limit exceeded'));
    });

    test('Response.BadGateway should create 502 response', () {
      final response = Response.BadGateway('Upstream error');
      
      expect(response.statusCode, equals(502));
      expect(response.body, equals('Upstream error'));
    });

    test('Response.ServiceUnavailable should create 503 response', () {
      final response = Response.ServiceUnavailable('Service down');
      
      expect(response.statusCode, equals(503));
      expect(response.body, equals('Service down'));
    });

    test('Response.RedirectForever should create 301 response', () {
      final response = Response.RedirectForever('/new-location');
      
      expect(response.statusCode, equals(308)); // HTTP 308 is permanent redirect
      expect(response.body, equals('/new-location'));
    });

    test('New constructors should work without body', () {
      final conflict = Response.Conflict();
      final unprocessable = Response.UnprocessableEntity();
      final tooMany = Response.TooManyRequests();
      final badGateway = Response.BadGateway();
      final unavailable = Response.ServiceUnavailable();
      
      expect(conflict.statusCode, equals(409));
      expect(unprocessable.statusCode, equals(422));
      expect(tooMany.statusCode, equals(429));
      expect(badGateway.statusCode, equals(502));
      expect(unavailable.statusCode, equals(503));
    });
  });
}
