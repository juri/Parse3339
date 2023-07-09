# ``Parts``

## Converting to Foundation types

`Parts` provides two computed properties for creating Foundation types, ``Parts/date`` for creating a `Date` and ``Parts/dateComponents`` for creating a `DateComponents`. 

From the `DateComponents` value you can go on to create a `Date` using a `Calendar`; RFC 3339 time stamps are defined to be in the Gregorian calendar and they always have a time zone, so the `DateComponents` `Parts` creates have those filled and the `DateComponents` value's `date` property works as expected.

However, ``Parts/date`` is a significantly faster path to `Date` than going via `DateComponents`. It uses the `timegm(3)` Unix function for calculating the `Date` value, and you can expect it to be several times faster than going via `DateComponents` and `Calendar` as of macOS Ventura.

## Topics

### Accessing parts of time stamp

- ``Parts/year``
- ``Parts/month``
- ``Parts/day``
- ``Parts/hour``
- ``Parts/minute``
- ``Parts/second``
- ``Parts/secondFraction``
- ``Parts/secondFractionDigits``
- ``Parts/zone``

### Converting values

- ``Parts/nanosecond``
- ``Parts/zoneSeconds``

### Creating Foundation types

- ``Parts/date``
- ``Parts/dateComponents``
