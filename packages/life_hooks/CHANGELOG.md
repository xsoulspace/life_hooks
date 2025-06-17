## 0.1.1

- chore: added xsoulspace_ui_foundation for DeviceRuntimeType

## 0.1.0

- chore: sdk: ">=3.8.1 <4.0.0"

## 0.0.21

- Updated Dependecies:
  - sdk: ">=3.7.0 <4.0.0"
  - replaced flutter_lints with lints: ^5.1.1
  - xsoulspace_lints: ^0.0.14
  - xsoulspace_foundation: ^0.0.10
  - flutter_hooks: ^0.21.2

## 0.0.20

BREAKING CHANGE:

- The project now utilizes the xsoulspace_foundation package for primitive interfaces.
  Loadable, Disposable are moved to xsoulspace_foundation.

Updated Dependencies:

- chore: dart_sdk up to 3.5.3
- chore: flutter_hooks: ^0.20.5
- chore: added flutter_keyboard_visibility, xsoulspace_foundation

Added:

- docs: Basic documentation for most classes (Work In Progress).
- use_keyboard_visibility
- use_state_builder

## 0.0.19

- chore: dart 3.2.0
- chore: flutter_hooks: ^0.20.3
- chore: xsoulspace_lints: ^0.0.10

## 0.0.19

- chore: flutter hooks to ^0.18.6
- chore: xsoulspace_lints: ^0.0.8

## 0.0.18

- chore: flutter constraints removed

## 0.0.17

- chore: max dart sdk up to 4.0.0

## 0.0.16

- chore: xsoulspace_lints up to 0.0.3
- chore: dart sdk up to 2.19.0

## 0.0.15

- exposed build and didUpdateHook for LifeState

## 0.0.14

- chore:
  dart sdk: 2.18
  flutter_hooks: ^0.18.5+1
  flutter: ">=3.3.0"
- perf: FormHelper now is independent class and can be used outside useFormHelper hook.
- feat: simple Disposable abstract class with dispose method

## 0.0.12

BREAKING CHANGE:

- fix: context in ContextfulLifeHook now removed and replaced with the getContext method.

## 0.0.11

- fix: Loadable now has no BuildContext in onLoad. BuildContext now in ContextfulLoadable

## 0.0.10

- feat: useFormHelper

## 0.0.9

- fix: export widgets

## 0.0.8

- feat: useIsBool hook
- feat: StateLoader widget with StateInitializer class to simplify any loading logic

- chore: xsoulspace_lints with flutter_lints

## 0.0.7

- fix: restore contextful hook

## 0.0.6

- fix: remove contextful hook

## 0.0.5

- fix: remove register hooks

## 0.0.4

- fix: register hooks override should be optional

## 0.0.3

- fix: flutter_lints

## 0.0.2

- feat: ContextfulLifeHook to create LifeState with context

## 0.0.1

Inital release and readme
