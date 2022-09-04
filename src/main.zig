const std = @import("std");
const testing = std.testing;

pub fn Matrix(comptime row: comptime_int, comptime col: comptime_int, comptime T: type) type {
    return struct {
        const RowType = @Vector(col, T);
        const Self = @This();
        const defalutAllocator: std.mem.Allocator = std.heap.page_allocator;
        val: [row]RowType,
        pub fn init(args: anytype) *Self {
            const ArgsType = @TypeOf(args);
            const ArgsTypeInfo = @typeInfo(ArgsType);
            if (ArgsTypeInfo != .Struct) {
                @panic(
                    \\
                    \\you should provide a struct like .{*,*...}
                    \\or a struct like .{.{*,*},.{*,*}...}
                    \\for init args here
                );
            }
            var self: *Self;
            switch (ArgsTypeInfo.Struct.fields[0].field_type) {
                .Struct => {
                    if(ArgsTypeInfo.Struct.fields.len != row or ArgsTypeInfo.Struct.fields[0].field_type.Struct.fields.len != col) {
                        @compileError("args ");
                    }
                    self = defalutAllocator.create(Self) catch @panic("failed to create memory");
                },
                .Float, .Int => {
                    if(ArgsTypeInfo.Struct.fields.len != row * col) {
                        @compileError("");
                    }
                },
                else => {
                    @compileError("type not supported");
                },
            }
            
            self.val = args;
            return self;
        }
        pub fn print(self: *Self) void {
            std.debug.print("Matrix{d}x{d}: \n", .{ row, col });
            for (self.val) |row_| {
                std.debug.print("{}\n", .{row_});
            }
        }
        pub fn deinit(self: *Self) void {
            defalutAllocator.destroy(self);
        }
    };
}

test "Matrix init" {
    var m1 = Matrix(4, 4, f32).init(.{ .{ 1, 2, 3, 4 }, .{ 1, 2, 3, 4 }, .{ 1, 2, 3, 4 }, .{ 1, 2, 3, 4 } });
    defer m1.deinit();
    std.log.warn("{d}", .{m1.val.len});
    m1.print();
    var m2 = Matrix(4, 4, f32).init(.{ 1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4 });
    defer m2.deinit();
    std.log.warn("{d}", .{m2.val.len});
    m2.print();
}
