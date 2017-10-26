module demo;

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
