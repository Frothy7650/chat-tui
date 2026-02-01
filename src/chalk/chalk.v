/*
   Chalk module for vlang
   Author Kutlay Ozger
   License MIT
   Version 0.1a
*/
module chalk

enum Color {
	red
	green
	black
	yellow
	blue
	magenta
	cyan
	gray
	default
	dark_gray
	light_red
	light_green
	light_yellow
	light_blue
	light_magenta
	light_cyan
	white
}

enum Style {
	reset
	bold
	dim
	italic
	underline
	overline
	inverse
	hidden
	strikethrough
}

const styles = [[0, 0], [1, 22], [2, 22], [3, 23], [4, 24], [53, 55],
	[7, 27], [8, 28], [9, 29]]
const fcodes = [[31, 39], [32, 39], [30, 39], [33, 39], [34, 39],
	[35, 39], [36, 39], [37, 39], [39, 39], [90, 39], [91, 39],
	[92, 39], [93, 39], [94, 39], [95, 39], [96, 39], [97, 39]]
const bcodes = [[41, 49], [42, 49], [40, 49], [43, 49], [44, 49],
	[45, 49], [46, 49], [47, 49], [49, 49], [100, 49], [101, 49],
	[102, 49], [103, 49], [104, 49], [105, 49], [106, 49], [107, 49]]

fn style(sty Style, s string) string {
	index := int(sty)
	open_code := styles[index][0]
	close_code := styles[index][1]
	return '\u001B[${open_code}m${s}\u001B[${close_code}m'
}

fn fgcol(color Color, s string) string {
	index := int(color)
	open_code := fcodes[index][0]
	close_code := fcodes[index][1]
	open := '\u001B[${open_code}m'
	close := '\u001B[${close_code}m'
	return open + s + close
}

fn bgcol(color Color, s string) string {
	index := int(color)
	open_code := bcodes[index][0]
	close_code := bcodes[index][1]
	open := '\u001B[${open_code}m'
	close := '\u001B[${close_code}m'
	return open + s + close
}

fn str_col(s string) Color {
	match s {
		'red' {
			return Color.red
		}
		'blue' {
			return Color.blue
		}
		'green' {
			return Color.green
		}
		'black' {
			return Color.black
		}
		'cyan' {
			return Color.cyan
		}
		'yellow' {
			return Color.yellow
		}
		'magenta' {
			return Color.magenta
		}
		'gray', 'grey' {
			return Color.gray
		}
		'dark_gray', 'dark_grey' {
			return Color.dark_gray
		}
		'light_red' {
			return Color.light_red
		}
		else {
			return Color.default
		}
	}
}

pub fn fg(s string, color string) string {
	return fgcol(str_col(color), s)
}

pub fn red(s string) string {
	return fgcol(Color.red, s)
}

pub fn bgred(s string) string {
	return bgcol(Color.red, s)
}

pub fn green(s string) string {
	return fgcol(Color.green, s)
}

pub fn bggreen(s string) string {
	return bgcol(Color.green, s)
}

pub fn black(s string) string {
	return fgcol(Color.black, s)
}

pub fn bgblack(s string) string {
	return bgcol(Color.black, s)
}

pub fn yellow(s string) string {
	return fgcol(Color.yellow, s)
}

pub fn bgyellow(s string) string {
	return bgcol(Color.yellow, s)
}

pub fn blue(s string) string {
	return fgcol(Color.blue, s)
}

pub fn bgblue(s string) string {
	return bgcol(Color.blue, s)
}

pub fn magenta(s string) string {
	return fgcol(Color.magenta, s)
}

pub fn bgmagenta(s string) string {
	return bgcol(Color.magenta, s)
}

pub fn cyan(s string) string {
	return fgcol(Color.cyan, s)
}

pub fn bgcyan(s string) string {
	return bgcol(Color.cyan, s)
}

pub fn gray(s string) string {
	return fgcol(Color.gray, s)
}

pub fn bggray(s string) string {
	return bgcol(Color.gray, s)
}

pub fn grey(s string) string {
	return fgcol(Color.gray, s)
}

pub fn bggrey(s string) string {
	return bgcol(Color.gray, s)
}

pub fn dark_gray(s string) string {
	return fgcol(Color.dark_gray, s)
}

pub fn bgdark_gray(s string) string {
	return bgcol(Color.dark_gray, s)
}

pub fn light_red(s string) string {
	return fgcol(Color.light_red, s)
}

pub fn bglight_red(s string) string {
	return bgcol(Color.light_red, s)
}

pub fn light_green(s string) string {
	return fgcol(Color.light_green, s)
}

pub fn bglight_green(s string) string {
	return bgcol(Color.light_green, s)
}

pub fn light_yellow(s string) string {
	return fgcol(Color.light_yellow, s)
}

pub fn bglight_yellow(s string) string {
	return bgcol(Color.light_yellow, s)
}

pub fn light_blue(s string) string {
	return fgcol(Color.light_blue, s)
}

pub fn bglight_blue(s string) string {
	return bgcol(Color.light_blue, s)
}

pub fn light_magenta(s string) string {
	return fgcol(Color.light_magenta, s)
}

pub fn bglight_magenta(s string) string {
	return bgcol(Color.light_magenta, s)
}

pub fn light_cyan(s string) string {
	return fgcol(Color.light_cyan, s)
}

pub fn bglight_cyan(s string) string {
	return bgcol(Color.light_cyan, s)
}

pub fn white(s string) string {
	return fgcol(Color.white, s)
}

pub fn bgwhite(s string) string {
	return bgcol(Color.white, s)
}

pub fn reset(s string) string {
	return style(Style.reset, s)
}

pub fn bold(s string) string {
	return style(Style.bold, s)
}

pub fn dim(s string) string {
	return style(Style.dim, s)
}

pub fn italic(s string) string {
	return style(Style.italic, s)
}

pub fn underline(s string) string {
	return style(Style.underline, s)
}

pub fn overline(s string) string {
	return style(Style.overline, s)
}

pub fn inverse(s string) string {
	return style(Style.inverse, s)
}

pub fn hidden(s string) string {
	return style(Style.hidden, s)
}

pub fn strikethrough(s string) string {
	return style(Style.strikethrough, s)
}
