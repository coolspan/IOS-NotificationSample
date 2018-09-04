//
//  ViewController.swift
//  NotificationSample
//
//  Created by 乔晓松 on 2018/8/28.
//  Copyright © 2018年 Coolspan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        print("currentUserNotificationSettings: \(UIApplication.shared.currentUserNotificationSettings)")
        print("currentUserNotificationSettings isEmpty: \(UIApplication.shared.currentUserNotificationSettings?.types.isEmpty)")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func requestPermission(_ sender: UIButton) {
        NotificationManager.shared.registerAppNotificationSettings()
    }
    
    @IBAction func sendMessage(_ sender: UIButton) {
        NotificationManager.shared.sendLocalMessage()
    }
}

