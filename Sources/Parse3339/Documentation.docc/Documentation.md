# ``Parse3339``

Parse RFC 3339 time stamps.

## Overview

Parse3339 is a fast pure Swift parser for a subset of [RFC 3339] formatted time stamps. 

[RFC 3339]: https://www.rfc-editor.org/rfc/rfc3339

### Time stamp format

The time stamp formats supported by Parse3339 are the following:

- `2023-07-09T113:14:00+03:00`
- `2023-07-09T113:14:00.2+03:00`
- `2023-07-09T113:14:00Z`
- `2023-07-09T113:14:00.2Z`

Note that the RFC specifies more allowed variations than this parser supports.

### Usage

```swift
import Parse3339

let s = "2023-07-09T13:14:00+03:00"
guard let parts = Parse3339.parse(s) else {
    return
}
let date = parts.date
print(date.timeIntervalSinceReferenceDate)
// output: 710590440.0
```

## Topics

### Parsing

- ``parse(_:)-89jso``
- ``parse(_:)-9on3x``

### Parser output

- ``Parts``
