# IvorSMPTE

SMPTE timecode and frame rate types.

[![Swift 6.3](https://img.shields.io/badge/Swift-6.3-orange.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/platforms-iOS%20%7C%20macOS-lightgrey.svg)](https://developer.apple.com)
[![SwiftPM](https://img.shields.io/badge/SwiftPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/eBardX/IvorSMPTE/blob/main/LICENSE.md)

* [Overview](#overview)
* [Requirements](#requirements)
* [Installation](#installation)
    * [Swift Package Manager](#spm_installation)
* [Quick Start](#quick_start)
* [Reference Documentation](#reference_documentation)
* [Credits](#credits)
* [License](#license)

## <a name="overview">Overview</a>

The IvorSMPTE framework provides SMPTE timecode and frame rate types written in
Swift. A timecode is expressed in hours, minutes, seconds, frames, and
hundredths of a frame at one of four standard frame rates: 24, 25, 29.97
(drop-frame), and 30 frames per second.

## <a name="requirements">Requirements</a>

* iOS 18.0+ / macOS 15.0+
* Swift 6.3 toolchain
* Swift 6 language mode

## <a name="installation">Installation</a>

### <a name="spm_installation">Swift Package Manager</a>

IvorSMPTE is distributed exclusively through the [Swift Package Manager][spm].

To add IvorSMPTE to a Swift package, add it to the `dependencies` in your
`Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/eBardX/IvorSMPTE.git",
             .upToNextMajor(from: "1.0.0"))
]
```

Then add `IvorSMPTE` to the dependencies of any target that uses it:

```swift
.target(name: "MyTarget",
        dependencies: [.product(name: "IvorSMPTE",
                                package: "IvorSMPTE")])
```

To add IvorSMPTE to an Xcode project, choose **File ▸ Add Package
Dependencies…** and enter the repository URL:

```
https://github.com/eBardX/IvorSMPTE.git
```

IvorSMPTE has no dependencies.

## <a name="quick_start">Quick Start</a>

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

The initializer is failable: it returns `nil` if any component is out of
range, such as a frame number that is not less than the nominal frame rate.

## <a name="reference_documentation">Reference Documentation</a>

Full [reference documentation][refdoc] is available courtesy of [DocC][docc].

## <a name="credits">Credits</a>

John Gary Pusey (ebardx@gmail.com)

## <a name="license">License</a>

IvorSMPTE is available under [the MIT license][license].

[docc]:     https://www.swift.org/documentation/docc/
[license]:  https://github.com/eBardX/IvorSMPTE/blob/main/LICENSE.md
[refdoc]:   https://eBardX.github.io/ivor-packages-docs/documentation/ivorsmpte
[spm]:      https://swift.org/package-manager/
