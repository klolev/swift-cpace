//
//  CPace+PendingConfirmation.swift
//  swift-cpace
//
//  Created by chloele on 2026-10-29.
//

extension CPace {
    public struct PendingConfirmation: ~Copyable {
        private let hash: Hash
        let isk: [UInt8]
        private let key: [UInt8]
        private let peerMessage: [UInt8]
        
        public let tag: [UInt8]
        
        public enum ConfirmationError: Error {
            case confirmationFailed
        }
        
        init(hash: Hash, sid: [UInt8], isk: [UInt8], Y: [UInt8], AD: [UInt8], peerY: [UInt8], peerAD: [UInt8]) {
            self.hash = hash
            self.isk = isk
            self.key = hash.hash(Array("CPaceMac".utf8) + sid + isk)
            self.peerMessage = StringUtils.lvCat(peerY, peerAD)
            self.tag = hash.authenticationCode(
                key,
                StringUtils.lvCat(Y, AD)
            )
        }

        public consuming func confirm(peerTag: [UInt8], info: [UInt8]) throws -> [UInt8] {
            guard hash.isValidAuthenticationCode(key, peerMessage, peerTag) else {
                throw ConfirmationError.confirmationFailed
            }
            
            return hash.keyDerivationFunction(isk, info)
        }
    }
}
