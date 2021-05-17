build:
	swift build -c release --build-tests -Xswiftc -whole-module-optimization -Xswiftc -Ounchecked -Xcc -ffast-math -Xcc -Ofast

build-debug:
	swift build --build-tests -Xswiftc -D -Xswiftc DEBUG

run:
	swift run -c release --build-tests -Xswiftc -whole-module-optimization -Xswiftc -Ounchecked -Xcc -ffast-math -Xcc -Ofast

run-debug:
	swift run -Xswiftc -D -Xswiftc DEBUG

test:
	swift test -c release -Xswiftc -whole-module-optimization -Xswiftc -Ounchecked -Xcc -ffast-math -Xcc -O2

test-debug:
	swift test -Xswiftc -D -Xswiftc DEBUG
