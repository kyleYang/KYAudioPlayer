//
//  KYAudioPlayer.swift
//  KYAudioPlayer
//
//  Created by 杨志赟 on 15/11/12.
//  Copyright © 2015年 xiaoluuu. All rights reserved.
//

import UIKit
import AVFoundation

class KYAudioPlayer: NSObject {

    
    
    private let kRateKey = "rate"
    private let kCurrentItemKey = "currentItem"
    
    
    private let kTrackKey = "tracks"
    private let kPlayableKey = "playable"
    private let kHasProtectedContentKey = "hasProtectedContent"

    private let kStatusKey         = "status"
    private let kDrautionKey        = "duration"
    private let kLoadedTimeRangesKey = "loadedTimeRanges"
    private let kPlaybackBufferEmpty = "playbackBufferEmpty"
    private let kPlaybackLikelyToKeepUp = "playbackLikelyToKeepUp"
    
    
    var  playerItemStatusContext : UnsafePointer<Void> = UnsafePointer<Void>()
    var  playerItemDurationContext : UnsafePointer<Void> = UnsafePointer<Void>()
    var  playerItemLoadedTimeRangesContext : UnsafePointer<Void> = UnsafePointer<Void>()
    var  playerItemBufferEmpty : UnsafePointer<Void> = UnsafePointer<Void>()
    var  playerItemLikelyToKeepUp : UnsafePointer<Void> = UnsafePointer<Void>()
    var  playerCurrentItemContext : UnsafePointer<Void> = UnsafePointer<Void>()
    var  playerRateContext : UnsafePointer<Void> = UnsafePointer<Void>()
    var  playerAirPlayVideoActiveContext : UnsafePointer<Void> = UnsafePointer<Void>()
    
    private var _seekToInitialPlaybackTimeBeforePlay : Bool = true
    
    private var userPause : Bool! = false
    
    private var playerItem : AVPlayerItem?
    
    weak var delegate : KYAudioPlayerDelegate?
    var initialPlaybackTime : NSTimeInterval! = 0
    var initialPlaybackToleranceTime : NSTimeInterval! = 1000
    weak var skippingTimer : NSTimer?

    private(set) var playing : Bool {
        get{
           return self.audioPlayer != nil && self.audioPlayer.rate != 0.0;
        }set{
            
        }
    }
    
    private(set) var scrubbing : Bool! = false
    var autostartWhenReady : Bool = true
    
    private var currentPlaybackTime : NSTimeInterval {
        get{
            let time = self.audioPlayer?.currentTime()
            if time != nil {
                return CMTimeGetSeconds(time!)
            }else{
                return 0
            }
            
            
        }
    }
    
    private var duration : NSTimeInterval{
        return CMTimeGetSeconds(self.CMDuration);
    }
    
    private var initialPlaybackToleranceCMTime : CMTime {
        if initialPlaybackToleranceTime >= 1000 {
            return kCMTimePositiveInfinity
        }else if initialPlaybackToleranceTime <= 0.001 {
            return kCMTimeZero
        }else{
            return CMTimeMakeWithSeconds(initialPlaybackToleranceTime, Int32(NSEC_PER_SEC))
        }
    }

