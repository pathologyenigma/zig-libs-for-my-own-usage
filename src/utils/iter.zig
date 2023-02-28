//! iterator trait and some specific methods
const std = @import("std");
/// basic iterator trait
/// the next is the only required method
/// more methods coming soon
pub fn Iterator(comptime Impl: type, comptime Value: type, comptime methods: struct {
    next: *const fn (Impl) ?Value,
}) type {
    return struct {
        pub const @"utils.Iterator" = struct {
            impl: Impl,
            const Self = @This();
            pub const Item = Value;
            pub inline fn next(self: Self) ?Item {
                return methods.next(self.impl);
            }
        };
        pub fn iterator(self: Impl) @"utils.Iterator" {
            return .{
                .impl = self,
            };
        }
    };
}
