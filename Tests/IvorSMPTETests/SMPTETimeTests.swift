// © 2025–2026 John Gary Pusey (see LICENSE.md)

@testable import IvorSMPTE
import Testing
import XestiNumbers

struct SMPTETimeTests {
}

// MARK: -

extension SMPTETimeTests {
    @Test
    func description() {
        #expect(SMPTETime(frameRate: .fps25, hour: 1, minute: 0, second: 3, frame: 12, subframe: 0)?.description == "01:00:03:12")
        #expect(SMPTETime(frameRate: .fps2997Drop, hour: 1, minute: 0, second: 3, frame: 12, subframe: 0)?.description == "01:00:03;12")
        #expect(SMPTETime(frameRate: .fps5994Drop, hour: 0, minute: 0, second: 0, frame: 7, subframe: 5)?.description == "00:00:00;07.05")
        #expect(SMPTETime(frameRate: .fps2997, hour: 23, minute: 59, second: 59, frame: 29, subframe: 99)?.description == "23:59:59:29.99")
        #expect(SMPTETime(frameRate: .fps30Drop, hour: 0, minute: 1, second: 0, frame: 2, subframe: 0)?.description == "00:01:00;02")
        #expect(SMPTETime(frameRate: .fps60Drop, hour: 0, minute: 1, second: 0, frame: 4, subframe: 0)?.description == "00:01:00;04")
    }

    @Test
    func elapsedSeconds() {
        let time1 = SMPTETime(frameRate: .fps25, hour: 1, minute: 0, second: 0, frame: 0, subframe: 0)
        let time2 = SMPTETime(frameRate: .fps25, hour: 0, minute: 0, second: 0, frame: 1, subframe: 50)
        let time3 = SMPTETime(frameRate: .fps2997Drop, hour: 0, minute: 0, second: 0, frame: 1, subframe: 0)
        let time4 = SMPTETime(frameRate: .fps2997Drop, hour: 0, minute: 10, second: 0, frame: 0, subframe: 0)
        let time5 = SMPTETime(frameRate: .fps2997, hour: 1, minute: 0, second: 0, frame: 0, subframe: 0)

        #expect(time1?.elapsedSeconds == 3_600)
        #expect(time2?.elapsedSeconds == SMPTEExactSeconds(Number(numerator: 3, denominator: 50)))
        #expect(time3?.elapsedSeconds == SMPTEExactSeconds(Number(numerator: 1_001, denominator: 30_000)))
        #expect(time4?.elapsedSeconds == SMPTEExactSeconds(Number(numerator: 17_982 * 1_001, denominator: 30_000)))
        #expect(time5?.elapsedSeconds == SMPTEExactSeconds(Number(numerator: 108_000 * 1_001, denominator: 30_000)))
    }

    @Test
    func elapsedSeconds_description() throws {
        let time = try #require(SMPTETime(string: "01:00:03;12", frameRate: .fps2997Drop))

        #expect(time.elapsedSeconds.numberValue.description == "18016999/5000")
    }

    @Test
    func elapsedSeconds_dropFrameAtTrueRate() throws {
        // At a true 30 fps, one hour of drop-frame timecode is 3.6 seconds short of one hour of real time.
        let time = try #require(SMPTETime(frameRate: .fps30Drop, hour: 1, minute: 0, second: 0, frame: 0, subframe: 0))

        #expect(time.elapsedSeconds == SMPTEExactSeconds(Number(numerator: 107_892, denominator: 30)))
        #expect(abs(time.elapsedSeconds.numberValue - 3_600) == Number(numerator: 18, denominator: 5))
    }

    @Test
    func elapsedSeconds_dropFrameTracksRealTime() throws {
        // One hour of drop-frame timecode is 3.6 ms short of one hour of real time.
        let time = try #require(SMPTETime(frameRate: .fps2997Drop, hour: 1, minute: 0, second: 0, frame: 0, subframe: 0))

        #expect(time.elapsedSeconds == SMPTEExactSeconds(Number(numerator: 107_892 * 1_001, denominator: 30_000)))
        #expect(abs(time.elapsedSeconds.numberValue - 3_600) == Number(numerator: 18, denominator: 5_000))
    }

