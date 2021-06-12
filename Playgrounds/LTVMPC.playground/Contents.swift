//: A SpriteKit based Playground
// Changes
import PlaygroundSupport
import SpriteKit
import SimpleSimulator
import LTVMPC
import RealModule

let viewWidth: Double = 500
let viewHeight: Double = 500
let simulationWidth: Double = 100.0
let simulationHeight: Double = 100.0

class GameScene: SKScene {
    
    private var label : SKLabelNode!
    private var spinnyNode : SKShapeNode!
    
    private var timeSinceFrame: TimeInterval? = nil
    private var cars: [CarObject] = []
    private var bicycle: BicycleObject = BicycleObject()
    
    private var simulator: SimpleSimulator = SimpleSimulator()
    private var mpc: LTVMPC = LTVMPC(numSteps: 30)
    
    override func didMove(to view: SKView) {
        // Add the cars
        let car1 = CarObject(image: "blue_car.jpg", position: Vec2(0.0, 4.0), velocity: Vec2(1.0, 0.0))
        self.cars.append(car1)
        self.simulator.addObject(car1)
        self.addChild(car1.sprite)

        self.simulator.addObject(self.bicycle)
        self.addChild(self.bicycle.sprite)
    }
    
    @objc static override var supportsSecureCoding: Bool {
        // SKNode conforms to NSSecureCoding, so any subclass going
        // through the decoding process must support secure coding
        get {
            return true
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard let previousTime = self.timeSinceFrame else {
            self.timeSinceFrame = currentTime
            return
        }
        
        if(currentTime - previousTime > 0.1) {
            // Actually run an mpc step and update
            var acceleration: Double = 0.0
            var steeringAngle: Double = 0.0
            do {
                (acceleration, steeringAngle) = try self.mpc.getNextControls()
            } catch {
                print(error)
            }

            // Set the control variable in the simulator for the car
            self.bicycle.acceleration = acceleration
            self.bicycle.steeringAngle = steeringAngle
            
            // Update object positions
            self.simulator.evolve(timeStep: currentTime - previousTime)
            self.timeSinceFrame = currentTime
        }
    }
}

// Load the SKScene from 'GameScene.sks'
let sceneView = SKView(frame: CGRect(x:0 , y:0, width: viewWidth, height: viewHeight))
sceneView.showsFPS = true
sceneView.showsNodeCount = true

let scene = GameScene()
// Set the scale mode to scale to fit the window
//scene.scaleMode = .aspectFill

// Present the scene
sceneView.presentScene(scene)

PlaygroundSupport.PlaygroundPage.current.liveView = sceneView







//=============================================================
//=============================================================


public struct BicycleObject: SimulationObject {
    // State
    var frontWheelPosition: Vec2
    var velocity: Double
    var angle: Double
    var wheelBase: Double

    // Control
    public var acceleration: Double
    public var steeringAngle: Double

    public var sprite: SKSpriteNode

    public init(position: Vec2 = Vec2(0.0, 0.0), velocity: Double = 0.0, angle: Double = 0.0, wheelBase: Double = 2.0, acceleration: Double = 0.0, steeringAngle: Double = 0.0) {
        self.frontWheelPosition = position
        self.velocity = velocity
        self.angle = angle
        self.wheelBase = wheelBase

        self.acceleration = acceleration
        self.steeringAngle = steeringAngle

        self.sprite = SKSpriteNode(texture: nil,
                                  color: NSColor.red,
                                  size: CGSize(width: self.wheelBase/100.0, height: 1.0/100.0))
    }

    public var boundingBox: BoundingBox {
        var minX = self.frontWheelPosition.x - self.wheelBase*Double.cos(self.angle)
        var maxX = self.frontWheelPosition.x
        if(minX > maxX) {
            let temp = minX
            minX = maxX
            maxX = temp
        }

        var minY = self.frontWheelPosition.y - self.wheelBase*Double.sin(self.angle)
        var maxY = self.frontWheelPosition.y
        if(minY > maxY) {
            let temp = minY
            minY = maxY
            maxY = temp
        }

        return BoundingBox(minX: minX, maxX: maxX, minY: minY, maxY: maxY)
    }

    public mutating func evolve(timeStep: Double) {
        self.frontWheelPosition = self.frontWheelPosition + timeStep*Vec2(self.velocity*Double.cos(self.angle + self.steeringAngle), self.velocity*Double.sin(self.angle + self.steeringAngle))
        self.angle = self.angle + timeStep*self.velocity/self.wheelBase * Double.sin(self.steeringAngle)
        self.velocity = self.velocity + timeStep*self.acceleration

        // Update the sprite
        self.sprite.position = scaleCoordinates(simulatorFrame: self.boundingBox.center)
        self.sprite.zRotation = CGFloat(self.angle)
    }
}

//=============================================================
//=============================================================

public class CarObject: SimulationObject  {
    private var position: Vec2
    private var width: Double
    private var height: Double
    
    private var velocity: Vec2
    public let sprite: SKSpriteNode
    
    public var boundingBox: BoundingBox {
        return BoundingBox(center: position, width: width, height: height)
    }
    
    public init(image: String, position: Vec2, velocity: Vec2 = Vec2(1.0, 0.0), width: Double = 2.0, height: Double = 1.0) {
        self.position = position
        self.width = width
        self.height = height
        self.velocity = velocity
//        self.sprite = SKSpriteNode(imageNamed: image)
        self.sprite = SKSpriteNode(texture: nil,
                                  color: NSColor.blue,
                                  size: CGSize(width: scaleWidth(simulationFrame: self.width), height: scaleHeight(simulationFrame: self.height)))
    }

    public func evolve(timeStep: Double) {
        self.position = self.position + timeStep*self.velocity
        
        // Update sprite parts
//        let move = SKAction.move(to: scaleCoordinates(self.position), duration: timeStep)
//        self.sprite.run(SKAction.sequence([move, SKAction.removeFromParent()]))
        self.sprite.position = scaleCoordinates(simulatorFrame: self.position)
    }
}

//=============================================================
//=============================================================

public func scaleCoordinates(simulatorFrame: Vec2) -> CGPoint {
    return CGPoint(x: simulatorFrame.x*(1.0/simulationWidth), y: simulatorFrame.y*(1.0/simulationHeight)+(1.0/2.0))
}

public func scaleWidth(simulationFrame: Double) -> Double {
    return simulationFrame * 1.0/simulationWidth
}

public func scaleHeight(simulationFrame: Double) -> Double {
    return simulationFrame * 1.0/simulationHeight
}
