#!/usr/bin/env python3
import fcntl
import html
import json
import os
import pty
import select
import signal
import struct
import sys
import termios
import threading
import time

class VirtualTerminal:
    def __init__(self, cols=78, rows=17):
        self.cols = cols
        self.rows = rows
        self.grid = [[(" ", "") for _ in range(cols)] for _ in range(rows)]
        self.cx = 0
        self.cy = 0
        self.fg = ""
        self.bold = False
        self.saved_cursor = (0, 0)
        self.state = "normal"
        self.esc_buf = ""

    def resize(self, cols, rows):
        cols = max(20, cols)
        rows = max(5, rows)
        new_grid = [[(" ", "") for _ in range(cols)] for _ in range(rows)]
        for r in range(min(self.rows, rows)):
            for c in range(min(self.cols, cols)):
                new_grid[r][c] = self.grid[r][c]
        self.cols = cols
        self.rows = rows
        self.grid = new_grid
        self.cx = min(self.cx, cols - 1)
        self.cy = min(self.cy, rows - 1)

    def scroll_up(self):
        self.grid.pop(0)
        self.grid.append([(" ", "") for _ in range(self.cols)])

    def put_char(self, ch):
        if self.cx >= self.cols:
            self.cx = 0
            self.cy += 1
        if self.cy >= self.rows:
            self.scroll_up()
            self.cy = self.rows - 1
        style = ""
        if self.fg:
            style += f"color:{self.fg};"
        if self.bold:
            style += "font-weight:700;"
        self.grid[self.cy][self.cx] = (ch, style)
        self.cx += 1

    def feed(self, text):
        for ch in text:
            if self.state == "normal":
                if ch == "\x1b":
                    self.state = "esc"
                    self.esc_buf = ""
                elif ch == "\r":
                    self.cx = 0
                elif ch == "\n":
                    self.cy += 1
                    if self.cy >= self.rows:
                        self.scroll_up()
                        self.cy = self.rows - 1
                elif ch == "\b" or ch == "\x7f":
                    if self.cx > 0:
                        self.cx -= 1
                elif ch == "\t":
                    nxt = (self.cx + 4) & ~3
                    while self.cx < min(nxt, self.cols):
                        self.put_char(" ")
                elif ord(ch) >= 32:
                    self.put_char(ch)
            elif self.state == "esc":
                if ch == "[":
                    self.state = "csi"
                    self.esc_buf = ""
                elif ch == "]":
                    self.state = "osc"
                    self.esc_buf = ""
                elif ch in ("(", ")", "*", "+"):
                    self.state = "charset"
                else:
                    self.state = "normal"
            elif self.state == "charset":
                self.state = "normal"
            elif self.state == "osc":
                if ch == "\x07":
                    self.state = "normal"
                elif ch == "\x1b":
                    self.state = "osc_esc"
            elif self.state == "osc_esc":
                if ch == "\\":
                    self.state = "normal"
                else:
                    self.state = "osc"
            elif self.state == "csi":
                if "@" <= ch <= "~":
                    self.handle_csi(self.esc_buf, ch)
                    self.state = "normal"
                else:
                    self.esc_buf += ch

    def handle_csi(self, params, cmd):
        clean = params.lstrip("?>=")
        parts = [p for p in clean.split(";") if p != ""]
        nums = []
        for p in parts:
            try:
                nums.append(int(p))
            except ValueError:
                nums.append(0)
        n1 = nums[0] if len(nums) >= 1 else 0
        n2 = nums[1] if len(nums) >= 2 else 0

        if cmd == "A":
            self.cy = max(0, self.cy - max(1, n1))
        elif cmd == "B":
            self.cy = min(self.rows - 1, self.cy + max(1, n1))
        elif cmd == "C":
            self.cx = min(self.cols - 1, self.cx + max(1, n1))
        elif cmd == "D":
            self.cx = max(0, self.cx - max(1, n1))
        elif cmd == "G":
            self.cx = max(0, min(self.cols - 1, max(1, n1) - 1))
        elif cmd in ("H", "f"):
            r = max(1, n1) - 1
            c = max(1, n2) - 1
            self.cy = max(0, min(self.rows - 1, r))
            self.cx = max(0, min(self.cols - 1, c))
        elif cmd == "J":
            if n1 == 2 or n1 == 3:
                self.grid = [[(" ", "") for _ in range(self.cols)] for _ in range(self.rows)]
                if n1 == 2:
                    self.cx = 0
                    self.cy = 0
            elif n1 == 0:
                for c in range(self.cx, self.cols):
                    self.grid[self.cy][c] = (" ", "")
                for r in range(self.cy + 1, self.rows):
                    self.grid[r] = [(" ", "") for _ in range(self.cols)]
        elif cmd == "K":
            if n1 == 0:
                for c in range(self.cx, self.cols):
                    self.grid[self.cy][c] = (" ", "")
            elif n1 == 1:
                for c in range(0, min(self.cx + 1, self.cols)):
                    self.grid[self.cy][c] = (" ", "")
            elif n1 == 2:
                self.grid[self.cy] = [(" ", "") for _ in range(self.cols)]
        elif cmd == "s":
            self.saved_cursor = (self.cx, self.cy)
        elif cmd == "u":
            self.cx, self.cy = self.saved_cursor
        elif cmd == "m":
            self.handle_sgr(nums if nums else [0])
        elif cmd in ("h", "l"):
            if "?1049" in params or "1049" in params:
                self.grid = [[(" ", "") for _ in range(self.cols)] for _ in range(self.rows)]
                self.cx = 0
                self.cy = 0

    def handle_sgr(self, nums):
        ansi_fg = {
            30: "#4b5563", 31: "#f87171", 32: "#4ade80", 33: "#facc15",
            34: "#60a5fa", 35: "#c084fc", 36: "#22d3ee", 37: "#e5e7eb",
            90: "#9ca3af", 91: "#fca5a5", 92: "#86efac", 93: "#fde047",
            94: "#93c5fd", 95: "#d8b4fe", 96: "#67e8f9", 97: "#ffffff",
        }
        i = 0
        while i < len(nums):
            code = nums[i]
            if code == 0:
                self.fg = ""
                self.bold = False
            elif code == 1:
                self.bold = True
            elif code == 22:
                self.bold = False
            elif code == 39:
                self.fg = ""
            elif code in ansi_fg:
                self.fg = ansi_fg[code]
            elif code == 38 and i + 2 < len(nums) and nums[i + 1] == 5:
                idx = nums[i + 2]
                if idx < 16:
                    base = [
                        "#4b5563", "#f87171", "#4ade80", "#facc15",
                        "#60a5fa", "#c084fc", "#22d3ee", "#e5e7eb",
                        "#9ca3af", "#fca5a5", "#86efac", "#fde047",
                        "#93c5fd", "#d8b4fe", "#67e8f9", "#ffffff",
                    ]
                    self.fg = base[idx]
                elif idx >= 232:
                    v = 8 + (idx - 232) * 10
                    self.fg = f"#{v:02x}{v:02x}{v:02x}"
                else:
                    idx -= 16
                    r = (idx // 36) * 51
                    g = ((idx % 36) // 6) * 51
                    b = (idx % 6) * 51
                    self.fg = f"#{r:02x}{g:02x}{b:02x}"
                i += 2
            elif code == 38 and i + 4 < len(nums) and nums[i + 1] == 2:
                self.fg = f"#{nums[i+2]:02x}{nums[i+3]:02x}{nums[i+4]:02x}"
                i += 4
            i += 1

    def render_html_lines(self):
        lines = []
        for r in range(self.rows):
            row = self.grid[r]
            last = self.cols - 1
            while last >= 0 and row[last][0] == " " and row[last][1] == "":
                last -= 1
            if last < 0 and r != self.cy:
                lines.append("")
                continue
            out = []
            cur_style = None
            buf = []
            limit = max(last + 1, self.cx + 1 if r == self.cy else 0)
            limit = min(limit, self.cols)
            for c in range(limit):
                ch, st = row[c]
                if r == self.cy and c == self.cx:
                    st = (st or "") + "background-color:#f08236;color:#000000;"
                if st != cur_style:
                    if buf:
                        txt = html.escape("".join(buf)).replace(" ", "&nbsp;")
                        out.append(f'<span style="{cur_style}">{txt}</span>' if cur_style else txt)
                        buf = []
                    cur_style = st
                buf.append(ch)
            if buf:
                txt = html.escape("".join(buf)).replace(" ", "&nbsp;")
                out.append(f'<span style="{cur_style}">{txt}</span>' if cur_style else txt)
            lines.append("".join(out))
        return lines


def set_winsize(fd, rows, cols):
    winsize = struct.pack("HHHH", rows, cols, 0, 0)
    fcntl.ioctl(fd, termios.TIOCSWINSZ, winsize)


def main():
    if len(sys.argv) < 5:
        sys.exit(1)
    cols = int(sys.argv[1])
    rows = int(sys.argv[2])
    cwd = sys.argv[3]
    cmd = sys.argv[4:]

    vt = VirtualTerminal(cols=cols, rows=rows)
    pid, master_fd = pty.fork()
    if pid == 0:
        if cwd and os.path.isdir(cwd):
            os.chdir(cwd)
        os.environ["TERM"] = "xterm-256color"
        os.environ["COLORTERM"] = "truecolor"
        os.execvp(cmd[0], cmd)

    set_winsize(master_fd, rows, cols)
    stop_flag = False

    def stdin_loop():
        nonlocal stop_flag
        while not stop_flag:
            line = sys.stdin.readline()
            if not line:
                stop_flag = True
                break
            try:
                msg = json.loads(line)
                mtype = msg.get("type")
                if mtype == "input":
                    data = msg.get("data", "")
                    if data:
                        os.write(master_fd, data.encode("utf-8"))
                elif mtype == "resize":
                    nc = int(msg.get("cols", cols))
                    nr = int(msg.get("rows", rows))
                    vt.resize(nc, nr)
                    set_winsize(master_fd, nr, nc)
                elif mtype == "quit":
                    stop_flag = True
                    try:
                        os.kill(pid, signal.SIGTERM)
                    except OSError:
                        pass
                    break
            except Exception:
                pass

    t = threading.Thread(target=stdin_loop, daemon=True)
    t.start()

    last_emit = 0.0
    dirty = False

    while not stop_flag:
        rlist, _, _ = select.select([master_fd], [], [], 0.04)
        if master_fd in rlist:
            try:
                chunk = os.read(master_fd, 8192)
                if not chunk:
                    break
                vt.feed(chunk.decode("utf-8", errors="replace"))
                dirty = True
            except OSError:
                break

        now = time.monotonic()
        if dirty and (now - last_emit >= 0.035):
            payload = {"lines": vt.render_html_lines(), "running": True}
            sys.stdout.write(json.dumps(payload) + "\n")
            sys.stdout.flush()
            last_emit = now
            dirty = False

    if dirty:
        payload = {"lines": vt.render_html_lines(), "running": False}
        sys.stdout.write(json.dumps(payload) + "\n")
        sys.stdout.flush()

    try:
        os.close(master_fd)
    except OSError:
        pass
    try:
        os.waitpid(pid, os.WNOHANG)
    except OSError:
        pass
    sys.stdout.write(json.dumps({"lines": vt.render_html_lines(), "running": False}) + "\n")
    sys.stdout.flush()


if __name__ == "__main__":
    main()
