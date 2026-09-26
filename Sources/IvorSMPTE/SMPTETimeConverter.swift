// © 2026 John Gary Pusey (see LICENSE.md)

private import XestiNumbers

/// A type that converts between SMPTE timecode and an exact number of seconds
/// from a starting timecode.
///
/// Create an `SMPTETimeConverter` from the timecode at which zero seconds
/// occurs, and use it to convert times. The mapping between the two is fixed
/// by the frame rate and the start timecode alone, so a converter can label
/// any timeline measured in seconds, such as the wall time of a performance,
/// with SMPTE timecode.
public struct SMPTETimeConverter {

    // MARK: Public Initializers

    /// Creates a new `SMPTETimeConverter` instance for the given frame rate,
    /// with zero seconds occurring at midnight (00:00:00:00).
    ///
    /// - Parameter frameRate:  The SMPTE frame rate.
    public init(frameRate: SMPTEFrameRate) {
        self.init(startTime: SMPTETime(frameRate: frameRate,
                                       frameCount: 0,
                                       subframe: 0)!)   // swiftlint:disable:this force_unwrapping
    }

    /// Creates a new `SMPTETimeConverter` instance with zero seconds
    /// occurring at the given timecode.
    ///
    /// The converter uses the frame rate of the start timecode.
    ///
    /// - Parameter startTime:  The timecode at zero seconds.
    public init(startTime: SMPTETime) {
        self.startTime = startTime
    }

    // MARK: Public Instance Properties

    /// The timecode at zero seconds.
    public let startTime: SMPTETime
}

// MARK: -

extension SMPTETimeConverter {

    // MARK: Public Instance Properties

    /// The SMPTE frame rate of the timecodes this converter produces.
    public var frameRate: SMPTEFrameRate {
        startTime.frameRate
    }

    // MARK: Public Instance Methods

    /// Returns the exact number of seconds from the start timecode to the
    /// given timecode.
    ///
    /// Because timecode wraps around after 24 hours, a timecode earlier than
    /// the start timecode is treated as occurring on the following day. For
    /// example, if the start timecode is 23:59:00:00, then 00:01:00:00 occurs
    /// 120 seconds after the start timecode.
    ///
    /// - Parameter time:   The timecode to convert. Its frame rate must match
    ///                     this converter’s ``frameRate``.
    ///
    /// - Returns:  The number of seconds from the start timecode to `time`,
    ///             which is at least zero and less than one day of timecode.
    ///
    /// - Precondition: `time`’s frame rate must equal this converter’s
    ///                 ``frameRate``.
    public func seconds(at time: SMPTETime) -> SMPTEExactSeconds {
        precondition(time.frameRate == frameRate,
                     "Frame rate of time does not match frame rate of converter")

        return SMPTEExactSeconds(_wrap(time.elapsedSeconds.numberValue - startTime.elapsedSeconds.numberValue))
    }

    /// Returns the timecode at the given number of seconds from the start
    /// timecode.
    ///
    /// The result is rounded to the nearest hundredth of a frame, and wraps
    /// around to 00:00:00:00 after 24 hours of timecode.
    ///
    /// - Parameter seconds:    The number of seconds from the start timecode.
    ///
    /// - Returns:  The ``SMPTETime`` at `seconds`.
    public func smpteTime(at seconds: SMPTEExactSeconds) -> SMPTETime {
        SMPTETime(frameRate: frameRate,
                  elapsedSeconds: SMPTEExactSeconds(startTime.elapsedSeconds.numberValue + seconds.numberValue))
    }

    // MARK: Private Instance Methods

    // Reduces seconds to the range 0 up to (but not including) one day of
    // timecode at this converter’s frame rate.
    private func _wrap(_ seconds: Number) -> Number {
        let secondsPerDay = Number(frameRate.framesPerDay) / frameRate.numberValue

        return seconds - (secondsPerDay * floor(seconds / secondsPerDay))
    }
}

// MARK: - Equatable

extension SMPTETimeConverter: Equatable {
}

// MARK: - Hashable

extension SMPTETimeConverter: Hashable {
}

// MARK: - Sendable

extension SMPTETimeConverter: Sendable {
}
