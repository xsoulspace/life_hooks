# DPug Core

This package is the heart of the DPug project. It contains the core components for the DPug language, including the compiler, lexer, parser, and Abstract Syntax Tree (AST) definitions. It handles the logic for converting DPug code to Dart and vice-versa.

## Features

- **DPug to Dart Conversion**: Converts DPug source code into standard Dart code.
- **Dart to DPug Conversion**: Converts standard Dart code into DPug syntax.
- **Lexer**: Tokenizes DPug source code.
- **Parser**: Parses the token stream into an AST.
- **AST**: Defines the structure of the DPug language.

## Usage

This package is intended to be used by other packages in the DPug project, such as `dpug_server` and `dpug_code_builder`. It is not intended to be used directly by end-users.