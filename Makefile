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
RELEASE = #-c release # Release build is broken on linux (compiler bug), so disabled for now

build:
	swift build $(RELEASE) --build-tests $(WHOLE_MODULE) $(UNCHECKED) $(FAST_MATH) $(COMPILER_OPT) $(EXTRAS)

build-debug:
	swift build --build-tests $(DEBUG) $(EXTRAS)

test:
	swift test $(RELEASE) $(WHOLE_MODULE) $(UNCHECKED) $(FAST_MATH) $(COMPILER_OPT) $(EXTRAS) $(NO_PARALLEL)

test-debug:
	swift test $(DEBUG) $(EXTRAS) $(NO_PARALLEL)

clean:
	rm -rf .build/
