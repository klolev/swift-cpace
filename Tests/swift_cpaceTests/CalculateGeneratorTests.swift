//
//  CalculateGeneratorTests.swift
//  swift-cpace
//
//  Created by chloele on 2026-10-29.
//

import Testing
@testable import swift_cpace

@Test func `B.3.1.  Test vectors for calculate_generator with group ristretto255`() async throws {
    let hash = CPace.Hash.Sha512
    let group = CPace.Group.Ristretto255
    let prs = Array("Password".utf8)
    let ci = hexStringToBytes("0b415f696e69746961746f720b425f726573706f6e646572")
    let sid = hexStringToBytes("7e4b4791d6a8ef019b936c79fb7f2c57")
    
    let generatorString = CPace.generatorString(dsi: group.dsi, prs: prs, ci: ci, sid: sid, sInBytes: hash.blockSize)
    let expectedValue = "11435061636552697374726574746f3235350850617373776f72646400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000180b415f696e69746961746f720b425f726573706f6e646572107e4b4791d6a8ef019b936c79fb7f2c57"
    #expect(generatorString == hexStringToBytes(expectedValue))
    
    let hashed = hash.hash(generatorString)
    let expectedHash = "da6d3ddc8802fca9058755ffd3ebde08a9c2c74945901a258482a288b6663af06bf645c93cd1c51512307199c80e84908916d983b34af77205f90851a657ee27"
    #expect(hashed == hexStringToBytes(expectedHash))
    
    let encodedGenerator = CPace.calculateGenerator(group: group, hash: hash, prs: prs, ci: ci, sid: sid)
    let expectedGenerator = "222b6b195fe84b1652badb6f6a3ae3d24341e7306967f0b8115b40d5698c7e56"
    #expect(encodedGenerator == hexStringToBytes(expectedGenerator))
}
