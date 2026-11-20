//
//  TranscriptOCTests.swift
//  swift-cpace
//
//  Created by chloele on 2026-11-20.
//

import Testing
@testable import swift_cpace

@Test func `OC test vector 1`() async throws {
    let expectedValue = "6f6303323334065061727479420331323306506172747941"
    #expect(StringUtils.transcriptOC(Ya: Array("123".utf8),
                                     ADa: Array("PartyA".utf8),
                                     Yb: Array("234".utf8),
                                     ADb: Array("PartyB".utf8)) == hexStringToBytes(expectedValue))
}

@Test func `OC test vector 2`() async throws {
    let expectedValue = "6f63043334353606506172747941043233343506506172747942"
    #expect(StringUtils.transcriptOC(Ya: Array("3456".utf8),
                                     ADa: Array("PartyA".utf8),
                                     Yb: Array("2345".utf8),
                                     ADb: Array("PartyB".utf8)) == hexStringToBytes(expectedValue))
}
