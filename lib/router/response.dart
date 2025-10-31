import 'dart:convert';
import 'dart:io';

import 'package:mustache_template/mustache.dart';

const _originKey = 'Access-Control-Allow-Origin';
const _methodsKey = 'Access-Control-Allow-Methods';
const _headersKey = 'Access-Control-Allow-Headers';
const _cookieKey = 'Set-Cookie';

abstract interface class Jsonable {
  Map<String, dynamic> toJson();
}

/// Models HTTP Headers that can be managed by the framework.
class Headers {
  ContentType? contentType;
  DateTime? date = DateTime.now();
  final Map<String, List<String>> _headers = {};

  Headers();

  /// Sets the values of the header with the given name.
  /// Overrides existing values if the header already exists.
  void set(String key, List<String> value) {
    _headers[key] = value;
  }

  /// Adds a header with the given name and values.
  /// Appends to the existing values if the header already exists.
  void add(String key, List<String> value) {
    if (_headers[key] == null) {
      _headers[key] = value;
    } else {
      _headers[key]?.addAll(value);
    }
  }

  /// Easily index into the headers map.
  List<String>? operator [](String key) {
    return _headers[key];
  }
}

/// Models an HTTP Response
/// Steward processes this response and writes out the necessary data to the
/// live HTTP response.
class Response {
  int statusCode;
  Headers headers = Headers();
  String? body;

  /// Whether the connection should be persistent or not
  bool persistent = false;

  /// General constructor, sets the status code and body.
  Response(this.statusCode, {this.body, this.persistent = false});

  /// Constructor for 200 OK responses.
  Response.Ok([String? body]) : this(HttpStatus.ok, body: body);

  /// Typesafe constructor for a response for a jsonable
  Response.Json(Jsonable jsonable, {int statusCode = HttpStatus.ok})
      : this(statusCode, body: jsonEncode(jsonable));

  /// Constructor for 201 Created responses.
  Response.Created([String? body]) : this(HttpStatus.created, body: body);

  /// Constructor for 400 bad request responses.
  Response.BadRequest([String? body]) : this(HttpStatus.badRequest, body: body);

  /// Constructor for 401 unauthorized responses.
  Response.Unauthorized([String? body])
      : this(HttpStatus.unauthorized, body: body);

  /// Constructor for 403 forbidden responses.
  Response.Forbidden([String? body]) : this(HttpStatus.forbidden, body: body);

  /// Constructor for 404 not found responses.
  Response.NotFound([String? body]) : this(HttpStatus.notFound, body: body);

  /// Constructor for 500 internal server error responses.
  Response.InternalServerError([String? body])
      : this(HttpStatus.internalServerError, body: body);

  /// Alternative Constructor for 500 internal server error responses.
  Response.Boom([String? body])
      : this(HttpStatus.internalServerError, body: body);

  /// Constructor for 204 no content responses.
  Response.NoContent() : this(HttpStatus.noContent);

  /// Constructor for 409 conflict responses.
  Response.Conflict([String? body]) : this(HttpStatus.conflict, body: body);

  /// Constructor for 422 unprocessable entity responses.
  Response.UnprocessableEntity([String? body])
      : this(HttpStatus.unprocessableEntity, body: body);

  /// Constructor for 429 too many requests responses.
  Response.TooManyRequests([String? body])
      : this(HttpStatus.tooManyRequests, body: body);

  /// Constructor for 502 bad gateway responses.
  Response.BadGateway([String? body])
      : this(HttpStatus.badGateway, body: body);

  /// Constructor for 503 service unavailable responses.
  Response.ServiceUnavailable([String? body])
      : this(HttpStatus.serviceUnavailable, body: body);

  /// Constructor for 302 redirect responses.
  Response.Redirect(String location)
      : this(HttpStatus.temporaryRedirect, body: location);

  /// Constructor for 308 permanent redirect responses.
  Response.RedirectForever(String location)
      : this(308, body: location); // HTTP 308 Permanent Redirect

  /// Render a template from a template string.
  /// Templates can be inlined or looked up from a template
  Response.View(String templateString,
      {this.statusCode = HttpStatus.ok,
      Map<String, dynamic> varMap = const {}}) {
    final template = Template(templateString);
    body = template.renderString(varMap);
  }

  /// Sets the cookies on the response as headers
  void setCookies(List<Cookie> cookies) {
    cookies.forEach((cookie) {
      headers.add(_cookieKey, [cookie.toString()]);
    });
  }
}

/// writeResponse takes in an HTTP request and a steward response, and writes the
/// contents of the steward response to the HTTP response.
/// TODO: this should only be called by Steward
Future<void> writeResponse(HttpRequest request, Future<Response> resp) async {
  final response = await resp;
  final body = response.body;

  request.response.headers.contentType = response.headers.contentType;
  request.response.headers.date = response.headers.date;

  if (response.headers[_headersKey] != null) {
    request.response.headers.set(_headersKey, response.headers[_headersKey]!);
  }

  if (response.headers[_originKey] != null) {
    request.response.headers.set(_originKey, response.headers[_originKey]!);
  }

  if (response.headers[_methodsKey] != null) {
    request.response.headers.set(_methodsKey, response.headers[_methodsKey]!);
  }

  request.response.statusCode = response.statusCode;
  request.response.write(body);

  return;
}
