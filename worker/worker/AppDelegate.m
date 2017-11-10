//
//  AppDelegate.m
//  worker
//
//  Created by 郭健 on 2017/7/26.
//  Copyright © 2017年 郭健. All rights reserved.


#import "AppDelegate.h"
#import "JPUSHService.h"
#import <UserNotifications/UserNotifications.h>
#import <UMSocialCore/UMSocialCore.h>
#import "ViewpagerViewController.h"
#import "WorkerViewController.h"


#define UshareKey @"598278a7310c937245000d29"


@interface AppDelegate () <UISplitViewControllerDelegate, UITabBarControllerDelegate, JPUSHRegisterDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    self.window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    
    self.window.backgroundColor = [UIColor whiteColor];
    
    NSUserDefaults *useDef = [NSUserDefaults standardUserDefaults];
    
    NSString *userName = [useDef objectForKey:@"firstName"];
    
    // 使用 NSUserDefaults 读取用户数据
    if (![userName isEqualToString:@"userId"])
    {
        // 如果是第一次进入引导页
        [useDef setObject:@"userId" forKey:@"firstName"];
        
        _window.rootViewController = [[ViewpagerViewController alloc] init];
        
        
        
    }
    else
    {
        // 否则直接进入应用
        
        WorkerViewController *tabBarController = [[WorkerViewController alloc] init];
        self.window.rootViewController = tabBarController;

    } 
    
  
    [self BaiduMap];
    
    [self Jpush];
    
    [self Ushare];
    
 //   [WXApi registerApp：@"wxd930ea5d5a258f4f" withDescription：@"demo 2.0"];
    [WXApi registerApp:@"wx88a7414f850651c8"];    //注册微信， 一定要在友盟的后面
    
   
    
    [self.window makeKeyAndVisible];
    
    return YES;
    
}



//友盟
- (void)Ushare
{
    /* 打开调试日志 */
    [[UMSocialManager defaultManager] openLog:YES];
    
    /* 设置友盟appkey */
    [[UMSocialManager defaultManager] setUmSocialAppkey:UshareKey];
    
    [self configUSharePlatforms];
    
    [self confitUShareSettings];
}

//设置系统回调
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url];
    if (!result)
    {
        // 其他如支付等SDK的回调
    }
    return result;
}


- (void)confitUShareSettings
{
    /*
     * 打开图片水印
     */
    //[UMSocialGlobal shareInstance].isUsingWaterMark = YES;
    
    /*
     * 关闭强制验证https，可允许http图片分享，但需要在info.plist设置安全域名
     <key>NSAppTransportSecurity</key>
     <dict>
     <key>NSAllowsArbitraryLoads</key>
     <true/>
     </dict>
     */
    //[UMSocialGlobal shareInstance].isUsingHttpsWhenShareContent = NO;
    
}


- (void)configUSharePlatforms
{
    /*
     设置微信的appKey和appSecret
     [微信平台从U-Share 4/5升级说明]http://dev.umeng.com/social/ios/%E8%BF%9B%E9%98%B6%E6%96%87%E6%A1%A3#1_1
     */
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatSession appKey:@"wx88a7414f850651c8" appSecret:@"3baf1193c85774b3fd9d18447d76cab0" redirectURL:nil];
    /*
     * 移除相应平台的分享，如微信收藏
     */
    //[[UMSocialManager defaultManager] removePlatformProviderWithPlatformTypes:@[@(UMSocialPlatformType_WechatFavorite)]];
    
    /* 设置分享到QQ互联的appID
     * U-Share SDK为了兼容大部分平台命名，统一用appKey和appSecret进行参数设置，而QQ平台仅需将appID作为U-Share的appKey参数传进即可。
     100424468.no permission of union id
     [QQ/QZone平台集成说明]http://dev.umeng.com/social/ios/%E8%BF%9B%E9%98%B6%E6%96%87%E6%A1%A3#1_3
     */
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_QQ appKey:@"1105821097"/*设置QQ平台的appID*/  appSecret:nil redirectURL:@"http://mobile.umeng.com/social"];
    
    /*
     设置新浪的appKey和appSecret
     [新浪微博集成说明]http://dev.umeng.com/social/ios/%E8%BF%9B%E9%98%B6%E6%96%87%E6%A1%A3#1_2
     */
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_Sina appKey:@"3921700954"  appSecret:@"04b48b094faeb16683c32669824ebdad" redirectURL:@"https://sns.whalecloud.com/sina2/callback"];
    
    /* 钉钉的appKey */
    [[UMSocialManager defaultManager] setPlaform: UMSocialPlatformType_DingDing appKey:@"dingoalmlnohc0wggfedpk" appSecret:nil redirectURL:nil];
    
    /* 支付宝的appKey */
    [[UMSocialManager defaultManager] setPlaform: UMSocialPlatformType_AlipaySession appKey:@"2015111700822536" appSecret:nil redirectURL:nil];
    
    
}



