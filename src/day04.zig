const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

pub fn main() !void {
    const data = @embedFile("data/day04.txt");
    const part1Res = part1(data) catch |err| {
        std.debug.panic("{!}\n", .{err});
    };
    print("part 1: {}\n", .{part1Res});
    const part2Res = part2(data) catch |err| {
        std.debug.panic("{!}\n", .{err});
    };
    print("part 2: {}\n", .{part2Res});
}

const WordSearch = struct {
    arr: std.ArrayList([]const u8),
    numRows: usize,
    numCols: usize,
    allocator: Allocator,

    pub fn init(allocator: Allocator, data: []const u8) !WordSearch {
        var lines = std.mem.splitScalar(u8, data, '\n');
        var matrix = std.ArrayList([]const u8).init(allocator);
        while (lines.next()) |line| {
            if (line.len == 0) {
                continue;
            }
            try matrix.append(line);
        }

        return WordSearch{ .arr = matrix, .numRows = matrix.items.len, .numCols = matrix.items[0].len, .allocator = allocator };
    }

    pub fn deinit(self: *const WordSearch) void {
        self.arr.deinit();
    }
};

const MatchState = struct {
    idx: usize,
    matched: bool,
};

const matchStr = "XMAS";
const forwardStartingIdx = 0;
const reverseStartingIdx = matchStr.len;

fn iterateSearch(wordSearch: *const WordSearch, rowIdx: usize, colIdx: usize, forwardIdx: usize, reverseIdx: usize) CurrentIndex {
    var forwardCurrIdx = forwardIdx;
    var reverseCurrIdx = reverseIdx;

    var forwardMatched = false;
    var reverseMatched = false;

    if (wordSearch.arr.items[rowIdx][colIdx] == matchStr[forwardCurrIdx]) {
        forwardCurrIdx += 1;
        if (forwardCurrIdx == matchStr.len) {
            forwardCurrIdx = forwardStartingIdx;
            forwardMatched = true;
        }
    } else {
        if (wordSearch.arr.items[rowIdx][colIdx] == matchStr[forwardStartingIdx]) {
            forwardCurrIdx = forwardStartingIdx + 1;
        } else {
            forwardCurrIdx = forwardStartingIdx;
        }
    }
    if (wordSearch.arr.items[rowIdx][colIdx] == matchStr[reverseCurrIdx - 1]) {
        reverseCurrIdx -= 1;
        if (reverseCurrIdx == 0) {
            reverseCurrIdx = reverseStartingIdx;
            reverseMatched = true;
        }
    } else {
        if (wordSearch.arr.items[rowIdx][colIdx] == matchStr[reverseStartingIdx - 1]) {
            reverseCurrIdx = reverseStartingIdx - 1;
        } else {
            reverseCurrIdx = reverseStartingIdx;
        }
    }

    return .{ .forward = MatchState{ .idx = forwardCurrIdx, .matched = forwardMatched }, .reverse = MatchState{ .idx = reverseCurrIdx, .matched = reverseMatched } };
}

