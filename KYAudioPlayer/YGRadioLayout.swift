//
//  YGRadioLayout.swift
//  KYAudioPlayer
//
//  Created by 杨志赟 on 15/11/24.
//  Copyright © 2015年 xiaoluuu. All rights reserved.
//

import UIKit

class YGRadioLayout: KYAudioPlayerLayout {
    
    var iconView : UIImageView!
    var titleLabel : UILabel!
    var authorLabel : UILabel!
    
    override init() {
        super.init()
        
        iconView = UIImageView()
        iconView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        authorLabel = UILabel()
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    
    override func attachView() {
        
        self.audioPlayer.view.controlsView.addSubview(iconView)
        self.audioPlayer.view.controlsView.addSubview(titleLabel)
        self.audioPlayer.view.controlsView.addSubview(authorLabel)
        
    }
    
    override func updateWithPlaybackStatus(isPlaying: Bool) {
        
        if isPlaying {
            playPauseControl.backgroundColor = UIColor.redColor()
        }else{
            playPauseControl.backgroundColor = UIColor.blackColor()
        }
        
        
    }
    
    override func updateControlStyle(controlStyle: KYAudioControlStyle) {
        
        controlsView.removeConstraints(controlsView.constraints)
        
        let views = [ "scrubberControl" :scrubberControl,  "playPauseControl":playPauseControl,   "forwardControl":forwardControl,"iconView":iconView,"titleLabel":titleLabel,"authorLabel":authorLabel]
      
        
        controlsView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-10-[scrubberControl]-10-|", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: views))
        controlsView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-10-[iconView(40)]-6-[titleLabel]->=20-[playPauseControl(40)]-10-[forwardControl(30)]-10-|", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: views))
        controlsView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-5-[scrubberControl(18)]-5-[iconView(40)]", options: NSLayoutFormatOptions(rawValue:0), metrics: nil, views: views))
    
        controlsView.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: .Top, relatedBy: .Equal, toItem: iconView, attribute: .Top, multiplier: 1.0, constant: 0))
       
        controlsView.addConstraint(NSLayoutConstraint(item: playPauseControl, attribute: .Top, relatedBy: .Equal, toItem: iconView, attribute: .Top, multiplier: 1.0, constant: 0))
        controlsView.addConstraint(NSLayoutConstraint(item: playPauseControl, attribute: .Height, relatedBy: .Equal, toItem: playPauseControl, attribute: .Width, multiplier: 1.0, constant: 0))
        
        controlsView.addConstraint(NSLayoutConstraint(item: forwardControl, attribute: .Height, relatedBy: .Equal, toItem: forwardControl, attribute: .Width, multiplier: 1.0, constant: 0))
        controlsView.addConstraint(NSLayoutConstraint(item: forwardControl, attribute: .CenterY, relatedBy: .Equal, toItem: playPauseControl, attribute: .CenterY, multiplier: 1.0, constant: 0))
        
        controlsView.addConstraint(NSLayoutConstraint(item: authorLabel, attribute: .Left, relatedBy: .Equal, toItem: titleLabel, attribute: .Left, multiplier: 1.0, constant: 0))
        controlsView.addConstraint(NSLayoutConstraint(item: authorLabel, attribute: .Top, relatedBy: .Equal, toItem: titleLabel, attribute: .Bottom, multiplier: 1.0, constant: 8))

    }
    

}
