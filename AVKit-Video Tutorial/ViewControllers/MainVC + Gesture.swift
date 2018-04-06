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
        self.playBackControlView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleVolumePanGesture)))
    }
    
    @objc func handleBrightenssGesure(gesture: UIPanGestureRecognizer){
        
    }
    @objc func handleVolumePanGesture(gesture: UIPanGestureRecognizer){
        if gesture.state == .began {
            isVolumeChanging = true
        }else if gesture.state == .changed {
            let velocity = gesture.velocity(in: containerView)
            if velocity.y < 0 {
                NotificationCenter.default.post(name: Notification.Name("AVSystemController_SystemVolumeDidChangeNotification"), object: true)
            }else if velocity.y > 0 {
                NotificationCenter.default.post(name: Notification.Name("AVSystemController_SystemVolumeDidChangeNotification"), object: false)
            }
            if self.volumeIndicatorViewHeightConstraint.constant > containerView.frame.height {
                self.volumeIndicatorViewHeightConstraint.constant = containerView.frame.height
            }else if self.volumeIndicatorViewHeightConstraint.constant < 0 {
                self.volumeIndicatorViewHeightConstraint.constant = 0
            }
            
            UIView.animate(withDuration: 0.5) {
                self.volumeIndicatorView.alpha = 0.4
            }
        }else if gesture.state == .ended {
            isVolumeChanging = false
            UIView.animate(withDuration: 0.5) {
                self.volumeIndicatorView.alpha = 0
            }
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
                UIView.animate(withDuration: 0.7) {
                    self.volumeIndicatorView.alpha = 0
                }
            }
        }
    }
}
