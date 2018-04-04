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
    
    @IBOutlet weak var containerView: UIView!
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
    
    var currentTimeLabel:UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.text = "00:00"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var videoDurationLabel:UILabel = {
       let label = UILabel()
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.text = "00:00"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
        button.contentMode = .scaleAspectFit
        button.setImage(#imageLiteral(resourceName: "icons-full_screen"), for: .normal)
        return button
    }()
    
    var playbackSlider:UISlider = {
        let slider = UISlider()
        slider.minimumTrackTintColor = .darkGray
        slider.setThumbImage(#imageLiteral(resourceName: "icons-slider-thumb"), for: .normal)
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    
    var playerLayer:AVPlayerLayer!
    var isLandscapeMode:Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVideoPlayerContainerView()
        observePlayer()
        observePlayerCurrentTime()
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
        let time = CMTimeMake(1, 10)
        let times = [NSValue.init(time: time)]
        player.addBoundaryTimeObserver(forTimes: times, queue: .main) { [weak self] in
            self?.playPauseButton.setImage(#imageLiteral(resourceName: "icons-pause"), for: .normal)
        }
    }
    
    fileprivate func observePlayerCurrentTime(){
        let timeInterval = CMTimeMake(1, 2)
        player.addPeriodicTimeObserver(forInterval: timeInterval, queue: .main) { [weak self] (time) in
            self?.currentTimeLabel.text = time.toDisplayString()
            if let durationTime = self?.player.currentItem?.duration, self?.player.currentItem?.status == .readyToPlay{
                self?.videoDurationLabel.text = durationTime.toDisplayString()
                self?.playbackSlider.value = Float(CMTimeGetSeconds(time)) / Float(CMTimeGetSeconds(durationTime))
            }
        }
    }
    
    fileprivate func setupVideoPlayerContainerView(){
        setupPlayerItem()
        setupPlayerLayer()
        setupPlayBackControlView()
    }
    
    fileprivate func setupPlayBackControlView(){
        containerView.addSubview(playBackControlView)
        playBackControlView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        playBackControlView.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        playBackControlView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        playBackControlView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        
        playBackControlView.addSubview(enlargrScreenButton)
        enlargrScreenButton.widthAnchor.constraint(equalToConstant: 25).isActive = true
        enlargrScreenButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        enlargrScreenButton.trailingAnchor.constraint(equalTo: playBackControlView.trailingAnchor, constant: -10).isActive = true
        enlargrScreenButton.bottomAnchor.constraint(equalTo: playBackControlView.bottomAnchor, constant: -10).isActive = true
        enlargrScreenButton.addTarget(self, action: #selector(hanldeEnlargeScreen), for: .touchUpInside)
        
        playBackControlView.addSubview(videoDurationLabel)
        videoDurationLabel.rightAnchor.constraint(equalTo: enlargrScreenButton.leftAnchor, constant: -4).isActive = true
        videoDurationLabel.centerYAnchor.constraint(equalTo: enlargrScreenButton.centerYAnchor).isActive = true
        
        playBackControlView.addSubview(currentTimeLabel)
        currentTimeLabel.leftAnchor.constraint(equalTo: playBackControlView.leftAnchor, constant: 4).isActive = true
        currentTimeLabel.centerYAnchor.constraint(equalTo: enlargrScreenButton.centerYAnchor).isActive = true

        playBackControlView.addSubview(playPauseButton)
        playPauseButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        playPauseButton.heightAnchor.constraint(equalToConstant: 100).isActive = true
        playPauseButton.centerXAnchor.constraint(equalTo: playBackControlView.centerXAnchor).isActive = true
        playPauseButton.centerYAnchor.constraint(equalTo: playBackControlView.centerYAnchor).isActive = true
        playPauseButton.addTarget(self, action: #selector(handlePlayPauseButton), for: .touchUpInside)
        
        
        playBackControlView.addSubview(playbackSlider)
        playbackSlider.leftAnchor.constraint(equalTo: currentTimeLabel.rightAnchor, constant: 14).isActive = true
        playbackSlider.rightAnchor.constraint(equalTo: videoDurationLabel.leftAnchor, constant: -14).isActive = true
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
