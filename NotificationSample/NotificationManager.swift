//
//  NotificationManager.swift
//  NotificationSample
//
//  Created by 乔晓松 on 2018/8/28.
//  Copyright © 2018年 Coolspan. All rights reserved.
//

import UIKit
import UserNotifications
import CoreLocation

enum AuthorizationStatus {
    
    // The user has not yet made a choice regarding whether the application may post user notifications.
    case notDetermined
    
    
    // The application is not authorized to post user notifications.
    case denied
    
    
    // The application is authorized to post user notifications.
    case authorized
}

/// 通知管理类
class NotificationManager: NSObject {
    
    public static let shared = NotificationManager()
    
    private override init() {
        super.init()
    }
    
}

// MARK: - public methods application
extension NotificationManager {
    
    /// 当用户拒绝或同意授权或曾静操作过，会调用此代理方法
    func notificationManager(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        print("didRegister: \(notificationSettings)")
    }
    
    /// 向服务端注册远程推送的时候，会请求Apple获取Token，成功后会调用此代理方法
    func notificationManager(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("didRegisterForRemoteNotificationsWithDeviceToken: \(deviceToken)")
    }
    
    /// 向服务端注册远程推送的时候，会请求Apple获取Token，失败的时候会调用此代理方法
    func notificationManager(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("didFailToRegisterForRemoteNotificationsWithError: \(error)")
    }
    
    /// 低于10.0的系统，收到消息或点击消息会调用此代理方法
    func notificationManager(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        if application.applicationState == .active {
            /// 代表从前台接受消息app
        } else {
            /// 代表从后台接受消息后进入app
            application.applicationIconBadgeNumber = 0
        }
    }
}

// MARK: - public methods custom
extension NotificationManager {
    
    /// 注册App的通知
    ///
    /// - Parameter launchOptions: 启动参数
    func registerAppNotificationSettings() {
        if #available(iOS 10.0, *) {
            let notifiCenter = UNUserNotificationCenter.current()
            notifiCenter.delegate = self
            notifiCenter.getNotificationSettings { (settings) in
                /// 是否允许通知
                switch settings.authorizationStatus {
                case .authorized:
                    /// 已经同意授权
                    print("已经同意授权")
                    break
                case .notDetermined:
                    /// 第一次授权，请求授权
                    let types = UNAuthorizationOptions(arrayLiteral: [.alert, .badge, .sound])
                    notifiCenter.requestAuthorization(options: types) { (flag, error) in
                        if flag {
                            print("ios>10.0授权成功")
                        } else {
                            print("ios>10.0拒绝授权")
                        }
                    }
                    print("第一次授权，请求授权")
                case .denied:
                    /// 用户之前拒绝授权，可跳转到设置界面进行设置
                    self.showSettingAlert()
                    print("用户之前拒绝授权")
                }
            }
        } else { //iOS8,iOS9 注册通知
            let setting = UIUserNotificationSettings.init(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(setting)
            
            /// IOS8以下
            //        [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound];
        }
        
        // 注册远程推送通知，向APNSS请求deviceToken
        UIApplication.shared.registerForRemoteNotifications()
        
    }
    