    @Test(arguments: SMPTEFrameRate.allCases)
    func elapsedSeconds_roundTrip(frameRate: SMPTEFrameRate) throws {
        let lastFrameCount = frameRate.framesPerDay - 1

        for frameCount in Array(0..<2_000) + Array((lastFrameCount - 2_000)...lastFrameCount) {
            let time = try #require(SMPTETime(frameRate: frameRate, frameCount: frameCount, subframe: frameCount % 100))
            let roundTrip = SMPTETime(frameRate: frameRate, elapsedSeconds: time.elapsedSeconds)

            #expect(roundTrip == time)
        }
    }

    @Test
    func equality() {
        let time1 = SMPTETime(frameRate: .fps24, hour: 1, minute: 2, second: 3, frame: 4, subframe: 5)!  // swiftlint:disable:this force_unwrapping
        let time2 = SMPTETime(frameRate: .fps24, hour: 1, minute: 2, second: 3, frame: 4, subframe: 5)!  // swiftlint:disable:this force_unwrapping

        #expect(time1 == time2)
    }

    @Test
    func frameCount_fps2997Drop() {
        #expect(SMPTETime(frameRate: .fps2997Drop, hour: 0, minute: 0, second: 59, frame: 29, subframe: 0)?.frameCount == 1_799)
        #expect(SMPTETime(frameRate: .fps2997Drop, hour: 0, minute: 1, second: 0, frame: 2, subframe: 0)?.frameCount == 1_800)
        #expect(SMPTETime(frameRate: .fps2997Drop, hour: 0, minute: 10, second: 0, frame: 0, subframe: 0)?.frameCount == 17_982)
        #expect(SMPTETime(frameRate: .fps2997Drop, hour: 1, minute: 0, second: 0, frame: 0, subframe: 0)?.frameCount == 107_892)
        #expect(SMPTETime(frameRate: .fps2997Drop, hour: 23, minute: 59, second: 59, frame: 29, subframe: 0)?.frameCount == 2_589_407)
    }

    @Test
    func frameCount_fps30() {
        #expect(SMPTETime(frameRate: .fps30, hour: 0, minute: 1, second: 0, frame: 0, subframe: 0)?.frameCount == 1_800)
        #expect(SMPTETime(frameRate: .fps30, hour: 23, minute: 59, second: 59, frame: 29, subframe: 0)?.frameCount == 2_591_999)
    }

    @Test
    func frameCount_fps30Drop() {
        #expect(SMPTETime(frameRate: .fps30Drop, hour: 0, minute: 1, second: 0, frame: 2, subframe: 0)?.frameCount == 1_800)
        #expect(SMPTETime(frameRate: .fps30Drop, hour: 0, minute: 10, second: 0, frame: 0, subframe: 0)?.frameCount == 17_982)
        #expect(SMPTETime(frameRate: .fps30Drop, hour: 23, minute: 59, second: 59, frame: 29, subframe: 0)?.frameCount == 2_589_407)
    }

    @Test
    func frameCount_fps5994Drop() {
        #expect(SMPTETime(frameRate: .fps5994Drop, hour: 0, minute: 0, second: 59, frame: 59, subframe: 0)?.frameCount == 3_599)
        #expect(SMPTETime(frameRate: .fps5994Drop, hour: 0, minute: 1, second: 0, frame: 4, subframe: 0)?.frameCount == 3_600)
        #expect(SMPTETime(frameRate: .fps5994Drop, hour: 0, minute: 10, second: 0, frame: 0, subframe: 0)?.frameCount == 35_964)
        #expect(SMPTETime(frameRate: .fps5994Drop, hour: 23, minute: 59, second: 59, frame: 59, subframe: 0)?.frameCount == 5_178_815)
    }

    @Test
    func frameCount_fps60Drop() {
        #expect(SMPTETime(frameRate: .fps60Drop, hour: 0, minute: 1, second: 0, frame: 4, subframe: 0)?.frameCount == 3_600)
        #expect(SMPTETime(frameRate: .fps60Drop, hour: 0, minute: 10, second: 0, frame: 0, subframe: 0)?.frameCount == 35_964)
        #expect(SMPTETime(frameRate: .fps60Drop, hour: 23, minute: 59, second: 59, frame: 59, subframe: 0)?.frameCount == 5_178_815)
    }

    @Test(arguments: SMPTEFrameRate.allCases)
    func frameCount_roundTrip(frameRate: SMPTEFrameRate) throws {
        let lastFrameCount = frameRate.framesPerDay - 1

        for frameCount in Array(0..<40_000) + Array((lastFrameCount - 40_000)...lastFrameCount) {
            let time = try #require(SMPTETime(frameRate: frameRate, frameCount: frameCount, subframe: 0))

            #expect(time.frameCount == frameCount)
        }
    }

