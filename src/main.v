module main

import kutlayozger.chalk
import frothy7650.vircc
import term.ui as tui
import os

// Application State
struct App {
mut:
  tui         &tui.Context = unsafe { nil }
  conn        vircc.IrcConn

  messages    []string
  input_buf   string

  scroll      int
  autoscroll  bool = true
}

// IRC Receive Thread
fn start_receiver(mut app App) {
  go fn [mut app]() {
    for app.conn.is_running {
      app.conn.color = true
      line := app.conn.readline() or { continue }

      app.messages << line.trim_space()

      // auto scroll to bottom unless user scrolled up
      if app.autoscroll {
        app.scroll = 0
      }
    }
  }()
}

// Event Handler
fn event(e &tui.Event, x voidptr) {
  mut app := unsafe { &App(x) }

  if e.typ != .key_down {
    return
  }

  match e.code {

    .escape {
      // Hard exit
      app.conn.writeline("/quit") or {}
      exit(0)
    }

    .enter {
      if app.input_buf.len == 0 {
        return
      }

      if app.input_buf == "/clear".trim_space() {
        app.messages = []string{}
        app.scroll = 0
        app.input_buf = ""
        return
      }
      app.conn.writeline(app.input_buf) or {}

      // if /quit, vircc already sets is_running = false
      if !app.conn.is_running {
        exit(0)
      }
      
      if app.conn.channel != "" {
        if !app.input_buf.trim_space().starts_with("/") {
          app.messages << chalk.bold("<${chalk.cyan(app.conn.nick)}> ${app.input_buf.trim_space()}")
        }
      }
      app.input_buf = ""
      app.autoscroll = true
    }

    .backspace {
      if app.input_buf.len > 0 {
        app.input_buf = app.input_buf[..app.input_buf.len - 1]
      }
    }

    .up {
      if app.messages.len > 0 {
        app.scroll++
        app.autoscroll = false
      }
    }

    .down {
      if app.scroll > 0 {
        app.scroll--
      }

      if app.scroll == 0 {
        app.autoscroll = true
      }
    }

    else {
      if e.ascii != 0 {
        if e.ascii == 12 {
          app.messages = []string{}
          app.scroll = 0
        } else {
          app.input_buf += e.utf8
        }
      }
    }
  }
}

// Frame Renderer
fn frame(x voidptr) {
  mut app := unsafe { &App(x) }

  app.tui.clear()

  w := app.tui.window_width
  h := app.tui.window_height

  if h < 4 {
    app.tui.draw_text(0, 0, "Window too small.")
    app.tui.flush()
    return
  }

  // Top Status Bar
  app.tui.set_bg_color(tui.Color{ r: 40, g: 40, b: 40 })
  app.tui.draw_rect(0, 0, w - 1, 0)

  status := " ${app.conn.nick} | ${app.conn.channel} | ${if app.conn.is_running { "CONNECTED" } else { "DISCONNECTED" }} "

  app.tui.draw_text(1, 0, status)
  app.tui.reset()

  // Message Area
  msg_area_height := h - 3

  max_visible := msg_area_height

  total := app.messages.len

  mut start := total - max_visible - app.scroll
  if start < 0 {
    start = 0
  }

  mut end := start + max_visible
  if end > total {
    end = total
  }

  mut y := 2
  for i in start .. end {
    mut line := app.messages[i]

    // trim to window width
    if line.len > w {
      line = line[..w]
    }

    app.tui.draw_text(0, y, line)
    y++
  }

  // Separator
  app.tui.horizontal_separator(h - 2)

  // Input Line
  app.tui.set_bg_color(tui.Color{ r: 30, g: 30, b: 30 })
  app.tui.draw_rect(0, h - 1, w - 1, h - 1)

  mut input_line := "> ${app.input_buf}"

  if input_line.len > w {
    input_line = input_line[input_line.len - w..]
  }

  app.tui.draw_text(0, h - 1, input_line)

  mut cursor_x := 3 + app.input_buf.len
  if cursor_x >= w {
    cursor_x = w - 1
  }

  app.tui.set_cursor_position(cursor_x, h - 1)

  app.tui.reset()
  app.tui.flush()
}

fn main() {
  ip := os.input("Enter server IP: ")
  nick := os.input("Enter nickname: ")

  mut conn := vircc.connect(ip, "6667", nick)
  conn.login()!

  mut app := &App{
    conn: conn
  }

  start_receiver(mut app)

  app.tui = tui.init(
    user_data: app
    event_fn: event
    frame_fn: frame
    capture_events: true
    hide_cursor: false
    frame_rate: 30
  )

  app.tui.run()!
}
