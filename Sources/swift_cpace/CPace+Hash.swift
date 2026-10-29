//
//  CPace+Hash.swift
//  swift-cpace
//
//  Created by chloele on 2026-10-29.
//

import CryptoKit

extension CPace {
    public struct Hash: Sendable {
        let blockSize: Int
        let hash: @Sendable ([UInt8]) -> [UInt8]
        let authenticationCode: @Sendable ([UInt8], [UInt8]) -> [UInt8]
        let isValidAuthenticationCode: @Sendable ([UInt8], [UInt8], [UInt8]) -> Bool
        let keyDerivationFunction: @Sendable ([UInt8], [UInt8]) -> [UInt8]

        public static var Sha512: Hash {
            .init(blockSize: 128) {
                Array(SHA512.hash(data: $0))
            } authenticationCode: { key, value in
                Array(HMAC<SHA512>.authenticationCode(for: value, using: SymmetricKey(data: key)))
            } isValidAuthenticationCode: { key, message, tag in
                HMAC<SHA512>.isValidAuthenticationCode(
                    tag,
                    authenticating: message,
                    using: .init(data: key)
                )
            } keyDerivationFunction: { key, info in
                HKDF<SHA512>.deriveKey(inputKeyMaterial: .init(data: key), info: info, outputByteCount: 32)
                    .withUnsafeBytes(Array.init)
            }
        }
    }
    
}
