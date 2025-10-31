import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:steward/steward.dart';

void main() {
  group('Request Query Parameters', () {
    test('queryParams should return query parameters as map', () {
      final httpRequest = _MockHttpRequest(
        uri: Uri.parse('http://localhost:4040/test?name=John&age=30')
      );
      final request = Request(request: httpRequest);
      
      expect(request.queryParams['name'], equals('John'));
      expect(request.queryParams['age'], equals('30'));
    });

    test('queryParams should return empty map when no parameters', () {
      final httpRequest = _MockHttpRequest(
        uri: Uri.parse('http://localhost:4040/test')
      );
      final request = Request(request: httpRequest);
      
      expect(request.queryParams, isEmpty);
    });

    test('queryParamsAll should handle multiple values', () {
      final httpRequest = _MockHttpRequest(
        uri: Uri.parse('http://localhost:4040/test?tag=dart&tag=flutter')
      );
      final request = Request(request: httpRequest);
      
      expect(request.queryParamsAll['tag'], equals(['dart', 'flutter']));
    });
  });

  group('Request Body Parsing', () {
    test('json() should parse JSON body', () async {
      final jsonBody = {'name': 'John', 'age': 30};
      final httpRequest = _MockHttpRequest(
        body: jsonEncode(jsonBody),
      );
      final request = Request(request: httpRequest);
      
      final parsed = await request.json();
      expect(parsed['name'], equals('John'));
      expect(parsed['age'], equals(30));
    });

    test('jsonList() should parse JSON array', () async {
      final jsonArray = [1, 2, 3, 4, 5];
      final httpRequest = _MockHttpRequest(
        body: jsonEncode(jsonArray),
      );
      final request = Request(request: httpRequest);
      
      final parsed = await request.jsonList();
      expect(parsed, equals([1, 2, 3, 4, 5]));
    });

    test('json() should throw on invalid JSON', () async {
      final httpRequest = _MockHttpRequest(
        body: 'not valid json',
      );
      final request = Request(request: httpRequest);
      
      expect(() => request.json(), throwsA(isA<FormatException>()));
    });
  });

  group('Request Properties', () {
    test('method should return HTTP method', () {
      final httpRequest = _MockHttpRequest(method: 'POST');
      final request = Request(request: httpRequest);
      
      expect(request.method, equals('POST'));
    });

    test('isJson should return true for JSON content type', () {
      final httpRequest = _MockHttpRequest(
        contentType: ContentType.json,
      );
      final request = Request(request: httpRequest);
      
      expect(request.isJson, isTrue);
    });

    test('isJson should return true for JSON API content type', () {
      final httpRequest = _MockHttpRequest(
        contentType: ContentType('application', 'vnd.api+json'),
      );
      final request = Request(request: httpRequest);
      
      expect(request.isJson, isTrue);
    });

    test('isForm should return true for form content type', () {
      final httpRequest = _MockHttpRequest(
        contentType: ContentType('application', 'x-www-form-urlencoded'),
      );
      final request = Request(request: httpRequest);
      
      expect(request.isForm, isTrue);
    });

    test('header should return header value', () {
      final httpRequest = _MockHttpRequest(
        headers: {'Authorization': 'Bearer token123'},
      );
      final request = Request(request: httpRequest);
      
      expect(request.header('Authorization'), equals('Bearer token123'));
    });

    test('headers should return all header values', () {
      final httpRequest = _MockHttpRequest(
        multiHeaders: {'Accept': ['application/json', 'text/html']},
      );
      final request = Request(request: httpRequest);
      
      expect(request.headers('Accept'), equals(['application/json', 'text/html']));
    });
  });
}

// Mock HttpRequest for testing
class _MockHttpRequest implements HttpRequest {
  final Uri uri;
  final String body;
  @override
  final String method;
  final ContentType? contentType;
  final Map<String, String>? _headerMap;
  final Map<String, List<String>>? multiHeaders;
  
  _MockHttpRequest({
    Uri? uri,
    this.body = '',
    this.method = 'GET',
    this.contentType,
    Map<String, String>? headers,
    this.multiHeaders,
  }) : uri = uri ?? Uri.parse('http://localhost:4040/'),
       _headerMap = headers;

  @override
  Stream<R> cast<R>() {
    return Stream.value(utf8.encode(body) as R);
  }

  @override
  Future<E> drain<E>([E? futureValue]) async {
    return futureValue as E;
  }

  @override
  StreamSubscription<Uint8List> listen(
    void Function(Uint8List event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream.value(Uint8List.fromList(utf8.encode(body))).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  HttpHeaders get headers => _MockHttpHeaders(
    headers: _headerMap ?? {},
    multiHeaders: this.multiHeaders ?? {},
    contentType: contentType,
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

// Mock HttpHeaders for testing
class _MockHttpHeaders implements HttpHeaders {
  final Map<String, String> headers;
  final Map<String, List<String>> multiHeaders;
  final ContentType? contentType;

  _MockHttpHeaders({
    required this.headers,
    required this.multiHeaders,
    this.contentType,
  });

  @override
  String? value(String name) => headers[name];

  @override
  List<String>? operator [](String name) => multiHeaders[name];

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
