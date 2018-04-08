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
        let location:CGPoint!
        if gesture.state == .began {
            location = gesture.location(in: containerView)
            if location.x < self.containerView.frame.width / 2 {
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
            let velocity = gesture.velocity(in: containerView)
            // Volume control
            if isVolumeChanging {
                if velocity.y < 0 { // +
                    NotificationCenter.default.post(name: Notification.Name("AVSystemController_SystemVolumeDidChangeNotification"), object: true)
                }else if velocity.y > 0 { // -
                    NotificationCenter.default.post(name: Notification.Name("AVSystemController_SystemVolumeDidChangeNotification"), object: false)
                }
                indicatorViewValueChanged(constraint: volumeIndicatorViewHeightConstraint, of: volumeIndicatorView)
            }
            // Brightness control
            if isBrightnessChanging {
                if velocity.y < 0 { // +
                    self.brightnessIndicatorViewHeightConstraint.constant += (3*containerView.frame.height)/self.view.frame.height
                }else if velocity.y > 0 { // -
                    self.brightnessIndicatorViewHeightConstraint.constant -= (3*containerView.frame.height)/self.view.frame.height
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
        guard let systemVolueViewSlider = self.systemVolumeView.subviews.first as? UISlider else {return}
        if let obj = notification.object as? Bool {
            if obj {
                self.volumeIndicatorViewHeightConstraint.constant += (3*containerView.frame.height)/self.view.frame.height
            }else{
                self.volumeIndicatorViewHeightConstraint.constant -= (3*containerView.frame.height)/self.view.frame.height
            }
            systemVolueViewSlider.value = Float(self.volumeIndicatorViewHeightConstraint.constant / containerView.frame.height)
        }else{
            let volume = notification.userInfo!["AVSystemController_AudioVolumeNotificationParameter"] as! Float
            if isVolumeChanging == false {
                self.volumeIndicatorViewHeightConstraint.constant = CGFloat(volume) * self.containerView.frame.height
                self.volumeIndicatorView.alpha = 0.4
                indicatorDismissAnimation(of:volumeIndicatorView ,duration: 0.7)
            }
        }
    }
}
