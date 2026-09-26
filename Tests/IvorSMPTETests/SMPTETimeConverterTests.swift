// © 2026 John Gary Pusey (see LICENSE.md)

@testable import IvorSMPTE
import Testing
import XestiNumbers

struct SMPTETimeConverterTests {
}

// MARK: -

extension SMPTETimeConverterTests {
    @Test
    func equality() throws {
        let start = try #require(SMPTETime(string: "01:00:00:00", frameRate: .fps25))

        let tcconv1 = SMPTETimeConverter(startTime: start)
        let tcconv2 = SMPTETimeConverter(startTime: start)

        #expect(tcconv1 == tcconv2)
        #expect(tcconv1 != SMPTETimeConverter(frameRate: .fps25))
    }

    @Test
    func frameRate() throws {
        let start = try #require(SMPTETime(string: "01:00:00;00", frameRate: .fps2997Drop))

        #expect(SMPTETimeConverter(startTime: start).frameRate == .fps2997Drop)
        #expect(SMPTETimeConverter(frameRate: .fps50).frameRate == .fps50)
    }

    @Test
    func hashable() throws {
        let start = try #require(SMPTETime(string: "01:00:00:00", frameRate: .fps25))
        let set: Set<SMPTETimeConverter> = [SMPTETimeConverter(startTime: start),
                                            SMPTETimeConverter(startTime: start),
                                            SMPTETimeConverter(frameRate: .fps25)]

        #expect(set.count == 2)
    }

    @Test
    func init_frameRate_startsAtMidnight() {
        let tcconv = SMPTETimeConverter(frameRate: .fps24)

        #expect(tcconv.startTime.frameCount == 0)
        #expect(tcconv.startTime.subframe == 0)
        #expect(tcconv.smpteTime(at: 0).description == "00:00:00:00")
    }

    @Test
    func init_startTime() throws {
        let start = try #require(SMPTETime(string: "10:00:00;02.50", frameRate: .fps2997Drop))

        #expect(SMPTETimeConverter(startTime: start).startTime == start)
    }

    @Test
    func seconds() throws {
        let start = try #require(SMPTETime(string: "01:00:00:00", frameRate: .fps25))
        let tcconv = SMPTETimeConverter(startTime: start)
        let later = try #require(SMPTETime(string: "01:00:01:12.50", frameRate: .fps25))

        #expect(tcconv.seconds(at: start) == 0)
        #expect(tcconv.seconds(at: later) == SMPTEExactSeconds(Number(numerator: 3, denominator: 2)))
    }

    @Test
    func seconds_beforeStartWraps() throws {
        let start = try #require(SMPTETime(string: "00:59:58:00", frameRate: .fps25))
        let tcconv = SMPTETimeConverter(startTime: start)
        let earlier = try #require(SMPTETime(string: "00:59:57:00", frameRate: .fps25))

        #expect(tcconv.seconds(at: earlier) == 86_399)
    }

    @Test
    func seconds_crossesMidnight() throws {
        let start = try #require(SMPTETime(string: "23:59:00:00", frameRate: .fps30))
        let tcconv = SMPTETimeConverter(startTime: start)
        let later = try #require(SMPTETime(string: "00:01:00:00", frameRate: .fps30))

        #expect(tcconv.seconds(at: later) == 120)
    }

    @Test
    func seconds_dropFrame() throws {
        let tcconv = SMPTETimeConverter(frameRate: .fps2997Drop)
        let time = try #require(SMPTETime(string: "00:00:00;01", frameRate: .fps2997Drop))

        // Exactly 1001/30000 seconds, with no rounding.
        #expect(tcconv.seconds(at: time) == SMPTEExactSeconds(Number(numerator: 1_001, denominator: 30_000)))
    }

    @Test
    func seconds_mismatchedFrameRateTraps() async {
        await #expect(processExitsWith: .failure) {
            let tcconv = SMPTETimeConverter(frameRate: .fps25)

            _ = tcconv.seconds(at: SMPTETime(frameRate: .fps24, elapsedSeconds: .zero))
        }
    }

    @Test(arguments: SMPTEFrameRate.allCases)
    func seconds_roundTrip(frameRate: SMPTEFrameRate) throws {
        let start = try #require(SMPTETime(frameRate: frameRate, frameCount: frameRate.framesPerDay / 3, subframe: 0))
        let tcconv = SMPTETimeConverter(startTime: start)

        for frameCount in stride(from: 0, to: frameRate.framesPerDay, by: 4_999) {
            let time = try #require(SMPTETime(frameRate: frameRate, frameCount: frameCount, subframe: frameCount % 100))

            #expect(tcconv.smpteTime(at: tcconv.seconds(at: time)) == time)
        }
    }

    @Test
    func smpteTime_dropFrame() {
        let tcconv = SMPTETimeConverter(frameRate: .fps2997Drop)

        // 60 seconds of real time is only 1,798.2 frames, so the timecode lags behind.
        #expect(tcconv.smpteTime(at: 60).description == "00:00:59;28.20")

        // Ten minutes of drop-frame timecode is exactly 17,982 frames.
        #expect(tcconv.smpteTime(at: SMPTEExactSeconds(Number(numerator: 17_982 * 1_001, denominator: 30_000))).description == "00:10:00;00")
    }

    @Test
    func smpteTime_withStartOffset() throws {
        let start = try #require(SMPTETime(string: "00:59:58:00", frameRate: .fps25))
        let tcconv = SMPTETimeConverter(startTime: start)

        #expect(tcconv.smpteTime(at: 0) == start)
        #expect(tcconv.smpteTime(at: 2).description == "01:00:00:00")
        #expect(tcconv.smpteTime(at: SMPTEExactSeconds(Number(numerator: 202, denominator: 100))).description == "01:00:00:00.50")
    }

    @Test
    func smpteTime_wrapsAfter24Hours() throws {
        let start = try #require(SMPTETime(string: "23:59:59:00", frameRate: .fps25))
        let tcconv = SMPTETimeConverter(startTime: start)

        #expect(tcconv.smpteTime(at: 2).description == "00:00:01:00")
    }
}
