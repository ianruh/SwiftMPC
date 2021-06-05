# Compiler flags
NO_SIMPLIFY = -Xswiftc -D -Xswiftc NO_SIMPLIFY
NO_PRINT = -Xswiftc -D -Xswiftc NO_PRINT
NO_PARALLEL = -Xswiftc -D -Xswiftc NO_PARALLEL
DBEUG = -Xswiftc -D -Xswiftc DEBUG
FAST_MATH = -Xcc -ffast-math
UNCHECKED = -Xswiftc -Ounchecked
WHOLE_MODULE = -Xswiftc -whole-module-optimization
COMPILER_OPT = -Xcc -Ofast
NO_NUMERIC_OBJECTIVE = -Xswiftc -D -Xswiftc NO_NUMERIC_OBJECTIVE

build:
	swift build -c release --build-tests $(WHOLE_MODULE) $(UNCHECKED) $(FAST_MATH) $(COMPILER_OPT) $(EXTRAS)

build-debug:
	swift build --build-tests $(DEBUG) $(EXTRAS)

test:
	swift test -c release $(WHOLE_MODULE) $(UNCHECKED) $(FAST_MATH) $(COMPILER_OPT) $(EXTRAS)

test-debug:
	swift test $(DEBUG) $(EXTRAS)

clean:
	rm -rf .build/
