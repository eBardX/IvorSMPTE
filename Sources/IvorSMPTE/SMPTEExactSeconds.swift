// © 2026 John Gary Pusey (see LICENSE.md)

public import XestiNumbers

/// An exact, non-negative number of seconds.
///
/// The number of seconds is always an exact rational value. A finite
/// floating-point value is converted to the exact rational value it represents,
/// so no precision is lost; note, however, that a floating-point value such as
/// `0.1` is not exactly one tenth. Use `Number(numerator:denominator:)` to
/// express decimal fractions exactly.
public struct SMPTEExactSeconds {

    // MARK: Public Initializers

    /// Creates a new `SMPTEExactSeconds` instance from a number value, or
    /// `nil` if the number value is negative or is not a finite real number.
    ///
    /// - Parameter numberValue:    The number of seconds.
    public init?(numberValue: Number) {
        guard Self.isValid(numberValue)
        else { return nil }

        self.numberValue = numberValue.exact
    }

    // MARK: Public Instance Properties

    /// The exact rational number of seconds.
    public let numberValue: Number
}

// MARK: -

extension SMPTEExactSeconds {

    // MARK: Public Type Properties

    /// Zero seconds.
    public static let zero = Self(0)

    // MARK: Public Type Methods

    /// Returns a Boolean value indicating whether the given number is a valid
    /// number of seconds.
    ///
    /// - Parameter numberValue:    The number to validate.
    ///
    /// - Returns:  `true` if `numberValue` is rational (that is, a finite real
    ///             number) and non-negative; otherwise, `false`.
    public static func isValid(_ numberValue: Number) -> Bool {
        numberValue.isRational && !numberValue.isNegative
    }
}

// MARK: - NumberRepresentable

extension SMPTEExactSeconds: NumberRepresentable {
}
