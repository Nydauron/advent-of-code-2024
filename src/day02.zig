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
    print("part 2: {}\n", .{part2(data)});
}
const Direction = enum(u1) {
    increasing,
    decreasing,
};

const badLevelsAllowed = 2;

const MemoizationMatrix = struct {
    arr: [badLevelsAllowed][]bool,
    allocator: Allocator,

    pub fn init(allocator: Allocator, numLevels: usize) !MemoizationMatrix {
        var arr = [badLevelsAllowed][]bool{ &[0]bool{}, &[0]bool{} };
        for (0..badLevelsAllowed) |badLevelIdx| {
            var row = try allocator.alloc(bool, numLevels + 1);

            for (0..row.len) |rowIdx| {
                var v = false;
                if (rowIdx == row.len - 1 or rowIdx == row.len - 2) {
                    v = true;
                }
                row[rowIdx] = v;
            }

            arr[badLevelIdx] = row[0..];
        }
        return .{
            .arr = arr,
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *MemoizationMatrix) void {
        for (0..badLevelsAllowed) |idx| {
            self.allocator.free(self.arr[idx]);
        }
    }
};

fn isSafeSnapshot(currentNumber: u64, prevNumber: ?u64, ordering: ?Direction) bool {
    const minDiff = 1;
    const maxDiff = 3;
    if (prevNumber) |p| {
        if (ordering) |o| {
            switch (o) {
                Direction.increasing => {
                    return ((p +| minDiff) <= currentNumber) and ((p +| maxDiff) >= currentNumber);
                },
                Direction.decreasing => {
                    return ((p -| minDiff) >= currentNumber) and ((p -| maxDiff) <= currentNumber);
                },
            }
        } else {
            return (((p +| minDiff) <= currentNumber) and ((p +| maxDiff) >= currentNumber)) or (((p -| minDiff) >= currentNumber) and ((p -| maxDiff) <= currentNumber));
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

fn part2(data: []const u8) u64 {
    var lines = std.mem.splitScalar(u8, data, '\n');

    var safeReportCount: u64 = 0;
    while (lines.next()) |line| {
        if (std.mem.eql(u8, line, "")) {
            break;
        }
        var numbers = std.mem.splitScalar(u8, line, ' ');
        var numArr = std.ArrayList(u64).init(std.heap.page_allocator);
        defer numArr.deinit();
        while (numbers.next()) |num_str| {
            const num = std.fmt.parseInt(u64, num_str, 10) catch |err| {
                std.debug.panic("String cannot be parsed as number: \"{s}\" {any}", .{ line, err });
            };
            numArr.append(num) catch {
                @panic("Could not add to num array");
            };
        }

        const levelsPerReport: usize = numArr.items.len;

        var incMemArr = MemoizationMatrix.init(std.heap.page_allocator, levelsPerReport) catch {
            @panic("Could not construct increasing memoization matrix");
        };
        defer incMemArr.deinit();
        var decMemArr = MemoizationMatrix.init(std.heap.page_allocator, levelsPerReport) catch {
            @panic("Could not construct decreasing memoization matrix");
        };
        defer decMemArr.deinit();

        // backtrack(currIdx, badLevels, ordering);
        // if good level
        // backtrack(currIdx + 1, badLevels, ordering);
        // if bad level
        // backtrack(currIdx + 2, badLevels + 1, ordering);

        const numArrSlice = numArr.items;
        for ([2]Direction{ Direction.increasing, Direction.decreasing }) |direction| {
            const memArr: *[badLevelsAllowed][]bool = switch (direction) {
                Direction.increasing => &incMemArr.arr,
                Direction.decreasing => &decMemArr.arr,
            };

            var badLevels: usize = 2;
            while (badLevels > 0) {
                badLevels -= 1;
                const len = memArr.*[badLevels].len;
                var currIdx = len - 2;
                while (currIdx > 0) {
                    currIdx -= 1;

                    memArr[badLevels][currIdx] = isSafeSnapshot(numArrSlice[currIdx + 1], numArrSlice[currIdx], direction) and memArr[badLevels][currIdx + 1];

                    if (currIdx + 2 < len and badLevels + 1 < badLevelsAllowed) {
                        var isSafeJump = true;
                        if (currIdx + 2 < numArrSlice.len) {
                            isSafeJump = isSafeSnapshot(numArrSlice[currIdx + 2], numArrSlice[currIdx], direction);
                        }
                        memArr[badLevels][currIdx] = memArr[badLevels][currIdx] or (isSafeJump and memArr[badLevels + 1][currIdx + 2]);
                    }
                }
            }
        }
        if (incMemArr.arr[0][0] or incMemArr.arr[1][1] or decMemArr.arr[0][0] or decMemArr.arr[1][1]) {
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
