//
//  KYAudioPlayerControlView.swift
//  KYAudioPlayer
//
//  Created by 杨志赟 on 15/11/13.
//  Copyright © 2015年 xiaoluuu. All rights reserved.
//

import UIKit

class KYAudioPlayerControlView: UIView {

    var layout : KYAudioPlayerLayout {
        get{
            return _layout
        }set{
            if _layout != newValue {
                _layout = newValue
                _layout.updateControlStyle(controlStyle)
            }
        }
    }
    
    private(set) var playPauseControl : UIButton!
    private(set) var rewindControl : UIButton!   //上一首
    private(set) var forwardControl : UIButton!  //下一首
    private(set) var currentTimeLabel : UILabel!
    private(set) var remainingTimeLabel : UILabel!
    private(set) var scrubberControl : KYAudioScrubber!

    weak var delegate : KYAudioPlayerControlActionDelegate?
    
     var controlStyle : KYAudioControlStyle!{
        get{
            return _controlStyle
        }set{
            if _controlStyle != newValue {
                _controlStyle = newValue
                layout.updateControlStyle(_controlStyle)
            }
        }
    }
    
   

    
    override init(frame: CGRect) {
        super.init(frame:frame)
        
        
        playPauseControl = UIButton(type: .Custom)
        playPauseControl.contentMode = .Center
        playPauseControl.showsTouchWhenHighlighted = true
        playPauseControl.backgroundColor = UIColor.redColor()
        playPauseControl.translatesAutoresizingMaskIntoConstraints = false
        playPauseControl.addTarget(self, action: "handlePlayPauseButtonPress:", forControlEvents: .TouchUpInside)
        addSubview(playPauseControl)
        
        rewindControl = UIButton(type: .Custom)
        rewindControl.translatesAutoresizingMaskIntoConstraints = false
        rewindControl.showsTouchWhenHighlighted = true;
        rewindControl.addTarget(self, action: "handleRewindButtonTouchUp:", forControlEvents: .TouchUpInside)
        addSubview(rewindControl)
        
        forwardControl = UIButton(type: .Custom)
        forwardControl.backgroundColor = UIColor.greenColor()
        forwardControl.translatesAutoresizingMaskIntoConstraints = false
        forwardControl.showsTouchWhenHighlighted = true;
        forwardControl.addTarget(self, action: "handleForwordButtonTouchUp:", forControlEvents: .TouchUpInside)
        addSubview(forwardControl)
    
        currentTimeLabel = UILabel(frame: CGRectZero)
        currentTimeLabel.textColor = UIColor.whiteColor()
        currentTimeLabel.font = UIFont.systemFontOfSize(13)
        currentTimeLabel.textAlignment = .Right
        currentTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(currentTimeLabel)
        
        remainingTimeLabel = UILabel(frame: CGRectZero)
        remainingTimeLabel.textColor = UIColor.whiteColor()
        remainingTimeLabel.font = UIFont.systemFontOfSize(13)
        remainingTimeLabel.textAlignment = .Left
        remainingTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(remainingTimeLabel)
    
        scrubberControl = KYAudioScrubber(frame: CGRectZero)
        scrubberControl.translatesAutoresizingMaskIntoConstraints = false
        scrubberControl.addTarget(self, action: "handleBeginScrubbing:", forControlEvents: .TouchDown)
        scrubberControl.addTarget(self, action: "handleScrubbingValueChanged:", forControlEvents: .ValueChanged)
        scrubberControl.addTarget(self, action: "handleEndScrubbing:", forControlEvents: .TouchUpInside)
        scrubberControl.addTarget(self, action: "handleEndScrubbing:", forControlEvents: .TouchUpOutside)
        addSubview(scrubberControl)
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layout.layoutControls(self.controlStyle)
    }
    
    
    func updateWithPlaybackStatus(isPlaying : Bool){
        self.layout.updateWithPlaybackStatus(isPlaying)
    }
    
   private var _controlStyle : KYAudioControlStyle! = .InitView
   private var _layout : KYAudioPlayerLayout! = KYAudioPlayerLayout()
}

//MARK:
//MARK: BUTTON ACTION
extension KYAudioPlayerControlView {
    
    func handlePlayPauseButtonPress(sender : AnyObject) {
        
        delegate?.audioPlayer?(sender, didPerformAction: .TogglePlayPause)
        
    }
    
    func handleRewindButtonTouchUp(sender : AnyObject) {
        
        delegate?.audioPlayer?(sender, didPerformAction: .Previous)
    }
    
    func handleForwordButtonTouchUp(sender : AnyObject) {
      
        delegate?.audioPlayer?(sender, didPerformAction: .Next)
    }

    
    func handleBeginScrubbing(sender:KYAudioScrubber){
        delegate?.audioPlayer?(sender, didPerformAction: .BeginScrubbing)
    }
    
    func handleScrubbingValueChanged(sender:KYAudioScrubber){
        
        self.currentTimeLabel.text = NSTimeInterval(self.scrubberControl.value).audioPlayerGetTimeFormatted()
        self.remainingTimeLabel.text = NSTimeInterval(self.scrubberControl.maximumValue).audioPlayerGetTimeFormatted()
        
        delegate?.audioPlayer?(sender, didPerformAction: .ScrubbingValueChanged)
    }
    
    func handleEndScrubbing(sender:KYAudioScrubber){
         delegate?.audioPlayer?(sender, didPerformAction: .EndScrubbing)
    }
    
    
    
}
