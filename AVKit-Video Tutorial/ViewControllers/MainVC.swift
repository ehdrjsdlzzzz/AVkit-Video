//
//  MainVC.swift
//  AVKit-Video Tutorial
//
//  Created by 이동건 on 2018. 4. 3..
//  Copyright © 2018년 이동건. All rights reserved.
//

import UIKit
import Alamofire
import AVKit

class MainVC: UIViewController {
    
    var player:AVPlayer = {
        let player = AVPlayer()
        player.automaticallyWaitsToMinimizeStalling = false
        return player
    }()
    
    var playPauseButton:UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(#imageLiteral(resourceName: "icons-play"), for: .normal)
        return button
    }()
    
    var playBackControlView:UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var enlargrScreenButton:UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(#imageLiteral(resourceName: "icons-full_screen"), for: .normal)
        return button
    }()
    
    var playerLayer:AVPlayerLayer!
    var isLandscapeMode:Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVideoPlayerContainerView()
        observePlayer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        player.play()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer.frame = containerView.frame
    }
    
    fileprivate func observePlayer(){
        let time = CMTime(value: 1, timescale: 10)
        let times = [NSValue.init(time: time)]
        player.addBoundaryTimeObserver(forTimes: times, queue: .main) {
            self.playPauseButton.setImage(#imageLiteral(resourceName: "icons-pause"), for: .normal)
            Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: { (_) in
                UIView.animate(withDuration: 1.5, animations: {
                    if self.playBackControlView.alpha == 1 {
                        self.playBackControlView.alpha = 0
                    }
                })
            })
        }
    }
    
    fileprivate func setupVideoPlayerContainerView(){
        setupPlayerItem()
        setupPlayerLayer()
        containerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleVideoViewTap)))
        setupPlayBackControlView()
    }
    
    fileprivate func setupPlayBackControlView(){
        containerView.addSubview(playBackControlView)
        playBackControlView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        playBackControlView.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        playBackControlView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        playBackControlView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        
        playBackControlView.addSubview(playPauseButton)
        playPauseButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        playPauseButton.heightAnchor.constraint(equalToConstant: 100).isActive = true
        playPauseButton.centerXAnchor.constraint(equalTo: playBackControlView.centerXAnchor).isActive = true
        playPauseButton.centerYAnchor.constraint(equalTo: playBackControlView.centerYAnchor).isActive = true
        playPauseButton.addTarget(self, action: #selector(handlePlayPauseButton), for: .touchUpInside)
        
        playBackControlView.addSubview(enlargrScreenButton)
        enlargrScreenButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        enlargrScreenButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        enlargrScreenButton.rightAnchor.constraint(equalTo: playBackControlView.rightAnchor, constant: 4).isActive = true
        enlargrScreenButton.bottomAnchor.constraint(equalTo: playBackControlView.bottomAnchor, constant: 4).isActive = true
        enlargrScreenButton.addTarget(self, action: #selector(hanldeEnlargeScreen), for: .touchUpInside)
        
        let playbackSlider = UISlider()
        playbackSlider.minimumTrackTintColor = .darkGray
        playbackSlider.setThumbImage(#imageLiteral(resourceName: "icons-slider-thumb"), for: .normal)
        playBackControlView.addSubview(playbackSlider)
        playbackSlider.translatesAutoresizingMaskIntoConstraints = false
        playbackSlider.leftAnchor.constraint(equalTo: playBackControlView.leftAnchor, constant: 4).isActive = true
        playbackSlider.rightAnchor.constraint(equalTo: enlargrScreenButton.leftAnchor, constant: 2).isActive = true
        playbackSlider.centerYAnchor.constraint(equalTo: enlargrScreenButton.centerYAnchor).isActive = true
    }
    
    @objc func hanldeEnlargeScreen(){
        let value:Int!
        if isLandscapeMode {
             value = UIInterfaceOrientation.portrait.rawValue
            isLandscapeMode = false
        }else {
            value = UIInterfaceOrientation.landscapeRight.rawValue
            isLandscapeMode = true
        }
        UIDevice.current.setValue(value, forKey: "orientation")
    }
    
    @objc func handleVideoViewTap(){
        UIView.animate(withDuration: 0.5, animations: {
            if self.playBackControlView.alpha == 0 {
                self.playBackControlView.alpha = 1
            }else {
                self.playBackControlView.alpha = 0
            }
        }) { (_) in
            Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: { (_) in
                UIView.animate(withDuration: 1.5, animations: {
                    if self.playBackControlView.alpha == 1 {
                        self.playBackControlView.alpha = 0
                    }
                })
            })
        }
    }
    
    fileprivate func setupPlayerLayer(){
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resize
        containerView.layer.addSublayer(playerLayer)
    }
    fileprivate func setupPlayerItem(){
        guard let videoUrl = URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4") else {return}
        let item = AVPlayerItem(url: videoUrl)
        player.replaceCurrentItem(with: item)
    }
    
    @objc fileprivate func handlePlayPauseButton(){
        if player.timeControlStatus == .playing {
            player.pause()
            playPauseButton.setImage(#imageLiteral(resourceName: "icons-play"), for: .normal)
        }else if player.timeControlStatus == .paused {
            player.play()
            playPauseButton.setImage(#imageLiteral(resourceName: "icons-pause"), for: .normal)
        }
    }
}
