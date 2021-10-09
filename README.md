# SwiftMPC ![](https://app.travis-ci.com/ianruh/SwiftMPC.svg?token=ZN5yFcNz885N6gGA3KWn&branch=main)

[Documentation](https://ian.ruh.io/SwiftMPC) | Author: [Ian Ruh](https://ian.ruh.io)

---

A pure Swift MPC implementation, based on [Fast Model Predictive Control Using Online Optimization](https://web.stanford.edu/~boyd/papers/pdf/fast_mpc.pdf). 

SwiftMPC allows a user to specify the model of the system in an intuitive and flexible manner, and supports incremental performance improvements. In addition to a purely symbolic operational mode that automatically differentiates and evaulates the objective and constraints at runtime, it also supports the pre-computing of derivatives via code generation, significantly increasing the runtime performance. Moreover, the solver enables the user to easily customize the computation of the steps in the optimization problem, thus enabling the user to take advantage of structure within the optimization problem to increase performance.

### Cartpole Proof of Concept

The cartpole proof of concept code is in [SwiftMPC Gym](https://github.com/ianruh/SwiftMPC-Gym), and the most interesting file (the model definition in symbolic form) is [here](https://github.com/ianruh/SwiftMPC-Gym/blob/main/Sources/CartPole/CartPoleSymbolicObjective.swift).



The above simulation was run with a 20 step time horizon, with a uniform timestep of 0.2 seconds. The controller ran at 50 Hz, with each MPC step taking between 2 ms (while the pole is balancing and the dynamics are slow) to 6 ms (while the pole is swinging up and the dynamics are faster).
