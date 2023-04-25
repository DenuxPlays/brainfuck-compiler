const std = @import("std");
const cli = @import("zig-cli");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

var file = cli.Option{
    .long_name = "path",
    .help = "Path to the file to compile.",
    .value = cli.OptionValue{ .string = "main.bf" },
};

var app = &cli.App{
    .name = "bfc",
    .options = &.{&file},
    .action = enter_file,
};

const allowed_characters = [_]u8{ '>', '<', '+', '-', '.', ',', '[', ']' };

pub fn main() !void {
    return cli.run(app, allocator);
}

fn enter_file(_: []const []const u8) !void {
    var f = file.value.string.?;
    std.log.debug("Path to file: {s}", .{f});

    var file_f = try std.fs.cwd().openFile(f, .{});
    defer file_f.close();

    var buf_reader = std.io.bufferedReader(file_f.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        std.log.debug("{s}", .{line});
        for (range(line.len - 1)) |_, i| {
            var char = line[i];
            std.log.debug("Char: {} contains: {}", .{ char, contains(char) });
        }
    }
}

fn range(len: usize) []const void {
    return @as([*]void, undefined)[0..len];
}

fn contains(char: u8) bool {
    for (range(allowed_characters.len)) |_, i| {
        if (char == allowed_characters[i]) {
            return true;
        }
    }
    return false;
}

pub fn parser() void {}
