module main

import os
import time
import term
import kutlayozger.chalk
import frothy7650.vircc
import tauraamui.bobatea as tea

// Messages
struct TickMsg {
	time time.Time
}

struct NewLineMsg {
	line string
}

// App Model
struct App {
mut:
	conn            vircc.IrcConn
	messages        []string
	input_buf       string
	scroll          int
	autoscroll      bool = true
	window_width    int
	window_height   int
	frame_count     int
	last_fps_update time.Time = time.now()
	app_send        ?fn (tea.Msg)
}

// IRC Receiver
fn start_receiver(mut app App) {
	go fn [mut app] () {
		for app.conn.is_running {
			app.conn.color = true
			line := app.conn.readline() or { continue }

			// Send new line to BubbleTea program
			if app.app_send != none {
				app.app_send(NewLineMsg{ line: line.trim_space() })
			}
		}
	}()
}

// BubbleTea Commands
pub fn tick_cmd() tea.Cmd {
	return tea.tick(50 * time.millisecond, fn (t time.Time) tea.Msg {
		return TickMsg{ time: t }
	})
}

// BubbleTea Methods
fn (mut m App) init() fn () tea.Msg {
	start_receiver(mut m)
	return tick_cmd()
}

fn (mut m App) update(msg tea.Msg) (tea.Model, fn () tea.Msg) {
	match msg {
		TickMsg {
			return m.clone(), tick_cmd()
		}
		NewLineMsg {
			m.messages << msg.line
			if m.autoscroll {
				m.scroll = 0
			}
			return m.clone(), tea.noop_cmd
		}
		tea.KeyMsg {
			match msg.k_type {
				.special {
					match msg.string() {
						'escape' {
							m.conn.writeline('/quit') or {}
							return m.clone(), tea.quit
						}
						'enter' {
							if m.input_buf.len == 0 {
								return m.clone(), tea.noop_cmd
							}

							if m.input_buf.trim_space() == '/clear' {
								m.messages.clear()
								m.scroll = 0
							} else {
								m.conn.writeline(m.input_buf) or {}

								if m.conn.channel != ''
									&& !m.input_buf.trim_space().starts_with('/') {
									m.messages << chalk.bold('<${chalk.cyan(m.conn.nick)}> ${m.input_buf.trim_space()}')
								}

								if m.input_buf.trim_space().starts_with('/quit') {
									return m.clone(), tea.quit
								}
							}
							m.input_buf = ''
							m.autoscroll = true
						}
						'backspace' {
							if m.input_buf.len > 0 {
								m.input_buf = m.input_buf[..m.input_buf.len - 1]
							}
						}
						'up' {
							if m.messages.len > 0 {
								m.scroll++
								m.autoscroll = false
							}
						}
						'down' {
							if m.scroll > 0 {
								m.scroll--
							}
							if m.scroll == 0 {
								m.autoscroll = true
							}
						}
						'ctrl+l' {
							m.messages.clear()
							m.scroll = 0
						}
						else {}
					}
				}
				.runes {
					if msg.string() != '\0' && msg.string() != '\r' {
						if msg.string() == '\f' {
							m.messages.clear()
							m.scroll = 0
						} else {
							m.input_buf += msg.string()
						}
					}
				}
			}
		}
		tea.ResizedMsg {
			m.window_width = msg.window_width
			m.window_height = msg.window_height
		}
		else {}
	}
	return m.clone(), tea.noop_cmd
}

// View
fn (mut m App) view(mut ctx tea.Context) {
	w := m.window_width
	h := m.window_height

	ctx.set_bg_color(tea.Color{30, 30, 30})
	ctx.reset_bg_color()

	// Top Status Bar
	ctx.set_bg_color(tea.Color{40, 40, 40})
	ctx.draw_rect(0, 0, w - 1, 0)
	status := ' Nickname: ${m.conn.nick} | Channel: ${m.conn.channel} | ${if m.conn.is_running {
		'Connected'
	} else {
		'Disconnected'
	}} | Command: ${m.conn.command}'
	ctx.set_color(tea.Color.ansi(255))
	ctx.draw_text(1, 0, status)
	ctx.reset_bg_color()

	// Messages Area
	msg_area_height := h - 2
	total := m.messages.len
	max_visible := msg_area_height

	start := if total - max_visible - m.scroll < 0 { 0 } else { total - max_visible - m.scroll }
	end := if start + max_visible > total { total } else { start + max_visible }

	mut y := 1
	for i in start .. end {
		line := if m.messages[i].len > w { m.messages[i][..w] } else { m.messages[i] }
		ctx.draw_text(0, y, line)
		y++
	}

	// Input Line at bottom
	ctx.set_bg_color(tea.Color{30, 30, 30})
	ctx.draw_rect(0, h - 1, w - 1, h - 1)

	mut input_line := '>${m.input_buf}'
	if input_line.len > w {
		input_line = input_line[input_line.len - w..]
	}
	ctx.draw_text(0, h - 1, input_line)

	// Cursor right after input text
	cursor_x := if m.input_buf.len >= w { w - 1 } else { m.input_buf.len + 2 }
	ctx.set_cursor_position(cursor_x, h)
	ctx.show_cursor()
}

// Helpers
fn (m App) clone() tea.Model {
	return App{
		...m
	}
}

// Main
fn main() {
	ip := os.input('Enter server IP: ')
	nick := os.input('Enter nickname: ')

	mut conn := vircc.connect(ip, '6667', nick)!
	conn.login()!

	window_width, window_height := term.get_terminal_size()
	mut app := App{
		conn:          conn
		window_width:  window_width
		window_height: window_height
	}

	mut program := tea.new_program(mut app)
	app.app_send = program.send
	program.run() or { panic('App failed: ${err}') }
}
