build:
	swift build -c release --build-tests -Xswiftc -whole-module-optimization -Xswiftc -Ounchecked -Xcc -ffast-math -Xcc -O2

build-debug:
	swift build --build-tests

run:
	swift run -c release --build-tests -Xswiftc -Ounchecked -Xcc -ffast-math -Xcc -O2

run-debug:
	swift run

test:
	swift test -Xswiftc -Ounchecked -Xcc -ffast-math -Xcc -O2
