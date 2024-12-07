const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub fn main() !void {
    const data = @embedFile("data/day03.txt");
    print("part 1: {}\n", .{part1(data)});
}

fn part1(data: []const u8) u64 {
    var total: u64 = 0;
    var dataSlice = data[0..];
    const mulPrefixStr = "mul(";
    while (dataSlice.len >= mulPrefixStr.len) {
        defer dataSlice = dataSlice[1..];
        const isMul = std.mem.eql(u8, dataSlice[0..mulPrefixStr.len], mulPrefixStr);

        if (!isMul) {
            continue;
        }
        dataSlice = dataSlice[mulPrefixStr.len..];
        if (dataSlice.len == 0) {
            continue;
        }
        const commaIdx = std.mem.indexOf(u8, dataSlice, ",");
        const closingParenIdx = std.mem.indexOf(u8, dataSlice, ")");

        if (commaIdx) |cIdx| {
            const lhsNumber = std.fmt.parseInt(u64, dataSlice[0..cIdx], 10) catch {
                continue;
            };
            if (closingParenIdx) |pIdx| {
                const rhsNumber = std.fmt.parseInt(u64, dataSlice[cIdx + 1 .. pIdx], 10) catch {
                    continue;
                };
                total += lhsNumber * rhsNumber;
            }
        }
    }

    return total;
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
