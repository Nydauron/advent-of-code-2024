const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub fn main() !void {
    const data = @embedFile("data/day01.txt");
    print("part 1: {}\n", .{
        part1(data),
    });
    print("part 2: {}\n", .{
        part2(data),
    });
}

pub fn part1(data: []const u8) u64 {
    var lhs = std.ArrayList(i64).init(std.heap.page_allocator);
    var rhs = std.ArrayList(i64).init(std.heap.page_allocator);

    var lines = std.mem.splitScalar(u8, data, '\n');

    while (lines.next()) |line| {
        var num_arr = std.mem.split(u8, line, "   ");

        const lhs_str_opt = num_arr.next();
        const rhs_str_opt = num_arr.next();
        if (lhs_str_opt) |lhs_str| {
            if (lhs_str.len == 0) {
                break;
            }
            if (rhs_str_opt) |rhs_str| {
                if (rhs_str.len == 0) {
                    break;
                }
                const lhs_num = std.fmt.parseInt(i64, lhs_str, 10) catch {
                    @panic("LHS was not a num");
                };
                const rhs_num = std.fmt.parseInt(i64, rhs_str, 10) catch {
                    @panic("RHS was not a num");
                };
                lhs.append(lhs_num) catch {
                    @panic("Could not add to LHS");
                };
                rhs.append(rhs_num) catch {
                    @panic("Could not add to RHS");
                };
            }
        }
    }

    sort(i64, lhs.items, {}, std.sort.asc(i64));
    sort(i64, rhs.items, {}, std.sort.asc(i64));

    var total: u64 = 0;
    for (lhs.items, rhs.items) |l, r| {
        const diff = @abs(l - r);

        total += diff;
    }

    return total;
}

pub fn part2(data: []const u8) u64 {
    var lhs = std.ArrayList(u64).init(std.heap.page_allocator);
    var rhs_map = std.AutoHashMap(u64, u64).init(std.heap.page_allocator);

    var lines = std.mem.splitScalar(u8, data, '\n');

    while (lines.next()) |line| {
        var num_arr = std.mem.split(u8, line, "   ");

        const lhs_str_opt = num_arr.next();
        const rhs_str_opt = num_arr.next();
        if (lhs_str_opt) |lhs_str| {
            if (lhs_str.len == 0) {
                break;
            }
            if (rhs_str_opt) |rhs_str| {
                if (rhs_str.len == 0) {
                    break;
                }
                const lhs_num = std.fmt.parseInt(u64, lhs_str, 10) catch {
                    @panic("LHS was not a num");
                };
                const rhs_num = std.fmt.parseInt(u64, rhs_str, 10) catch {
                    @panic("RHS was not a num");
                };
                lhs.append(lhs_num) catch {
                    @panic("Could not add to LHS");
                };
                var rhs_count = rhs_map.get(rhs_num) orelse 0;
                rhs_count += 1;
                rhs_map.put(rhs_num, rhs_count) catch {
                    @panic("Could not add to RHS map");
                };
            }
        }
    }

    var total: u64 = 0;
    for (lhs.items) |l| {
        const count = rhs_map.get(l) orelse 0;

        total += l * count;
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
