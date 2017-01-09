//
//  XMPPManager.h
//  xmpp
//
//  Created by 王战胜 on 2017/1/3.
//  Copyright © 2017年 gocomtech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPMessageArchivingCoreDataStorage.h"//消息存储
#import "XMPPAutoPing.h"//自动连接
#import "XMPPRosterMemoryStorage.h"  //单聊花名册存储
#import "XMPPRoomCoreDataStorage.h"  //群聊花名册存储

typedef enum{
    ConnectServerPurposeLogin,    //登录
    ConnectServerPurposeRegister   //注册
}ConnectServerPurpose;
@protocol XMPPManagerDelegate <NSObject>
@optional
//协议方法
-(void)sendRosterArr:(NSArray*)rosterArr;
@end

@interface XMPPManager : NSObject
@property(nonatomic,weak)id<XMPPManagerDelegate>delegate;
@property(nonatomic)ConnectServerPurpose connectServerPurposeType;//用来标记连接服务器目的的属性
@property(nonatomic, strong) XMPPStream * xmppStream;
@property(nonatomic, strong) XMPPAutoPing * xmppAutoPing;
@property(nonatomic, strong) XMPPRosterMemoryStorage *xmppRosterMemoryStorage;//单聊花名册存储
@property(nonatomic, strong) XMPPRoster * xmppRoster;//单聊花名册
@property(nonatomic, strong) XMPPMessageArchivingCoreDataStorage * xmppMessageArchivingCoreDataStorage;//消息存储
@property(nonatomic, strong) XMPPMessageArchiving * xmppMessageArchiving;//消息模块
@property(nonatomic, strong) XMPPRoomCoreDataStorage * xmppRoomStorage;//群聊花名册存储
@property(nonatomic, strong) XMPPRoom * xmppRoom;//群聊

//用来记录用户输入的密码
//单例方法
+(XMPPManager *)defaultManager;
//登录的方法
-(void)loginwithName:(NSString *)userName andPassword:(NSString *)password andFuwuqi:(NSString *)fuwuqi;
//注册的方法
-(void)registerWithName:(NSString *)userName andPassword:(NSString *)password andFuwuqi:(NSString *)fuwuqi;
//注销
-(void)logout;
//发送消息
- (void)sendMessage:(NSString *)message toUser:(XMPPJID *)user;
//添加好友
- (void)XMPPAddFriendSubscribe:(NSString *)name;
//删除好友
- (void)removeBuddy:(NSString *)name;

@end
