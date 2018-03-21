/++
    see also:
        https://github.com/alizain/ulid (original ulid)
        https://github.com/suyash/ulid (c++ implementation of ulid, ulid-d is based on this)
+/
module ulid.ulid;

@safe:

/++
    ULID data type.

    see:
        https://github.com/alizain/ulid
+/
struct ULID
{
    /// data stores ulid elements
    /// 0..6 bytes make up the time stamp
    /// 6..16 bytes make up entropy (random) part
    ubyte[16] data;

    private void setTimePart()
    {
        import core.time : MonoTime;

        setTimePart(MonoTime.currTime.ticks);
    }

    private void setTimePart(long time) @nogc
    {
        data[0] = cast(ubyte)(time >> 40);
        data[1] = cast(ubyte)(time >> 32);
        data[2] = cast(ubyte)(time >> 24);
        data[3] = cast(ubyte)(time >> 16);
        data[4] = cast(ubyte)(time >> 8);
        data[5] = cast(ubyte)(time);
    }

    private void setEntropy()
    {
        import std.random : uniform;

        foreach (idx; 6 .. 16)
            data[idx] = uniform!ubyte;
    }

    private void setEntropy(ubyte function() @safe gen)
    {
        foreach (idx; 6 .. 16)
            data[idx] = gen();
    }

    private void setEntropy(ubyte delegate() @safe gen)
    {
        foreach (idx; 6 .. 16)
            data[idx] = gen();
    }

    /// allocation free string encoding
    void encode(ref char[26] dst) const @nogc
    {
        static string Encoding = "0123456789ABCDEFGHJKMNPQRSTVWXYZ";

        // 10 byte timestamp
        dst[0] = Encoding[(data[0] & 224) >> 5];
        dst[1] = Encoding[data[0] & 31];
        dst[2] = Encoding[(data[1] & 248) >> 3];
        dst[3] = Encoding[((data[1] & 7) << 2) | ((data[2] & 192) >> 6)];
        dst[4] = Encoding[(data[2] & 62) >> 1];
        dst[5] = Encoding[((data[2] & 1) << 4) | ((data[3] & 240) >> 4)];
        dst[6] = Encoding[((data[3] & 15) << 1) | ((data[4] & 128) >> 7)];
        dst[7] = Encoding[(data[4] & 124) >> 2];
        dst[8] = Encoding[((data[4] & 3) << 3) | ((data[5] & 224) >> 5)];
        dst[9] = Encoding[data[5] & 31];

        // 16 bytes of entropy
        dst[10] = Encoding[(data[6] & 248) >> 3];
        dst[11] = Encoding[((data[6] & 7) << 2) | ((data[7] & 192) >> 6)];
        dst[12] = Encoding[(data[7] & 62) >> 1];
        dst[13] = Encoding[((data[7] & 1) << 4) | ((data[8] & 240) >> 4)];
        dst[14] = Encoding[((data[8] & 15) << 1) | ((data[9] & 128) >> 7)];
        dst[15] = Encoding[(data[9] & 124) >> 2];
        dst[16] = Encoding[((data[9] & 3) << 3) | ((data[10] & 224) >> 5)];
        dst[17] = Encoding[data[10] & 31];
        dst[18] = Encoding[(data[11] & 248) >> 3];
        dst[19] = Encoding[((data[11] & 7) << 2) | ((data[12] & 192) >> 6)];
        dst[20] = Encoding[(data[12] & 62) >> 1];
        dst[21] = Encoding[((data[12] & 1) << 4) | ((data[13] & 240) >> 4)];
        dst[22] = Encoding[((data[13] & 15) << 1) | ((data[14] & 128) >> 7)];
        dst[23] = Encoding[(data[14] & 124) >> 2];
        dst[24] = Encoding[((data[14] & 3) << 3) | ((data[15] & 224) >> 5)];
        dst[25] = Encoding[data[15] & 31];
    }

    /// ditto, but allocates 
    string toString() const
    {
        char[26] chars;
        encode(chars);
        return cast(string) chars.idup;
    }

