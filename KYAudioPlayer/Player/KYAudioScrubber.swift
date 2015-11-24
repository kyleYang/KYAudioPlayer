//
//  KYAudioScrubber.swift
//  KYAudioPlayer
//
//  Created by 杨志赟 on 15/11/18.
//  Copyright © 2015年 xiaoluuu. All rights reserved.
//

import UIKit

class KYAudioScrubber: UISlider {

    
    private(set) var scrubbingSpeed : Float!
    var scrubbingSpeeds : Array<Float>! = [1.0,0.5,0.25,0.1]
    var scrubbingSpeedChangePositions : Array<Float>! = [0.0,50.0,100.0,150.0]
    
    private var _playableValue : Float! = 0.0
    var playableValue : Float! {
        get {
            return _playableValue
        }set{
            if _playableValue != newValue {
                _playableValue = newValue
                
                if _playableValue == 0 || isnan(_playableValue) {
                    playableView.frame = CGRectZero
                }
                
                let valueDifference = self.maximumValue - self.minimumValue
                let percentage = playableValue/valueDifference

                var trackRect = self.trackRectForBounds(self.bounds)
                trackRect = CGRectInset(trackRect,0.0,2.0)
                trackRect.size.width *= CGFloat(percentage)
                trackRect.size.width = min(trackRect.size.width,self.frame.size.width)
                trackRect = CGRectIntegral(trackRect)
                
                playableView.frame = trackRect
            
            }
        }
    }
    
    private var _playableValueColor : UIColor! = UIColor(red: 89.0/255.0, green: 89.0/255.0, blue: 89.0/255.0, alpha: 1.0)
    var playableValueColor : UIColor!  {
        get {
            return _playableValueColor
        }set{
            if _playableValueColor != newValue {
                _playableValueColor = newValue
                playableView.backgroundColor = _playableValueColor
            }
        }
        
    }
    var fillColor : UIColor!
    var playableValueRoundedRectRadius : Float! {
        get{

            let layer = playableView.layer
            return Float(layer.cornerRadius)
            
        }set{
            
            let layer = playableView.layer
            layer.masksToBounds = true
            layer.cornerRadius = CGFloat(newValue)
            layer.borderWidth = 0.0
            
        }
    }
    
    var updateTimeCloseure :  ((NSTimeInterval) -> (Void))?
    
    private var playableView : UIView! = UIView(frame: CGRectZero)
    private var beganTrackingLocation : CGPoint! = CGPointZero
    private var _realPositionValue : Float! = 0.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.scrubbingSpeed = self.scrubbingSpeeds[0]
        playableView.userInteractionEnabled = false
        playableView.backgroundColor = playableValueColor
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: UIControl
    
    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        let beginTracking = super.beginTrackingWithTouch(touch, withEvent: event)
        
        if beginTracking {
            
            _realPositionValue = self.value
        }
        return beginTracking
    }
    
    
    override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
     
        if self.tracking {
            
            let previousLocation = touch.previousLocationInView(self)
            let currentLocation = touch.locationInView(self)
            let trackingOffset = currentLocation.x - previousLocation.x
            
            let verticalOffset = fabsf(Float(currentLocation.y - beganTrackingLocation.y))
            var scrubbingSpeedChangePosIndex = self.indexOfLowerScrubbingSpeed(self.scrubbingSpeedChangePositions, forOffset: verticalOffset)
            
            if scrubbingSpeedChangePosIndex == NSNotFound {
                scrubbingSpeedChangePosIndex = scrubbingSpeeds.count
            }
            
            scrubbingSpeed = scrubbingSpeeds[scrubbingSpeedChangePosIndex-1]
            
            let trackRect = self.trackRectForBounds(self.bounds)
            _realPositionValue = _realPositionValue + (self.maximumValue - self.minimumValue) * Float(trackingOffset / trackRect.size.width)
            
            let valueAdjustment = scrubbingSpeed * (self.maximumValue - self.minimumValue) * Float(trackingOffset / trackRect.size.width)
            var thumbAdjustment : Float = 0.0
            
            if ((beganTrackingLocation.y < currentLocation.y) && (currentLocation.y < previousLocation.y)) || ((beganTrackingLocation.y > currentLocation.y) && (currentLocation.y > previousLocation.y)) {
                thumbAdjustment = (_realPositionValue - self.value)/( 1 + fabsf(Float(currentLocation.y - self.beganTrackingLocation.y)))
            }
            
            self.value += valueAdjustment + thumbAdjustment
            
            if let _ = updateTimeCloseure {
                
                let timeInterval = NSTimeInterval(self.value)
                updateTimeCloseure!(timeInterval)
            }
            
        }
        
        return self.tracking
    }
    
    override func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
        
        if self.tracking {
            scrubbingSpeed = scrubbingSpeeds[0]
            self.sendActionsForControlEvents(.ValueChanged)
        }
    
    }

    
    
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        var bounds = self.bounds
        bounds = CGRectInset(bounds, -10.0, -10.0)
        
        return CGRectContainsPoint(bounds, point)
    }
    
    
    private func indexOfLowerScrubbingSpeed(scrubbingSpeedPositions : Array<Float> , forOffset verticalOffset : Float) -> Int {
        
        for i in 0...scrubbingSpeedPositions.count-1 {
            
            let value = scrubbingSpeedPositions[i]
            if verticalOffset < value {
                return i
            }
        }
        
        return NSNotFound
    }
    
    
    
    override func layoutSubviews() {
        
    }

}
