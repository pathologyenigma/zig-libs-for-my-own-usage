const std = @import("std");
/// Component constructor
/// create a normal zig struct using args
/// and create it's storage using options
/// leave options .{} for default options
/// example:
/// const Transform = Component(.{
///     .x = 0.0,
///     .y = 0.0,
///     .z = 0.0
/// }, .{});
/// then you can just using this type as a component inside any system function
pub fn Component(comptime args: anytype, comptime options: ComponentOptions) type {
    // check the options and set up storage of this type
    // check about the arguments for more details(component type arguments should all be ownned types or will cause memory leak)
    // return the final component type
}
