// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorSMPTE
import Testing
import XestiNumbers

struct SMPTEFrameRateTests {
}

// MARK: -

extension SMPTEFrameRateTests {
    @Test
    func allCases() {
        let allCases = SMPTEFrameRate.allCases

        #expect(allCases.count == 12)
        #expect(Set(allCases).count == 12)
    }

    @Test
    func description() {
        #expect(SMPTEFrameRate.fps23976.description == "23.976")
        #expect(SMPTEFrameRate.fps24.description == "24")
        #expect(SMPTEFrameRate.fps25.description == "25")
        #expect(SMPTEFrameRate.fps2997Drop.description == "29.97DF")
        #expect(SMPTEFrameRate.fps2997.description == "29.97")
        #expect(SMPTEFrameRate.fps30.description == "30")
        #expect(SMPTEFrameRate.fps30Drop.description == "30DF")
        #expect(SMPTEFrameRate.fps50.description == "50")
        #expect(SMPTEFrameRate.fps5994Drop.description == "59.94DF")
        #expect(SMPTEFrameRate.fps5994.description == "59.94")
        #expect(SMPTEFrameRate.fps60.description == "60")
        #expect(SMPTEFrameRate.fps60Drop.description == "60DF")
    }

    @Test
    func droppedFramesPerMinute() {
        #expect(SMPTEFrameRate.fps2997Drop.droppedFramesPerMinute == 2)
        #expect(SMPTEFrameRate.fps5994Drop.droppedFramesPerMinute == 4)
        #expect(SMPTEFrameRate.fps30Drop.droppedFramesPerMinute == 2)
        #expect(SMPTEFrameRate.fps60Drop.droppedFramesPerMinute == 4)

        for frameRate in SMPTEFrameRate.allCases where !frameRate.isDropFrame {
            #expect(frameRate.droppedFramesPerMinute == 0)
        }
    }

    @Test
    func equality() {
        #expect(SMPTEFrameRate.fps24 == .fps24)
    }

    @Test
    func framesPerDay() {
        #expect(SMPTEFrameRate.fps24.framesPerDay == 24 * 86_400)
        #expect(SMPTEFrameRate.fps25.framesPerDay == 25 * 86_400)
        #expect(SMPTEFrameRate.fps2997Drop.framesPerDay == (30 * 86_400) - (2 * ((24 * 60) - (24 * 6))))
        #expect(SMPTEFrameRate.fps30.framesPerDay == 30 * 86_400)
        #expect(SMPTEFrameRate.fps30Drop.framesPerDay == SMPTEFrameRate.fps2997Drop.framesPerDay)
        #expect(SMPTEFrameRate.fps23976.framesPerDay == 24 * 86_400)
        #expect(SMPTEFrameRate.fps2997.framesPerDay == 30 * 86_400)
        #expect(SMPTEFrameRate.fps50.framesPerDay == 50 * 86_400)
        #expect(SMPTEFrameRate.fps5994Drop.framesPerDay == (60 * 86_400) - (4 * ((24 * 60) - (24 * 6))))
        #expect(SMPTEFrameRate.fps5994.framesPerDay == 60 * 86_400)
        #expect(SMPTEFrameRate.fps60.framesPerDay == 60 * 86_400)
        #expect(SMPTEFrameRate.fps60Drop.framesPerDay == SMPTEFrameRate.fps5994Drop.framesPerDay)
    }

    @Test
    func hashable() {
        let set: Set<SMPTEFrameRate> = [.fps30, .fps30, .fps2997Drop]

        #expect(set.count == 2)
    }

    @Test
    func inequality_sameNominalRate() {
        #expect(SMPTEFrameRate.fps30 != .fps2997Drop)
        #expect(SMPTEFrameRate.fps30 != .fps30Drop)
        #expect(SMPTEFrameRate.fps30Drop != .fps2997Drop)
        #expect(SMPTEFrameRate.fps60Drop != .fps5994Drop)
    }

    @Test
    func init_string_alternateName() {
        #expect(SMPTEFrameRate(string: "23.98") == .fps23976)
    }

