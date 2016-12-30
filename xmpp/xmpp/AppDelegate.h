//
//  AppDelegate.h
//  xmpp
//
//  Created by 王战胜 on 2016/12/29.
//  Copyright © 2016年 gocomtech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPP.h"
#import "XMPPRosterCoreDataStorage.h"
#import "XMPPMessageArchivingCoreDataStorage.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) XMPPStream * xmppStream;
@property (strong, nonatomic) NSManagedObjectContext *xmppManagedObjectContext;
@property (strong, nonatomic) NSManagedObjectContext *xmppRosterManagedObjectContext;

- (void)logout;
@end
