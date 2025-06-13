## 0.1.0

- chore: dart sdk: ">=3.8.1 <4.0.0"

## 0.0.15

- fix: non_nullable_equals_parameter not found

## 0.0.14

- Added lints:
  strict_top_level_inference
  unnecessary_underscores
  omit_obvious_property_types
  unnecessary_async
  unsafe_variance
  annotate_redeclares
- Removed lints:
  package_api_docs

- Updated README
- Chore: dart sdk: ">=3.7.0 <4.0.0"
- Chore: lints: ^5.1.1

- Removed flutter dependency

## 0.0.13

- fix: removed flutter_lints from app.yaml

## 0.0.12

- Removed flutter_lints dependency and added lints dependency
- Added lints (mostly from old flutter_lints but with const lints):
  avoid_print: true
  prefer_inlined_adds: true
  null_closures: true
  avoid_unnecessary_containers: true
  avoid_web_libraries_in_flutter: true
  no_logic_in_create_state: true
  prefer_const_constructors_in_immutables: true
  sized_box_for_whitespace: true
  use_key_in_widget_constructors: true
  prefer_const_constructors: true
  prefer_const_declarations: true
  prefer_const_literals_to_create_immutables: true

## 0.0.11

BREAKING:

- updated dart sdk to upper constraint sdk: ">=3.5.3 <4.0.0"
- updated flutter_lints to 5.0.0

DEV:

- added Makefile for managing the package

## 0.0.10

BREAKING:

- updated dart sdk to upper constraint sdk: ">=3.1.0 <4.0.0"
- updated flutter_lints to 3.0.0
- removed redundant rules from code metrics

added:

- implicit_reopen
- type_literal_in_constant_pattern
- use_late_for_private_fields_and_variables

## 0.0.9

- updated dart sdk to upper constraint sdk: ">=3.0.1 <4.0.0"

## 0.0.8

- remove always_specify_types

## 0.0.7

- fix conflicts

## 0.0.6

- reviewed all lint rules, removed useless and enabled some experimental features.
- added new lint: public_library - the purpose to use this lint if you developing a library which will be published to pub.dev

## 0.0.5

- chore: flutter constraints removed

# 0.0.4

- chore: max dart sdk up to 4.0.0

# 0.0.3

- chore: dart sdk up to 2.19.0

## 0.0.2

- chore: dart sdk min now is 2.18.0
- feat: added as true:
  use_super_parameters
  prefer_function_declarations_over_variables
  prefer_initializing_formals

## 0.0.1

Initial release
