//
//  PrependLengthTests.swift
//  swift-cpace
//
//  Created by chloele on 2026-10-28.
//

import Testing
@testable import swift_cpace

func hexStringToBytes(_ hexString: String) -> [UInt8] {
    stride(from: 0, to: hexString.count, by: 2)
        .compactMap {
            let index = hexString.index(hexString.startIndex, offsetBy: $0)
            let end = hexString.index(index, offsetBy: 2)
            return UInt8("\(hexString[index..<end])", radix: 16)
        }
}

@Test func `empty string`() async throws {
    #expect(StringUtils.prependLength(data: []) == [0])
}

@Test func `four bytes`() async throws {
    #expect(StringUtils.prependLength(data: Array("1234".utf8)) == [0x04,0x31,0x32,0x33,0x34])
}

@Test func `127 bytes`() async throws {
    let input: [UInt8] = Array((0..<127))
    let expectedValue = "7f000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f404142434445464748494a4b4c4d4e4f505152535455565758595a5b5c5d5e5f606162636465666768696a6b6c6d6e6f707172737475767778797a7b7c7d7e"
    
    #expect(StringUtils.prependLength(data: input) == hexStringToBytes(expectedValue))
}

@Test func `128 bytes`() async throws {
    let input: [UInt8] = Array((0..<128))
    let expectedValue = "8001000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f404142434445464748494a4b4c4d4e4f505152535455565758595a5b5c5d5e5f606162636465666768696a6b6c6d6e6f707172737475767778797a7b7c7d7e7f"
    
    #expect(StringUtils.prependLength(data: input) == hexStringToBytes(expectedValue))
}
