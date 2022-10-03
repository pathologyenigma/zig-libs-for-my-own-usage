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