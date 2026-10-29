//
//  Group+Ristretto255.swift
//  swift-cpace
//
//  Created by chloele on 2026-10-28.
//

import CryptoKit
import Clibsodium

extension CPace.Group {
    public static var Ristretto255: CPace.Group {
        guard sodium_init() >= 0 else { fatalError("libsodium init failed") }
        let pointBytes  = Int(crypto_core_ristretto255_BYTES)
        let scalarBytes = Int(crypto_core_ristretto255_SCALARBYTES)
        let identity = [UInt8](repeating: 0, count: pointBytes)

        return .init(dsi: Array("CPaceRistretto255".utf8), fieldSizeBytes: pointBytes, groupSizeBits: 252, identity: identity) {
            var g = [UInt8](repeating: 0, count: pointBytes)
            crypto_core_ristretto255_from_hash(&g, $0)
            return g
        } sampleScalar: {
            var y = [UInt8](repeating: 0, count: scalarBytes)
            crypto_core_ristretto255_scalar_random(&y)
            return y
        } scalarMult: { y, g in
            guard y.count == scalarBytes, g.count == pointBytes else {
                return nil
            }
            
            var Y = [UInt8](repeating: 0, count: pointBytes)
            guard crypto_scalarmult_ristretto255(&Y, y, g) == 0 else { return nil }
            return Y
        } scalarMultVfy: { y, X in
            guard y.count == scalarBytes, X.count == pointBytes else { return identity }
            var K = [UInt8](repeating: 0, count: pointBytes)
            guard crypto_scalarmult_ristretto255(&K, y, X) == 0 else { return identity }
            return K
        }
    }
}
