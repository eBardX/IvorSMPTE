# ``IvorSMPTE``

@Metadata {
    @PageColor(blue)
}

SMPTE timecode, frame rate, and timecode conversion types.

## Overview

The IvorSMPTE framework provides SMPTE timecode and frame rate types written in
Swift. A timecode is expressed in hours, minutes, seconds, frames, and
hundredths of a frame at one of the standard frame rates: 23.976, 24, 25, 29.97
(drop-frame or non-drop-frame), 30 (drop-frame or non-drop-frame), 50, 59.94
(drop-frame or non-drop-frame), and 60 (drop-frame or non-drop-frame) frames per
second. Timecodes can be parsed from and formatted as
`HH:MM:SS:FF` strings, and converted to and from an exact number of seconds
since midnight, with drop-frame numbering handled throughout. A timecode
converter labels any timeline measured in seconds, such as wall-clock time, with
timecode relative to a chosen start timecode.

```swift
import IvorSMPTE

// One hour exactly, at 25 frames per second.
let start = SMPTETime(frameRate: .fps25,
                      hour: 1,
                      minute: 0,
                      second: 0,
                      frame: 0,
                      subframe: 0)

// Drop-frame timecode uses `;` before the frame number.
if let time = SMPTETime(string: "01:00:03;12",
                        frameRate: .fps2997Drop) {
    print(time.elapsedSeconds)  // 18016999/5000 (about 3,603.4 seconds)
}
```

Every public type is a `Sendable` value type, so instances can be freely shared
across tasks and actor boundaries.

## Topics

### Timecode

- ``SMPTETime``
- ``SMPTEFrameRate``

### Conversion

- ``SMPTETimeConverter``
- ``SMPTEExactSeconds``
