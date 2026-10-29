//
//  CPace+Session.swift
//  swift-cpace
//
//  Created by chloele on 2026-10-28.
//

extension CPace {
    public struct Session: ~Copyable {
        private let group: Group
        private let hash: Hash
        private let role: Role
        
        /// session identifier
        private let sid: [UInt8]
        
        private let y: [UInt8]
        public let Y: [UInt8]
        public let AD: [UInt8]
        
        public enum SessionError: Error {
            case scalarMultError
            case identity
        }
        
        public enum Role {
            case initiator
            case responder
        }
        
        public init(group: Group,
                    hash: Hash,
                    role: Role,
                    scalar: [UInt8]? = nil,
                    ad: [UInt8],
                    prs: [UInt8],
                    ci: [UInt8],
                    sid: [UInt8]) throws {
            self.group = group
            self.hash = hash
            self.role = role
            self.sid = sid
            self.AD = ad
            let g = CPace.calculateGenerator(group: group, hash: hash, prs: prs, ci: ci, sid: sid)
            self.y = scalar ?? group.sampleScalar()
            guard let Y = group.scalarMult(y, g) else {
                throw SessionError.scalarMultError
            }
            self.Y = Y
        }
        
        public consuming func finish(peerY: [UInt8], peerAD: [UInt8]) throws -> PendingConfirmation {
            let K = group.scalarMultVfy(y, peerY)
            guard K != group.identity else {
                throw SessionError.identity
            }
            
            let firstPart = StringUtils.lvCat(group.dsi + Array("_ISK".utf8), sid, K)
            let secondPart = switch role {
            case .initiator:
                StringUtils.transcriptIR(Ya: Y, ADa: AD, Yb: peerY, ADb: peerAD)
            case .responder:
                StringUtils.transcriptIR(Ya: peerY, ADa: peerAD, Yb: Y, ADb: AD)
            }
            
            let isk = hash.hash(firstPart + secondPart)
            
            return PendingConfirmation(hash: hash, sid: sid, isk: isk, Y: Y, AD: AD, peerY: peerY, peerAD: peerAD)
        }
    }
}
