//
//  StringUtils.swift
//  swift-cpace
//
//  Created by chloele on 2026-10-28.
//

public enum StringUtils {
    /// prepend LEB128 encoding of length
    static func prependLength(data: [UInt8]) -> [UInt8] {
        var length = data.count
        var encoded = [UInt8]()
        repeat {
            if length < 128 {
                encoded.append(UInt8(length))
            } else {
                encoded.append(UInt8(length & 0x7f) | 0x80)
            }
            
            length >>= 7
        } while length != 0
        
        return encoded + data
    }

    public static func lvCat(_ parts: [UInt8]...) -> [UInt8] {
        parts.flatMap(prependLength(data:))
    }
    
    static func transcriptIR(Ya: [UInt8], ADa: [UInt8], Yb: [UInt8], ADb: [UInt8]) -> [UInt8] {
        lvCat(Ya, ADa) + lvCat(Yb, ADb)
    }
}
