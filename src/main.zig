const math = @import("math/math.zig");
const std = @import("std");
const Matrix = math.Matrix;
const gql = @import("gql/gql.zig");
const iter = @import("utils/iter.zig");
test "Matrix" {
    var m1 = Matrix(4, 4, f32).init(.{ .{ 1, 2, 3, 4 }, .{ 1, 2, 3, 4 }, .{ 1, 2, 3, 4 }, .{ 1, 2, 3, 4 } });
    defer m1.deinit();
    m1.print();
    var m2 = Matrix(4, 4, f32).init(.{ 1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4 });
    defer m2.deinit();
    std.log.warn("{d}", .{m2.val.len});
    m2.print();
    var m3 = m1.add(m2);
    defer m3.deinit();
    std.log.warn("{d}", .{m3.val.len});
    m3.print();
    m3.add_assign(m3);
    std.log.warn("{d}", .{m3.val.len});
    m3.print();
    var m4 = m3.reduce(m2);
    defer m4.deinit();
    m4.print();
    m4.reduce_assign(m3);
    m4.print();
    var m5 = m3.mul(m4);
    defer m5.deinit();
    m5.print();
    var v1 = @Vector(4, f32){ 1, 2, 3, 4 };
    var v2 = m5.mul(v1);
    std.log.warn("{}", .{v2});
}

test "scalar" {
    const A = struct {
        // const json = std.json;
        const Self = @This();
        comptime type_name: []const u8 = "Null",
        pub fn serialize(self: *Self) []const u8 {
            _ = self;
            return "null";
        }
        pub fn deserialize(input: []const u8) Self {
            _ = input;
            return Self{};
        }
    };
    try std.testing.expect(gql.isScalarType(A));
}

