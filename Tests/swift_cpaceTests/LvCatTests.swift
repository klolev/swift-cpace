//
//  LvCatTests.swift
//  swift-cpace
//
//  Created by chloele on 2026-10-28.
//

import Testing
@testable import swift_cpace

@Test func `test vector`() async throws {
    let expectedValue = "043132333401350003363738"
    #expect(StringUtils.lvCat(Array("1234".utf8),[0x35],[],Array("678".utf8)) == hexStringToBytes(expectedValue))
}
