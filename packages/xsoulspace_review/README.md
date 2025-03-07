# xsoulspace_review Package

The main purpose of this package is to unite and simplify the process of requesting reviews from various stores.

Currently, the package supports the following stores:

## Native support:

- Google Play and App Store (via [in_app_review](https://pub.dev/packages/in_app_review))
- RuStore

## Non-native support (using Consent Screen and then asking to go to the store):

- Snapstore

## Usage

```dart
import 'package:xsoulspace_review/xsoulspace_review.dart';

void onLoad() {
  /// this will create a store reviewer specific to
  /// installation source. This is made via
  /// [store_checker](https://pub.dev/packages/store_checker)
  /// package and additional methods from [xsoulspace_foundation](https://pub.dev/packages/xsoulspace_foundation).
  StoreReviewerFactory.create();
}
```

or use `StoreReviewRequester` to initialize the store review requester and schedule reviews.

```dart
final storeReviewRequester = StoreReviewRequester();

Future<void> onLoad() async {
  await storeReviewRequester.onLoad();
}

void dispose() {
  storeReviewRequester.dispose();
}
```
