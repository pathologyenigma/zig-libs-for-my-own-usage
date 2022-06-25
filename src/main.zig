const std = @import("std");
const testing = std.testing;

pub fn Matrix(comptime row: comptime_int, comptime col: comptime_int, comptime T: type) type {
    return struct {
        const RowType = @Vector(col, T);
        const Self = @This();
        const defalutAllocator = std.heap.page_allocator;
        val: [row]RowType,
        pub fn init(args: anytype) Self{
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
            var self = defalutAllocator.create(Self);
            return self;
        }
    };
}

test "Matrix init" {
    _ = Matrix(4, 4, f32).init(1);
}