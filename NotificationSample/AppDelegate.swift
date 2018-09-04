//
//  AppDelegate.swift
//  NotificationSample
//
//  Created by 乔晓松 on 2018/8/28.
//  Copyright © 2018年 Coolspan. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // 也可以第一次进来就注册通知
        NotificationManager.shared.registerAppNotificationSettings()
        
        return true
    }
    
    /// 当用户接受或拒绝请求许可又或者之前做出过是否允许的选择
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        print("notificationSettings: \(notificationSettings)")
        NotificationManager.shared.notificationManager(application, didRegister: notificationSettings)
    }
    
    /// registerForRemoteNotifications 回调
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        NotificationManager.shared.notificationManager(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        NotificationManager.shared.notificationManager(application, didFailToRegisterForRemoteNotificationsWithError: error)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        NotificationManager.shared.notificationManager(application, didReceiveRemoteNotification: userInfo)
    }
}