    /// 判断是否有权限
    func checkPermission(block: ((_ status: AuthorizationStatus) -> Void)?) {
        if #available(iOS 10.0, *) {
            let notifiCenter = UNUserNotificationCenter.current()
            notifiCenter.delegate = self
            notifiCenter.getNotificationSettings { (settings) in
                switch settings.authorizationStatus {
                case .authorized:
                    if let block = block { block(AuthorizationStatus.authorized) }
                case .denied:
                    if let block = block { block(AuthorizationStatus.denied) }
                case .notDetermined:
                    if let block = block { block(AuthorizationStatus.notDetermined) }
                }
            }
        } else {
            // 注: 低于10.0暂时无法判断是否已经授权或拒绝过，可以自行添加本地标识来记录是否弹出
            if UIApplication.shared.currentUserNotificationSettings != nil && (UIApplication.shared.currentUserNotificationSettings?.types.isEmpty)! {
                if let block = block { block(AuthorizationStatus.denied) }
            } else {
                if let block = block { block(AuthorizationStatus.authorized) }
            }
        }
    }
    
    /// 获取通知的设置，获取其他开关的状态
    /**
     /// 是否允许通知声音
     switch settings.soundSetting {
     case .enabled:
     /// 开启
     break
     case .disabled:
     /// 关闭
     break
     case .notSupported:
     /// 不支持
     break
     }
     
     /// 是否允许通知数字标记
     switch settings.badgeSetting {
     case .enabled:
     /// 开启
     break
     case .disabled:
     /// 关闭
     break
     case .notSupported:
     /// 不支持
     break
     }
     
     /// 是否允许通知在锁定屏幕上显示
     switch settings.lockScreenSetting {
     case .enabled:
     /// 开启
     break
     case .disabled:
     /// 关闭
     break
     case .notSupported:
     /// 不支持
     break
     }
     
     /// 是否允许通知在历史记录中显示
     switch settings.notificationCenterSetting {
     case .enabled:
     /// 开启
     break
     case .disabled:
     /// 关闭
     break
     case .notSupported:
     /// 不支持
     break
     }
     
     /// 是否允许通知在横幅显示
     switch settings.alertSetting {
     case .enabled:
     /// 开启
     break
     case .disabled:
     /// 关闭
     break
     case .notSupported:
     /// 不支持
     break
     }
     
     /// 是否允许通知显示预览
     if #available(iOS 11.0, *) {
     switch settings.showPreviewsSetting {
     case .always:
     /// 始终（默认）
     break
     case .whenAuthenticated:
     /// 解锁时
     break
     case .never:
     /// 从不
     break
     }
     } else {
     // Fallback on earlier versions
     }
     **/
    @available(iOS 10.0, *)
    func checkOtherPermission(block: @escaping ((_ settings: UNNotificationSettings) -> Void)) {
        let notifiCenter = UNUserNotificationCenter.current()
        notifiCenter.delegate = self
        notifiCenter.getNotificationSettings { (settings) in
            block(settings)
        }
    }
    
    /// 显示确认跳转到设置的确认框
    func showSettingAlert() {
        let alertController = UIAlertController(title: "消息推送已关闭",
                                                message: "想要及时获取消息。点击“设置”，开启通知。",
                                                preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title:"取消", style: .cancel, handler:nil)
        
        let settingsAction = UIAlertAction(title:"设置", style: .default, handler: {
            (action) -> Void in
            //                        let url = URL(string: "prefs:root=NOTIFICATIONS_ID&path=com.coolspan.NotificationSample")
            // // prefs:root=NOTIFICATIONS_ID
            self.toSettingsPage()
        })
        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)
        
        UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
        
    }
    
    /// 跳转到设置界面
    func toSettingsPage() {
        /// UIApplicationOpenSettingsURLString 等同于 prefs:root=NOTIFICATIONS_ID
        /// prefs:root=NOTIFICATIONS_ID&path=bundleid 待验证
        let url = URL(string: UIApplicationOpenSettingsURLString)
        if UIApplication.shared.canOpenURL(url!) {
            UIApplication.shared.openURL(url!)
        } else {
            /// 不支持此URL
        }
    }
    
    /// 发送本地通知
    func sendLocalMessage() {
        if #available(iOS 10.0, *) {
            
            
            
            
        } else {
            // 使用通用的方法发送，见LocalPushManager
            
            
        }
    }
    
    /// 发送指定时间后发送消息
    ///
    /// 设置5秒后发送消息，不重复发送
    /// Sample: sendMessage(title: "标题", subtitle: "副标题", body: "内容", identifier: "标识", timeInterval: 5, repeats: false)
    ///
    /// - Parameters:
    ///   - timeInterval: 倒计时
    ///   - repeats: 是否重复执行
    @available(iOS 10.0, *)
    func sendMessage(title: String, subtitle: String, body: String, identifier: String, timeInterval: TimeInterval, repeats: Bool) {
        //设置timeInterval秒后触发, 是否重复:repeats
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: repeats)
        let content = makeMessageContent(title: title, subtitle: subtitle, body: body, identifier: identifier)
        sendMessage(identifier: identifier, content: content, trigger: trigger)
    }
    
    /// 发送执行时间频次的消息
    ///
    /// 每周三，13点触发
    /// var components: DateComponents = DateComponents()
    /// components.weekday = 4 //周三
    /// components.hour = 13 //13点
    /// Sample: sendMessage(title: "标题", subtitle: "副标题", body: "内容", identifier: "标识", dateComponents: components, repeats: true)
    @available(iOS 10.0, *)
    func sendMessage(title: String, subtitle: String, body: String, identifier: String, dateComponents: DateComponents, repeats: Bool) {
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: repeats)
        let content = makeMessageContent(title: title, subtitle: subtitle, body: body, identifier: identifier)
        sendMessage(identifier: identifier, content: content, trigger: trigger)
    }
    
    /// 发送到达指定区域消息
    ///
    /// - Parameters:
    ///   - title: 标题
    ///   - subtitle: 副标题
    ///   - body: 内容
    ///   - identifier: 唯一标识
    ///   - latitude: 经度
    ///   - longitude: 维度
    ///   - radius: 半径
    ///   - repeats: 是否重复
    @available(iOS 10.0, *)
    func sendMessage(title: String, subtitle: String, body: String, identifier: String, latitude: Double, longitude: Double, radius: Double, repeats: Bool) {
        
        //这个点，100米范围内，进入触发。
        let Coordinate2: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let region: CLCircularRegion = CLCircularRegion(center: Coordinate2, radius: radius, identifier: identifier)
        region.notifyOnEntry = true
        region.notifyOnExit = false
        
        let triggerRegion = UNLocationNotificationTrigger(region: region, repeats: true)
        
        let content = makeMessageContent(title: title, subtitle: subtitle, body: body, identifier: identifier)
        sendMessage(identifier: identifier, content: content, trigger: triggerRegion)
    }
    
    /// 生成一个消息
    ///
    /// - Parameters:
    ///   - title: 推送内容标题
    ///   - subtitle: 推送内容副标题
    ///   - body: 推送内容内容
    ///   - identifier: category标识，操作策略
    @available(iOS 10.0, *)
    func makeMessageContent(title: String, subtitle: String, body: String, identifier: String) -> UNMutableNotificationContent {
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        content.body = body
        content.categoryIdentifier = identifier
        
        return content
    }
    
    /// 发送消息
    @available(iOS 10.0, *)
    func sendMessage(identifier: String, content: UNNotificationContent, trigger: UNNotificationTrigger) {
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        //将请求添加到发送中心
        UNUserNotificationCenter.current().add(request) { error in
            if error == nil {
                print("Time Interval Notification scheduled: ")
            }
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate methods
extension NotificationManager: UNUserNotificationCenterDelegate {
    
    /// 处理前台收到通知的代理方法，在应用内展示通知
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // 正常通知
        completionHandler([.alert, .sound])
        // 不显示此通知
        // completionHandler([])
    }
    
    /// 处理后台点击通知的代理方法，对通知进行响应，收到通知响应时的处理工作，用户与你推送的通知进行交互时被调用
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        completionHandler()
    }
}
