## [0.2.0]
- `URL#join` and `URL#merge` will return a new URL object. Use `#join!` and `#merge!` to modify the current URL.

## [0.1.1]
- Fixed a bug where a parsed URL ending with a slash would result in double slashes after the hostname when joined with additional paths.
- Fixed bug when `URL.parse` with `nil` was rasing an arrer. Now it returns `nil`.

## [0.1.0]
- Initial release

## [0.0.0]
- Unreleased
