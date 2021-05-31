

public class Simulator {

    var objects: [SimulationObject] = []

    public func addObject(_ obj: SimulationObject) {
        self.objects.append(obj)
    }

    public func getObjects() -> [SimulationObject] {
        return self.objects
    }

    public func evolve(timeStep: Double) {
        for i in 0..<self.objects.count {
            self.objects[i].evolve(timeStep: timeStep)
        }
    }

}