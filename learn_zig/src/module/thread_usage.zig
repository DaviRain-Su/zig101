const std = @import("std");
const Thread = std.Thread;

pub fn basicThreadExample() !void {
    std.debug.print("Basic main thread example start....\n", .{});

    // create a new thread
    const thread = try Thread.spawn(.{}, workerFunction, .{"Hello from worker thread!"});

    // wait for thread to finish
    thread.join();

    std.debug.print("Basic main thread example end....\n", .{});
}

fn workerFunction(message: []const u8) void {
    std.debug.print("Worker thread message: {s}\n", .{message});
    // use sleep from Thread.sleep
    Thread.sleep(5 * std.time.ns_per_s); // sleep 1s
}

pub fn multipleThreads(comptime num: usize) !void {
    var threads: [num]Thread = undefined;

    // create threads
    for (&threads, 0..) |*t, i| {
        t.* = try Thread.spawn(.{}, worker, .{i});
    }

    // wait for all threads to finish
    for (threads) |thread| {
        thread.join();
    }
}

fn worker(id: usize) void {
    std.debug.print("Worker thread id: {d}\n", .{id});
    Thread.sleep(2 * std.time.ns_per_s); // sleep 1s
    std.debug.print("Worker thread id: {d} finished\n", .{id});
}

const WorkerResult = struct {
    thread_id: usize,
    result: i32,
};

pub fn threadWithResult(comptime num: usize) !void {
    var results: [num]WorkerResult = undefined;
    var threads: [num]Thread = undefined;

    for (&threads, 0..) |*t, i| {
        t.* = try Thread.spawn(.{}, computeWork, .{ i, &results[i] });
    }

    for (threads) |thread| {
        thread.join();
    }

    for (results) |result| {
        std.debug.print("Thread id: {d}, result: {d}\n", .{ result.thread_id, result.result });
    }
}

fn computeWork(id: usize, result: *WorkerResult) void {
    Thread.sleep(1 * std.time.ns_per_s); // sleep 1s
    result.thread_id = id;
    result.result = @intCast(id * 2);
}

fn Counter(comptime T: type) type {
    return struct {
        mutex: std.Thread.Mutex = .{},
        value: T,

        const Self = @This();

        pub fn init(value: T) Self {
            return Self{ .value = value };
        }

        pub fn increment(self: *Self) void {
            self.mutex.lock();
            defer self.mutex.unlock();
            const v_t = @typeInfo(T);
            switch (v_t) {
                .int => {
                    self.value += 1;
                },
                .float => {
                    self.value += 1.1;
                },
                else => unreachable,
            }
        }

        pub fn getValue(self: *Self) T {
            self.mutex.lock();
            defer self.mutex.unlock();
            return self.value;
        }
    };
}

pub fn mutexExample(comptime T: type, comptime num: usize, v: T) !void {
    var counter = Counter(T).init(v);
    var thread: [num]Thread = undefined;

    for (&thread) |*t| {
        t.* = try Thread.spawn(.{}, struct {
            fn run(c: *Counter(T)) void {
                for (0..num) |_| {
                    c.increment();
                }
            }
        }.run, .{&counter});
    }

    for (thread) |t| {
        t.join();
    }

    std.debug.print("Final value: {any}\n", .{counter.getValue()});
}
