import 'dart:convert';
import 'dart:io';

/// Request models the request object that Steward processes.
/// It is a wrapper around the [HttpRequest] object but this may change in future iterations.
/// Generally, you will not need to new up a request object on your own, but may find that useful
/// when working with middleware and/or intercepting incoming requests.
class Request {
  HttpRequest request;
  Map<String, dynamic> pathParams;

  Request({required this.request, this.pathParams = const {}});

  /// Returns the body of this request as a Future<String>.
  Future<String> getBody() {
    return utf8.decodeStream(request);
  }

  /// Gets cookies associated with this request
  List<Cookie> get cookies => request.cookies;

  /// Gets the x509 certificate associated with this request
  X509Certificate? get certificate => request.certificate;

  /// Gets the HTTPSession associated with this request
  HttpSession get session => request.session;

  /// Gets the URI of the request
  Uri get uri => request.uri;

  /// Gets query parameters from the request URI
  Map<String, String> get queryParams => request.uri.queryParameters;

  /// Gets all query parameters (including duplicates) from the request URI
  Map<String, List<String>> get queryParamsAll =>
      request.uri.queryParametersAll;

  /// Parses the request body as JSON and returns a Map
  /// Throws FormatException if the body is not valid JSON
  Future<Map<String, dynamic>> json() async {
    final body = await getBody();
    return jsonDecode(body) as Map<String, dynamic>;
  }

  /// Parses the request body as a JSON list
  /// Throws FormatException if the body is not valid JSON
  Future<List<dynamic>> jsonList() async {
    final body = await getBody();
    return jsonDecode(body) as List<dynamic>;
  }

  /// Gets the HTTP method of the request (GET, POST, etc.)
  String get method => request.method;

  /// Gets the content type of the request
  ContentType? get contentType => request.headers.contentType;

  /// Returns true if the request content type is JSON
  bool get isJson =>
      contentType?.mimeType == 'application/json' ||
      contentType?.mimeType == 'application/vnd.api+json';

  /// Returns true if the request content type is form data
  bool get isForm =>
      contentType?.mimeType == 'application/x-www-form-urlencoded' ||
      contentType?.mimeType == 'multipart/form-data';

  /// Gets a header value from the request
  String? header(String name) => request.headers.value(name);

  /// Gets all header values for a given name
  List<String>? headers(String name) => request.headers[name];
}
