const std = @import("std");
const net = std.net;
const posix = std.posix;

pub fn simpleHttpServer() !void {
    // 1. 解析地址
    const address = try net.Address.parseIp("127.0.0.1", 8080);

    // 2. 创建 socket
    const sockfd = try posix.socket(address.any.family, posix.SOCK.STREAM | posix.SOCK.CLOEXEC, 0);
    // 注意：不要在这里 defer close，因为 Server.deinit() 会关闭它

    // 3. 设置 socket 选项（地址重用）
    const enable: c_int = 1;
    try posix.setsockopt(sockfd, posix.SOL.SOCKET, posix.SO.REUSEADDR, std.mem.asBytes(&enable));

    // 4. 绑定地址
    try posix.bind(sockfd, &address.any, address.getOsSockLen());

    // 5. 开始监听
    try posix.listen(sockfd, 128);

    // 6. 现在可以创建 Server 了
    var server = net.Server{
        .listen_address = address,
        .stream = net.Stream{ .handle = sockfd },
    };
    defer server.deinit();

    std.debug.print("🚀 Server listening on http://127.0.0.1:8080\n", .{});

    // 7. 接受连接
    while (true) {
        const connection = try server.accept();

        // 处理连接
        handleConnection(connection) catch |err| {
            std.debug.print("Error handling connection: {}\n", .{err});
        };
    }
}

fn handleConnection(connection: net.Server.Connection) !void {
    defer connection.stream.close();

    std.debug.print("✅ Client connected from {any}\n", .{connection.address});

    // 读取请求
    var buffer: [4096]u8 = undefined;
    const bytes_read = try connection.stream.read(&buffer);

    if (bytes_read == 0) {
        return;
    }

    const request = buffer[0..bytes_read];

    // 解析请求的第一行
    if (std.mem.indexOf(u8, request, "\r\n")) |line_end| {
        const first_line = request[0..line_end];
        std.debug.print("📥 Request: {s}\n", .{first_line});

        // 解析方法和路径
        var parts = std.mem.tokenizeScalar(u8, first_line, ' ');
        const method = parts.next() orelse "UNKNOWN";
        std.debug.print("method: {s}\n", .{method});
        const path = parts.next() orelse "/";

        // 根据路径返回不同的内容
        if (std.mem.eql(u8, path, "/")) {
            try sendHomePage(connection);
        } else if (std.mem.eql(u8, path, "/api")) {
            try sendApiResponse(connection);
        } else {
            try send404(connection);
        }
    } else {
        try sendError(connection, 400, "Bad Request");
    }
}

fn sendHomePage(connection: net.Server.Connection) !void {
    const html =
        \\<!DOCTYPE html>
        \\<html>
        \\<head>
        \\    <title>Zig HTTP Server</title>
        \\    <style>
        \\        body {
        \\            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
        \\            max-width: 800px;
        \\            margin: 50px auto;
        \\            padding: 20px;
        \\            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        \\            min-height: 100vh;
        \\        }
        \\        .container {
        \\            background: white;
        \\            border-radius: 15px;
        \\            padding: 40px;
        \\            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
        \\        }
        \\        h1 {
        \\            color: #333;
        \\            margin-bottom: 30px;
        \\            padding-bottom: 15px;
        \\            border-bottom: 3px solid #667eea;
        \\        }
        \\        .info-box {
        \\            background: #f7f9fc;
        \\            padding: 20px;
        \\            border-radius: 8px;
        \\            margin: 20px 0;
        \\        }
        \\        .endpoint {
        \\            background: #fff;
        \\            padding: 12px 20px;
        \\            margin: 10px 0;
        \\            border-left: 4px solid #667eea;
        \\            border-radius: 4px;
        \\            font-family: 'Courier New', monospace;
        \\            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        \\        }
        \\        .method {
        \\            display: inline-block;
        \\            padding: 3px 8px;
        \\            background: #667eea;
        \\            color: white;
        \\            border-radius: 3px;
        \\            font-weight: bold;
        \\            margin-right: 10px;
        \\        }
        \\    </style>
        \\</head>
        \\<body>
        \\    <div class="container">
        \\        <h1>🚀 Zig HTTP Server</h1>
        \\        <div class="info-box">
        \\            <h2>Server Info</h2>
        \\            <p>✅ Status: Running</p>
        \\            <p>📍 Address: 127.0.0.1:8080</p>
        \\            <p>⏰ Time: <span id="time"></span></p>
        \\        </div>
        \\        <div class="info-box">
        \\            <h2>Available Endpoints</h2>
        \\            <div class="endpoint">
        \\                <span class="method">GET</span> / - Home page
        \\            </div>
        \\            <div class="endpoint">
        \\                <span class="method">GET</span> /api - JSON API response
        \\            </div>
        \\        </div>
        \\    </div>
        \\    <script>
        \\        function updateTime() {
        \\            document.getElementById('time').textContent = new Date().toLocaleString();
        \\        }
        \\        updateTime();
        \\        setInterval(updateTime, 1000);
        \\    </script>
        \\</body>
        \\</html>
    ;

    var response_buf: [8192]u8 = undefined;
    const response = try std.fmt.bufPrint(&response_buf, "HTTP/1.1 200 OK\r\n" ++
        "Content-Type: text/html; charset=utf-8\r\n" ++
        "Content-Length: {d}\r\n" ++
        "Connection: close\r\n" ++
        "\r\n" ++
        "{s}", .{ html.len, html });

    _ = try connection.stream.write(response);
}

fn sendApiResponse(connection: net.Server.Connection) !void {
    const timestamp = std.time.timestamp();

    var json_buf: [256]u8 = undefined;
    const json = try std.fmt.bufPrint(&json_buf,
        \\{{
        \\  "status": "success",
        \\  "message": "Hello from Zig API",
        \\  "timestamp": {d},
        \\  "version": "1.0.0"
        \\}}
    , .{timestamp});

    var response_buf: [512]u8 = undefined;
    const response = try std.fmt.bufPrint(&response_buf, "HTTP/1.1 200 OK\r\n" ++
        "Content-Type: application/json\r\n" ++
        "Content-Length: {d}\r\n" ++
        "Connection: close\r\n" ++
        "\r\n" ++
        "{s}", .{ json.len, json });

    _ = try connection.stream.write(response);
}

fn send404(connection: net.Server.Connection) !void {
    const html =
        \\<!DOCTYPE html>
        \\<html>
        \\<head><title>404 Not Found</title></head>
        \\<body>
        \\    <h1>404 - Page Not Found</h1>
        \\    <p>The requested page was not found on this server.</p>
        \\    <a href="/">Go back to home</a>
        \\</body>
        \\</html>
    ;

    var response_buf: [512]u8 = undefined;
    const response = try std.fmt.bufPrint(&response_buf, "HTTP/1.1 404 Not Found\r\n" ++
        "Content-Type: text/html\r\n" ++
        "Content-Length: {d}\r\n" ++
        "Connection: close\r\n" ++
        "\r\n" ++
        "{s}", .{ html.len, html });

    _ = try connection.stream.write(response);
}

fn sendError(connection: net.Server.Connection, status_code: u16, status_text: []const u8) !void {
    var response_buf: [256]u8 = undefined;
    const response = try std.fmt.bufPrint(&response_buf, "HTTP/1.1 {d} {s}\r\n" ++
        "Content-Type: text/plain\r\n" ++
        "Content-Length: {d}\r\n" ++
        "Connection: close\r\n" ++
        "\r\n" ++
        "{s}", .{ status_code, status_text, status_text.len, status_text });

    _ = try connection.stream.write(response);
}
