//
//  PulseAnimation.swift
//  SmartEducation
//
//  Created by MacBook on 11/17/20.
//

import Foundation
import UIKit

class PulseAnimation: CALayer {
    var animationGroup = CAAnimationGroup()
    var animationDuration: TimeInterval = 1.5
    var radius: CGFloat = 200
    var numebrOfPulse: Float = Float.infinity
    
    override init(layer: Any) {
        super.init(layer: layer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(numberOfPulse: Float = Float.infinity, radius: CGFloat, postion: CGPoint) {
        super.init()
        
        backgroundColor = UIColor.black.cgColor
        contentsScale = UIScreen.main.scale
        opacity = 0
        self.radius = radius
        numebrOfPulse = numberOfPulse
        position = postion
        
        bounds = CGRect(x: 0, y: 0, width: radius*2, height: radius*2)
        cornerRadius = radius
        
        DispatchQueue.global().async { [weak self] in
            self?.setupAnimationGroup()
            DispatchQueue.main.async {
                self?.add(self?.animationGroup ?? CAAnimationGroup(), forKey: "pulse")
           }
        }
    }
    
    func scaleAnimation() -> CABasicAnimation {
        let scaleAnimaton = CABasicAnimation(keyPath: "transform.scale.xy")
        scaleAnimaton.fromValue = NSNumber(value: 0)
        scaleAnimaton.toValue = NSNumber(value: 1)
        scaleAnimaton.duration = animationDuration
        return scaleAnimaton
    }
    
    func createOpacityAnimation() -> CAKeyframeAnimation {
        let opacityAnimiation = CAKeyframeAnimation(keyPath: "opacity")
        opacityAnimiation.duration = animationDuration
        opacityAnimiation.values = [0.4,0.8,0]
        opacityAnimiation.keyTimes = [0,0.3,1]
        return opacityAnimiation
    }
    
    func setupAnimationGroup() {
        animationGroup.duration = animationDuration
        animationGroup.repeatCount = numebrOfPulse
        let defaultCurve = CAMediaTimingFunction(name: CAMediaTimingFunctionName.default)
        animationGroup.timingFunction = defaultCurve
        animationGroup.animations = [scaleAnimation(),createOpacityAnimation()]
    }
}
