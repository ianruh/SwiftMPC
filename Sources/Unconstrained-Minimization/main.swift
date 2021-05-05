import LASwift
import Numerics

let min = try unconstrainedMinimize(QuadraticObjective(n: 100), gradEpsilon: 1e-6, debugInfo: true)