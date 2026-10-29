//
//  SessionTests.swift
//  swift-cpace
//
//  Created by chloele on 2026-10-29.
//

import Testing
import CryptoKit
@testable import swift_cpace

fileprivate let hash = CPace.Hash.Sha512
fileprivate let group = CPace.Group.Ristretto255
fileprivate let prs = Array("Password".utf8)
fileprivate let ci = hexStringToBytes("0b415f696e69746961746f720b425f726573706f6e646572")
fileprivate let sid = hexStringToBytes("7e4b4791d6a8ef019b936c79fb7f2c57")
fileprivate let ADa = Array("ADa".utf8)
fileprivate let ya = hexStringToBytes("da3d23700a9e5699258aef94dc060dfda5ebb61f02a5ea77fad53f4ff0976d08")
fileprivate let ADb = Array("ADb".utf8)
fileprivate let yb = hexStringToBytes("d2316b454718c35362d83d69df6320f38578ed5984651435e2949762d900b80d")
fileprivate let Ya = hexStringToBytes("d6bac480f2c386c394efc7c47adb9925dcd2630b64f240c50f8d0eec482b9157")
fileprivate let Yb = hexStringToBytes("3ea7e0b19560d7c0b0f5734f63b955286dfa8232b5ebe63324e2d9e7433f7258")


@Test func `B.3.2.  Test vector for message from A`() async throws {
    let session = try CPace.Session(group: group, hash: hash, role: .initiator, scalar: ya, ad: ADa, prs: prs, ci: ci, sid: sid)
    let expectedYa = hexStringToBytes("d6bac480f2c386c394efc7c47adb9925dcd2630b64f240c50f8d0eec482b9157")
    
    #expect(session.Y == expectedYa)
}

@Test func `B.3.3.  Test vector for message from B`() async throws {
    let session = try CPace.Session(group: group, hash: hash, role: .responder, scalar: yb, ad: ADb, prs: prs, ci: ci, sid: sid)
    let expectedYb = hexStringToBytes("3ea7e0b19560d7c0b0f5734f63b955286dfa8232b5ebe63324e2d9e7433f7258")
    
    #expect(session.Y == expectedYb)
}

@Test func `B.3.4.  Test vector for secret points K`() async throws {

    let expectedK = hexStringToBytes("80b69a8a76457ab6a4d7f887a4bf6b55a2f80ac19c333f917a05fc9887c8b40f")
    
    #expect(group.scalarMultVfy(ya, Yb) == expectedK)
    #expect(group.scalarMultVfy(yb, Ya) == expectedK)
}

@Test func `B.3.5.  Test vector for ISK calculation initiator/responder`() async throws {
    let Ya = hexStringToBytes("d6bac480f2c386c394efc7c47adb9925dcd2630b64f240c50f8d0eec482b9157")
    let Yb = hexStringToBytes("3ea7e0b19560d7c0b0f5734f63b955286dfa8232b5ebe63324e2d9e7433f7258")

    #expect(
        StringUtils.transcriptIR(Ya: Ya, ADa: ADa, Yb: Yb, ADb: ADb) ==
        hexStringToBytes("20d6bac480f2c386c394efc7c47adb9925dcd2630b64f240c50f8d0eec482b915703414461203ea7e0b19560d7c0b0f5734f63b955286dfa8232b5ebe63324e2d9e7433f725803414462")
    )
    
    let sessionA = try CPace.Session(group: group, hash: hash, role: .initiator, scalar: ya, ad: ADa, prs: prs, ci: ci, sid: sid)
    let confirmA = try sessionA.finish(peerY: Yb, peerAD: ADb)
    let tagA = confirmA.tag
    let sessionB = try CPace.Session(group: group, hash: hash, role: .responder, scalar: yb, ad: ADb, prs: prs, ci: ci, sid: sid)
    let confirmB = try sessionB.finish(peerY: Ya, peerAD: ADa)
    let iskA = confirmA.isk
    let iskB = confirmB.isk
    _ = try confirmA.confirm(peerTag: confirmB.tag, info: Array("test".utf8))
    _ = try confirmB.confirm(peerTag: tagA, info: Array("test".utf8))
    let expected = "b69effbf61b51d56401c0f65601abe428de8206feaaf0e32198896dcae7b35cd2b38950a39dfd5d4a79164614c2984f7daa460b588c1e80c3fa2068af7900447"
    #expect(iskA == hexStringToBytes(expected))
    #expect(iskA == iskB)
}

@Test func `B.3.11.  Invalid inputs for scalar_mult_vfy`() async throws {
    let s = hexStringToBytes("7cd0e075fa7955ba52c02759a6c90dbbfc10e6d40aea8d283e407d88cf538a05")
    let Y_i1 = hexStringToBytes("2b3c6b8c4f3800e7aef6864025b4ed79bd599117e427c41bd47d93d654b4a51c")
    let Y_i2 = group.identity
    #expect(group.scalarMultVfy(s, Y_i1) == group.scalarMultVfy(s, Y_i2))
    #expect(group.scalarMultVfy(s, Y_i1) == group.identity)
}

