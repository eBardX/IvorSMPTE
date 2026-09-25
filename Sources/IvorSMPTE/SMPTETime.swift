// © 2025–2026 John Gary Pusey (see LICENSE.md)

public import XestiNumbers

/// A SMPTE timecode value specifying a point in time.
public struct SMPTETime {

    // MARK: Public Initializers

    /// Creates a new `SMPTETime` instance from an exact number of seconds
    /// since midnight (00:00:00:00), or `nil` if the number of seconds is
    /// negative or is not a finite real number.
    ///
    /// The number of seconds is rounded to the nearest hundredth of a frame.
    /// Timecode wraps around to 00:00:00:00 after 24 hours.
    ///
    /// - Parameter frameRate:       The SMPTE frame rate.
    /// - Parameter elapsedSeconds:  The number of seconds since midnight.
    public init?(frameRate: SMPTEFrameRate,
                 elapsedSeconds: Number) {
        guard elapsedSeconds.isReal,
              elapsedSeconds.isFinite,
              !elapsedSeconds.isNegative
        else { return nil }

        let hundredths = round(elapsedSeconds * frameRate.numberValue * 100).exact
        let hundredthsPerDay = Number(frameRate.framesPerDay * 100)
        let (frameCount, fraction) = modulo(hundredths, hundredthsPerDay).uintValue.quotientAndRemainder(dividingBy: 100)

        self.init(frameRate: frameRate,
                  frameCount: frameCount,
                  fraction: fraction)
    }

    /// Creates a new `SMPTETime` instance from a number of frames since
    /// midnight (00:00:00:00), or `nil` if the frame count or fraction is out
    /// of range for the given frame rate.
    ///
    /// At drop-frame rates, frames are numbered using drop-frame timecode, so
    /// the resulting components skip the frame numbers that drop-frame
    /// timecode omits.
    ///
    /// - Parameter frameRate:   The SMPTE frame rate.
    /// - Parameter frameCount:  The number of frames since midnight. Must be
    ///                          less than the frame rate’s `framesPerDay`.
    /// - Parameter fraction:    The sub-frame fraction component (0–99).
    public init?(frameRate: SMPTEFrameRate,
                 frameCount: UInt,
                 fraction: UInt) {
        guard frameCount < frameRate.framesPerDay
        else { return nil }

        let frameNumber = Self._convertToFrameNumber(frameCount, frameRate)
        let nominalRate = frameRate.uintValue
        let (seconds, frame) = frameNumber.quotientAndRemainder(dividingBy: nominalRate)
        let (minutes, second) = seconds.quotientAndRemainder(dividingBy: 60)
        let (hour, minute) = minutes.quotientAndRemainder(dividingBy: 60)

        self.init(frameRate: frameRate,
                  hour: hour,
                  minute: minute,
                  second: second,
                  frame: frame,
                  fraction: fraction)
    }

    /// Creates a new `SMPTETime` instance with the provided components,
    /// or `nil` if any component is out of range for the given frame rate.
    ///
    /// At drop-frame rates, the components must form a valid drop-frame
    /// timecode: the frame numbers that drop-frame timecode skips (0 and 1 at
    /// 29.97 frames per second, 0 through 3 at 59.94 frames per second) do not
    /// exist at the start of any minute other than minutes 0, 10, 20, 30, 40,
    /// and 50.
    ///
    /// - Parameter frameRate:  The SMPTE frame rate.
    /// - Parameter hour:       The hour component (0–23).
    /// - Parameter minute:     The minute component (0–59).
    /// - Parameter second:     The second component (0–59).
    /// - Parameter frame:      The frame component (0 to frameRate−1).
    /// - Parameter fraction:   The sub-frame fraction component (0–99).
    public init?(frameRate: SMPTEFrameRate,
                 hour: UInt,
                 minute: UInt,
                 second: UInt,
                 frame: UInt,
                 fraction: UInt) {
        let maxFrame = frameRate.uintValue

        guard (0..<24).contains(hour),
              (0..<60).contains(minute),
              (0..<60).contains(second),
              (0..<maxFrame).contains(frame),
              (0..<100).contains(fraction),
              !Self._isDroppedFrame(frameRate, minute, second, frame)
        else { return nil }

        self.fraction = fraction
        self.frame = frame
        self.frameRate = frameRate
        self.hour = hour
        self.minute = minute
        self.second = second
    }

