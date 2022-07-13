const std = @import("std");

pub fn build(b: *std.build.Builder) !void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    const exe = b.addExecutable("c_template", null);    
    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.install();
    exe.linkLibC();
    exe.addIncludeDir("./include/");
    const source_files = try getSourceFiles(b.allocator);
    exe.addCSourceFiles(
        source_files,
        &.{
            "-std=c11",
            "-pedantic",
            "-Wall",
            "-W",
            "-Wno-missing-field-initializers",
            "-fno-sanitize=undefined",
        }
    );
}

pub fn getSourceFiles(allocator: std.mem.Allocator) ![]const []const u8 {
    var source_files = std.ArrayList([]const u8).init(allocator);
    defer source_files.deinit();

    const dir = try std.fs.cwd().openDir("./src", .{ .iterate = true });
    var iter = dir.iterate();

    while (try iter.next()) |file| {
        const path = try std.mem.concat(
            allocator,
            u8,
            &[_][]const u8{
                "./src/",
                file.name,
            }
        );
        try source_files.append(path);
    }

    return source_files.toOwnedSlice();
}
