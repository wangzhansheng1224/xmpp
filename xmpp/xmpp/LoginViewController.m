//
//  LoginViewController.m
//  xmpp
//
//  Created by 王战胜 on 2016/12/29.
//  Copyright © 2016年 gocomtech. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"

@interface LoginViewController ()
@property (strong, nonatomic) XMPPStream * xmppStream;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=@"登录界面";
    self.view.backgroundColor=[UIColor greenColor];
    
    //获取应用的xmppSteam(通过Application中的单例获取)
    UIApplication *application = [UIApplication sharedApplication];
    id delegate = [application delegate];
    self.xmppStream = [delegate xmppStream];
    
    //注册回调
    [self.xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    [self xmppConnect];
}

//连接服务器
-(void)xmppConnect
{
    //1.创建JID
    XMPPJID *jid = [XMPPJID jidWithUser:@"wangzs" domain:@"localhost" resource:@"iPhone"];
    
    //2.把JID添加到xmppSteam中
    [self.xmppStream setMyJID:jid];
    
    //连接服务器
    NSError *error = nil;
    [self.xmppStream connectWithTimeout:10 error:&error];
    if (error) {
        NSLog(@"连接出错：%@",[error localizedDescription]);
    }
}

//连接后的回调
-(void)xmppStreamDidConnect:(XMPPStream *)sender
{
    //连接成功后认证用户名和密码
    NSError *error = nil;
    [self.xmppStream authenticateWithPassword:@"1" error:&error];
    if (error) {
        NSLog(@"认证错误：%@",[error localizedDescription]);
    }
}

//认证成功后的回调
-(void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    NSLog(@"登陆成功");
}

//认证成功后的回调
-(void)xmppStream:sender didNotAuthenticate:(DDXMLElement *)error
{
    NSLog(@"登陆失败");
}
@end
