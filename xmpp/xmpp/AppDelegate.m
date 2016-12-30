//
//  AppDelegate.m
//  xmpp
//
//  Created by 王战胜 on 2016/12/29.
//  Copyright © 2016年 gocomtech. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "XMPPReconnect.h"
#import "XMPPMessageArchiving.h"
#import "NavViewController.h"

@interface AppDelegate (){
    XMPPReconnect *xmppReconnect;                           //重新连接
    XMPPMessageArchiving * xmppMessageArchiving;            //消息保存
    XMPPMessageArchivingCoreDataStorage * messageStorage;   //把请求的数据添加到CoreDate中
    
    XMPPRoster *xmppRoster;                                 //好友列表保存
    XMPPRosterCoreDataStorage *xmppRosterStorage;
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    
    self.window.rootViewController = [[NavViewController alloc]initWithRootViewController:[[LoginViewController alloc]init]];
    
    [self.window makeKeyAndVisible];

    self.xmppStream = [[XMPPStream alloc]init];
    
    //创建消息保存策略（规则，规定）
    messageStorage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
    //用消息保存策略创建消息保存组件
    xmppMessageArchiving = [[XMPPMessageArchiving alloc]initWithMessageArchivingStorage:messageStorage];
    //使组件生效
    [xmppMessageArchiving activate:self.xmppStream];
    //提取消息保存组件的coreData上下文
    self.xmppManagedObjectContext = messageStorage.mainThreadManagedObjectContext;
    
    
    
    xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
    xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:xmppRosterStorage];
    //自动获取用户列表
    xmppRoster.autoFetchRoster = YES;
    xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = YES;
    
    [xmppRoster activate:self.xmppStream];
    self.xmppRosterManagedObjectContext = xmppRosterStorage.mainThreadManagedObjectContext;
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