    @Test
    func hashable() {
        let time1 = SMPTETime(frameRate: .fps24, hour: 1, minute: 2, second: 3, frame: 4, subframe: 5)!  // swiftlint:disable:this force_unwrapping
        let time2 = SMPTETime(frameRate: .fps24, hour: 1, minute: 2, second: 3, frame: 4, subframe: 5)!  // swiftlint:disable:this force_unwrapping
        let set: Set<SMPTETime> = [time1, time2]

        #expect(set.count == 1)
    }

    @Test
    func inequality_differentFrameRate() {
        let time1 = SMPTETime(frameRate: .fps24, hour: 1, minute: 2, second: 3, frame: 4, subframe: 5)
        let time2 = SMPTETime(frameRate: .fps25, hour: 1, minute: 2, second: 3, frame: 4, subframe: 5)

        #expect(time1 != nil)
        #expect(time1 != time2)
    }

    @Test
    func inequality_differentSubframe() {
        let time1 = SMPTETime(frameRate: .fps24, hour: 1, minute: 2, second: 3, frame: 4, subframe: 5)!  // swiftlint:disable:this force_unwrapping
        let time2 = SMPTETime(frameRate: .fps24, hour: 1, minute: 2, second: 3, frame: 4, subframe: 6)!  // swiftlint:disable:this force_unwrapping

        #expect(time1 != time2)
    }

    @Test
    func init_elapsedSeconds() {
        let time = SMPTETime(frameRate: .fps25, elapsedSeconds: SMPTEExactSeconds(Number(numerator: 7_261, denominator: 2)))

        #expect(time.hour == 1)
        #expect(time.minute == 0)
        #expect(time.second == 30)
        #expect(time.frame == 12)
        #expect(time.subframe == 50)
    }

    @Test
    func init_elapsedSeconds_inexact() {
        let time = SMPTETime(frameRate: .fps30, elapsedSeconds: SMPTEExactSeconds(Number(1.0 / 3.0)))

        #expect(time.second == 0)
        #expect(time.frame == 10)
        #expect(time.subframe == 0)
    }

    @Test
    func init_elapsedSeconds_roundsToNearestHundredth() {
        // 1/2000 s is 1/80 frame at 25 fps, which rounds to 1/100 frame.
        let time = SMPTETime(frameRate: .fps25, elapsedSeconds: SMPTEExactSeconds(Number(numerator: 1, denominator: 2_000)))

        #expect(time.frame == 0)
        #expect(time.subframe == 1)
    }

    @Test
    func init_elapsedSeconds_wraps() {
        // One day plus one hour.
        let time = SMPTETime(frameRate: .fps25, elapsedSeconds: 90_000)

        #expect(time.hour == 1)
        #expect(time.minute == 0)
        #expect(time.frameCount == 90_000)
    }

    @Test
    func init_elapsedSeconds_wrapsAfterRounding() {
        // Just short of midnight rounds up to exactly one day, which wraps to zero.
        let time = SMPTETime(frameRate: .fps25, elapsedSeconds: SMPTEExactSeconds(Number(numerator: 86_400 * 100_000 - 1, denominator: 100_000)))

        #expect(time.frameCount == 0)
        #expect(time.subframe == 0)
    }

    @Test
    func init_frameCount_fps2997Drop() {
        let time = SMPTETime(frameRate: .fps2997Drop, frameCount: 1_800, subframe: 50)

        #expect(time?.hour == 0)
        #expect(time?.minute == 1)
        #expect(time?.second == 0)
        #expect(time?.frame == 2)
        #expect(time?.subframe == 50)
    }

    @Test
    func init_frameCount_fps2997Drop_tenthMinute() {
        let time = SMPTETime(frameRate: .fps2997Drop, frameCount: 17_982, subframe: 0)

        #expect(time?.minute == 10)
        #expect(time?.second == 0)
        #expect(time?.frame == 0)
    }

    @Test
    func init_frameCount_fps30() {
        let time = SMPTETime(frameRate: .fps30, frameCount: 1_800, subframe: 0)

        #expect(time?.minute == 1)
        #expect(time?.second == 0)
        #expect(time?.frame == 0)
    }

