//! iterator trait and some specific methods
const std = @import("std");
/// check if the iter type is an iterator over type inner
pub fn isIteratorOf(comptime iter: type, comptime inner: type) bool {
    // iterator should be a struct type
    if(@typeInfo(iter) != .Struct) return false;
    // should have a next() method
    if (!comptime @hasDecl(iter, "next")) return false;
    const next_fn_info = @typeInfo(@TypeOf(@field(iter, "next")));
    if (next_fn_info != .Fn) return false;
    const return_type = next_fn_info.Fn.return_type;
    // next() should return an optional of type inner
    if(return_type.? != ?inner) return false;
    return true;
}
/// an empty iterator implementation
/// will always return null
pub fn EmptyIter(comptime T: type) type {
    return struct {
        pub fn next() ?T {
            return null;
        }
    };
}

const testing = std.testing;
test "iter" {
    const EmptyIterI32 = EmptyIter(i32);
    try testing.expect(isIteratorOf(EmptyIterI32, i32));
}

/// check if the type could be iterate
/// inner type represents the iterator's inner type
pub fn isIterable(comptime target: type, comptime inner: type) bool {
    // need to be struct type to have function field
    if(@typeInfo(target) != .Struct) return false;
    if(!comptime @hasDecl(target, "iter")) return false;
    const iter_fn_info = @typeInfo(@TypeOf(@field(target, "iter")));
    if(iter_fn_info != .Fn) return false;
    const iter_return_type = iter_fn_info.Fn.return_type;
    // iter function should return a iterator that will pass the isIteratorOf trait
    if(isIteratorOf(iter_return_type.?, ?*const inner)) return false;
    if(!comptime @hasDecl(target, "iter_mut")) return false;
    const iter_mut_fn_info = @typeInfo(@TypeOf(@field(target, "iter_mut")));
    if(iter_mut_fn_info != .Fn) return false;
    const iter_mut_return_type = iter_mut_fn_info.Fn.return_type;
    // iter function should return a iterator that will pass the isIteratorOf trait
    if(isIteratorOf(iter_mut_return_type.?, ?*inner)) return false;
    return true;
}

pub fn EmptyIterable(comptime T: type) type {
    return struct {
        pub fn iter() EmptyIter(*const T) {
            return EmptyIter(*const T){};
        }
        pub fn iter_mut() EmptyIter(*T) {
            return EmptyIter(*T){};
        }
    };
}

test "iterable" {
    const EIi32 = EmptyIterable(i32);
    try testing.expect(isIterable(EIi32, i32));
}