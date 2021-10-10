# SwiftMPC ![](https://app.travis-ci.com/ianruh/SwiftMPC.svg?token=ZN5yFcNz885N6gGA3KWn&branch=main)

[Documentation](https://ian.ruh.io/SwiftMPC) | Supported Platforms: macOS, Linux, [1] | Author: [Ian Ruh](https://ian.ruh.io)

---

A pure Swift MPC implementation, based on [Fast Model Predictive Control Using Online Optimization](https://web.stanford.edu/~boyd/papers/pdf/fast_mpc.pdf). 

SwiftMPC allows a user to specify the model of the system in an intuitive and flexible manner, and supports incremental performance improvements. In addition to a purely symbolic operational mode that automatically differentiates and evaulates the objective and constraints at runtime, it also supports the pre-computing of derivatives via code generation, significantly increasing the runtime performance. Moreover, the solver enables the user to easily customize the computation of the steps in the optimization problem, thus enabling the user to take advantage of structure within the optimization problem to increase performance.

### Cartpole Proof of Concept

The cartpole proof of concept code is in [SwiftMPC Gym](https://github.com/ianruh/SwiftMPC-Gym), and the most interesting file (the model definition in symbolic form) is [here](https://github.com/ianruh/SwiftMPC-Gym/blob/main/Sources/CartPole/CartPoleSymbolicObjective.swift).

https://user-images.githubusercontent.com/7023667/136676048-56452fea-a503-45a7-9a9c-7ca5bf97414b.mov

[Video Link](https://user-images.githubusercontent.com/7023667/136676048-56452fea-a503-45a7-9a9c-7ca5bf97414b.mov)

The above simulation was run with a 20 step time horizon, with a uniform timestep of 0.2 seconds. The controller ran at 50 Hz, with each MPC step taking between 2 ms (while the pole is balancing and the dynamics are slow) to 6 ms (while the pole is swinging up and the dynamics are faster).

### Getting Started

Add the following to your `Package.swift`:

```swift
.package(url: "git@github.com:ianruh/SwiftMPC.git")
```

On macOS, nothing else needs to be installed. On Linux, LAPACK needs to be installed seperately. The only supported and tested method is via apt:

```
$ apt install liblapacke-dev
```

However, other implementations should work if linked correctly.

### Development

**Architecture**

There are two primary modules, the SwiftMPC module that contains the optimization and MPC model generation code, and the SymbolicMath module that is the symbolic mathmatics library used to automatically differentiate and manipulate the objective and constraints in SwiftMPC.

**Build Settings**

There are a number of build settings avaible. Look at the `Makefile` for the most up-to-date list. However, there are two primary build modes, debug and release. Each can be run and tested using the following make targets

```
# Debug mode
$ make build-debug
$ make test-debug

# Release mode
$ make build
$ make test
```

**Documentation**

To build the documentation, both [Jazzy](https://github.com/realm/jazzy) and [SourceKitten](https://github.com/jpsim/SourceKitten) must be installed. Then run:

```
$ make documentation
```

### Footnotes

[1] Windows is untested, but I don't know of anything that would prevent it.
