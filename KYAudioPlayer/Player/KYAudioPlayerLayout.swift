//
//  KYAudioPlayerLayout.swift
//  KYAudioPlayer
//
//  Created by 杨志赟 on 15/11/13.
//  Copyright © 2015年 xiaoluuu. All rights reserved.
//

import UIKit

class KYAudioPlayerLayout: NSObject {

    private(set) var playPauseControl : UIButton!
    private(set) var rewindControl : UIButton!   //上一首
    private(set) var forwardControl : UIButton!  //下一首
    private(set) var currentTimeLabel : UILabel!
    private(set) var remainingTimeLabel : UILabel!
    private(set) var scrubberControl : KYAudioScrubber!
    
    weak var controlerView : KYAudioPlayerControlView!
    
    weak var audioPlayer : KYAudioPlayer! {
        get{
            return _audioPlayer
        }set{
            if _audioPlayer != newValue{
                _audioPlayer = newValue
                controlerView = _audioPlayer.view.controlsView
                self.linkView()
                self.attachView()
                
            }
        }
    }
    
    
    private func linkView() {
        
        playPauseControl = _audioPlayer.view.controlsView.playPauseControl
        rewindControl = _audioPlayer.view.controlsView.rewindControl
        forwardControl = _audioPlayer.view.controlsView.forwardControl
        currentTimeLabel = _audioPlayer.view.controlsView.currentTimeLabel
        remainingTimeLabel = _audioPlayer.view.controlsView.remainingTimeLabel
        scrubberControl = _audioPlayer.view.controlsView.scrubberControl
    }
    
    var controlsView : KYAudioPlayerControlView  {
        get{
           return audioPlayer.view.controlsView
        }
    }
    
    func invalidateLayout() {
        controlsView.setNeedsLayout()
    }
    
    
    func layoutControls(controlStyle : KYAudioControlStyle) {
        
    }
    
    weak var _audioPlayer : KYAudioPlayer!
    
    
    //MARK: custom the player style must override the method
    //add attach view in controller view
    func attachView(){
        
    }
    
    func updateWithPlaybackStatus(isPlaying : Bool){
        
    }
    
    func updateControlStyle(controlStyle:KYAudioControlStyle) {
        
    }

    
}


//MARK: Set Button Value
extension KYAudioPlayerLayout {
    
    

    
}
