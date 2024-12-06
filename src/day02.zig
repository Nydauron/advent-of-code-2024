const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub fn main() !void {
    const data = @embedFile("data/day02.txt");
    print("part 1: {}\n", .{part1(data)});
}
const Direction = enum(u1) {
    increasing,
    decreasing,
};

fn isSafeSnapshot(currentNumber: u64, prevNumber: ?u64, ordering: ?Direction) bool {
    const minDiff = 1;
    const maxDiff = 3;
    if (prevNumber) |p| {
        if (ordering) |o| {
            switch (o) {
                Direction.increasing => {
                    return (p + minDiff <= currentNumber) and (p + maxDiff >= currentNumber);
                },
                Direction.decreasing => {
                    return (p - minDiff >= currentNumber) and (p - maxDiff <= currentNumber);
                },
            }
        } else {
            return ((p + minDiff <= currentNumber) and (p + maxDiff >= currentNumber)) or ((p - minDiff >= currentNumber) and (p - maxDiff <= currentNumber));
        }
    }
    return true;
}

fn part1(data: []const u8) u64 {
    var lines = std.mem.splitScalar(u8, data, '\n');

    var safeReportCount: u64 = 0;
    while (lines.next()) |line| {
        if (std.mem.eql(u8, line, "")) {
            break;
        }
        var numbers = std.mem.splitScalar(u8, line, ' ');

        var currentNumber: ?u64 = null;
        var ordering: ?Direction = null;
        var isSafe = true;
        while (numbers.next()) |num_str| {
            const num = std.fmt.parseInt(u64, num_str, 10) catch |err| {
                std.debug.panic("String cannot be parsed as number: \"{s}\" {any}", .{ line, err });
            };

            if (isSafeSnapshot(num, currentNumber, ordering)) {
                if (currentNumber) |lastNum| {
                    if (ordering == null) {
                        ordering = switch (lastNum < num) {
                            true => Direction.increasing,
                            false => Direction.decreasing,
                        };
                    }
                }
                currentNumber = num;
            } else {
                isSafe = false;
                break;
            }
        }
        if (isSafe) {
            safeReportCount += 1;
        }
    }

    return safeReportCount;
}

// Useful stdlib functions
const tokenizeAny = std.mem.tokenizeAny;
const tokenizeSeq = std.mem.tokenizeSequence;
const tokenizeSca = std.mem.tokenizeScalar;
const splitAny = std.mem.splitAny;
const splitSeq = std.mem.splitSequence;
const splitSca = std.mem.splitScalar;
const indexOf = std.mem.indexOfScalar;
const indexOfAny = std.mem.indexOfAny;
const indexOfStr = std.mem.indexOfPosLinear;
const lastIndexOf = std.mem.lastIndexOfScalar;
const lastIndexOfAny = std.mem.lastIndexOfAny;
const lastIndexOfStr = std.mem.lastIndexOfLinear;
const trim = std.mem.trim;
const sliceMin = std.mem.min;
const sliceMax = std.mem.max;

const parseInt = std.fmt.parseInt;
const parseFloat = std.fmt.parseFloat;

const print = std.debug.print;
const assert = std.debug.assert;

const sort = std.sort.block;
const asc = std.sort.asc;
const desc = std.sort.desc;

// Generated from template/template.zig.
// Run `zig build generate` to update.
// Only unmodified days will be updated.