    private var CMDuration : CMTime {
        
        var duration = kCMTimeInvalid
        if self.audioPlayer?.currentItem?.status == .ReadyToPlay {
            if CMTIME_IS_VALID(self.audioPlayer.currentItem!.duration) {
                duration = (self.audioPlayer.currentItem?.duration)!
            }
        }
        
        if (!CMTIME_IS_VALID(duration) || duration.value/Int64(duration.timescale) < 2) && CMTIME_IS_VALID((self.audioPlayer?.currentItem?.duration)!) {
            duration = (self.audioPlayer?.currentItem?.duration)!
        }
        
        return duration
    }
    
   
    
    
    lazy private(set) var view : KYAudioPlayerView! = {
        
        let temp = KYAudioPlayerView(frame:CGRectZero)
        temp.delegate = self
        temp.dataSource = self
        return temp
    }()
    
    
    var layout : KYAudioPlayerLayout!  {
        get{
            return _layout
        }set{
            if _layout != newValue {
                _layout = newValue
                
                _layout.audioPlayer = self
                self.view.controlsView.layout = _layout
                
            }
        }
    }
    
    
    private(set) var audioPlayer : AVPlayer!
    var playerUrl : String! {
        get{
            return _playerUrl
        }set{
            if _playerUrl != newValue {
                _playerUrl = newValue
                
                
                if _playerUrl != nil {
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        self .doneLoadingURL(NSURL(string: self._playerUrl)!)
                    })
                
                    
                    self.view.updateCurrentTime(0, duration: 0)
                    self.view.resetAudioStatus()

                }
                
            }
        }
    }
    
    override init() {
        super.init()
        
        
    }
    
    
    convenience init(file : String!){
        self.init()
        self.playerUrl = file
        
    }
    
    
    func addToSuperView(superView : UIView , frame : CGRect){
        self.view.frame = frame
        superView.addSubview(self.view)
    }
    
    
    private func doneLoadingURL(url : NSURL) {
        
        
        if self.audioPlayer != nil {
            
            self.audioPlayer.pause()
            self.audioPlayer.removeObserver(self, forKeyPath: kStatusKey)
           
            self.audioPlayer.removeObserver(self, forKeyPath: kRateKey)
            self.audioPlayer.removeObserver(self, forKeyPath: kCurrentItemKey)
            
            NSNotificationCenter.defaultCenter().removeObserver(self, name: AVPlayerItemDidPlayToEndTimeNotification, object: self.audioPlayer)
            
        }
        
        _seekToInitialPlaybackTimeBeforePlay = true;
        
        // Create the player
        if self.audioPlayer == nil {
            
            self.audioPlayer = AVPlayer(URL: url)
            
            self.audioPlayer.addObserver(self, forKeyPath: kStatusKey, options: [.Initial,.New], context: &playerItemStatusContext)
            self.audioPlayer .addObserver(self, forKeyPath: kCurrentItemKey, options: [.Initial,.New], context: &playerCurrentItemContext)
            self.audioPlayer .addObserver(self, forKeyPath: kRateKey, options: [.Initial,.New], context: &playerRateContext)
           
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerItemDidPlayToEndTime:", name: AVPlayerItemDidPlayToEndTimeNotification, object: self.audioPlayer)
        }
        


        
    }
    
    //MARK: KVO
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if context == &playerItemStatusContext {
            
            let status = AVPlayerStatus(rawValue: Int(change![NSKeyValueChangeNewKey] as! NSNumber))
            
            if let temp = status{
                switch temp {
                case  .Unknown :
                    self.stopObservingPlayerTimeChanges()
                    self.view.updateCurrentTime(self.currentPlaybackTime, duration: self.duration)
                    
                case .ReadyToPlay :
                    if !self.scrubbing {
                        
                        if let _ = self.playerItem {
                            
                            self.playerItem!.removeObserver(self, forKeyPath: kDrautionKey)
                            self.playerItem!.removeObserver(self, forKeyPath: kLoadedTimeRangesKey)
                            self.playerItem!.removeObserver(self, forKeyPath: kPlaybackBufferEmpty)
                            self.playerItem!.removeObserver(self, forKeyPath: kPlaybackLikelyToKeepUp)
                            
                        }
                        
                        self.playerItem = self.audioPlayer.currentItem
                        
                        
                        if let _ = self.playerItem {
                            
                            self.playerItem!.addObserver(self, forKeyPath: kDrautionKey, options: [.Initial,.New], context: &playerItemDurationContext)
                            self.playerItem!.addObserver(self, forKeyPath: kLoadedTimeRangesKey, options: [.Initial,.New], context: &playerItemLoadedTimeRangesContext)
                            self.playerItem!.addObserver(self, forKeyPath: kPlaybackBufferEmpty, options: [.Initial,.New], context: &playerItemBufferEmpty)
                            self.playerItem!.addObserver(self, forKeyPath: kPlaybackLikelyToKeepUp, options: [.Initial,.New], context: &playerItemLikelyToKeepUp)
                            
                        }
                        
                        if self.autostartWhenReady && UIApplication.sharedApplication().applicationState == .Active {
                            self.autostartWhenReady = false
                            self.play()
                        }
                    }
                    
                case .Failed:
                    
                    self.stopObservingPlayerTimeChanges()
                    self.view.updateCurrentTime(self.currentPlaybackTime, duration: self.duration)
                    
                }

            }
            
            self.view .updateWithPlaybackStatus(self.playing)
            self.delegate?.audioPlayer?(self, didChangeStatus: status!)
        }
        else if context == &playerItemBufferEmpty {
            
            let item = object as? AVPlayerItem
            
            if (item!.playbackBufferEmpty) {
                self.pause()
                self.delegate?.audioPlayer?(self, isLoading: true)
            }
            else {
                self.play()
                self.delegate?.audioPlayer?(self, isLoading: false)
            }

            
        }
        else if context == &playerItemLikelyToKeepUp {
            
            let item = object as? AVPlayerItem
            if item!.playbackLikelyToKeepUp {
                if !self.userPause {
                   self.play()
                }
                self.delegate?.audioPlayer?(self, isLoading: false)
            } else {
                self.pause()
                self.delegate?.audioPlayer?(self, isLoading: true)
            }

            
        }
        else if context == &playerItemLoadedTimeRangesContext {
            self.updatePlayableDurationTimerFired(nil)
            
            
        }
        else if (context == &playerItemDurationContext) {
            self.view .updateCurrentTime(self.currentPlaybackTime, duration: self.duration)
            
        }
        else if (context == &playerCurrentItemContext) {
            let newPlayerItem = change![NSKeyValueChangeNewKey] as? AVPlayerItem
           
            if let _ = newPlayerItem {
                self.view .updateWithPlaybackStatus(self.playing)
                self.startObservingPlayerTimeChanges()
            }else{
                self.stopObservingPlayerTimeChanges()
            }
        }
            
        else if (context == &playerRateContext) {
            self.view.updateWithPlaybackStatus(self.playing)
            
            self.delegate?.audioPlayer?(self, didChangePlaybackRate: self.audioPlayer.rate)
        }
            
        else if (context == &playerAirPlayVideoActiveContext) {

        }
            
        else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }

        
    }
    
    
    //MARK: time observe
    private func startObservingPlayerTimeChanges() {
        
        if self.playerTimeObserver == nil {
            
            self.playerTimeObserver = self.audioPlayer.addPeriodicTimeObserverForInterval(CMTimeMakeWithSeconds(0.5,Int32(NSEC_PER_SEC)), queue: dispatch_get_main_queue(), usingBlock: { (CMTime) -> Void in
                
         
                if (CMTIME_IS_VALID(self.audioPlayer.currentTime()) && CMTIME_IS_VALID(self.CMDuration)) {
                    
                    self.view.updateCurrentTime(self.currentPlaybackTime, duration: self.duration)
                    self.moviePlayerDidUpdateCurrentPlaybackTime(self.currentPlaybackTime)
                    
                    self.delegate?.audioPlayer?(self, didUpdateCurrentTime: self.currentPlaybackTime)
                }
                
                
            })
            
        }
        
    }
    
    private func stopObservingPlayerTimeChanges() {
        if self.playerTimeObserver != nil {
            self.audioPlayer .removeTimeObserver(self.playerTimeObserver)
            self.playerTimeObserver = nil
        }
    }
    
    
    
    //MARK: UPDATA UI
    private func updatePlayableDurationTimerFired(timer : NSTimer?){
        
    }
    
    
    

    //MARK: - NGMoviePlayer Subclass Hooks
    private func moviePlayerDidStartToPlay() {

        view.updateWithPlaybackStatus(self.playing)
    }
    
    private func moviePlayerDidPausePlayback() {
        
        view.updateWithPlaybackStatus(self.playing)
    }
    
    private func moviePlayerDidResumePlayback() {
        
        view.updateWithPlaybackStatus(self.playing)
    }
    
    private func moviePlayerDidUpdateCurrentPlaybackTime(currentPlaybackTime:NSTimeInterval) {
        // do nothing here
    }

    private func moviePlayerWillShowControlsWithDuration(duration:NSTimeInterval) {
        // do nothing here
    }
    
    private func moviePlayerDidShowControls() {
        // do nothing here
    }
    

    private func moviePlayerWillHideControlsWithDuration(duration:NSTimeInterval) {
        // do nothing here
    }

    private func moviePlayerDidHideControls() {
        // do nothing here
    }

    
    
    
    private var _playerUrl : String! = ""
    private var _layout : KYAudioPlayerLayout! = KYAudioPlayerLayout()
    private var playerTimeObserver : AnyObject!

}