//极光推送
- (void)Jpush
{
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0)
    {
        JPUSHRegisterEntity *entity = [[JPUSHRegisterEntity alloc] init];
        
        entity.types = UNAuthorizationOptionAlert|UNAuthorizationOptionBadge|UNAuthorizationOptionSound;
        
        [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    
    }
    else if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0)
    {
        //可以添加自定义categories
        [JPUSHService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert) categories:nil];
        
    }
    else
    {
        //categories 必须为nil
        [JPUSHService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert) categories:nil];

    }
    NSDictionary *launchOptions = [NSDictionary dictionary];
    
    [JPUSHService setupWithOption:launchOptions appKey:@"246e2fe4b6e564597c8652f7"
                          channel:@"apple store"
                 apsForProduction:NO
            advertisingIdentifier:nil];
    
    // 这里是没有advertisingIdentifier的情况，有的话，大家在自行添加
    //注册远端消息通知获取device token
    
   
    
    
    
}


// ios 10 support 处于前台时接收到通知
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler { NSDictionary * userInfo = notification.request.content.userInfo; if ([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]])
    {
        [JPUSHService handleRemoteNotification:userInfo]; // 添加各种需求。。。。。
    }
    
    completionHandler(UNNotificationPresentationOptionAlert);
    // 处于前台时，添加需求，一般是弹出alert跟用户进行交互，这时候completionHandler(UNNotificationPresentationOptionAlert)这句话就可以注释掉了，这句话是系统的alert，显示在app的顶部，
}


// iOS 10 Support  点击处理事件
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler
{
    // Required
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]])
    {
        [JPUSHService handleRemoteNotification:userInfo];
        //推送打开
        if (userInfo)
        {
            // 取得 APNs 标准信息内容 //
            NSDictionary *aps = [userInfo valueForKey:@"aps"];
            //
            NSString *content = [aps valueForKey:@"alert"]; //推送显示的内容 //
            NSInteger badge = [[aps valueForKey:@"badge"] integerValue];
            //badge数量 //
            NSString *sound = [aps valueForKey:@"sound"];
            //播放的声音
            
            // 添加各种需求。。。。。
            [JPUSHService handleRemoteNotification:userInfo]; completionHandler(UIBackgroundFetchResultNewData);
          }
    completionHandler();
    // 系统要求执行这个方法
    
    }
    
}



- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    // Required, iOS 7 Support
    [JPUSHService handleRemoteNotification:userInfo];
    
    completionHandler(UIBackgroundFetchResultNewData);
    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive)
    {
        // 处于前台时 ，添加各种需求代码。。。。
    
    }
    else if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground)
    {
        // app 处于后台 ，添加各种需求
        
    }
        
        
}

//设置角标为0

//当程序被推送到后台的时候调用。所以要设置后台继续运行，则在这个函数里面设置即可
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[UIApplication alloc] setApplicationIconBadgeNumber:0];
}



//点击之后badge清零

//当程序从后台将要重新回到前台时候调用

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [application setApplicationIconBadgeNumber:0];
    
    [[UNUserNotificationCenter alloc] removeAllPendingNotificationRequests];
}





    




//- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
//{
//    
//    /// Required - 注册 DeviceToken
//    [JPUSHService registerDeviceToken:deviceToken];
//    
//}
//
//
//- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
//{
//    //处理收到的 APNs 消息
//    [JPUSHService handleRemoteNotification:userInfo];
//    
//    
//}
//
//
//- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
//    
//    // IOS 7 Support Required
//    [JPUSHService handleRemoteNotification:userInfo];
//    completionHandler(UIBackgroundFetchResultNewData);
//}
//
//
//- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
//{
//    //Optional
//    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
//}



//集成百度地图
- (void)BaiduMap
{
    // 要使用百度地图，请先启动BaiduMapManager  _mapManager = [[BMKMapManager alloc] init]; // 如果要关注网络及授权验证事件，请设定 generalDelegate参数
    
    mapManager = [[BMKMapManager alloc] init];
    
    BOOL ret = [mapManager start:@"EMcgUVa9NRQe9EgILyKOrFv9l7Zj3iIv" generalDelegate:nil];
    
    if (!ret)
    {
        NSLog(@"manager start failed!");
    }
    
    
}














- (void)applicationWillResignActive:(UIApplication *)application
{
  
}





- (void)applicationDidBecomeActive:(UIApplication *)application
{
    
}


- (void)applicationWillTerminate:(UIApplication *)application
{
   
}




@end