fn part1(data: []const u8) !u64 {
    const wordSearch = try WordSearch.init(std.heap.page_allocator, data);
    defer wordSearch.deinit();

    var occurances: u64 = 0;
    var forwardCurrIdx: usize = forwardStartingIdx;
    var reverseCurrIdx: usize = reverseStartingIdx;

    // search normal and reverse string

    // horizontal
    for (0..wordSearch.numRows) |rowIdx| {
        forwardCurrIdx = forwardStartingIdx;
        reverseCurrIdx = reverseStartingIdx;
        for (0..wordSearch.numCols) |colIdx| {
            const res = iterateSearch(&wordSearch, rowIdx, colIdx, forwardCurrIdx, reverseCurrIdx);

            forwardCurrIdx = res.forward.idx;
            reverseCurrIdx = res.reverse.idx;
            if (res.forward.matched) {
                occurances += 1;
            }
            if (res.reverse.matched) {
                occurances += 1;
            }
        }
    }

    // vertical
    for (0..wordSearch.numCols) |colIdx| {
        forwardCurrIdx = forwardStartingIdx;
        reverseCurrIdx = reverseStartingIdx;
        for (0..wordSearch.numRows) |rowIdx| {
            const res = iterateSearch(&wordSearch, rowIdx, colIdx, forwardCurrIdx, reverseCurrIdx);

            forwardCurrIdx = res.forward.idx;
            reverseCurrIdx = res.reverse.idx;
            if (res.forward.matched) {
                occurances += 1;
            }
            if (res.reverse.matched) {
                occurances += 1;
            }
        }
    }

    // pos diagonal
    for (0..wordSearch.numCols) |startingColIdx| {
        forwardCurrIdx = forwardStartingIdx;
        reverseCurrIdx = reverseStartingIdx;
        for (0..@min(wordSearch.numRows, wordSearch.numCols - startingColIdx)) |offset| {
            const colIdx = startingColIdx + offset;
            const rowIdx = offset;

            const res = iterateSearch(&wordSearch, rowIdx, colIdx, forwardCurrIdx, reverseCurrIdx);

            forwardCurrIdx = res.forward.idx;
            reverseCurrIdx = res.reverse.idx;
            if (res.forward.matched) {
                occurances += 1;
            }
            if (res.reverse.matched) {
                occurances += 1;
            }
        }
    }
    for (1..wordSearch.numRows) |startingRowIdx| {
        forwardCurrIdx = forwardStartingIdx;
        reverseCurrIdx = reverseStartingIdx;
        for (0..@min(wordSearch.numRows - startingRowIdx, wordSearch.numCols)) |offset| {
            const rowIdx = startingRowIdx + offset;
            const colIdx = offset;

            const res = iterateSearch(&wordSearch, rowIdx, colIdx, forwardCurrIdx, reverseCurrIdx);

            forwardCurrIdx = res.forward.idx;
            reverseCurrIdx = res.reverse.idx;
            if (res.forward.matched) {
                occurances += 1;
            }
            if (res.reverse.matched) {
                occurances += 1;
            }
        }
    }

    // neg diagonal
    for (1..wordSearch.numCols) |startingColIdx| {
        forwardCurrIdx = forwardStartingIdx;
        reverseCurrIdx = reverseStartingIdx;
        for (0..@min(wordSearch.numRows, wordSearch.numCols - startingColIdx)) |offset| {
            const colIdx = startingColIdx + offset;
            const rowIdx = wordSearch.numRows - 1 - offset;

            const res = iterateSearch(&wordSearch, rowIdx, colIdx, forwardCurrIdx, reverseCurrIdx);

            forwardCurrIdx = res.forward.idx;
            reverseCurrIdx = res.reverse.idx;
            if (res.forward.matched) {
                occurances += 1;
            }
            if (res.reverse.matched) {
                occurances += 1;
            }
        }
    }

    for (0..wordSearch.numRows) |startingRowIdx| {
        forwardCurrIdx = forwardStartingIdx;
        reverseCurrIdx = reverseStartingIdx;
        for (0..@min(wordSearch.numRows - startingRowIdx, wordSearch.numCols)) |offset| {
            const rowIdx = wordSearch.numRows - 1 - startingRowIdx - offset;
            const colIdx = offset;

            const res = iterateSearch(&wordSearch, rowIdx, colIdx, forwardCurrIdx, reverseCurrIdx);

            forwardCurrIdx = res.forward.idx;
            reverseCurrIdx = res.reverse.idx;
            if (res.forward.matched) {
                occurances += 1;
            }
            if (res.reverse.matched) {
                occurances += 1;
            }
        }
    }

    return occurances;
}

const CellIdx = struct {
    rowIdx: usize,
    colIdx: usize,
};

const CurrentIndex = struct {
    forward: MatchState,
    reverse: MatchState,
};

const MatchString = struct {
    str: []const u8,

    fn getLeftBound() usize {
        return 0;
    }

    fn getRightBound(self: *const MatchString) usize {
        return self.str.len;
    }
};

