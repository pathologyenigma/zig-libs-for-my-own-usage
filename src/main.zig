const std = @import("std");
const testing = std.testing;

pub fn Matrix(comptime row: comptime_int, comptime col: comptime_int, comptime T: type) type {
    return struct {
        const RowType = @Vector(col, T);
        const Self = @This();
        const defalutAllocator: std.mem.Allocator = std.heap.page_allocator;
        val: [row]RowType,
        const InitArgsCheckResult = enum {
            StructStruct,
            StructArray,
            StructNumberic,
        };
        const InitArgsCheckFailedError = error {
            InvalidFormat,
            AmountNotMatch,
            InnerTypeNotSupported,
        };
        fn init_args_check(args: anytype) Self.InitArgsCheckFailedError!Self.InitArgsCheckResult {
            const ArgsType = @TypeOf(args);
            const ArgsTypeInfo = @typeInfo(ArgsType);
            if (ArgsTypeInfo != .Struct) {
                return .InvalidFormat;
            }
            if (ArgsTypeInfo.Struct.fields.len != col * row) {
                if(@typeInfo(ArgsTypeInfo.Struct.fields[0].field_type) != .Struct) {
                    return .AmountNotMatch;
                }
                if(ArgsTypeInfo.Struct.fields.len != row) {
                    return .AmountNotMatch;
                }
                inline for (ArgsTypeInfo.Struct.fields) |field| {
                    switch(@typeInfo(field.field_type)) {
                        .Struct => {
                            if(@typeInfo(field.field_type).Struct.fields.len != col) {
                                return .AmountNotMatch;
                            }
                            inline for (@typeInfo(field.field_type).Struct.fields) |field_| {
                                switch(@typeInfo(field_.field_type)) {
                                    .Float, .Int, .ComptimeInt, .ComptimeFloat => {
                                        continue;
                                    },
                                    else => {
                                        return .InvalidFormat;
                                    }
                                }
                            }
                            return .StructStruct;
                        },
                        .Array => {
                            if(@typeInfo(field.field_type).Array.len != col) {
                                return .AmountNotMatch;
                            }
                            switch (@typeInfo(@typeInfo(field.field_type).Array.child)) {
                                .Float, .Int, .ComptimeInt, .ComptimeFloat => {
                                    return .StructStruct;
                                },
                                else => {
                                    return .InnerTypeNotSupported;
                                }
                            }
                            
                        },
                        else => {
                            return .InnerTypeNotSupported;
                        }
                    }
                }
            } else {
                inline for (ArgsTypeInfo.Struct.fields) |field| {
                    switch(@typeInfo(field.field_type)) {
                        .Struct, .Array => {
                            return .AmountNotMatch;
                        },
                        .Float, .Int, .ComptimeInt, .ComptimeFloat => {
                            return .StructNumberic;
                        },
                        else => {
                            return .InnerTypeNotSupported;
                        }
                    }
                }
            }
        }
        pub fn init(args: anytype) *Self {
            comptime var check_result = Self.init_args_check(args) catch |e| {
                switch(e) {
                    InitArgsCheckFailedError.InnerTypeNotSupported => {
                        @compileError(
                            \\ value inside tuple is not supported
                            \\ only supported tuple/struct, array type or numberics
                            );
                    },
                    InitArgsCheckFailedError.InvalidFormat => {
                        @compileError(
                            \\ not a valid format for arguments
                            \\ only supported format like {*, *...} or {{*,...},...}
                        );
                    },
                    InitArgsCheckFailedError.AmountNotMatch => {
                        @compileError(
                            \\ not a valid amount for arguments
                            \\ matrix should have a static size
                            \\ if you want to auto fill or ignore the extra arguments
                            \\ try using init_unchecked instead
                        );
                    }
                }
            };
            var self: *Self = defalutAllocator.create(Self) catch @panic("failed to create memory");
            switch (check_result) {
                .StructNumberic => {
                    inline for(args) |v, i| {
                        self.val[i / col][i % col] = v;
                    }
                },
                else => {
                    self.val = args;
                }
            }
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