    @Test
    func init_frameCount_fps5994Drop() {
        let time = SMPTETime(frameRate: .fps5994Drop, frameCount: 3_600, subframe: 0)

        #expect(time?.minute == 1)
        #expect(time?.second == 0)
        #expect(time?.frame == 4)
    }

    @Test
    func init_frameCount_invalid() {
        #expect(SMPTETime(frameRate: .fps25, frameCount: SMPTEFrameRate.fps25.framesPerDay, subframe: 0) == nil)
        #expect(SMPTETime(frameRate: .fps25, frameCount: 0, subframe: 100) == nil)
    }

    @Test
    func init_invalid_droppedFrame() {
        #expect(SMPTETime(frameRate: .fps2997Drop, hour: 0, minute: 1, second: 0, frame: 0, subframe: 0) == nil)
        #expect(SMPTETime(frameRate: .fps2997Drop, hour: 0, minute: 1, second: 0, frame: 1, subframe: 0) == nil)
        #expect(SMPTETime(frameRate: .fps2997Drop, hour: 0, minute: 59, second: 0, frame: 1, subframe: 0) == nil)
    }

    @Test
    func init_invalid_droppedFrame_fps30Drop() {
        #expect(SMPTETime(frameRate: .fps30Drop, hour: 0, minute: 1, second: 0, frame: 1, subframe: 0) == nil)
        #expect(SMPTETime(frameRate: .fps30Drop, hour: 0, minute: 1, second: 0, frame: 2, subframe: 0) != nil)
        #expect(SMPTETime(frameRate: .fps30, hour: 0, minute: 1, second: 0, frame: 0, subframe: 0) != nil)
    }

    @Test
    func init_invalid_droppedFrame_fps5994Drop() {
        #expect(SMPTETime(frameRate: .fps5994Drop, hour: 0, minute: 1, second: 0, frame: 3, subframe: 0) == nil)
        #expect(SMPTETime(frameRate: .fps5994Drop, hour: 0, minute: 1, second: 0, frame: 4, subframe: 0) != nil)
        #expect(SMPTETime(frameRate: .fps5994Drop, hour: 0, minute: 10, second: 0, frame: 0, subframe: 0) != nil)
        #expect(SMPTETime(frameRate: .fps5994, hour: 0, minute: 1, second: 0, frame: 0, subframe: 0) != nil)
        #expect(SMPTETime(frameRate: .fps2997, hour: 0, minute: 1, second: 0, frame: 0, subframe: 0) != nil)
    }

    @Test
    func init_invalid_droppedFrame_fps60Drop() {
        #expect(SMPTETime(frameRate: .fps60Drop, hour: 0, minute: 1, second: 0, frame: 3, subframe: 0) == nil)
        #expect(SMPTETime(frameRate: .fps60Drop, hour: 0, minute: 1, second: 0, frame: 4, subframe: 0) != nil)
        #expect(SMPTETime(frameRate: .fps60, hour: 0, minute: 1, second: 0, frame: 0, subframe: 0) != nil)
    }

    @Test
    func init_invalid_frame() {
        #expect(SMPTETime(frameRate: .fps24, hour: 0, minute: 0, second: 0, frame: 24, subframe: 0) == nil)
    }

    @Test
    func init_invalid_frame_fps50() {
        #expect(SMPTETime(frameRate: .fps50, hour: 0, minute: 0, second: 0, frame: 49, subframe: 0) != nil)
        #expect(SMPTETime(frameRate: .fps50, hour: 0, minute: 0, second: 0, frame: 50, subframe: 0) == nil)
    }

    @Test
    func init_invalid_hour() {
        #expect(SMPTETime(frameRate: .fps24, hour: 24, minute: 0, second: 0, frame: 0, subframe: 0) == nil)
    }

    @Test
    func init_invalid_minute() {
        #expect(SMPTETime(frameRate: .fps24, hour: 0, minute: 60, second: 0, frame: 0, subframe: 0) == nil)
    }

    @Test
    func init_invalid_second() {
        #expect(SMPTETime(frameRate: .fps24, hour: 0, minute: 0, second: 60, frame: 0, subframe: 0) == nil)
    }

    @Test
    func init_invalid_subframe() {
        #expect(SMPTETime(frameRate: .fps24, hour: 0, minute: 0, second: 0, frame: 0, subframe: 100) == nil)
    }