@Test func `mismatched prs`() async throws {
    let a = try CPace.Session(group: group, hash: hash, role: .initiator, scalar: ya, ad: ADa,
                                  prs: prs, ci: ci, sid: sid)
    let b = try CPace.Session(group: group, hash: hash, role: .responder, scalar: yb, ad: ADb,
                              prs: Array("Passw0rd".utf8), ci: ci, sid: sid)
    let (aY, bY) = (a.Y, b.Y)

    #expect(aY == Ya)
    #expect(bY != Yb)

    let confirmA = try a.finish(peerY: bY, peerAD: ADb)
    let confirmB = try b.finish(peerY: aY, peerAD: ADa)
    let tagA = confirmA.tag
    let tagB = confirmB.tag
    
    expectConfirmationFails(confirmA, peerTag: tagB)
    expectConfirmationFails(confirmB, peerTag: tagA)
}

@Test func `tampered AD`() async throws {
    let sessionA = try CPace.Session(group: group, hash: hash, role: .initiator, scalar: ya, ad: ADa, prs: prs, ci: ci, sid: sid)
    let sessionB = try CPace.Session(group: group, hash: hash, role: .responder, scalar: yb, ad: ADb, prs: prs, ci: ci, sid: sid)
    
    let confirmA = try sessionA.finish(peerY: Yb, peerAD: ADb)
    let confirmB = try sessionB.finish(peerY: Ya, peerAD: ADb)
    let tagA = confirmA.tag
    let tagB = confirmB.tag
    
    expectConfirmationFails(confirmA, peerTag: tagB)
    expectConfirmationFails(confirmB, peerTag: tagA)
}

@Test func `honest exchange confirms`() throws {
    let a = try CPace.Session(group: group, hash: hash, role: .initiator, scalar: ya, ad: ADa,
                              prs: prs, ci: ci, sid: sid)
    let b = try CPace.Session(group: group, hash: hash, role: .responder, scalar: yb, ad: ADb,
                              prs: prs, ci: ci, sid: sid)
    let (aY, bY) = (a.Y, b.Y)

    let pendingA = try a.finish(peerY: bY, peerAD: ADb)
    let pendingB = try b.finish(peerY: aY, peerAD: ADa)
    let (tagA, tagB) = (pendingA.tag, pendingB.tag)
    let (iskA, iskB) = (pendingA.isk, pendingB.isk)

    _ = try pendingA.confirm(peerTag: tagB, info: Array("test".utf8))
    _ = try pendingB.confirm(peerTag: tagA, info: Array("test".utf8))
    #expect(iskA == hexStringToBytes("b69effbf61b51d56401c0f65601abe428de8206feaaf0e32198896dcae7b35cd2b38950a39dfd5d4a79164614c2984f7daa460b588c1e80c3fa2068af7900447"))
    #expect(iskA == iskB)
}

@Test func `confirm derives HKDF key from ISK`() throws {
    let a = try CPace.Session(group: group, hash: hash, role: .initiator, scalar: ya, ad: ADa, prs: prs, ci: ci, sid: sid)
    let b = try CPace.Session(group: group, hash: hash, role: .responder, scalar: yb, ad: ADb, prs: prs, ci: ci, sid: sid)
    let pendingA = try a.finish(peerY: Yb, peerAD: ADb)
    let pendingB = try b.finish(peerY: Ya, peerAD: ADa)
    let (tagA, tagB) = (pendingA.tag, pendingB.tag)

    let info = Array("test".utf8)
    let keyA = try pendingA.confirm(peerTag: tagB, info: info)
    let keyB = try pendingB.confirm(peerTag: tagA, info: info)

    let expectedISK = hexStringToBytes("b69effbf61b51d56401c0f65601abe428de8206feaaf0e32198896dcae7b35cd2b38950a39dfd5d4a79164614c2984f7daa460b588c1e80c3fa2068af7900447")
    let expected = HKDF<SHA512>.deriveKey(inputKeyMaterial: SymmetricKey(data: expectedISK),
                  
                                          info: info, outputByteCount: 32)
    #expect(keyA == expected.withUnsafeBytes(Array.init))
    #expect(keyB == expected.withUnsafeBytes(Array.init))
}

fileprivate func expectConfirmationFails(_ pending: consuming CPace.PendingConfirmation,
                                         peerTag: [UInt8],
                                         sourceLocation: SourceLocation = #_sourceLocation) {
    do {
        _ = try pending.confirm(peerTag: peerTag, info: Array("test".utf8))
        Issue.record("expected confirmation to fail", sourceLocation: sourceLocation)
    } catch CPace.PendingConfirmation.ConfirmationError.confirmationFailed {
        // expected
    } catch {
        Issue.record("unexpected error: \(error)", sourceLocation: sourceLocation)
    }
}
