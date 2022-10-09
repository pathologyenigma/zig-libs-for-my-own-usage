// //! gql parser aims to parse zig code to schema string
// //! and parse query string to zig variables
// //! cause that Query Mutation and Subscription are also schema objects
// //! this will works for them too
// const gql = @import("gql.zig");
// const std = @import("std");
// const parser = @This();

// /// zig tyoe to graphql type definitions
// /// output type is auto-detected
// /// like struct will become object
// /// union will become union
// /// enum will become enum
// /// scalar type will become scalar type
// pub fn zigTypeToGraphqlType(comptime T: type, comptime subTypeOfOptional: bool) []const u8 {
//     const typeInfo = @typeInfo(T);
//     if (gql.isScalarType(T)) return res: {
//         if (subTypeOfOptional) break :res T.type_name;
//         break :res T.type_name ++ "!";
//     };

//     switch (typeInfo) {
//         .Type, .Void, .NoReturn => {
//             @compileError("not supported type to parse");
//         },
//         .ComptimeFloat, .ComptimeInt => {
//             @compileError(
//                 \\ compile time value is not able to deserialize from runtime.
//                 \\ using the same type runtime value instead
//             );
//         },
//         .Undefined, .Null => {
//             @compileError(
//                 \\ undefined and null value is not supported in the graphql side
//                 \\ if you really need some type to describe for no return from the api
//                 \\ try to declare a scalar type about it
//             );
//         },
//         .Vector => {
//             @compileError(
//                 \\ Vector type is not supported in the current version of this project
//                 \\ also Vector type in zig is not the same as vecoter type in c++ std lib or rust's Vec type
//                 \\ it is static sized simd vector, try arraylist if you want some dynamic size array
//             );
//         },
//         .Frame, .AnyFrame => {
//             @compileError(
//                 \\ frame type are not some thing that could be parsed to gql type
//                 \\ and you don't have to
//             );
//         },
//         .Opaque => {
//             @compileError(
//                 \\ opaque type are not actually zig type
//                 \\ try to implemente a scalar type for it
//                 \\ if you want to parse it
//             );
//         },
//         .EnumLiteral => {
//             @compileError(
//                 \\ using enum or union instead
//             );
//         },
//         .Bool => {
//             return res: {
//                 if (subTypeOfOptional) break :res "Boolean";
//                 break :res "Boolean!";
//             };
//         },
//         .Int => {
//             // will become graphql's int type
//             // that is why I ignore the value of this type here
//             return res: {
//                 if (subTypeOfOptional) break :res "Int";
//                 break :res "Int!";
//             };
//         },
//         .Float => {
//             // same reason as above
//             return res: {
//                 if (subTypeOfOptional) break :res "Float";
//                 break :res "Float!";
//             };
//         },
//         .Pointer => |p| {
//             return parsePointerType(p);
//         },
//         .Array => |array| {
//             // a lot people don't know but there actually is a type like this [A!]!
//             return res: {
//                 if (subTypeOfOptional) break :res "[" ++ zigTypeToGraphqlType(array.child, false) ++ "]";
//                 break :res "[" ++ zigTypeToGraphqlType(array.child) ++ "]!";
//             };
//         },
//         .Struct => |obj| {
//             comptime var res = "type " ++ @typeName(obj) ++ " {";
//             for (obj.fields) |field| {
//                 res = res ++ "\t\t" + field.name + ": " + zigTypeToGraphqlType(field.field_type, false) ++ "\n";
//             }
//             res = res ++ "}";
//             return res;
//         },
//         .Optional => |op| {
//             return zigTypeToGraphqlType(op.child);
//         },
//         // ErrorUnion: ErrorUnion,
//         // ErrorSet: ErrorSet,
//         // Enum: Enum,
//         // Union: Union,
//         // Fn: Fn,
//         // BoundFn: Fn,
//     }
// }

// /// parse one field of enum struct or union
// fn parseFieldOfAComplexType(comptime T: type, comptime isSubtype: bool) []const u8 {
//     if (isSubtype) return @typeName(T);

//     const typeInfo = @typeInfo(T);
//     switch (typeInfo) {
//         .Int, .Float, .Bool => {
//             return zigTypeToGraphqlType(T, false);
//         },
//         .Pointer => |p| {
//             if (T == []const u8) return res: {
//                 if (subTypeOfOptional) break :res "String";
//                 break :res "String!";
//             };
//             return parsePointerType(p.child);
//         },
//     }
// }

// fn parsePointerType(comptime ptr: std.builtin.Type.Pointer) []const u8 {
//     if (ptr.size != .One) {
//         // for string types
//         if (ptr.child == u8) return res: {
//             if (subTypeOfOptional) break :res "String";
//             break :res "String!";
//         };
//         @compileError(
//             \\ array pointer or slice is only supported for u8
//             \\ because of zig's string implementation
//             \\ try arraylist type from the standard library
//             \\ if you need a unknown size container of something
//         );
//     }
//     switch (@typeInfo(ptr.child)) {
//         .Struct, .Union => {
//             return zigTypeToGraphqlType(ptr.child, false);
//         },
//         else => {
//             @compileError(
//                 \\ only support struct or union pointer here
//             );
//         },
//     }
// }