    @Test
    func init_string() {
        let time = SMPTETime(string: "01:02:03:04", frameRate: .fps25)

        #expect(time == SMPTETime(frameRate: .fps25, hour: 1, minute: 2, second: 3, frame: 4, subframe: 0))
    }

    @Test
    func init_string_dropFrame() {
        let expected = SMPTETime(frameRate: .fps2997Drop, hour: 1, minute: 0, second: 3, frame: 12, subframe: 50)

        #expect(SMPTETime(string: "01:00:03;12.50", frameRate: .fps2997Drop) == expected)
        #expect(SMPTETime(string: "01:00:03:12.50", frameRate: .fps2997Drop) == expected)
    }

    @Test
    func init_string_invalid() {
        #expect(SMPTETime(string: "", frameRate: .fps25) == nil)
        #expect(SMPTETime(string: "1:02:03:04", frameRate: .fps25) == nil)
        #expect(SMPTETime(string: "01:02:03;04", frameRate: .fps25) == nil)
        #expect(SMPTETime(string: "01-02-03-04", frameRate: .fps25) == nil)
        #expect(SMPTETime(string: "01:02:03:25", frameRate: .fps25) == nil)
        #expect(SMPTETime(string: "01:02:03:04.5", frameRate: .fps25) == nil)
        #expect(SMPTETime(string: "01:02:03:04,50", frameRate: .fps25) == nil)
        #expect(SMPTETime(string: "0a:02:03:04", frameRate: .fps25) == nil)
        #expect(SMPTETime(string: "01:02:03:٠٤", frameRate: .fps25) == nil)
        #expect(SMPTETime(string: "00:01:00;00", frameRate: .fps2997Drop) == nil)
    }

    @Test
    func init_string_invalidSubframe() {
        #expect(SMPTETime(string: "01:02:03:04.ab", frameRate: .fps25) == nil)
        #expect(SMPTETime(string: "01:02:03:04.-1", frameRate: .fps25) == nil)
        #expect(SMPTETime(string: "01:02:03:04:50", frameRate: .fps25) == nil)
    }

    @Test
    func init_string_outOfRange() {
        #expect(SMPTETime(string: "24:00:00:00", frameRate: .fps25) == nil)
        #expect(SMPTETime(string: "00:60:00:00", frameRate: .fps25) == nil)
        #expect(SMPTETime(string: "00:00:60:00", frameRate: .fps25) == nil)
    }

    @Test(arguments: SMPTEFrameRate.allCases)
    func init_string_roundTrip(frameRate: SMPTEFrameRate) throws {
        for frameCount in stride(from: 0, to: frameRate.framesPerDay, by: 997) {
            let time = try #require(SMPTETime(frameRate: frameRate, frameCount: frameCount, subframe: frameCount % 100))

            #expect(SMPTETime(string: time.description, frameRate: frameRate) == time)
        }
    }

    @Test
    func init_string_subframe() {
        let time = SMPTETime(string: "01:02:03:04.99", frameRate: .fps25)

        #expect(time == SMPTETime(frameRate: .fps25, hour: 1, minute: 2, second: 3, frame: 4, subframe: 99))
    }

    @Test
    func init_validDropFrameBoundaries() {
        #expect(SMPTETime(frameRate: .fps2997Drop, hour: 0, minute: 0, second: 0, frame: 0, subframe: 0) != nil)
        #expect(SMPTETime(frameRate: .fps2997Drop, hour: 0, minute: 1, second: 0, frame: 2, subframe: 0) != nil)
        #expect(SMPTETime(frameRate: .fps2997Drop, hour: 0, minute: 1, second: 1, frame: 0, subframe: 0) != nil)
        #expect(SMPTETime(frameRate: .fps2997Drop, hour: 0, minute: 10, second: 0, frame: 0, subframe: 0) != nil)
        #expect(SMPTETime(frameRate: .fps30, hour: 0, minute: 1, second: 0, frame: 0, subframe: 0) != nil)
    }

    @Test
    func init_validValues() {
        let time = SMPTETime(frameRate: .fps24,
                             hour: 12,
                             minute: 34,
                             second: 56,
                             frame: 12,
                             subframe: 34)

        #expect(time != nil)
        #expect(time?.frameRate == .fps24)
        #expect(time?.hour == 12)
        #expect(time?.minute == 34)
        #expect(time?.second == 56)
        #expect(time?.frame == 12)
        #expect(time?.subframe == 34)
    }
}
