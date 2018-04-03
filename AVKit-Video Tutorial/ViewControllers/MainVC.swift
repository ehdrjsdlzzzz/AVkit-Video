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
    
    var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        return view
    }()

    var playPauseButton:UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(#imageLiteral(resourceName: "icon_play"), for: .normal)
        return button
    }()
    
    var playBackControlView:UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var playerLayer:AVPlayerLayer!
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad()")
        setupVideoPlayerContainerView()
        observePlayer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        player.play()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("viewDidLayoutSubviews()")
        playerLayer.frame = containerView.frame
        
    }
    
    fileprivate func observePlayer(){
        let time = CMTime(value: 1, timescale: 10)
        let times = [NSValue.init(time: time)]
        player.addBoundaryTimeObserver(forTimes: times, queue: .main) {
            self.playPauseButton.setImage(#imageLiteral(resourceName: "icon_pause"), for: .normal)
        }
    }
    
    fileprivate func setupVideoPlayerContainerView(){
        setupPlayerItem()
        setupPlayerLayer()
        containerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleVideoViewTap)))
        self.view.addSubview(containerView)
        containerView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        containerView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        containerView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        
        setupPlayBackControlView()
    }
    
    fileprivate func setupPlayBackControlView(){
        containerView.addSubview(playBackControlView)
        playBackControlView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        playBackControlView.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        playBackControlView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        playBackControlView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        
        playBackControlView.addSubview(playPauseButton)
        playPauseButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        playPauseButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        playPauseButton.centerXAnchor.constraint(equalTo: playBackControlView.centerXAnchor).isActive = true
        playPauseButton.centerYAnchor.constraint(equalTo: playBackControlView.centerYAnchor).isActive = true
    }
    
    @objc func handleVideoViewTap(){
        
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
            playPauseButton.setImage(#imageLiteral(resourceName: "icon_play"), for: .normal)
        }else if player.timeControlStatus == .paused {
            player.play()
            playPauseButton.setImage(#imageLiteral(resourceName: "icon_pause"), for: .normal)
        }
    }
}
