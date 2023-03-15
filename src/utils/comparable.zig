//! comparable type trait
const std = @import("std");
const StringHashMap = std.hash_map.StringHashMap;
const validate = @import("validate");
/// enum for comparing results
pub const CompareResult = enum(u8) {
    Greater = 0,
    Equal = 1,
    Less = 2,
};
// fn ComparableMethodsRule(comptime T: type) fn (?type) type {
//     return struct {
//         pub fn function(comptime RHS: ?type) type {
//             return comptime struct {
//                 const Self = @This();
//                 const Target = rhs: {
//                     if (RHS) |R| {
//                         break :rhs R;
//                     }
//                     break :rhs T;
//                 };
//                 comptime RHS: type = Target,
//                 cmpFn: *const fn (T, Target) CompareResult,
//             };
//         }
//     }.function;
// }
// fn InterfaceTypeInfer(comptime Impl: type, comptime RHS: ?type) fn (comptime ComparableMethodsRule(Impl)(RHS)) type {
//     return struct {
//         pub fn run(comptime rules: ComparableMethodsRule(Impl)(RHS)) type {
//             return struct {
//                 impl: Impl,
//                 const Self = @This();
//                 pub inline fn cmp(self: Self, rhs: rules.RHS) CompareResult {
//                     return rules.cmpFn(self.impl, rhs);
//                 }
//             };
//         }
//     }.run;
// }

// /// basic comparable trait
// /// the cmp is the only required method
// /// more methods coming soon
// pub fn Comparable(comptime Impl: type) type {
//     return struct {
//         pub fn impl(comptime RHS: ?type) fn (comptime ComparableMethodsRule(Impl)(RHS)) type {
//             return struct {
//                 pub fn function(comptime rules: ComparableMethodsRule(Impl)(RHS)) fn (Impl) InterfaceTypeInfer(Impl, RHS)(rules) {
//                     return struct {
//                         pub fn run(impl_: Impl) InterfaceTypeInfer(Impl, RHS)(rules) {
//                             return .{
//                                 .impl = impl_,
//                             };
//                         }
//                     }.run;
//                 }
//             }.function;
//         }
//     };
// }

// pub fn isComparableTo(comptime T: type) fn (type) bool {
//     return struct {
//         pub fn fun(subtype: type) bool {
//             const compareFunctionName = if(T == subtype) {
//                 "cmpSelf";
//             } else {
//                 "cmp" ++ @typeName(subtype);
//             };
//             const trait = std.meta.trait;
//             // const Type = std.builtin.Type;
//             if(!trait.hasFn(compareFunctionName)) return false;
//             const typeInfo = @typeInfo(T);
//             if(typeInfo != .Struct) {
//                 return false;
//             }
//             const typeStructInfo = typeInfo.Struct;
//             for(typeStructInfo.fields) |field| {
//                 if(field.type == InterfaceTypeInfer(T, subtype)) return true;
//             }
//             return false;
//         }
//     }.fun;
// }
// something I wish will work in the future version of zig
// pub fn ComparableManager(comptime Impl: type) type {
//     return struct {
//         map: StringHashMap(*const anyopaque) = StringHashMap(*const anyopaque).init(std.heap.page_allocator),
//         const Self = @This();
//         const TypeArgs = struct {
//             comptime RHS: ?type = null,
//         };

//         const Result = struct {
//             map: StringHashMap(*anyopaque),
//             pub fn cmp(self: @This(), comptime RHS: type) fn (Impl, RHS) CompareResult {
//                 if (self.map.get(@typeName(RHS)) == null) {
//                     @compileError("the trait Comparable(RHS: " ++ @typeName(RHS) ++ ") is not satisfied, do you have the implementation for that type?");
//                 }
//                 return @ptrCast(*const fn (Impl, RHS) CompareResult, self.map.get(@typeName(RHS)));
//             }
//         };
//         pub fn init() Self {
//             comptime {
//                 return Self{};
//             }
//         }
//         fn MethodBuilder(comptime type_args: TypeArgs, comptime self: Self) fn (comptime ComparableMethodsRule(Impl)(type_args.RHS)) Self {
//             // generate method types using type arguments that input
//             // return those methods with a struct with the impl function
//             return struct {
//                 pub fn impl(comptime rules: ComparableMethodsRule(Impl)(type_args.RHS)) Self {
//                     comptime {
//                         var map = try self.map.clone();
//                         try map.put(typename: {
//                             if (type_args.RHS) |some| {
//                                 break :typename @typeName(some);
//                             }
//                             break :typename @typeName(Impl);
//                         }, @ptrCast(*const anyopaque, &rules.cmpFn));
//                         self.map.deinit();
//                         self.map = map;
//                         return self;
//                     }
//                 }
//             }.impl;
//         }
//         pub fn where(comptime self: Self, comptime type_args: TypeArgs) fn (comptime ComparableMethodsRule(Impl)(type_args.RHS)) Self {
//             // return a MethodBuilder
//             return MethodBuilder(type_args, self);
//         }
//         pub fn end(comptime self: *Self) Result {
//             return Result{
//                 .map = self.map,
//             };
//         }
//     };
// }
pub fn Comparable(comptime RHS: type) type {
    return struct {
        const cmp = fn(*const @This(), *const RHS) CompareResult;
    };
}

pub fn compare(self: anytype, rhs: anytype) CompareResult {
    const Self = validate.utils.Deref(@TypeOf(self));
    const RHS = validate.utils.Deref(@TypeOf(rhs));
    const comparable = blk: {
        if(Self == RHS) {
            break :blk validate.static(Self.ComparableSelf, Comparable(RHS));
        } else if(@hasField(Self, "Comparable" ++ @typeName(RHS) )){
            break :blk validate.static(@field(Self, "Comparable" ++ @typeName(RHS)), Comparable(RHS));
        } else {
            @compileError("comparable implementation for " ++ @typeName(RHS) ++ "is not found, if you implemented it with a generic type, please use the generic version of this function instead");
        }
    };
    
    return comparable.Target.cmp(self, rhs);
}

pub fn compareWithCustomizedImplementation(comptime TraitType: type, self: anytype, rhs: anytype) CompareResult {
    const RHS = validate.utils.Deref(@TypeOf(rhs));
    const comparable = validate.static(TraitType, Comparable(RHS));
    return comparable.Target.cmp(self, rhs);    
}