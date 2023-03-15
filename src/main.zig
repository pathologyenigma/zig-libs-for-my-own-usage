pub const math = @import("math/math.zig");
const std = @import("std");
pub const Matrix = math.Matrix;
pub const gql = @import("gql/gql.zig");
pub const utils = @import("utils/utils.zig");
const validate = @import("validate");
comptime {
    _ = math;
    _ = Matrix;
    _ = gql;
    _ = utils;
}

pub fn Range(comptime T: type) type {
    const input_type_info = @typeInfo(T);
    switch (input_type_info) {
        .Int, .Float, .Bool => {},
        else => {
            @compileError("Range among non-numeric types is not supported");
        },
    }

    return struct {
        start: T = 0,
        end: T,
        step: T = 1,
        iterator: Iter = validate.dynamic(Iter, IteratorImpl),
        comparableSelf: ComparableSelf = ComparableSelf{},
        comparableInnerType: ComparableInnerType = ComparableInnerType{},
        const Iter = utils.Iterator(T);
        const Self = @This();
        const IteratorImpl = struct {
            pub fn next(iter: *Iter) ?T {
                var self = @fieldParentPtr(Self, "iterator", iter);
                if (self.start >= self.end) return null;
                const result = self.start;
                self.start += self.step;
                return result;
            }
        };
        pub const ComparableSelf = struct {
            pub fn cmp(self: *const Self, rhs: *const Self) utils.CompareResult {
                if (((self.end - self.start) / self.step) - ((rhs.end - rhs.start) / rhs.step) > 0) {
                    return .Greater;
                }
                if (((self.end - self.start) / self.step) - ((rhs.end - rhs.start) / rhs.step) < 0) {
                    return .Less;
                }
                return .Equal;
            }
        };
        pub const ComparableInnerType = struct{
            pub fn cmp(self: *const Self, rhs: *const T) utils.CompareResult {
                if (self.start > rhs.*) return .Greater;
                if (self.end < rhs.*) return .Less;
                return .Equal;
            }
        };
    };
}
// something I wish will work in the future version of zig
// pub const Infinity = struct {
//     is_negative: bool = false,
//     const Self = @This();
//     pub usingnamespace utils.ComparableManager(Self).init().where(.{ .RHS = null })(.{ .cmpFn = struct {
//         pub fn cmp(self: Self, rhs: Self) utils.CompareResult {
//             if (self.is_negative == rhs.is_negative) {
//                 return .Equal;
//             } else if (self.is_negative) {
//                 return .Less;
//             } else if (!self.is_negative) return .Greater;
//         }
//     }.cmp }).end();
// };

test "Iterator" {
    var range = std.heap.page_allocator.create(Range(u32)) catch unreachable;
    range.* = Range(u32){ .end = 5 };
    try std.testing.expectEqual(@as(?u32, 0), range.iterator.next(@constCast(&range.iterator)));
    try std.testing.expectEqual(@as(?u32, 1), range.iterator.next(@constCast(&range.iterator)));
    try std.testing.expectEqual(@as(?u32, 2), range.iterator.next(@constCast(&range.iterator)));
    try std.testing.expectEqual(@as(?u32, 3), range.iterator.next(@constCast(&range.iterator)));
    try std.testing.expectEqual(@as(?u32, 4), range.iterator.next(@constCast(&range.iterator)));
    try std.testing.expectEqual(@as(?u32, null), range.iterator.next(@constCast(&range.iterator)));
    try std.testing.expectEqual(@as(?u32, null), range.iterator.next(@constCast(&range.iterator)));
}
test "Comparable" {
    var range_1 = Range(u32){ .end = 5 };
    var range_2 = Range(u32){ .end = 4 };
    try std.testing.expectEqual(utils.compare(&range_1, &range_2), .Greater);
    try std.testing.expectEqual(utils.compareWithCustomizedImplementation(Range(u32).ComparableInnerType, &range_1, &@intCast(u32, 3)), .Equal);
    var option_range_1 = utils.option.Option(Range(u32)).Some(range_1) catch unreachable;
    defer option_range_1.deinit();
    var option_range_2 = utils.option.Option(Range(u32)).Some(range_2) catch unreachable;
    defer option_range_2.deinit();
    try std.testing.expectEqual(utils.compare(&option_range_1, &option_range_2), .Greater);
    // something I wish will work in the future version of zig
    // var infinity = Infinity {};
    // try std.testing.expectEqual(infinity.cmp(Infinity)(infinity), .Equal);
}