//MARK:
//MARK: ACTION
extension KYAudioPlayer {
    
    
    func play() {
        
        if self.audioPlayer.status == .ReadyToPlay {
            if _seekToInitialPlaybackTimeBeforePlay && initialPlaybackTime >= 0 {
                let time = CMTimeMakeWithSeconds(initialPlaybackTime,Int32(NSEC_PER_SEC))
                let tolerance = initialPlaybackToleranceCMTime
                
                let afterSeekAction : dispatch_block_t = { [weak self]() -> Void in
                    
                    self?.moviePlayerDidStartToPlay()
                    self?.delegate?.audioPlayer?(self!, didStartPlaybackOfURL: self!.playerUrl)
        
                }
                
                if self.audioPlayer.respondsToSelector(Selector("seekToTime:toleranceBefore:toleranceAfter:completionHandler")) {
                    
                    self.audioPlayer .seekToTime(time, toleranceBefore: tolerance, toleranceAfter: tolerance, completionHandler: { (Bool) -> Void in
                        afterSeekAction()
                    })
                    
                }else{
                    self.audioPlayer.seekToTime(time, toleranceBefore: tolerance, toleranceAfter: tolerance)
                    afterSeekAction()
                }
                
                _seekToInitialPlaybackTimeBeforePlay = false
                
            }else{
                
                self.delegate?.audioPlayerDidResumePlayback?(self)
                
                self.moviePlayerDidResumePlayback()
                self.audioPlayer.play()
            }
        }
        
    }
    
    
    func pause() {
        
        self.audioPlayer.pause()
        
        if let _ = self.skippingTimer {
            self.skippingTimer?.invalidate()
            self.skippingTimer = nil
        }
        
       
        self.delegate?.audioPlayerDidPausePlayback?(self)
        
        self.moviePlayerDidPausePlayback()
    }
    
    func togglePlaybackState() {
        
        if self.playing {
            self.pause()
        }else{
            self.play()
        }
        
    }
    
}


//MARK:
//MARK: AVAudioPlayerDelegate
extension KYAudioPlayer : AVAudioPlayerDelegate {
    
    
    
    
}



extension KYAudioPlayer : KYAudioPlayerControlActionDelegate {
    
    func audioPlayer(control: AnyObject, didPerformAction action: KYAudionPlayerControlAction) {
        
        switch action {
        case .TogglePlayPause :
            self.togglePlaybackState()
            break
        case .BeginScrubbing :
            break
        case .ScrubbingValueChanged :
            break
        case .EndScrubbing :
            break
        case .Next :
            break
        case .Previous :
            break
        }
        
    }
    
}

extension KYAudioPlayer : KYAudioPlayerControlDataSource {
    
    
}
