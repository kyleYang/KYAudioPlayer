//
//  KYAudioPlayerView.swift
//  KYAudioPlayer
//
//  Created by 杨志赟 on 15/11/13.
//  Copyright © 2015年 xiaoluuu. All rights reserved.
//

import UIKit

class KYAudioPlayerView: UIView {

    weak var _delegate : KYAudioPlayerControlActionDelegate?
    weak var delegate : KYAudioPlayerControlActionDelegate?{
        get{
            return _delegate
        }set{
            
            _delegate = newValue
            self.controlsView.delegate = _delegate
        }
    }
    weak var dataSource : KYAudioPlayerControlDataSource?
    
    var controlStyle : KYAudioControlStyle!{
        get{
            return _controlStyle
        }set{
            if _controlStyle != newValue {
                _controlStyle = newValue
                controlsView.controlStyle = _controlStyle
                
            }
        }
    }
    private(set) var controlsView : KYAudioPlayerControlView! =  KYAudioPlayerControlView(frame:CGRectZero)
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    private func setup() {

        controlsView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(controlsView)
    
        let views = ["controlsView":controlsView]
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[controlsView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[controlsView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
    }
    
    
    
    func updateCurrentTime(currentTime:NSTimeInterval, duration : NSTimeInterval){
        
    }
    
    func updateWithPlaybackStatus(isPlaying : Bool){
        
        controlsView.updateWithPlaybackStatus(isPlaying)
    }

    func resetAudioStatus() {
        
    }
    
    
    private var _controlStyle : KYAudioControlStyle! = .InitView
}


