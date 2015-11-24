//
//  ViewController.swift
//  KYAudioPlayer
//
//  Created by 杨志赟 on 15/11/12.
//  Copyright © 2015年 xiaoluuu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
    var player : KYAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        player = KYAudioPlayer(file: "http://qiniuuwmp3.changba.com/582639094.mp3")
        let layout = YGRadioLayout()
        layout.titleLabel.text = "韩语最动听的音乐集锦"
        layout.authorLabel.text = "想唱就唱"
        player.layout = layout
        
        player.addToSuperView(self.view, frame: CGRectMake(0, 100, CGRectGetWidth(self.view.bounds), 83))
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

