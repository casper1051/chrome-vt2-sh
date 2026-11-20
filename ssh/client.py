import sys
import urllib.error
import urllib.request

if len(sys.argv) < 2:
    print("Usage: python3 http_sh_client.py http://<ip>:<port>")
    sys.exit(1)

url = sys.argv[1].rstrip("/")

while True:
    try:
        cmd = input("remote$ ").strip()
    except (EOFError, KeyboardInterrupt):
        print()
        break

    if not cmd:
        continue
    if cmd in ("exit", "quit"):
        break

    req = urllib.request.Request(
        url,
        data=cmd.encode("utf-8"),
        method="POST",
        headers={"Content-Type": "text/plain; charset=utf-8"},
    )
    try:
        with urllib.request.urlopen(req, timeout=65) as resp:
            print(resp.read().decode("utf-8", errors="replace"), end="")
    except urllib.error.URLError as e:
        print(f"Request error: {e}")