    /// Creates a new `SMPTETime` instance by parsing its string representation,
    /// or `nil` if the string cannot be parsed or any component is out of
    /// range for the given frame rate.
    ///
    /// The string must have the form `HH:MM:SS:FF`, with each component
    /// written as exactly two decimal digits. At drop-frame rates, the
    /// separator before the frame component may be either `:` or `;`; at other
    /// rates, it must be `:`. The string may end with a period and a two-digit
    /// sub-frame fraction component, as in `01:00:03;12.50`.
    ///
    /// - Parameter string:     The string representation of the timecode (as
    ///                         produced by `description`).
    /// - Parameter frameRate:  The SMPTE frame rate.
    public init?(string: String,
                 frameRate: SMPTEFrameRate) {
        let chars = Array(string)

        guard chars.count == 11 || (chars.count == 14 && chars[11] == "."),
              chars[2] == ":",
              chars[5] == ":",
              chars[8] == ":" || (chars[8] == ";" && frameRate.isDropFrame),
              let hour = Self._parseComponent(chars[0...1]),
              let minute = Self._parseComponent(chars[3...4]),
              let second = Self._parseComponent(chars[6...7]),
              let frame = Self._parseComponent(chars[9...10])
        else { return nil }

        let fraction: UInt

        if chars.count == 14 {
            guard let value = Self._parseComponent(chars[12...13])
            else { return nil }

            fraction = value
        } else {
            fraction = 0
        }

        self.init(frameRate: frameRate,
                  hour: hour,
                  minute: minute,
                  second: second,
                  frame: frame,
                  fraction: fraction)
    }

    // MARK: Public Instance Properties

    /// The sub-frame fraction component (0–99).
    public let fraction: UInt

    /// The frame component.
    public let frame: UInt

    /// The SMPTE frame rate.
    public let frameRate: SMPTEFrameRate

    /// The hour component (0–23).
    public let hour: UInt

    /// The minute component (0–59).
    public let minute: UInt

    /// The second component (0–59).
    public let second: UInt
}

// MARK: -

extension SMPTETime {

    // MARK: Public Instance Properties

    /// The exact number of seconds since midnight (00:00:00:00), including
    /// the sub-frame fraction component.
    ///
    /// For the NTSC-derived rates, this is an exact rational value; for
    /// example, frame 1 at 29.97 frames per second is 1001/30000 seconds after
    /// midnight.
    public var elapsedSeconds: Number {
        Number((frameCount * 100) + fraction) / (frameRate.numberValue * 100)
    }

    /// The number of frames since midnight (00:00:00:00).
    ///
    /// At drop-frame rates, this accounts for the frame numbers that
    /// drop-frame timecode skips.
    public var frameCount: UInt {
        let totalMinutes = (hour * 60) + minute
        let frameNumber = (((totalMinutes * 60) + second) * frameRate.uintValue) + frame
        let dropped = frameRate.droppedFramesPerMinute

        return frameNumber - (dropped * (totalMinutes - (totalMinutes / 10)))
    }

    // MARK: Private Type Methods

    private static func _convertToFrameNumber(_ frameCount: UInt,
                                              _ frameRate: SMPTEFrameRate) -> UInt {
        let dropped = frameRate.droppedFramesPerMinute

        guard dropped > 0
        else { return frameCount }

        // Each 10-minute block holds all the frames of its first minute, and
        // all but the dropped frame numbers of each of the other nine minutes.
        let framesPerMinute = frameRate.uintValue * 60
        let framesPerDroppedMinute = framesPerMinute - dropped
        let framesPerBlock = framesPerMinute + (9 * framesPerDroppedMinute)
        let (blocks, remainder) = frameCount.quotientAndRemainder(dividingBy: framesPerBlock)
        let blockOffset = 9 * dropped * blocks

        guard remainder >= dropped
        else { return frameCount + blockOffset }

        return frameCount + blockOffset + (dropped * ((remainder - dropped) / framesPerDroppedMinute))
    }

    private static func _formatComponent(_ value: UInt) -> String {
        value < 10 ? "0\(value)" : "\(value)"
    }

    private static func _isDroppedFrame(_ frameRate: SMPTEFrameRate,
                                        _ minute: UInt,
                                        _ second: UInt,
                                        _ frame: UInt) -> Bool {
        second == 0 && frame < frameRate.droppedFramesPerMinute && !minute.isMultiple(of: 10)
    }

    private static func _parseComponent(_ chars: ArraySlice<Character>) -> UInt? {
        guard chars.allSatisfy({ $0.isASCII && $0.isWholeNumber })
        else { return nil }

        return UInt(String(chars))
    }
}

// MARK: - CustomStringConvertible

extension SMPTETime: CustomStringConvertible {

    // MARK: Public Instance Properties

    /// The string representation of this timecode, in the form `HH:MM:SS:FF`.
    ///
    /// At drop-frame rates, the separator before the frame component is `;`
    /// instead of `:`. If the sub-frame fraction component is nonzero, it is
    /// appended after a period, as in `01:00:03;12.50`.
    public var description: String {
        let frameSeparator = frameRate.isDropFrame ? ";" : ":"
        let result = Self._formatComponent(hour)
            + ":" + Self._formatComponent(minute)
            + ":" + Self._formatComponent(second)
            + frameSeparator + Self._formatComponent(frame)

        guard fraction > 0
        else { return result }

        return result + "." + Self._formatComponent(fraction)
    }
}

// MARK: - Equatable

extension SMPTETime: Equatable {
}

// MARK: - Hashable

extension SMPTETime: Hashable {
}

// MARK: - Sendable

extension SMPTETime: Sendable {
}
