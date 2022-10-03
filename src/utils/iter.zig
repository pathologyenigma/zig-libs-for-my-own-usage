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

const testing = @import("std").testing;
test "iter" {
    const EmptyIterI32 = iter.EmptyIter(i32);
    try testing.expect(iter.isIteratorOf(EmptyIterI32, i32));
}