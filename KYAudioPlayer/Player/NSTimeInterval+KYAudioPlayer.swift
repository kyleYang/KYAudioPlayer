//
//  NSTimeInterval+KYAudioPlayer.swift
//  KYAudioPlayer
//
//  Created by 杨志赟 on 15/11/18.
//  Copyright © 2015年 xiaoluuu. All rights reserved.
//

import UIKit

extension NSTimeInterval {
    
    
    func audioPlayerGetTimeFormatted() -> String {
        
        if self < 0.0 {
            return "0:00"
        }
        
        let seconds = Int(self)%60
        let minutes = Int(self)/60
        let hours = minutes/60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours,minutes,seconds)
        }else{
            return String(format: "%d:%02d",minutes,seconds)
        }
        
    }
    
    
    static func audioPlayerGetRemainingTimeFormatted(currentTime : NSTimeInterval, duration : NSTimeInterval) ->String {
        let remainingTime = duration - currentTime
        let formattedRemainingTime = remainingTime.audioPlayerGetTimeFormatted()
        return String(format: "-%@", formattedRemainingTime)
    }
    
}
