//
//  MainVC + Gesture.swift
//  AVKit-Video Tutorial
//
//  Created by 이동건 on 2018. 4. 6..
//  Copyright © 2018년 이동건. All rights reserved.
//

import UIKit

extension MainVC {
    func setupGesture(){
        self.playBackControlView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleVolumeBrightnessGesture)))
    }
    @objc func handleVolumeBrightnessGesture(gesture: UIPanGestureRecognizer){
        if gesture.state == .began {
            panStartLocation = gesture.location(in: containerView)
            if panStartLocation.x < self.containerView.frame.width / 2 {
                // Brightness control
                isBrightnessChanging = true
                isVolumeChanging = false
                // Set brightness when value is changed at Contol Center
                let brightness = UIScreen.main.brightness
                let brightnessHeightConstant = self.containerView.frame.height * brightness
                brightnessIndicatorViewHeightConstraint.constant = brightnessHeightConstant
            }else{
                // Volume control
                isBrightnessChanging = false
                isVolumeChanging = true
            }
        }else if gesture.state == .changed {
            guard let systemVolueViewSlider = self.systemVolumeView.subviews.first as? UISlider else {return}
            let velocity = gesture.velocity(in: containerView)
            panCurrentLoaction = gesture.location(in: containerView)
            // Volume control
            if isVolumeChanging {
                if velocity.y < 0 {
                    systemVolueViewSlider.value += 0.015
                }else if velocity.y > 0 {
                    print("Volume dowon")
                    systemVolueViewSlider.value -= 0.015
                }
            }
            // Brightness control
            if isBrightnessChanging {
                if velocity.y < 0 { // +
                    self.brightnessIndicatorViewHeightConstraint.constant += (2*containerView.frame.height)/self.view.frame.height
                }else if velocity.y > 0 { // -
                    self.brightnessIndicatorViewHeightConstraint.constant -= (2*containerView.frame.height)/self.view.frame.height
                }
                UIScreen.main.brightness = brightnessIndicatorViewHeightConstraint.constant / containerView.frame.height
                indicatorViewValueChanged(constraint: brightnessIndicatorViewHeightConstraint, of: brightnessIndicatorView)
            }
        }else if gesture.state == .ended {
            if isVolumeChanging {
                isVolumeChanging = false
                indicatorDismissAnimation(of:volumeIndicatorView, duration: 0.5)
            }
            if isBrightnessChanging {
                isBrightnessChanging = false
                indicatorDismissAnimation(of:brightnessIndicatorView ,duration: 0.5)
            }
        }
    }
    
    fileprivate func indicatorDismissAnimation(of indicatorView:UIView, duration: TimeInterval){
        UIView.animate(withDuration: duration) {
            indicatorView.alpha = 0
        }
    }
    
    fileprivate func indicatorViewValueChanged(constraint:NSLayoutConstraint, of indicatorView: UIView) {
        if constraint.constant > containerView.frame.height {
            constraint.constant = containerView.frame.height
        }else if constraint.constant < 0 {
            constraint.constant = 0
        }
        UIView.animate(withDuration: 0.5) {
            indicatorView.alpha = 0.4
        }
    }
    @objc func volumeChanged(notification: Notification){
        if let volume = notification.userInfo?["AVSystemController_AudioVolumeNotificationParameter"] as? Float {
            print("current Volume : \(volume)")
            currentOutputVolume = volume // 0.0 ~ 1.0
            self.volumeIndicatorViewHeightConstraint.constant = CGFloat(currentOutputVolume) * self.containerView.frame.height
            self.volumeIndicatorView.alpha = 0.4
            indicatorDismissAnimation(of:volumeIndicatorView ,duration: 0.7)
        }
    }
}
