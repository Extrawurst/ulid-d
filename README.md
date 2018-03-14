# ulid-d [![Build Status](https://travis-ci.org/Extrawurst/ulid-d.svg?branch=master)](https://travis-ci.org/Extrawurst/ulid-d)
ULID implementation in D

# usage
```
import std.stdio;

import ulid.ulid;

void main()
{
    // simple usage but shows different time portions
    writefln("simple: %s", ULID.generate());
    writefln("simple: %s", ULID.generate().toString());

    // set your own time stamp
    writefln("custom time: %s", ULID.generate(1469918176385).toString());
    writefln("custom time: %s", ULID.generate(1469918176385).toString());
    writefln("custom time: %s <- time portion", ULID.generate(1469918176385).toString()[0 .. 10]);

    static ubyte randomByte()
    {
        return 4;
    }

    // now we define all components manually by also overriding the random generator
    writefln("all custom: %s", ULID.generate(1469918176385, &randomByte).toString());
    writefln("all custom: %s", ULID.generate(1469918176385, &randomByte).toString());
}
```

see `source/demo.d`

# build demo

```
dub --config=demo
```

output:

```
simple: 7DFPGD9GPH2X5T9Y05S7EDW3N2
simple: 7DFPGDEC1JQC153KSP6VPEF27T
custom time: 01ARYZ6S410EHN4S8FDPCWWQ00
custom time: 01ARYZ6S413XBZ5V68XJJTV5FS
custom time: 01ARYZ6S41 <- time portion
all custom: 01ARYZ6S410G2081040G208104
all custom: 01ARYZ6S410G2081040G208104
```