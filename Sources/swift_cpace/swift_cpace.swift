import CryptoKit
import Clibsodium

public enum CPace {
    public struct Group: Sendable {
        let dsi: [UInt8]
        let fieldSizeBytes: Int
        let groupSizeBits: Int
        let identity: [UInt8]
        let elementDerivation: @Sendable ([UInt8]) -> [UInt8]
        let sampleScalar: @Sendable () -> [UInt8]
        let scalarMult: @Sendable ([UInt8], [UInt8]) -> [UInt8]?
        let scalarMultVfy: @Sendable ([UInt8], [UInt8]) -> [UInt8]
    }
    
    static func calculateGenerator(group: Group, hash: Hash, prs: [UInt8], ci: [UInt8], sid: [UInt8]) -> [UInt8] {
        let generatorString = generatorString(dsi: group.dsi, prs: prs, ci: ci, sid: sid, sInBytes: hash.blockSize)
        let hashed = hash.hash(generatorString)
        precondition(hashed.count == 2 * group.fieldSizeBytes)
        return group.elementDerivation(hashed)
    }
    
    /// Concat all input fields with prepended length information.
    /// Add zero padding in the first hash block after DSI and PRS.
    static func generatorString(dsi: [UInt8], prs: [UInt8], ci: [UInt8], sid: [UInt8], sInBytes: Int) -> [UInt8] {
        let zeroPaddingLength = max(0, sInBytes - 1 - StringUtils.prependLength(data: prs).count - StringUtils.prependLength(data: dsi).count)
        return StringUtils.lvCat(dsi, prs, [UInt8](repeating: 0, count: zeroPaddingLength), ci, sid)
    }
}
