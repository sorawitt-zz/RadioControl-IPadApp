import SpriteKit

protocol GameSceneActionDelegate {
    func didUpdateLeftStick(throttle: Int, yaw: Int)
    func didUpdateRightStick(pitch: Int, roll: Int)
}

class GameScene: SKScene {
    
    var actionDelegate: GameSceneActionDelegate?

    static let stickDiameter: CGFloat = 200
    let leftStick = ThrottleAnalogJoystick(diameter: stickDiameter)
    let rightStick = AnalogJoystick(diameter: stickDiameter)
    
    static let throttleMin = 1000
    static let throttleMax = 2000
    static let stickMiddle      = 1500

    static let deadzone = 20
    
    var throttleVal = throttleMin
    var yawVal = 1500
    var pitchVal = 1000
    var rollVal = 1500
    
    let throttleLabel = SKLabelNode(text: "Throttle: 1000")
    
    override func didMove(to view: SKView) {

        /* Setup your scene here */
        backgroundColor = UIColor.white
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        leftStick.position = CGPoint(x: leftStick.radius + 50, y: leftStick.radius + 200)
        leftStick.stick.color = UIColor.yellow
        addChild(leftStick)
        
        rightStick.position = CGPoint(x: self.frame.maxX - rightStick.radius - 50, y:rightStick.radius + 200)
        rightStick.stick.color = UIColor.yellow
        addChild(rightStick)
        
        let selfHeight = frame.height
        let btnsOffset: CGFloat = 10
        let btnsOffsetHalf = btnsOffset / 2
        
        throttleLabel.fontSize = 20
        throttleLabel.fontColor = UIColor.black
        throttleLabel.horizontalAlignmentMode = .left
        throttleLabel.verticalAlignmentMode = .top
        throttleLabel.position = CGPoint(x: btnsOffset, y: selfHeight - btnsOffset)
        addChild(throttleLabel)
        
        let yawLabel = SKLabelNode(text: "Yaw: 1500")
        yawLabel.horizontalAlignmentMode = .right
        yawLabel.fontSize = 20
        yawLabel.fontColor = UIColor.black
        yawLabel.horizontalAlignmentMode = .left
        yawLabel.verticalAlignmentMode = .top
        yawLabel.position = CGPoint(x: btnsOffset, y: selfHeight - btnsOffset - 50)
        addChild(yawLabel)
        
        let pitchLabel = SKLabelNode(text: "Pitch: 1500")
        pitchLabel.horizontalAlignmentMode = .right
        pitchLabel.fontSize = 20
        pitchLabel.fontColor = UIColor.black
        pitchLabel.horizontalAlignmentMode = .left
        pitchLabel.verticalAlignmentMode = .top
        pitchLabel.position = CGPoint(x: btnsOffset+200, y: selfHeight - btnsOffset)
        addChild(pitchLabel)
        
        let rollLabel = SKLabelNode(text: "Roll: 1500")
        rollLabel.horizontalAlignmentMode = .right
        rollLabel.fontSize = 20
        rollLabel.fontColor = UIColor.black
        rollLabel.horizontalAlignmentMode = .left
        rollLabel.verticalAlignmentMode = .top
        rollLabel.position = CGPoint(x: btnsOffset+200, y: selfHeight - btnsOffset-50)
        addChild(rollLabel)
        
        //MARK: Handlers begin
        leftStick.beginHandler = { [unowned self] in
 
        }
        
        leftStick.trackingHandler = { [unowned self] data in
            let y = 0.5 + data.velocity.y/GameScene.stickDiameter
            self.throttleVal = Int(CGFloat(GameScene.throttleMin) + y*CGFloat(GameScene.throttleMax-GameScene.throttleMin))
            if self.throttleVal < GameScene.throttleMin + GameScene.deadzone {
                self.throttleVal = GameScene.throttleMin
            }
            if self.throttleVal > GameScene.throttleMax - GameScene.deadzone {
                self.throttleVal = GameScene.throttleMax
            }
            
            self.yawVal = Int(1500 + data.velocity.x*5)
            self.throttleLabel.text = "Throttle: \(self.throttleVal)"
            yawLabel.text = "Yaw:\(self.yawVal)"
            
            self.actionDelegate?.didUpdateLeftStick(throttle: self.throttleVal, yaw: self.yawVal)
        }
        
        leftStick.stopHandler = { [unowned self] in
            self.yawVal = Int(1500 + self.leftStick.data.velocity.x*5)
            yawLabel.text = "Yaw: \(self.yawVal)"
            self.actionDelegate?.didUpdateLeftStick(throttle: self.throttleVal, yaw: self.yawVal)
        }
        
        rightStick.trackingHandler = { [unowned self] jData in
            self.pitchVal = Int(1500 + jData.velocity.y*5)
            pitchLabel.text = "Pitch: \(self.pitchVal)"
            
            self.rollVal = Int(1500 + jData.velocity.x*5)
            rollLabel.text = "Roll: \(self.rollVal)"
            
            self.actionDelegate?.didUpdateRightStick(pitch: self.pitchVal, roll: self.rollVal)
        }
        
        rightStick.stopHandler =  { [unowned self] in
            self.pitchVal = Int(1500 + self.rightStick.data.velocity.y*5)
            pitchLabel.text = "Pitch: \(self.pitchVal)"
            
            self.rollVal = Int(1500 + self.rightStick.data.velocity.x*5)
            rollLabel.text = "Roll: \(self.rollVal)"
            
            self.actionDelegate?.didUpdateRightStick(pitch: self.pitchVal, roll: self.rollVal)
        }
        
        //MARK: Handlers end
        view.isMultipleTouchEnabled = true
    }
    
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
    }
}

extension UIColor {
    
    static func random() -> UIColor {
        return UIColor(red: CGFloat(drand48()), green: CGFloat(drand48()), blue: CGFloat(drand48()), alpha: 1)
    }
}
