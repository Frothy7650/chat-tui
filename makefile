DEBUGFLAGS := -os linux -g -showcc -show-c-output -cc clang -keepc
VFLAGS := -os linux -cc clang -prod -cflags "-Wall -Wextra -Wshadow -Wformat=2 -Wconversion -Wfloat-equal -O2"
WINVFLAGS := -os windows -cc clang -prod -cflags "-Wall -Wextra -Wshadow -Wformat=2 -Wconversion -Wfloat-equal -O2"
BIN := chat-tui
OUTPUT := ./build/$(BIN)

debug: clean
	mkdir -p build/
	v $(DEBUGFLAGS) src/. -o $(OUTPUT)-debug
release: clean
	mkdir -p build/
	v $(VFLAGS) src/. -o $(OUTPUT)
check:
	echo "Soon!"
install: release
	install -Dm755 $(OUTPUT) /usr/bin/$(BIN)
clean:
	rm -rf build/*
windows: clean
	mkdir -p build/
	v $(WINVFLAGS) src/. -o $(OUTPUT)

.PHONY: debug release check install clean windows
