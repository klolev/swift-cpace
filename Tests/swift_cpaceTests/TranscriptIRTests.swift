//
//  TranscriptIRTests.swift
//  swift-cpace
//
//  Created by chloele on 2026-10-28.
//

import Testing
@testable import swift_cpace

@Test func `test vector 1`() async throws {
    let expectedValue = "03313233065061727479410332333406506172747942"
    #expect(StringUtils.transcriptIR(Ya: Array("123".utf8),
                                     ADa: Array("PartyA".utf8),
                                     Yb: Array("234".utf8),
                                     ADb: Array("PartyB".utf8)) == hexStringToBytes(expectedValue))
}

@Test func `test vector 2`() async throws {
    let expectedValue = "043334353606506172747941043233343506506172747942"
    #expect(StringUtils.transcriptIR(Ya: Array("3456".utf8),
                                     ADa: Array("PartyA".utf8),
                                     Yb: Array("2345".utf8),
                                     ADb: Array("PartyB".utf8)) == hexStringToBytes(expectedValue))
}
