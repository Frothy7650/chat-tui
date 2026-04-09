#!/usr/bin/env -S v run

import build

const app_name = 'chat-tui'

mut context := build.context(
	default: 'build'
)

context.task(
	name: 'build'
	run:  |self| system('v . -o ${app_name}')
)

context.task(
	name: 'build-prod'
	run:  |self| system('v -cc clang -prod . -o ${app_name}')
)

context.task(
	name: 'quick'
	run:  |self| system('v -cc tcc -d none -cflags "-O0" src/. -o ${app_name}')
)

context.task(
	name: 'format'
	run:  |self| system('v fmt -w *.v lib/')
)

context.task(
	name: 'test'
	run:  |self| system('v -g test .')
)

context.run()
