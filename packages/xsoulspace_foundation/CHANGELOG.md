## 0.2.0

- chore: sdk: ">=3.8.1 <4.0.0"

## 0.1.0

BREAKING CHANGES:

- isEmpty, onEmpty methods migrated to new library [is_dart_empty_or_not](https://pub.dev/packages/is_dart_empty_or_not)
- json encoding and decoding functions moved into [from_json_to_json](https://pub.dev/packages/from_json_to_json)

- ui and flutter related utilities migrated to new library [xsoulspace_ui_foundation]()

## 0.0.11

- Updated:
  - freezed_annotation: ^3.0.0
  - freezed: ^3.0.3
  - json_serializable: ^6.9.4

## 0.0.10

- Updated:
  - dart sdk 3.7.0
  - collection 1.19.0
  - collection: ^1.19.0
  - shared_preferences: ^2.5.2
  - store_checker: ^1.8.0
  - lints: ^5.1.1
  - xsoulspace_lints: ^0.0.14

## 0.0.9

- Fixed:
  - export `infinite_scroll_pagination_utils`

## 0.0.8

- Added:
  - `infinite_scroll_pagination_utils` module with Readme documentation.
- Changed:
  - Improved some of Readme documentation.

## 0.0.7

- Fixed:
  - `set_x.dart` and `map_x.dart` exports

## 0.0.6

- Added:
  - `whenZeroUse` extension for `int` and `double`
  - `whenEmptyUse` extension for `Set`, `List`, `Map`
  - `unmodifiable` extension for `Set`, `List`, `Map`
  - Bumped Dart SDK to 3.6.0 and dependency versions
  - Updated extension names for consistency (now all ends with `X`, and starts with `XS`)

## 0.0.5

- Added:
  - `whenZeroUse` extension for `int` and `double`
- Chore:
  - updated `xsoulspace_lints` to 0.0.12

## 0.0.4

- Changed:
  - Names of the extensions to exclude conflicts with other packages
  - Added `context.viewPadding` extension to simplify getting specific to view padding

## 0.0.3

- Added:
  - AppStoreUtils with StoreChecker package

## 0.0.2

- Added:
  - Loadable, Disposable
- Removed:
  - hooks moved to life_hooks package.
  - dependecies flutter_hooks and flutter_keyboard_visibility removed

## 0.0.1

- Initial release with basic utils.
