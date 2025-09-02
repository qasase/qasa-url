## [0.1.2]
- Fixed a bug in URL parsing when the protocol separator appeared in the path

## [0.1.1]
- Fixed a bug where a parsed URL ending with a slash would produce double slashes after the hostname when joined with additional paths.
- Fixed a bug where calling `URL.parse` with `nil` raised an error. It now returns `nil`

## [0.1.0]
- Initial release

## [0.0.0]
- Unreleased
