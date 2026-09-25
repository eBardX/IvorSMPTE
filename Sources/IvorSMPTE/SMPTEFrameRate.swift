// © 2025–2026 John Gary Pusey (see LICENSE.md)

public import XestiNumbers

/// A SMPTE frame rate.
public enum SMPTEFrameRate {

    /// 23.976 (24000/1001) frames per second.
    case fps23976

    /// 24 frames per second.
    case fps24

    /// 25 frames per second.
    case fps25

    /// 29.97 (30000/1001) frames per second (drop-frame).
    case fps2997

    /// 29.97 (30000/1001) frames per second (non-drop-frame).
    case fps2997NonDrop

    /// 30 frames per second.
    case fps30

    /// 50 frames per second.
    case fps50

    /// 59.94 (60000/1001) frames per second (drop-frame).
    case fps5994

    /// 59.94 (60000/1001) frames per second (non-drop-frame).
    case fps5994NonDrop

    /// 60 frames per second.
    case fps60
}

// MARK: -

extension SMPTEFrameRate {

    // MARK: Public Initializers

    /// Creates a new `SMPTEFrameRate` instance by parsing its string
    /// representation, or `nil` if the string does not name a frame rate.
    ///
    /// - Parameter string: The string representation of the frame rate (as
    ///                     produced by `description`).
    public init?(string: String) {
        guard let frameRate = Self.allCases.first(where: { $0.description == string })
        else { return nil }

        self = frameRate
    }

    // MARK: Public Instance Properties

    /// The number of frames in one day (24 hours) of timecode at this frame
    /// rate.
    ///
    /// For drop-frame rates, this accounts for the frame numbers that
    /// drop-frame timecode skips.
    public var framesPerDay: UInt {
        (uintValue * 86_400) - (droppedFramesPerMinute * 9 * 144)
    }

    /// A Boolean value indicating whether this frame rate uses drop-frame
    /// timecode.
    ///
    /// Drop-frame timecode skips frame numbers at the start of every minute
    /// except minutes 0, 10, 20, 30, 40, and 50, so that timecode stays in step
    /// with real time: frame numbers 0 and 1 at 29.97 frames per second, and 0
    /// through 3 at 59.94 frames per second.
    public var isDropFrame: Bool {
        droppedFramesPerMinute > 0
    }

    /// The exact frame rate in frames per second.
    ///
    /// For the NTSC-derived rates, this is an exact rational value, such as
    /// 30000/1001 for 29.97 frames per second.
    public var numberValue: Number {
        switch self {
        case .fps23976:
            Number(numerator: 24_000,
                   denominator: 1_001)

        case .fps2997,
             .fps2997NonDrop:
            Number(numerator: 30_000,
                   denominator: 1_001)

        case .fps5994,
             .fps5994NonDrop:
            Number(numerator: 60_000,
                   denominator: 1_001)

        case .fps24,
             .fps25,
             .fps30,
             .fps50,
             .fps60:
            Number(uintValue)
        }
    }

    /// The nominal integer frame rate: the number of frame numbers in each
    /// second of timecode (24, 25, 30, 50, or 60).
    public var uintValue: UInt {
        switch self {
        case .fps24,
             .fps23976:
            24

        case .fps25:
            25

        case .fps30,
             .fps2997,
             .fps2997NonDrop:
            30

        case .fps50:
            50

        case .fps60,
             .fps5994,
             .fps5994NonDrop:
            60
        }
    }

    // MARK: Internal Instance Properties

    internal var droppedFramesPerMinute: UInt {
        switch self {
        case .fps2997:
            2

        case .fps5994:
            4

        default:
            0
        }
    }
}

// MARK: - CaseIterable

extension SMPTEFrameRate: CaseIterable {
}

// MARK: - CustomStringConvertible

extension SMPTEFrameRate: CustomStringConvertible {

    // MARK: Public Instance Properties

    /// The string representation of this frame rate: the number of frames per
    /// second, followed by `DF` for the drop-frame rates, as in `25`,
    /// `29.97DF`, or `59.94`.
    public var description: String {
        switch self {
        case .fps23976:
            "23.976"

        case .fps24:
            "24"

        case .fps25:
            "25"

        case .fps2997:
            "29.97DF"

        case .fps2997NonDrop:
            "29.97"

        case .fps30:
            "30"

        case .fps50:
            "50"

        case .fps5994:
            "59.94DF"

        case .fps5994NonDrop:
            "59.94"

        case .fps60:
            "60"
        }
    }
}

// MARK: - Equatable

extension SMPTEFrameRate: Equatable {
}

// MARK: - Hashable

extension SMPTEFrameRate: Hashable {
}

// MARK: - Sendable

extension SMPTEFrameRate: Sendable {
}
