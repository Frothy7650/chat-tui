import net
import os

// ---------------------
// TCP Framing helpers
// ---------------------
fn read_exact(mut conn net.TcpConn, n int) ![]u8 {
  mut buf := []u8{len: n}
  mut off := 0

  for off < n {
    r := conn.read(mut buf[off..])!
    if r == 0 {
      return error('connection closed')
    }
    off += r
  }

  return buf
}

fn read_msg(mut conn net.TcpConn) !string {
  len_buf := read_exact(mut conn, 4)!
  msg_len := int(
    (u32(len_buf[0]) << 24) |
    (u32(len_buf[1]) << 16) |
    (u32(len_buf[2]) << 8)  |
     u32(len_buf[3])
  )

  if msg_len <= 0 || msg_len > 65536 {
    return error('invalid message length')
  }

  data := read_exact(mut conn, msg_len)!
  return data.bytestr()
}

fn write_msg(mut conn net.TcpConn, msg string) ! {
  data := msg.bytes()
  l := u32(data.len)

  conn.write([
    u8((l >> 24) & 0xff),
    u8((l >> 16) & 0xff),
    u8((l >> 8) & 0xff),
    u8(l & 0xff),
  ])!

  conn.write(data)!
}

// ---------------------
// Main client
// ---------------------
fn main() {
  mut conn := net.dial_tcp("frothy7650.org:9001")!
  defer { conn.close() or {} }

  print("Username: ")
  username := os.get_line()

  write_msg(mut conn, "JOIN ${username}") or { return }

  go read_loop(mut conn, username)

  for {
    line := os.get_line()
    if line.trim_space().to_lower() == "quit" { return }

    write_msg(mut conn, "MSG ${line}") or { break }
  }
}

// ---------------------
// Background reader
// ---------------------
fn read_loop(mut conn net.TcpConn, username string) {
  for {
    msg := read_msg(mut conn) or { break }

    // Skip our own messages
    if msg.contains("MSG ${username}:") {
      continue
    }

    println(msg)
  }
}
