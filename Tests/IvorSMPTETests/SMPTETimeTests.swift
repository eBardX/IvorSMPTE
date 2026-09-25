// © 2025–2026 John Gary Pusey (see LICENSE.md)

@testable import IvorSMPTE
import Testing

struct SMPTETimeTests {
}

// MARK: -

extension SMPTETimeTests {
    @Test
    func equality() {
        let time1 = SMPTETime(frameRate: .fps24, hour: 1, minute: 2, second: 3, frame: 4, fraction: 5)!  // swiftlint:disable:this force_unwrapping
        let time2 = SMPTETime(frameRate: .fps24, hour: 1, minute: 2, second: 3, frame: 4, fraction: 5)!  // swiftlint:disable:this force_unwrapping

        #expect(time1 == time2)
    }

    @Test
    func hashable() {
        let time1 = SMPTETime(frameRate: .fps24, hour: 1, minute: 2, second: 3, frame: 4, fraction: 5)!  // swiftlint:disable:this force_unwrapping
        let time2 = SMPTETime(frameRate: .fps24, hour: 1, minute: 2, second: 3, frame: 4, fraction: 5)!  // swiftlint:disable:this force_unwrapping
        let set: Set<SMPTETime> = [time1, time2]

        #expect(set.count == 1)
    }

    @Test
    func inequality_differentFraction() {
        let time1 = SMPTETime(frameRate: .fps24, hour: 1, minute: 2, second: 3, frame: 4, fraction: 5)!  // swiftlint:disable:this force_unwrapping
        let time2 = SMPTETime(frameRate: .fps24, hour: 1, minute: 2, second: 3, frame: 4, fraction: 6)!  // swiftlint:disable:this force_unwrapping

        #expect(time1 != time2)
    }

    @Test
    func init_invalid_fraction() {
        #expect(SMPTETime(frameRate: .fps24, hour: 0, minute: 0, second: 0, frame: 0, fraction: 100) == nil)
    }

    @Test
    func init_invalid_frame() {
        #expect(SMPTETime(frameRate: .fps24, hour: 0, minute: 0, second: 0, frame: 24, fraction: 0) == nil)
    }

    @Test
    func init_invalid_hour() {
        #expect(SMPTETime(frameRate: .fps24, hour: 24, minute: 0, second: 0, frame: 0, fraction: 0) == nil)
    }

    @Test
    func init_invalid_minute() {
        #expect(SMPTETime(frameRate: .fps24, hour: 0, minute: 60, second: 0, frame: 0, fraction: 0) == nil)
    }

    @Test
    func init_invalid_second() {
        #expect(SMPTETime(frameRate: .fps24, hour: 0, minute: 0, second: 60, frame: 0, fraction: 0) == nil)
    }

    @Test
    func init_validValues() {
        let time = SMPTETime(frameRate: .fps24,
                             hour: 12,
                             minute: 34,
                             second: 56,
                             frame: 12,
                             fraction: 34)

        #expect(time != nil)
        #expect(time?.frameRate == .fps24)
        #expect(time?.hour == 12)
        #expect(time?.minute == 34)
        #expect(time?.second == 56)
        #expect(time?.frame == 12)
        #expect(time?.fraction == 34)
    }
}
