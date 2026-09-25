// © 2025–2026 John Gary Pusey (see LICENSE.md)

/// A SMPTE timecode value specifying a point in time.
public struct SMPTETime {

    // MARK: Public Initializers

    /// Creates a new `SMPTETime` instance with the provided components,
    /// or `nil` if any component is out of range for the given frame rate.
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
              (0..<100).contains(fraction)
        else { return nil }

        self.fraction = fraction
        self.frame = frame
        self.frameRate = frameRate
        self.hour = hour
        self.minute = minute
        self.second = second
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

// MARK: - Equatable

extension SMPTETime: Equatable {
}

// MARK: - Hashable

extension SMPTETime: Hashable {
}

// MARK: - Sendable

extension SMPTETime: Sendable {
}
