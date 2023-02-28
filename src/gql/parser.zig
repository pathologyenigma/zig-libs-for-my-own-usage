//! gql parser aims to parse zig code to schema string
//! and parse query string to zig variables
//! experimental right now
const gql = @import("gql.zig");
const std = @import("std");
const parser = @This();
pub const ParseContext = enum {
    IsInnerTypeOfType,
    IsInnerTypeOfPointer,
    IsInnerTypeOfPointerAndType,
    const Self = @This();
    pub fn join(self: *Self, rhs: *Self) !Self {
        return switch (self) {
            .IsInnerTypeOfType => {
                switch (rhs) {
                    .IsInnerTypeOfType => .IsInnerTypeOfType,
                    .IsInnerTypeOfPointer => .IsInnerTypeOfPointerAndType,
                    .IsInnerTypeOfPointerAndType => .IsInnerTypeOfPointerAndType,
                }
            },
            .IsInnerTypeOfPointer => {
                switch (rhs) {
                    .IsInnerTypeOfType => .IsInnerTypeOfPointerAndType,
                    .IsInnerTypeOfPointer => .IsInnerTypeOfPointer,
                    .IsInnerTypeOfPointerAndType => .IsInnerTypeOfPointerAndType,
                }
            },
            .IsInnerTypeOfPointerAndType => .IsInnerTypeOfPointerAndType,
        };
    }
};
// /// output type should be type xxxx {}
// pub fn gqlParseType(comptime T: type, comptime ctx: ?ParseContext) []const u8 {}
// /// will parse the type behind the pointer
// pub fn gqlParsePointType(comptime T: type, comptime ctx: ?ParseContext) []const u8 {}
// /// output type should be interface xxxx {}
// pub fn gqlParseInterface(comptime T: type, comptime ctx: ?ParseContext) []const u8 {}
// /// output type should be union = xxx | xxx
// pub fn gqlParseUnion(comptime T: type, comptime ctx: ?ParseContext) []const u8 {
//     if (ctx == null) {
//         var res = "union ";
//         res += @typeName(T);
//         res += "=";
//         const typeInfo = @typeInfo(T);
//         switch (typeInfo) {
//             .Union => |u|{
//                 for (u.fields) |field| {
//                     switch (@typeInfo(field.field_type)) {
//                         .Struct, .Union, .Enum, .Int, .Float, .ComptimeFloat, .ComptimeInt => {
//                             res += " " + field.name;
//                         },
//                         .Pointer => |p| {
//                             if (T == []const u8) {
//                                 res += " String";
//                             } else {
//                                 if (p.size != .One) {
//                                     @compileError("array is not supported in graphql union");
//                                 }
//                                 res += gqlParsePointType(@Type(p), .IsInnerTypeOfType);
//                             }
//                         },
//                         else => {
//                             comptimeError("not supported field type for graphql union");
//                         },
//                     }
//                     res += field.name + "\n";
//                 }
//                 res += "}";
//             },
//             else => @compileError("only allow union right here"),
//         }
//         return res;
//     } else {
//         return @typeName(T);
//     }
// }
// /// output type should be enum xxx {}
// pub fn gqlParseEnum(comptime T: type, comptime ctx: ?ParseContext) []const u8 {
//     if (ctx == null) {
//         var res = "enum ";
//         res += @typeName(T);
//         res += "{\n";
//         const typeInfo = @typeInfo(T);
//         switch (typeInfo) {
//             .Enum => |e| {
//                 for (e.fields) |field| {
//                     res += field.name + "\n";
//                 }
//                 res += "}";
//             },
//             else => @compleError("only allow enum right here"),
//         }
//         return res;
//     } else {
//         return @typeName(T);
//     }
// }
// /// zig's builtin type to gql type
// pub fn gqlParseSimpleBuiltInType(comptime T: type, comptime ctx: ?ParseContext) []const u8 {}