    /// creates ULID from a previously string encoded ULID
    static ULID fromString(string str) @nogc
    {
        static const ubyte[256] dec = [
            0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
            0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
            0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
            0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
            0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06,
            0x07, 0x08, 0x09, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x0A,
            0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10, 0x11, 0xFF, 0x12, 0x13, 0xFF,
            0x14, 0x15, 0xFF, 0x16, 0x17, 0x18, 0x19, 0x1A, 0xFF, 0x1B, 0x1C,
            0x1D, 0x1E, 0x1F, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
            0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
            0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
            0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
            0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
            0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
            0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
            0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
            0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
            0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
            0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
            0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
            0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
            0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
            0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
        ];

        ULID ulid;
        // timestamp
        ulid.data[0] = cast(ubyte)((dec[cast(int) str[0]] << 5) | dec[cast(int) str[1]]);
        ulid.data[1] = cast(ubyte)((dec[cast(int) str[2]] << 3) | (dec[cast(int) str[3]] >> 2));
        ulid.data[2] = cast(ubyte)((dec[cast(int) str[3]] << 6) | (
                dec[cast(int) str[4]] << 1) | (dec[cast(int) str[5]] >> 4));
        ulid.data[3] = cast(ubyte)((dec[cast(int) str[5]] << 4) | (dec[cast(int) str[6]] >> 1));
        ulid.data[4] = cast(ubyte)((dec[cast(int) str[6]] << 7) | (
                dec[cast(int) str[7]] << 2) | (dec[cast(int) str[8]] >> 3));
        ulid.data[5] = cast(ubyte)((dec[cast(int) str[8]] << 5) | dec[cast(int) str[9]]);

        // entropy
        ulid.data[6] = cast(ubyte)((dec[cast(int) str[10]] << 3) | (dec[cast(int) str[11]] >> 2));
        ulid.data[7] = cast(ubyte)((dec[cast(int) str[11]] << 6) | (
                dec[cast(int) str[12]] << 1) | (dec[cast(int) str[13]] >> 4));
        ulid.data[8] = cast(ubyte)((dec[cast(int) str[13]] << 4) | (dec[cast(int) str[14]] >> 1));
        ulid.data[9] = cast(ubyte)((dec[cast(int) str[14]] << 7) | (
                dec[cast(int) str[15]] << 2) | (dec[cast(int) str[16]] >> 3));
        ulid.data[10] = cast(ubyte)((dec[cast(int) str[16]] << 5) | dec[cast(int) str[17]]);
        ulid.data[11] = cast(ubyte)((dec[cast(int) str[18]] << 3) | (dec[cast(int) str[19]] >> 2));
        ulid.data[12] = cast(ubyte)((dec[cast(int) str[19]] << 6) | (
                dec[cast(int) str[20]] << 1) | (dec[cast(int) str[21]] >> 4));
        ulid.data[13] = cast(ubyte)((dec[cast(int) str[21]] << 4) | (dec[cast(int) str[22]] >> 1));
        ulid.data[14] = cast(ubyte)((dec[cast(int) str[22]] << 7) | (
                dec[cast(int) str[23]] << 2) | (dec[cast(int) str[24]] >> 3));
        ulid.data[15] = cast(ubyte)((dec[cast(int) str[24]] << 5) | dec[cast(int) str[25]]);
        return ulid;
    }

    ///
    unittest
    {
        import fluent.asserts;

        static ubyte gen()
        {
            return 4;
        }

        ULID decoded = ULID.fromString("01ARYZ6S410G2081040G208104");
        ULID.generate(1469918176385, &gen).should.equal(decoded);
    }

    /// uses std.random.uniform and core.time.MonoTime.currTime
    static ULID generate()
    {
        ULID ulid;
        ulid.setTimePart();
        ulid.setEntropy();
        return ulid;
    }

    ///
    unittest
    {
        import fluent.asserts;

        auto ulid1 = ULID.generate();
        auto ulid2 = ULID.generate();
        ulid1.should.not.equal(ulid2);

        ulid1.toString[0 .. 10].should.not.equal(ulid2.toString[0 .. 10]);
        ulid1.data[0 .. 6].should.not.equal(ulid2.data[0 .. 6]);
    }

    /// uses std.random.uniform
    static ULID generate(ulong seed)
    {
        ULID ulid;
        ulid.setTimePart(seed);
        ulid.setEntropy();
        return ulid;
    }

    ///
    unittest
    {
        import fluent.asserts;

        auto ulid1 = ULID.generate(1469918176385);
        auto ulid2 = ULID.generate(1469918176385);
        ulid1.toString[0 .. 10].should.equal("01ARYZ6S41");
        ulid2.toString[0 .. 10].should.equal(ulid1.toString[0 .. 10]);
        ulid1.should.not.equal(ulid2);
    }

    /// uses callback to set entropy
    static ULID generate(ulong seed, ubyte function() @safe gen)
    {
        ULID ulid;
        ulid.setTimePart(seed);
        ulid.setEntropy(gen);
        return ulid;
    }

    ///
    unittest
    {
        import fluent.asserts;

        static ubyte gen()
        {
            return 4;
        }

        //should return expected encoded time component result
        ULID.generate(1469918176385, &gen).toString.should.equal("01ARYZ6S410G2081040G208104");
    }

    /// ditto
    static ULID generate(ulong seed, ubyte delegate() @safe gen)
    {
        ULID ulid;
        ulid.setTimePart(seed);
        ulid.setEntropy(gen);
        return ulid;
    }

    ///
    unittest
    {
        import fluent.asserts;

        ubyte gen()
        {
            return 4;
        }

        //should return expected encoded time component result
        ULID.generate(1469918176385, &gen).toString.should.equal("01ARYZ6S410G2081040G208104");
    }
}

///
unittest
{
    import fluent.asserts;

    ULID.generate().toString.length.should.equal(26);

    //should return expected encoded time component result
    ULID.generate(1469918176385).toString[0 .. 10].should.equal("01ARYZ6S41");
}
