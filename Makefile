# Compiler flags
NO_SIMPLIFY = -Xswiftc -D -Xswiftc NO_SIMPLIFY
DBEUG = -Xswiftc -D -Xswiftc DEBUG
FAST_MATH = -Xcc -ffast-math
UNCHECKED = -Xswiftc -Ounchecked
WHOLE_MODULE = -Xswiftc -whole-module-optimization
COMPILER_OPT = -Xcc -Ofast

build:
	swift build -c release --build-tests $(WHOLE_MODULE) $(UNCHECKED) $(FAST_MATH) $(COMPILER_OPT)

build-debug:
	swift build --build-tests $(DEBUG)

run:
	swift run -c release --build-tests $(WHOLE_MODULE) $(UNCHECKED) $(FAST_MATH) $(COMPILER_OPT)

run-debug:
	swift run $(DEBUG)

test:
	swift test -c release -Xswiftc $(WHOLE_MODULE) $(UNCHECKED) $(FAST_MATH) $(COMPILER_OPT)

test-debug:
	swift test $(DEBUG)
