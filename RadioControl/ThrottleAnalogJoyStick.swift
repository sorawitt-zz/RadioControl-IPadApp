//
//  AnalogStick.swift
//  Joystick
//
//  Created by Dmitriy Mitrophanskiy on 28.09.14.
//
//
import SpriteKit

//MARK: - AnalogJoystick
open class ThrottleAnalogJoystick: AnalogJoystick {
    
    // private methods
    override func resetStick() {
        tracking = false
        let moveToBack = SKAction.move(to: CGPoint(x: 0.0, y: stick.position.y), duration: TimeInterval(0.1))
        moveToBack.timingMode = .easeOut
        stick.run(moveToBack)
        data.resetDirectionX()
        stopHandler?();
    }
}
