pub const math = @import("math/math.zig");
const std = @import("std");
pub const Matrix = math.Matrix;
pub const gql = @import("gql/gql.zig");
pub const utils = @import("utils/utils.zig");
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
        const Self = @This();
        pub usingnamespace utils.Iterator(*Self, T, .{
            .next = next,
        });
        pub const ComparableSelf = utils.Comparable(*Self).impl(null)(.{
            .cmpFn = cmp,
        });
        pub const ComparableT = utils.Comparable(*Self).impl(T)(.{
            .cmpFn = cmpT,
        });
        fn next(self: *Self) ?T {
            if (self.start >= self.end) return null;
            const result = self.start;
            self.start += self.step;
            return result;
        }
        fn cmp(self: *Self, rhs: *Self) utils.CompareResult {
            if (((self.end - self.start) / self.step) - ((rhs.end - rhs.start) / rhs.step) > 0) {
                return .Greater;
            }
            if (((self.end - self.start) / self.step) - ((rhs.end - rhs.start) / rhs.step) < 0) {
                return .Less;
            }
            return .Equal;
        }
        fn cmpT(self: *Self, rhs: T) utils.CompareResult {
            if (self.start > rhs) return .Greater;
            if (self.end < rhs) return .Less;
            return .Equal;
        }
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
    var range = Range(u32){ .end = 5 };
    const iter = range.iterator();
    try std.testing.expectEqual(@as(?u32, 0), iter.next());
    try std.testing.expectEqual(@as(?u32, 1), iter.next());
    try std.testing.expectEqual(@as(?u32, 2), iter.next());
    try std.testing.expectEqual(@as(?u32, 3), iter.next());
    try std.testing.expectEqual(@as(?u32, 4), iter.next());
    try std.testing.expectEqual(@as(?u32, null), iter.next());
    try std.testing.expectEqual(@as(?u32, null), iter.next());
}
test "Comparable" {
    var range_1 = Range(u32){ .end = 5 };
    var range_2 = Range(u32){ .end = 4 };
    try std.testing.expectEqual(range_1.ComparableSelf().cmp(&range_2), .Greater);
    try std.testing.expectEqual(range_1.ComparableT().cmp(3), .Equal);
    // something I wish will work in the future version of zig
    // var infinity = Infinity {};
    // try std.testing.expectEqual(infinity.cmp(Infinity)(infinity), .Equal);
}
