struct Base64 {
    static let encodingTable: [UInt8] = [
        .period, .forwardSlash, .A, .B, .C, .D, .E, .F, .G, .H, .I, .J, .K,
        .L, .M, .N, .O, .P, .Q, .R, .S, .T, .U, .V, .W, .X,
        .Y, .Z, .a, .b, .c, .d, .e, .f, .g, .h, .i, .j, .k,
        .l, .m, .n, .o, .p, .q, .r, .s, .t, .u, .v, .w, .x,
        .y, .z, .zero, .one, .two, .three, .four, .five, .six, .seven, .eight, .nine
    ]

    static let decodingTable: [UInt8]  = [
        .max, .max, .max, .max, .max, .max, .max, .max, .max, .max,
        .max, .max, .max, .max, .max, .max, .max, .max, .max, .max,
        .max, .max, .max, .max, .max, .max, .max, .max, .max, .max,
        .max, .max, .max, .max, .max, .max, .max, .max, .max, .max,
        .max, .max, .max, .max, .max, .max,  0,  1, 54, 55,
        56, 57, 58, 59, 60, 61, 62, 63, .max, .max,
        .max, .max, .max, .max, .max,  2,  3,  4,  5,  6,
        7,  8,  9, 10, 11, 12, 13, 14, 15, 16,
        17, 18, 19, 20, 21, 22, 23, 24, 25, 26,
        27, .max, .max, .max, .max, .max, .max, 28, 29, 30,
        31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
        41, 42, 43, 44, 45, 46, 47, 48, 49, 50,
        51, 52, 53, .max, .max, .max, .max, .max
    ]

    static func encode(_ bytes: [UInt8], count: UInt) -> [UInt8] {
        if bytes.count == 0 || count == 0 {
            return []
        }

        var len: Int = numericCast(count)
        if len > bytes.count {
            len = bytes.count
        }

        var offset: Int = 0
        var c1: UInt8
        var c2: UInt8
        var result = [UInt8]()
        result.reserveCapacity(24)

        while offset < len {
            c1 = bytes[offset] & 0xff
            offset = offset &+ 1
            result.append(encodingTable[numericCast((c1 >> 2) & 0x3f)])
            c1 = (c1 & 0x03) << 4
            if offset >= len {
                result.append(encodingTable[numericCast(c1 & 0x3f)])
                break
            }

            c2 = bytes[offset] & 0xff
            offset = offset &+ 1
            c1 |= (c2 >> 4) & 0x0f
            result.append(encodingTable[numericCast(c1 & 0x3f)])
            c1 = (c2 & 0x0f) << 2
            if offset >= len {
                result.append(encodingTable[numericCast(c1 & 0x3f)])
                break
            }

            c2 = bytes[offset] & 0xff
            offset = offset &+ 1
            c1 |= (c2 >> 6) & 0x03
            result.append(encodingTable[numericCast(c1 & 0x3f)])
            result.append(encodingTable[numericCast(c2 & 0x3f)])
        }

        return result
    }

    private static func char64of(_ x: UInt8) -> UInt8 {
        if x < 0 || x > 128 - 1 {
            return UInt8.max
        }
        return decodingTable[numericCast(x)]
    }

    static func decode(_ bytes: [UInt8], count: UInt) -> [UInt8] {
        let count: Int = numericCast(count)

        var off: Int = 0
        var olen: Int = 0
        var result = [UInt8](repeating: 0, count: count)
        result.reserveCapacity(count)

        var c1: UInt8
        var c2: UInt8
        var c3: UInt8
        var c4: UInt8
        var o: UInt8

        while off < bytes.count - 1 && olen < count {
            c1 = char64of(bytes[off])
            off = off &+ 1
            c2 = char64of(bytes[off])
            off = off &+ 1
            if c1 == UInt8.max || c2 == UInt8.max {
                break
            }

            o = c1 << 2
            o |= (c2 & 0x30) >> 4
            result[olen] = o
            olen = olen &+ 1
            if olen >= count || off >= bytes.count {
                break
            }

            c3 = char64of(bytes[numericCast(off)])
            off = off &+ 1

            if c3 == UInt8.max {
                break
            }

            o = (c2 & 0x0f) << 4
            o |= (c3 & 0x3c) >> 2
            result[olen] = o
            olen = olen &+ 1
            if olen >= count || off >= bytes.count {
                break
            }

            c4 = char64of(bytes[off])
            off = off &+ 1
            o = (c3 & 0x03) << 6
            o |= c4
            result[olen] = o
            olen = olen &+ 1
        }

        return result[0..<olen].array
    }
}