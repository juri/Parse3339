# ``Parse3339``

Parse RFC 3339 time stamps.

## Overview

Parse3339 is a fast pure Swift parser for [RFC 3339] formatted time stamps. 

[RFC 3339]: https://www.rfc-editor.org/rfc/rfc3339

### Time stamp format

The time stamp formats supported by Parse3339 are the following:

- `2023-07-09T113:14:00+03:00`
- `2023-07-09T113:14:00.2+03:00`
- `2023-07-09T113:14:00Z`
- `2023-07-09T113:14:00.2Z`

See the RFC for the exact format specification.

## Topics

### Parsing

- ``parse(_:)-89jso``
- ``parse(_:)-9on3x``

### Parser output

- ``Parts``
