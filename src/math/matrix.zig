const std = @import("std");
const testing = std.testing;

/// a matrix implementation based on standard library vector type
/// onlu support numberics type for T
/// type check not implemented for type definitions
/// but will be check when calling init function
/// a print function is provided for debug usage
/// not thread safe, but you can only got one pointer at a time
/// thread safe implementation will be available when I add ownship check utils to my library
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
        /// the type of the transpose one
        pub const TransposeMatrix = Matrix(col, row, T);
        /// the type of column vector
        pub const ColVector = @Vector(row, T);
        /// check the if the input matrix is valid type
        /// if the input is not matrix but having row as comptime field
        /// this function may not works well, so it should be private
        /// and only be used when the input is a matrix
        inline fn isValidMulMatrix(comptime m: type) bool {
            // only support matrix pointer
            // cause the matrix's constructor returns a pointer
            // don't trying to dereference it yourself
            if(@typeInfo(m) != .Pointer) return false;
            // if the inner type of the pointer is not matrix
            // will get a compile error like this:
            // type xxx not have a field call col_size
            return @typeInfo(m).Pointer.child.row_size() == col;
        }
        const RowOrCol = enum {
            row,
            col
        };
        const Vector = union(RowOrCol) {
            row: RowType,
            col: ColVector
        };
        /// implementation for dot multiplication for vectors
        /// this function should only be used when the size of the vector is checked
        /// for some reason the input type could only be col vector or row vector
        /// and should be the same type
        inline fn dot(vec1: Vector, vec2: Vector) T {
            if(@as(RowOrCol, vec1) != @as(RowOrCol, vec2) and row != col) @panic("vec1 and vec2 should be the same size");
            var res: T = 0;
            // this is weird
            // but if you try not to using switch
            // you still need to write the same code twice
            // cause they are different types
            switch(vec1) {
                .row => |r| {
                    var index: usize = 0;
                    while(index < col):(index += 1) {
                        res += r[index] * vec2.row[index];
                    }
                },
                .col => |c| {
                    var index: usize = 0;
                    while(index < row):(index += 1) {
                        res += c[index] * vec2.row[index];
                    }
                }
            }
            return res;
        }
        // like the trait in dlang or c++
        // but in zig we can check more things about it
        // but this type of concept may not that readable
        // so I will change it as soon as zig support a more readable type of type concept
        // this type of comptime check is fine, but using anytype for arg's type is not that readable
        // the trait that standard library is using is also not that readable
        /// check if the type is supported or not
        inline fn init_args_check(args: anytype) Self.InitArgsCheckFailedError!Self.InitArgsCheckResult {
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
        /// init a matrix using the given values
        /// supported a double tuple or a single tuple
        /// the amount of elements should match the size of the matrix
        pub inline fn init(args: anytype) *Self {
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
                            \\ if you want to auto fill
                            \\ try using default function or fill function
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
        /// returns a matrix that filled with zeros
        pub inline fn default() *Self{
            return Self.fill(0);
        }
        /// returns a matrix that filled with the given value
        pub inline fn fill(arg: f32) *Self {
            var self: *Self = defalutAllocator.create(Self) catch @panic("failed to create memory");
            self.val = [_]RowType{.{arg} ** col} ** row;
            return self;
        }
        pub inline fn from_array(input: [row]RowType) *Self {
            var self: *Self = defalutAllocator.create(Self) catch @panic("failed to create memory");
            self.val = input;
            return self;
        }
        /// print to the console
        /// for example, a 4x4 matrix created by default will be format like:
        /// Matrix4x4:
        /// { 0.0e+00, 0.0e+00, 0.0e+00, 0.0e+00 }
        /// { 0.0e+00, 0.0e+00, 0.0e+00, 0.0e+00 }
        /// { 0.0e+00, 0.0e+00, 0.0e+00, 0.0e+00 }
        /// { 0.0e+00, 0.0e+00, 0.0e+00, 0.0e+00 }
        pub inline fn print(self: *Self) void {
            std.debug.print("Matrix{d}x{d}: \n", .{ row, col });
            for (self.val) |row_| {
                std.debug.print("{}\n", .{row_});
            }
        }
        /// deinit a matrix
        /// matrix created by functions inside this type will all be valid to use this
        pub inline fn deinit(self: *Self) void {
            defalutAllocator.destroy(self);
        }
        /// get the row size
        /// actually the size is static and is defined by yourself
        /// so you actually don't need this function do you
        inline fn row_size() comptime_int {
            return row;
        }
        /// get the col size
        /// actually the size is static and is defined by yourself
        /// so you actually don't need this function do you
        inline fn col_size() comptime_int {
            return col;
        }
        /// get the given index of column
        pub inline fn get_col(self: *Self, col_index: usize) ColVector {
            if(col_index >= col) @panic("index out of range");
            var res = init: {
                var ptr: [row]T = undefined;
                for(ptr)|*p, i| {
                    p.* = self.val[i][col_index];
                }
                break :init ptr;
            };
            return res;
        }
        /// get the given index of the row
        pub inline fn get_row(self: *Self, row_index: usize) RowType {
            if(row_index >= row) @panic("index out of range");
            return self.val[row_index];
        }
        /// add calculation for matrix
        /// will create a new matrix for result
        /// if you want to add to this matrix, using add_assign instead
        /// this opration is not checked, may overflow the number limit
        pub inline fn add(self: *Self, rhs: *Self) *Self {
            var res = Self.default();
            var i: usize = 0;
            while (i < row) :(i += 1) {
                res.val[i] = self.val[i] + rhs.val[i];
            }
            return res;
        }
        /// add assignment opration for matrix
        /// this opration is not checked, may overflow the number limit
        pub inline fn add_assign(self: *Self, rhs: *Self) void {
            var i: usize = 0;
            while (i < row) :(i += 1) {
                self.val[i] += rhs.val[i];
            }
        }
        /// reduce calculation for matrix
        /// will create a new matrix for result
        /// if you want to reduce from this matrix, using reduce_assign instead
        /// this opration is not checked, may overflow the number limit
        pub inline fn reduce(self: *Self, rhs: *Self) *Self {
            var res = Self.default();
            var i: usize = 0;
            while (i < row) :(i += 1) {
                res.val[i] = self.val[i] - rhs.val[i];
            }
            return res;
        }
        /// reduce assignment opration for matrix
        /// this opration is not checked, may overflow the number limit
        pub inline fn reduce_assign(self: *Self, rhs: *Self) void {
            var i: usize = 0;
            while (i < row) :(i += 1) {
                self.val[i] -= rhs.val[i];
            }
        }
        /// because of zig's trait design
        /// it is not that convenient to define a trait for Matrix type
        /// and valid type for mul is the Matrix which's col is the same size of this matrix
        /// the row size is not known at compile time
        /// using anytype here is not recommended, but I running out of solutions
        /// the return type is a little be weird, but actually valid
        pub inline fn mul(self: *Self, rhs: anytype) return_type:{
            if(@TypeOf(rhs) == RowType) break :return_type ColVector;
            break :return_type *Matrix(row, @typeInfo(@TypeOf(rhs)).Pointer.child.col_size(), T);
        } {
            if(@TypeOf(rhs) == RowType) {
                var res: ColVector = init: {
                    var ptr: [row]T = undefined;
                    for(ptr) |*p, i| {
                        p.* = dot(Vector{
                            .row = self.get_row(i)
                            }, Vector{
                            .row = rhs
                            });
                    }
                    break :init ptr;
                };
                return res;
            }
            if(isValidMulMatrix(@TypeOf(rhs))) {
                var res: *Matrix(row, @typeInfo(@TypeOf(rhs)).Pointer.child.col_size(), T) = init: {
                    var array: [row]@Vector(@typeInfo(@TypeOf(rhs)).Pointer.child.col_size(), T) = undefined;
                    for(array) |*p, i| {
                        p.* = self.mul(rhs.get_col(i));
                    }
                    break :init Self.from_array(array);
                };
                return res;
            }
            @panic("not a valid type");
        }
    };
}


