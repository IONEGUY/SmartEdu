//
//  RotatableSCNNode.swift
//  SmartEducation
//
//  Created by MacBook on 11/14/20.
//

import Foundation
import SceneKit

class RotatableSCNNode: VolumetricObjectSCNNode {
    private var currentRotation: Float = 0

    public func addRotationAction(duration: Float, rotation: Float? = nil) {
        currentRotation = rotation ?? currentRotation
        let rotationAction = SCNAction.rotateBy(x: 0, y: CGFloat(currentRotation), z: 0,
                                                duration: TimeInterval(1 - duration / 10))
        runAction(SCNAction.repeatForever(rotationAction))
    }
    
    public func updateRotationSpeed(_ duration: Float) {
        removeAllActions()
        addRotationAction(duration: duration)
    }
}
