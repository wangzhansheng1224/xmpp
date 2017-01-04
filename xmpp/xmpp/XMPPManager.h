//
//  XMPPManager.h
//  xmpp
//
//  Created by 王战胜 on 2017/1/3.
//  Copyright © 2017年 gocomtech. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol XMPPManagerDelegate <NSObject>
@optional
//协议方法
-(void)sendRosterArr:(NSArray*)rosterArr;
@end

@interface XMPPManager : NSObject
@property(nonatomic,weak)id<XMPPManagerDelegate>delegate;
//单例方法
+(XMPPManager *)defaultManager;
//登录的方法
-(void)loginwithName:(NSString *)userName andPassword:(NSString *)password andFuwuqi:(NSString *)fuwuqi;
//注册的方法
-(void)registerWithName:(NSString *)userName andPassword:(NSString *)password andFuwuqi:(NSString *)fuwuqi;
//注销
-(void)logout;
//发送消息
- (void)sendMessage:(NSString *)message toUser:(NSString *)user;
//添加好友
- (void)XMPPAddFriendSubscribe:(NSString *)name;
//删除好友
- (void)removeBuddy:(NSString *)name;
@end

