# ``IvorSMPTE``

@Metadata {
    @PageColor(blue)
}

SMPTE timecode and frame rate types.

## Overview

The IvorSMPTE framework provides SMPTE timecode and frame rate types written in
Swift. A timecode is expressed in hours, minutes, seconds, frames, and
hundredths of a frame at one of four standard frame rates: 24, 25, 29.97
(drop-frame), and 30 frames per second.

```swift
import IvorSMPTE

// One hour exactly, at 25 frames per second.
let start = SMPTETime(frameRate: .fps25,
                      hour: 1,
                      minute: 0,
                      second: 0,
                      frame: 0,
                      fraction: 0)
```

Every public type is a `Sendable` value type, so instances can be freely shared
across tasks and actor boundaries.

## Topics

### Timecode

- ``SMPTETime``
- ``SMPTEFrameRate``
