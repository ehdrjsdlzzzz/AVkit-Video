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
import MediaPlayer

class MainVC: UIViewController {
    
    //MARK:- Outlets
    @IBOutlet weak var containerView: UIView! {
        didSet{
            containerView.isUserInteractionEnabled = true
        }
    }
    var player:AVPlayer = {
        let player = AVPlayer()
        player.automaticallyWaitsToMinimizeStalling = false
        return player
    }()
    
    var playPauseButton:UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(#imageLiteral(resourceName: "icons-play"), for: .normal)
        button.setImage(#imageLiteral(resourceName: "icons-pause"), for: .selected)
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
        view.isUserInteractionEnabled = true
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
    
    var volumeIndicatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .green
        view.alpha = 0
        return view
    }()
    
    var brightnessIndicatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .green
        view.alpha = 0
        return view
    }()
    
    var systemVolumeView:MPVolumeView = {
        let volumeView = MPVolumeView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        volumeView.isHidden = true
        return volumeView
    }()
    //MARK:- Properties
    var playerLayer:AVPlayerLayer!
    var isLandscapeMode:Bool = false
    var isVolumeChanging:Bool = false
    var isBrightnessChanging:Bool = false
    var volumeIndicatorViewHeightConstraint:NSLayoutConstraint!
    var brightnessIndicatorViewHeightConstraint:NSLayoutConstraint!
    var currentOutputVolume:Float!
    var panStartLocation:CGPoint!
    var panCurrentLoaction:CGPoint!
    var panCount:Int = 0
    //MARK:- Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVideoPlayerContainerView()
        observePlayer()
        observePlayerCurrentTime()
        setupGesture()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        player.play()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer.frame = containerView.frame
    }
}
//MARK:- Setup View
extension MainVC {
    fileprivate func setupVideoPlayerContainerView(){
        setupPlayerItem()
        setupPlayerLayer()
        setupPlayBackControlView()
    }
    
    fileprivate func setupPlayBackControlView(){
        self.view.addSubview(systemVolumeView)
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
        playbackSlider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        
        playBackControlView.addSubview(volumeIndicatorView)
        volumeIndicatorView.rightAnchor.constraint(equalTo: playBackControlView.rightAnchor).isActive = true
        volumeIndicatorView.bottomAnchor.constraint(equalTo: playBackControlView.bottomAnchor).isActive = true
        volumeIndicatorView.widthAnchor.constraint(equalTo: playBackControlView.widthAnchor, multiplier: 0.5).isActive = true
        currentOutputVolume = AVAudioSession.sharedInstance().outputVolume
        let volumeHeightConstant = self.containerView.frame.height * CGFloat(currentOutputVolume)
        volumeIndicatorViewHeightConstraint = volumeIndicatorView.heightAnchor.constraint(equalToConstant: volumeHeightConstant)
        volumeIndicatorViewHeightConstraint.isActive = true
        
        playBackControlView.addSubview(brightnessIndicatorView)
        brightnessIndicatorView.leftAnchor.constraint(equalTo: playBackControlView.leftAnchor).isActive = true
        brightnessIndicatorView.bottomAnchor.constraint(equalTo: playBackControlView.bottomAnchor).isActive = true
        brightnessIndicatorView.widthAnchor.constraint(equalTo: playBackControlView.widthAnchor, multiplier: 0.5).isActive = true
        let brightness = UIScreen.main.brightness
        let brightnessHeightConstant = self.containerView.frame.height * brightness
        brightnessIndicatorViewHeightConstraint = brightnessIndicatorView.heightAnchor.constraint(equalToConstant: brightnessHeightConstant)
        brightnessIndicatorViewHeightConstraint.isActive = true
    }
}
//MARK:- Setup & Observce AVPlayer
extension MainVC {
    fileprivate func observePlayer(){
        let time = CMTimeMake(1, 10)
        let times = [NSValue.init(time: time)]
        player.addBoundaryTimeObserver(forTimes: times, queue: .main) { [weak self] in
            self?.playPauseButton.isSelected = true
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
}
//MARK:- Handler
extension MainVC {
    @objc func sliderValueChanged(){
        let percentage = playbackSlider.value
        guard let duration = player.currentItem?.duration else {return}
        let durationInSeconds = CMTimeGetSeconds(duration)
        let seekTimeInSeconds = Float64(percentage) * durationInSeconds
        let seekTime = CMTimeMakeWithSeconds(seekTimeInSeconds, Int32(NSEC_PER_SEC))
        player.seek(to: seekTime)
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
    @objc fileprivate func handlePlayPauseButton(){
        playPauseButton.isSelected = !playPauseButton.isSelected
        let isSelected = playPauseButton.isSelected
        
        if isSelected {
            player.play()
        }else{
            player.pause()
        }
    }
}