    @Test
    func init_string_invalid() {
        #expect(SMPTEFrameRate(string: "") == nil)
        #expect(SMPTEFrameRate(string: "29.97 DF") == nil)
        #expect(SMPTEFrameRate(string: "48") == nil)
    }

    @Test
    func init_string_lowercaseSuffix() {
        #expect(SMPTEFrameRate(string: "29.97df") == nil)
        #expect(SMPTEFrameRate(string: "30df") == nil)
    }

    @Test(arguments: SMPTEFrameRate.allCases)
    func init_string_roundTrip(frameRate: SMPTEFrameRate) {
        #expect(SMPTEFrameRate(string: frameRate.description) == frameRate)
    }

    @Test
    func isDropFrame() {
        #expect(!SMPTEFrameRate.fps24.isDropFrame)
        #expect(!SMPTEFrameRate.fps25.isDropFrame)
        #expect(SMPTEFrameRate.fps2997Drop.isDropFrame)
        #expect(!SMPTEFrameRate.fps30.isDropFrame)
        #expect(SMPTEFrameRate.fps30Drop.isDropFrame)
        #expect(!SMPTEFrameRate.fps23976.isDropFrame)
        #expect(!SMPTEFrameRate.fps2997.isDropFrame)
        #expect(!SMPTEFrameRate.fps50.isDropFrame)
        #expect(SMPTEFrameRate.fps5994Drop.isDropFrame)
        #expect(!SMPTEFrameRate.fps5994.isDropFrame)
        #expect(!SMPTEFrameRate.fps60.isDropFrame)
        #expect(SMPTEFrameRate.fps60Drop.isDropFrame)
    }

    @Test
    func numberValue() {
        #expect(SMPTEFrameRate.fps23976.numberValue == Number(numerator: 24_000, denominator: 1_001))
        #expect(SMPTEFrameRate.fps24.numberValue == 24)
        #expect(SMPTEFrameRate.fps25.numberValue == 25)
        #expect(SMPTEFrameRate.fps2997Drop.numberValue == Number(numerator: 30_000, denominator: 1_001))
        #expect(SMPTEFrameRate.fps2997.numberValue == Number(numerator: 30_000, denominator: 1_001))
        #expect(SMPTEFrameRate.fps30.numberValue == 30)
        #expect(SMPTEFrameRate.fps30Drop.numberValue == 30)
        #expect(SMPTEFrameRate.fps50.numberValue == 50)
        #expect(SMPTEFrameRate.fps5994Drop.numberValue == Number(numerator: 60_000, denominator: 1_001))
        #expect(SMPTEFrameRate.fps5994.numberValue == Number(numerator: 60_000, denominator: 1_001))
        #expect(SMPTEFrameRate.fps60.numberValue == 60)
        #expect(SMPTEFrameRate.fps60Drop.numberValue == 60)
    }

    @Test(arguments: SMPTEFrameRate.allCases)
    func numberValue_isExact(frameRate: SMPTEFrameRate) {
        #expect(frameRate.numberValue.isExact)
    }

    @Test
    func uintValue_fps24() {
        #expect(SMPTEFrameRate.fps24.uintValue == 24)
    }

    @Test
    func uintValue_fps25() {
        #expect(SMPTEFrameRate.fps25.uintValue == 25)
    }

    @Test
    func uintValue_fps2997Drop() {
        #expect(SMPTEFrameRate.fps2997Drop.uintValue == 30)
    }

    @Test
    func uintValue_fps30() {
        #expect(SMPTEFrameRate.fps30.uintValue == 30)
    }

    @Test
    func uintValue_otherRates() {
        #expect(SMPTEFrameRate.fps23976.uintValue == 24)
        #expect(SMPTEFrameRate.fps2997.uintValue == 30)
        #expect(SMPTEFrameRate.fps30Drop.uintValue == 30)
        #expect(SMPTEFrameRate.fps50.uintValue == 50)
        #expect(SMPTEFrameRate.fps5994Drop.uintValue == 60)
        #expect(SMPTEFrameRate.fps5994.uintValue == 60)
        #expect(SMPTEFrameRate.fps60.uintValue == 60)
        #expect(SMPTEFrameRate.fps60Drop.uintValue == 60)
    }
}
