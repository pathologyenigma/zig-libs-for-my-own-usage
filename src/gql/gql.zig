const gql = @This();
const std = @import("std");
const trait = std.meta.trait;
pub const parser = @import("parser.zig");
// /// type checker for scalar type
// /// return false immediately when one item check is failed
// /// you can replace return false things to custom error to show more info
// /// every step of the type check having debug print
// /// you can remove it if you want to
// /// this is equal with the a trait in rust like:
// /// trait ScalarType<'a> {
// ///     fn serialize(&mut self) -> &'a str;
// ///     fn deserialize(input: &'a str') -> Self;
// /// }
// /// but a little more, because we expect type to having a type_name field
// /// which is a comptime []const u8
// /// notice: this type checker may not being used outside of this library
// /// scalar type is only need to check when default parse rule is failed
// pub fn isScalarType(comptime T: type) bool {
//     std.debug.print("\ntype check starting...\n", .{});
//     if (@typeInfo(T) != .Struct) {
//         return false;
//     }
//     std.debug.print("root type check passed...\n", .{});
//     if (!trait.hasFn("serialize")(T)) return false;
//     std.debug.print("serialize function is contained...\n", .{});
//     const serialize_fn = @typeInfo(@TypeOf(@field(T, "serialize"))).Fn;
//     const serialize_fn_args = serialize_fn.params;
//     if (serialize_fn_args.len != 1) {
//         return false;
//     }
//     std.debug.print("serialize function's args length is correct...\n", .{});
//     if (!trait.isPtrTo(@typeInfo(T))(serialize_fn_args[0].type.?)) {
//         return false;
//     }
//     std.debug.print("serialize function's args type is correct...\n", .{});
//     if (serialize_fn.return_type != []const u8) {
//         return false;
//     }
//     std.debug.print("serialize function's return type is correct...\n", .{});

//     if (!trait.hasFn("deserialize")(T)) return false;
//     std.debug.print("deserialize function si contained...\n", .{});

//     const deserialize_fn = @typeInfo(@TypeOf(@field(T, "deserialize"))).Fn;
//     const deserialize_fn_args = deserialize_fn.params;
//     if (deserialize_fn_args.len != 1) {
//         return false;
//     }
//     std.debug.print("deserialize function's args length is correct\n", .{});
//     if (deserialize_fn_args[0].type.? != []const u8) {
//         return false;
//     }
//     std.debug.print("deserialize function's args type is correct...\n", .{});
//     if (deserialize_fn.return_type != T) {
//         return false;
//     }
//     std.debug.print("deserialize function's return type is correct...\n", .{});
//     if (@hasField(T, "type_name")) {
//         std.debug.print("type_name arg is contained...\n", .{});
//         inline for (@typeInfo(T).Struct.fields) |field| {
//             comptime if (std.mem.indexOfDiff(u8, field.name, "type_name")) |index_diff| {
//                 _ = index_diff;
//                 continue;
//             };
//             if (field.type != []const u8) {
//                 return false;
//             }
//             std.debug.print("type_name arg's type is correct...\n", .{});
//             if (!field.is_comptime) {
//                 return false;
//             }
//             std.debug.print("type_name arg is comptime...\n", .{});
//         }
//     }
//     return true;
// }
// test "scalar" {
//     const A = struct {
//         // const json = std.json;
//         const Self = @This();
//         comptime type_name: []const u8 = "Null",
//         pub fn serialize(self: *Self) []const u8 {
//             _ = self;
//             return "null";
//         }
//         pub fn deserialize(input: []const u8) Self {
//             _ = input;
//             return Self{};
//         }
//     };
//     try std.testing.expect(gql.isScalarType(A));
// }
// those things are not friendly for building high-level api
