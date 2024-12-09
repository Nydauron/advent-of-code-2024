const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub fn main() !void {
    const data = @embedFile("data/day05.txt");
    const part1Res = part1(data) catch |err| {
        std.debug.panic("{!}\n", .{err});
    };
    print("part 1: {}\n", .{part1Res});
    const part2Res = part2(data) catch |err| {
        std.debug.panic("{!}\n", .{err});
    };
    print("part 2: {}\n", .{part2Res});
}
const ParsingError = error{
    TooManySections,
    NoPipeFound,
};

const Ordering = struct {
    less: u64,
    greater: u64,
};

const LookupKey = struct {
    a: u64,
    b: u64,

    fn new(a: u64, b: u64) LookupKey {
        var key = LookupKey{
            .a = a,
            .b = b,
        };
        if (key.a > key.b) {
            std.mem.swap(u64, &key.a, &key.b);
        }
        return key;
    }
};

fn part1(data: []const u8) !u64 {
    var sections = std.mem.splitSequence(u8, std.mem.trim(u8, data, "\n"), "\n\n");

    const orderingRulesStr = sections.next().?;
    const updateListStr = sections.next().?;

    if (sections.next() != null) {
        return ParsingError.TooManySections;
    }

    var orderingRulesStrIter = std.mem.splitScalar(u8, orderingRulesStr, '\n');
    var orderLookup = std.AutoHashMap(LookupKey, Ordering).init(std.heap.page_allocator);
    defer orderLookup.deinit();

    while (orderingRulesStrIter.next()) |ruleStr| {
        const pipeIdxOpt = std.mem.indexOf(u8, ruleStr, "|");

        if (pipeIdxOpt) |pipeIdx| {
            const smallWeightStr = ruleStr[0..pipeIdx];
            const bigWeightStr = ruleStr[pipeIdx + 1 ..];

            const smallWeight = try std.fmt.parseInt(u64, smallWeightStr, 10);
            const bigWeight = try std.fmt.parseInt(u64, bigWeightStr, 10);

            const key = LookupKey.new(smallWeight, bigWeight);
            try orderLookup.put(key, Ordering{
                .less = smallWeight,
                .greater = bigWeight,
            });
        } else {
            return ParsingError.NoPipeFound;
        }
    }

    const cmpLessThan = struct {
        pub fn cmp(lookup: *std.AutoHashMap(LookupKey, Ordering), a: u64, b: u64) bool {
            const key = LookupKey.new(a, b);
            if (lookup.get(key)) |order| {
                return order.less == a and order.greater == b;
            } else {
                std.debug.panic("could not find {any} in lookup table\n", .{key});
            }
        }
    }.cmp;

    var total: u64 = 0;
    var updateStrIter = std.mem.splitScalar(u8, updateListStr, '\n');

    while (updateStrIter.next()) |updateStr| {
        var updateNumbers = std.mem.splitScalar(u8, updateStr, ',');
        var numbers = std.ArrayList(u64).init(std.heap.page_allocator);
        defer numbers.deinit();

        while (updateNumbers.next()) |numStr| {
            const num = try std.fmt.parseInt(u64, numStr, 10);
            try numbers.append(num);
        }

        // check if update is in order
        if (std.sort.isSorted(u64, numbers.items, &orderLookup, cmpLessThan)) {
            total += numbers.items[numbers.items.len / 2];
        }
    }

    return total;
}

fn part2(data: []const u8) !u64 {
    var sections = std.mem.splitSequence(u8, std.mem.trim(u8, data, "\n"), "\n\n");

    const orderingRulesStr = sections.next().?;
    const updateListStr = sections.next().?;

    if (sections.next() != null) {
        return ParsingError.TooManySections;
    }

    var orderingRulesStrIter = std.mem.splitScalar(u8, orderingRulesStr, '\n');
    var orderLookup = std.AutoHashMap(LookupKey, Ordering).init(std.heap.page_allocator);
    defer orderLookup.deinit();

    while (orderingRulesStrIter.next()) |ruleStr| {
        const pipeIdxOpt = std.mem.indexOf(u8, ruleStr, "|");

        if (pipeIdxOpt) |pipeIdx| {
            const smallWeightStr = ruleStr[0..pipeIdx];
            const bigWeightStr = ruleStr[pipeIdx + 1 ..];

            const smallWeight = try std.fmt.parseInt(u64, smallWeightStr, 10);
            const bigWeight = try std.fmt.parseInt(u64, bigWeightStr, 10);

            const key = LookupKey.new(smallWeight, bigWeight);
            try orderLookup.put(key, Ordering{
                .less = smallWeight,
                .greater = bigWeight,
            });
        } else {
            return ParsingError.NoPipeFound;
        }
    }

    const cmpLessThan = struct {
        pub fn cmp(lookup: *std.AutoHashMap(LookupKey, Ordering), a: u64, b: u64) bool {
            const key = LookupKey.new(a, b);
            if (lookup.get(key)) |order| {
                return order.less == a and order.greater == b;
            } else {
                std.debug.panic("could not find {any} in lookup table\n", .{key});
            }
        }
    }.cmp;

    var total: u64 = 0;
    var updateStrIter = std.mem.splitScalar(u8, updateListStr, '\n');

    while (updateStrIter.next()) |updateStr| {
        var updateNumbers = std.mem.splitScalar(u8, updateStr, ',');
        var numbers = std.ArrayList(u64).init(std.heap.page_allocator);
        defer numbers.deinit();

        while (updateNumbers.next()) |numStr| {
            const num = try std.fmt.parseInt(u64, numStr, 10);
            try numbers.append(num);
        }

        // check if update is in order
        if (!std.sort.isSorted(u64, numbers.items, &orderLookup, cmpLessThan)) {
            std.mem.sort(u64, numbers.items, &orderLookup, cmpLessThan);
            total += numbers.items[numbers.items.len / 2];
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
