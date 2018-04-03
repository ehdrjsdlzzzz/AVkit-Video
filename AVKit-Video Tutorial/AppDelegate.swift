//
//  AppDelegate.swift
//  AVKit-Video Tutorial
//
//  Created by 이동건 on 2018. 4. 3..
//  Copyright © 2018년 이동건. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow()
        window?.makeKeyAndVisible()
        window?.rootViewController = MainVC()
        return true
    }
}

