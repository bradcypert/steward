# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
- Comprehensive feature analysis document (FEATURE_ANALYSIS.md)
- Request query parameter helpers (`queryParams`, `queryParamsAll`)
- Request JSON body parsing methods (`json()`, `jsonList()`)
- Request helper methods (`method`, `contentType`, `isJson`, `isForm`, `header()`, `headers()`)
- New Response constructors: `NoContent()`, `Conflict()`, `UnprocessableEntity()`, `TooManyRequests()`, `BadGateway()`, `ServiceUnavailable()`
- SecurityHeadersMiddleware for automatic security header injection
- RateLimitMiddleware for request rate limiting
- CompressionMiddleware for response compression (gzip/deflate)
- RequestIdMiddleware for request tracking
- GitHub issue templates (bug report, feature request, documentation)
- GitHub pull request template
- REST API example demonstrating all features
- Security best practices documentation
- Comprehensive test coverage for all new features

### Documentation
- Updated README with feature list and improved examples
- Added security best practices guide
- Added comprehensive REST API example

## [0.4.0] - 2023-10-22
### Added
- Steward Context
- AoT compilation support
- URI property on Request

### Removed
- Controllers
- Reflection-based routing

## [0.3.2] - 2023-03-15
### Added
- Support for `.staticFiles('/my-static-files')` on the router.

### Fixed
- Several inconsistencies with type names that deviated from the dart standard.

## [0.3.1] - 2022-10-01
### Added
- Support for middlware in the @Path annotation when working with controllers.

## [0.3.0] - 2022-09-13
### Changed
- The Form API has changed a small bit. This is a breaking change. Overriding the validator function is the preferred way forward instead of passing it via constructor.

## [0.2.8] - 2022-06-22
### Fixed
- Let strings render as text by default instead of application/json. You can still override this if needed by passing in a content type.

## [0.2.7] - 2022-06-17
### Added
- Support for wrangling forms of data via the Forms class. You don't have to use this and Steward will work fine without it, but its there if you'd like it!

## [0.2.6] - 2022-06-12
### Added
- Requests now expose cookies
- Requests now expose the x509 Certificate object
- Requests now expose the session
- Responses now support setting cookies
- Responses now have a named constructor for temporary and permenant redirects

## [0.2.5] - 2022-05-27
### Fixed
- Resolved an issue where loopback was being used vs AnyIPvX and prevented use from docker containers.

## [0.2.4] - 2022-03-21
### Fixed
- Resolved an issue where if a path was defined with a trailing slash, the trailing slash was required. This was particularly problematic with combinations of the @Path and @GET (or other) decorators.

# [0.2.3] - 2022-03-16
### Fixed
- Route specific middlewares were being called before router specific middlewares. This is no longer the case.
## [0.2.2] - 2022-03-16
### Fixed
- Middlewares were being called from right to left in declararation order and this was causing a lot of confusion (and wasnt intended). This is now fixed.

## [0.2.1] - 2022-03-16
### Added
- Support for Controller Method level Middleware. More below.

Controller Method-level middleware can be specified by passing an optional list of middleware to the annotation for controller method decorations.

## [0.2.0] - 2022-03-15
### Added
- Support for the app to take in an environment variable which is used to help determine if stacktraces should be written via HTTP when failures are caught. The plan is to ultimately incorporate this into more functionality in the future.
- Steward CLI support for `steward doctor`
- Steward CLI support for `steward new controller $controllerName`
- Support for `dart pub global activate steward`

### Changed
- The Container abstract class now has an abstract method called Clone. Containers must implement clone to be used by Steward.
- The container made available to a request is cloned right before we start processing middleware and/or the request handler. This should allow users to bind request specific details via middleware and expose those in the handler should they choose to do so.

### Fixed
- Steward CLI support for up-to-date steward app generation.

## [0.1.7] - 2022-03-09
### Added
- Support for optional trailing slash support in router matching.
- Support for case insensitive pattern matching for router matching.

### Changed
- Bump version of Bosun dependency.

## [0.1.6] - 2022-03-06
### Fixed
- Dont try to JSONify primitives on their own.
- Catch errors at the framework layer and dont crash the server)
    - There's a lot of further improvement to be made here. See https://github.com/PyreStudios/steward/issues/16 for more information.

## [0.1.5] - 2022-03-05
### Fixed
- Changed the JSON detection mechanism to be less picky.
## [0.1.4] - 2022-03-05
### Fixed
- JSON-ify the body even if the content type is already set

## [0.1.3] - 2022-03-05
### Fixed
- Resolved an issue that was preventing the previous change from running. My bad.

## [0.1.2] - 2022-03-05
### Fixed
- Resolved an issue that was preventing Futures of Futures (and so on) from serializing properly

## [0.1.1] - 2022-02-10
### Changed
- Added support for passing in a host to the router, default to AnyIPv4

## [0.1.0] - 2022-02-2
### Changed
- Steward is now async based!

## [0.0.8] - 2022-02-02
### Added
- Support for @Path decorator to be used on controllers.

### Fixed
- Steward's new command should now place dart files in the correct place

## [0.0.7]
### Added
- Infer content type from response body if none is provided.

## [0.0.6] - 2022-01-26
### Fixed
- An issue with config reader types not working as expected.

## [0.0.5] - 2022-01-26
### Added
- CORS middleware

### Changed
- Refactor and clean up a lot of the app and router code.

## [0.0.4] - 2021-12-18
### Added
- Tests around HEAD, PUT, PATCH, and DELETE in the router
- You can now simply import `package:steward/steward.dart` to bring the entire steward suite into scope. This is the intended way to use steward.
- Added tests for the new controller patterns.
- Added Injectable annotation and HTTP Verb annotations for controllers.

### Changed
- Description in Pubspec.yaml
- Router package now exports the request and response classes as well, since theyre coupled.
- Simplified the generated seed-code to use the simplified imports changes captured in #4
- Controllers function completely differently now. Controllers are mounted into the router which reflectively generates routes from member annotations. Additionally, controllers reflectively have DI items injected via the @Injectable annotation during this time as well.
- Migrated what little CLI we already have to Bosun to provide a better CLI experience.


## [0.0.3] - 2021-04-17
### Added
- Added support for middleware functions
- Added the requestLogger middleware that ships with Steward
- Tests around the router, middleware, and controllers.

### Fixed
- Steward CLI new was not adding imports to the generated controller

## [0.0.2] - 2021-04-11
### Added
- Initial public release of Steward. It's still light with much more to come, but the current pieces work well.
- Add support for Mustache templates and view binding from controllers.
- Add support for wiring up controllers to the router.
