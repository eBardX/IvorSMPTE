// © 2026 John Gary Pusey (see LICENSE.md)

import Foundation
@testable import IvorSMPTE
import Testing
import XestiNumbers

struct SMPTEExactSecondsTests {
}

// MARK: -

extension SMPTEExactSecondsTests {
    @Test
    func codable() throws {
        let original = SMPTEExactSeconds(Number(numerator: 1_001, denominator: 30_000))
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(SMPTEExactSeconds.self,
                                               from: data)

        #expect(decoded == original)
    }

    @Test
    func comparable() {
        let half: SMPTEExactSeconds = 0.5
        let otherHalf = SMPTEExactSeconds(Number(numerator: 1, denominator: 2))
        let one: SMPTEExactSeconds = 1

        #expect(half < one)
        #expect(!(one < half))
        #expect(!(half < otherHalf))
    }

    @Test
    func description() {
        #expect(SMPTEExactSeconds(Number(numerator: 3, denominator: 2)).description == "3/2")
    }

    @Test
    func equality() {
        #expect(SMPTEExactSeconds(0.5) == SMPTEExactSeconds(Number(numerator: 1, denominator: 2)))
        #expect(SMPTEExactSeconds(0.5) != .zero)
    }

    @Test
    func hashable() {
        let set: Set<SMPTEExactSeconds> = [0.5, SMPTEExactSeconds(Number(numerator: 1, denominator: 2)), 1]

        #expect(set.count == 2)
    }

    @Test
    func init_invalidTraps() async {
        await #expect(processExitsWith: .failure) {
            _ = SMPTEExactSeconds(Number(numerator: -1, denominator: 2))
        }
    }

    @Test
    func init_numberValue() {
        #expect(SMPTEExactSeconds(numberValue: Number(numerator: 3, denominator: 2))?.numberValue == Number(numerator: 3, denominator: 2))
    }

    @Test
    func init_numberValue_inexactBecomesExact() throws {
        let seconds = try #require(SMPTEExactSeconds(numberValue: Number(0.5)))

        #expect(seconds.numberValue.isExact)
        #expect(seconds.numberValue == Number(numerator: 1, denominator: 2))
    }

    @Test
    func init_numberValue_invalid() {
        #expect(SMPTEExactSeconds(numberValue: -1) == nil)
        #expect(SMPTEExactSeconds(numberValue: Number(numerator: -1, denominator: 2)) == nil)
        #expect(SMPTEExactSeconds(numberValue: .nan) == nil)
        #expect(SMPTEExactSeconds(numberValue: .positiveInfinity) == nil)
        #expect(SMPTEExactSeconds(numberValue: .negativeInfinity) == nil)
    }

    @Test
    func isValid() {
        #expect(SMPTEExactSeconds.isValid(0))
        #expect(SMPTEExactSeconds.isValid(Number(1.0 / 3.0)))
        #expect(!SMPTEExactSeconds.isValid(-1))
        #expect(!SMPTEExactSeconds.isValid(.nan))
        #expect(!SMPTEExactSeconds.isValid(.positiveInfinity))
    }

    @Test
    func literals() {
        let fromFloat: SMPTEExactSeconds = 1.5
        let fromInteger: SMPTEExactSeconds = 90

        #expect(fromFloat.numberValue.isExact)
        #expect(fromFloat.numberValue == Number(numerator: 3, denominator: 2))
        #expect(fromInteger.numberValue == 90)
    }

    @Test
    func zero() {
        #expect(SMPTEExactSeconds.zero.numberValue == 0)
    }
}
