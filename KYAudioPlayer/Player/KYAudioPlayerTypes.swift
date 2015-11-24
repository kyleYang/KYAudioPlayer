//
//  KYAudioPlayerTypes.swift
//  KYAudioPlayer
//
//  Created by 杨志赟 on 15/11/13.
//  Copyright © 2015年 xiaoluuu. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation

enum KYAudioControlStyle {
    
    case InitView
    case FullView
    case CustomView
}


@objc public enum KYAudionPlayerControlAction : Int {
    
    case TogglePlayPause
    case BeginScrubbing
    case ScrubbingValueChanged
    case EndScrubbing
    case Next
    case Previous
    
}


@objc protocol KYAudioPlayerDelegate : NSObjectProtocol {
    
    optional func audioPlayer(player : KYAudioPlayer , didFailPlaybackOfURL URL : String) -> Void
    optional func audioPlayer(player : KYAudioPlayer , didStartPlaybackOfURL URL : String) -> Void
    optional func audioPlayer(player : KYAudioPlayer , hasProtectedContentURL URL : String) -> Void
    optional func audioPlayer(player : KYAudioPlayer , didUpdateCurrentTime currentTime:NSTimeInterval) ->Void
    optional func audioPlayer(player : KYAudioPlayer , didChangeStatus playerStatus : AVPlayerStatus) ->Void
    
    optional func audioPlayer(player : KYAudioPlayer , isLoading loading : Bool) ->Void
    optional func audioPlayer(player : KYAudioPlayer , didChangePlaybackRate rate : Float) ->Void
    optional func audioPlayerDidResumePlayback(player : KYAudioPlayer) ->Void
    optional func audioPlayerDidPausePlayback(player : KYAudioPlayer) ->Void
}



@objc protocol KYAudioPlayerControlActionDelegate : NSObjectProtocol {
    
    optional func audioPlayer(control : AnyObject , didPerformAction action :KYAudionPlayerControlAction) -> Void
}


@objc protocol KYAudioPlayerControlDataSource : NSObjectProtocol {
    
   
}



@objc protocol AudioPlayerViewDelegate : NSObjectProtocol {
    
    
}