const part2MatchStr = MatchString{ .str = "MAS" };

fn part2(data: []const u8) !u64 {
    const wordSearch = try WordSearch.init(std.heap.page_allocator, data);
    defer wordSearch.deinit();

    var posCurrIdx = CurrentIndex{ .forward = MatchState{ .idx = MatchString.getLeftBound(), .matched = false }, .reverse = MatchState{ .idx = part2MatchStr.getRightBound(), .matched = false } };
    var negCurrIdx = CurrentIndex{ .forward = MatchState{ .idx = MatchString.getLeftBound(), .matched = false }, .reverse = MatchState{ .idx = part2MatchStr.getRightBound(), .matched = false } };
    var occurances: u64 = 0;

    for (0..wordSearch.numRows - part2MatchStr.str.len + 1) |rowIdx| {
        for (0..wordSearch.numCols - part2MatchStr.str.len + 1) |colIdx| {
            posCurrIdx = CurrentIndex{ .forward = MatchState{ .idx = MatchString.getLeftBound(), .matched = false }, .reverse = MatchState{ .idx = part2MatchStr.getRightBound(), .matched = false } };
            negCurrIdx = CurrentIndex{ .forward = MatchState{ .idx = MatchString.getLeftBound(), .matched = false }, .reverse = MatchState{ .idx = part2MatchStr.getRightBound(), .matched = false } };
            for (0..part2MatchStr.str.len) |offset| {
                const posIdx = CellIdx{ .rowIdx = rowIdx + offset, .colIdx = colIdx + offset };
                const negIdx = CellIdx{ .rowIdx = rowIdx + part2MatchStr.str.len - 1 - offset, .colIdx = colIdx + offset };

                posCurrIdx = part2IterateSearch(wordSearch.arr.items[posIdx.rowIdx][posIdx.colIdx], posCurrIdx.forward.idx, posCurrIdx.reverse.idx);
                negCurrIdx = part2IterateSearch(wordSearch.arr.items[negIdx.rowIdx][negIdx.colIdx], negCurrIdx.forward.idx, negCurrIdx.reverse.idx);
            }

            if ((posCurrIdx.forward.matched or posCurrIdx.reverse.matched) and (negCurrIdx.forward.matched or negCurrIdx.reverse.matched)) {
                occurances += 1;
            }
        }
    }

    return occurances;
}

fn part2IterateSearch(currChar: u8, forwardIdx: usize, reverseIdx: usize) CurrentIndex {
    var forwardCurrIdx = forwardIdx;
    var reverseCurrIdx = reverseIdx;

    var forwardMatched = false;
    var reverseMatched = false;

    if (currChar == part2MatchStr.str[forwardCurrIdx]) {
        forwardCurrIdx += 1;
        if (forwardCurrIdx == part2MatchStr.str.len) {
            forwardCurrIdx = MatchString.getLeftBound();
            forwardMatched = true;
        }
    } else {
        if (currChar == part2MatchStr.str[MatchString.getLeftBound()]) {
            forwardCurrIdx = MatchString.getLeftBound() + 1;
        } else {
            forwardCurrIdx = MatchString.getLeftBound();
        }
    }
    if (currChar == part2MatchStr.str[reverseCurrIdx - 1]) {
        reverseCurrIdx -= 1;
        if (reverseCurrIdx == 0) {
            reverseCurrIdx = part2MatchStr.getRightBound();
            reverseMatched = true;
        }
    } else {
        if (currChar == part2MatchStr.str[part2MatchStr.getRightBound() - 1]) {
            reverseCurrIdx = part2MatchStr.getRightBound() - 1;
        } else {
            reverseCurrIdx = part2MatchStr.getRightBound();
        }
    }

    return .{ .forward = MatchState{ .idx = forwardCurrIdx, .matched = forwardMatched }, .reverse = MatchState{ .idx = reverseCurrIdx, .matched = reverseMatched } };
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
