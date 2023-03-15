//! iterator trait and some specific methods
const std = @import("std");
/// basic iterator trait
/// the next is the only required method
/// more methods coming soon
pub fn Iterator(comptime Item: type) type {
    return struct {
        const Self = @This();
        next: *const fn(*Self) ?Item
    };
}