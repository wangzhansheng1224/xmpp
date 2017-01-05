//
//  XMPPManager.m
//  xmpp
//
//  Created by 王战胜 on 2017/1/3.
//  Copyright © 2017年 gocomtech. All rights reserved.
//

#import "XMPPManager.h"
#import "AppDelegate.h"
#import "NavViewController.h"
#import "LoginViewController.h"
#import "TabBarViewController.h"

@interface XMPPManager()<XMPPStreamDelegate,XMPPRosterDelegate>

@property(nonatomic, copy) NSString *password;
@property(nonatomic, strong) NSMutableArray *rosterArr;
@end
@implementation XMPPManager

#pragma mark 单例方法的实现
+(XMPPManager *)defaultManager{
    static XMPPManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[XMPPManager alloc]init];
    });
    return manager;
}

#pragma mark init方法重写
/**
 *  重写初始化方法是因为在manager一创建就要使用一些功能，
 *    把这些功能放在初始化方法里面
 */
-(instancetype)init{
    if ([super init]){
        
        //初始化xmppStream，登录和注册的时候都会用到它
        self.xmppStream = [[XMPPStream alloc]init];
        //设置代理
        [self.xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        
        
        // 3.好友模块 支持我们管理、同步、申请、删除好友
        _xmppRosterMemoryStorage = [[XMPPRosterMemoryStorage alloc] init];
        _xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:_xmppRosterMemoryStorage];
        [_xmppRoster activate:self.xmppStream];
        
        //同时给_xmppRosterMemoryStorage 和 _xmppRoster都添加了代理
        [_xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
        //设置好友同步策略,XMPP一旦连接成功，同步好友到本地
        [_xmppRoster setAutoFetchRoster:YES]; //自动同步，从服务器取出好友
        //关掉自动接收好友请求，默认开启自动同意
        [_xmppRoster setAutoAcceptKnownPresenceSubscriptionRequests:NO];
       
        
        
        //4.消息模块，这里用单例，不能切换账号登录，否则会出现数据问题。
        _xmppMessageArchivingCoreDataStorage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
        _xmppMessageArchiving = [[XMPPMessageArchiving alloc] initWithMessageArchivingStorage:_xmppMessageArchivingCoreDataStorage dispatchQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 9)];
        [_xmppMessageArchiving activate:self.xmppStream];
        
    }
    return self;
}

#pragma mark - 用户登录
-(void)loginwithName:(NSString *)userName andPassword:(NSString *)password andFuwuqi:(NSString *)fuwuqi
{
    //标记连接服务器的目的
    self.connectServerPurposeType = ConnectServerPurposeLogin;
    //这里记录用户输入的密码，在登录（注册）的方法里面使用
    self.password = password;
    /**
     *  1.初始化一个xmppStream
     2.连接服务器（成功或者失败）
     3.成功的基础上，服务器验证（成功或者失败）
     4.成功的基础上，发送上线消息
     */
    
    
    // *  创建xmppjid（用户）
    // *  @param NSString 用户名，域名，登录服务器的方式（苹果，安卓等）
    
    XMPPJID *jid = [XMPPJID jidWithUser:userName domain:fuwuqi resource:@"iPhone8"];
    self.xmppStream.myJID = jid;
    //连接到服务器
    [self connectToServer];
    
    //有可能成功或者失败，所以有相对应的代理方法
}

#pragma mark 用户注册
-(void)registerWithName:(NSString *)userName andPassword:(NSString *)password andFuwuqi:(NSString *)fuwuqi{
    self.password = password;
    //0.标记连接服务器的目的
    self.connectServerPurposeType = ConnectServerPurposeRegister;
    //1. 创建一个jid
    XMPPJID *jid = [XMPPJID jidWithUser:userName domain:fuwuqi resource:@"iPhone8"];
    //2.将jid绑定到xmppStream
    self.xmppStream.myJID = jid;
    //3.连接到服务器
    [self connectToServer];
}

#pragma mark 连接到服务器的方法
-(void)connectToServer{
    //如果已经存在一个连接，需要将当前的连接断开，然后再开始新的连接
    if ([self.xmppStream isConnected]) {
        [self logout];
    }
    NSError *error = nil;
    [self.xmppStream connectWithTimeout:30.0f error:&error];
    if (error) {
        NSLog(@"error = %@",error);
    }
}

#pragma mark 注销方法的实现
-(void)logout{
    //表示离线不可用
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    //    向服务器发送离线消息
    [self.xmppStream sendElement:presence];
    //断开链接
    [self.xmppStream disconnect];
    NSLog(@"断开连接");
    //清空好友列表
    _rosterArr=nil;
    //调回登录界面
    NavViewController *nav=[[NavViewController alloc]initWithRootViewController:[[LoginViewController alloc]init]];
    UIApplication *application = [UIApplication sharedApplication];
    application.keyWindow.rootViewController=nav;
}



#pragma mark xmppStream的代理方法
//注册成功的方法
-(void)xmppStreamDidRegister:(XMPPStream *)sender
{
    NSLog(@"注册成功的方法");
}

//注册失败的方法
-(void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error
{
    NSLog(@"注册失败执行的方法");
}

//连接服务器失败的方法
-(void)xmppStreamConnectDidTimeout:(XMPPStream *)sender
{
    NSLog(@"连接服务器失败的方法，请检查网络是否正常");
}

//连接服务器成功的方法
-(void)xmppStreamDidConnect:(XMPPStream *)sender
{
    NSLog(@"连接服务器成功的方法");
    //登录
    if (self.connectServerPurposeType == ConnectServerPurposeLogin) {
        NSError *error = nil;
        //        向服务器发送密码验证 //验证可能失败或者成功
        [sender authenticateWithPassword:self.password error:&error];
        //        NSLog(@"-----%@",self.password);
    }
    //注册
    else{
        //向服务器发送一个密码注册（成功或者失败）
        [sender registerWithPassword:self.password error:nil];
    }
}

//验证成功的方法
-(void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    NSLog(@"验证成功的方法");
    /**
     *  unavailable 离线
     available  上线
     away  离开
     do not disturb 忙碌
     */
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"available"];
    [self.xmppStream sendElement:presence];
    
    //开启服务监听(感觉没有多大用,可注释)
//    [self autoPingProxyServer:LOCALHOST];
    
    //跳转的messageviewcontroller
    UIApplication *application = [UIApplication sharedApplication];
    [application.keyWindow setRootViewController:[[TabBarViewController alloc]init]];
}

//验证失败的方法
-(void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error
{
    NSLog(@"验证失败的方法,请检查你的用户名或密码是否正确,%@",error);
}




#pragma mark ===== 好友模块 委托=======
#pragma mark 收到添加好友的请求
- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence
{
    //取得好友状态
    NSString *presenceType = [NSString stringWithFormat:@"%@", [presence type]]; //online/offline
    //请求的用户
    NSString *presenceFromUser =[NSString stringWithFormat:@"%@", [[presence from] user]];
    NSLog(@"presenceType:%@",presenceType);
    
    NSLog(@"presence2:%@  sender2:%@",presence,sender);
    
    XMPPJID *jid = [XMPPJID jidWithString:presenceFromUser];
    //接收添加好友请求
    [_xmppRoster acceptPresenceSubscriptionRequestFrom:jid andAddToRoster:YES];
    
}
// 开始接收好友列表
- (void)xmppRosterDidBeginPopulating:(XMPPRoster *)sender withVersion:(NSString *)version
{
    NSLog(@"开始接收好友列表");
}

// 接收完毕
- (void)xmppRosterDidEndPopulating:(XMPPRoster *)sender
{
    NSLog(@"结束接收好友列表");
    NSLog(@"%@",self.rosterArr);
    if ([self.delegate respondsToSelector:@selector(sendRosterArr:)]) {
        [self.delegate sendRosterArr:self.rosterArr];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kXMPP_ROSTER_CHANGE object:nil];
    
}

- (void)xmppRoster:(XMPPRoster *)sender didReceiveRosterItem:(DDXMLElement *)item
{
    
    NSString *jid = [[item attributeForName:@"jid"] stringValue];
    
    XMPPJID *xmppjid = [XMPPJID jidWithString:jid resource:@"iPhone"];
    
    [self.rosterArr addObject:xmppjid];
}

- (NSMutableArray *)rosterArr{
    ArrayLazyLoad(_rosterArr);
}

// 如果不是初始化同步来的roster,那么会自动存入我的好友存储器
- (void)xmppRosterDidChange:(XMPPRosterMemoryStorage *)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kXMPP_ROSTER_CHANGE object:nil];
}


#pragma mark 接收消息
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    NSString *messageBody = [[message elementForName:@"body"] stringValue];
    NSString *from = [[message attributeForName:@"from"] stringValue];
    //    NSLog(@"%@\n%@",from,messageBody);
    if (messageBody) {
        NSRange range=[from rangeOfString:[NSString stringWithFormat:@"@%@",LOCALHOST]];
        from=[from substringToIndex:range.location];
        NSLog(@"%@发来消息,内容为:%@",from,messageBody);
    }
}

#pragma mark 发送消息
- (void)sendMessage:(NSString *)message toUser:(XMPPJID *) user {
    if (message.length < 1) {
        return;
    }
    XMPPMessage *xiaoxi = [XMPPMessage messageWithType:@"chat" to:user];
    [xiaoxi addBody:message];
    [self.xmppStream sendElement:xiaoxi];
}



#pragma mark 添加好友
- (void)XMPPAddFriendSubscribe:(NSString *)name{
    
    XMPPJID *jid = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@",name,LOCALHOST]];
    [_xmppRoster subscribePresenceToUser:jid];
}

#pragma mark 删除好友
- (void)removeBuddy:(NSString *)name{
    
    XMPPJID *jid = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@",name,LOCALHOST]];
    [_xmppRoster removeUser:jid];
}


#pragma mark 初始化并启动ping
-(void)autoPingProxyServer:(NSString*)strProxyServer{
    
    _xmppAutoPing = [[XMPPAutoPing alloc]init];
    [_xmppAutoPing activate:self.xmppStream];
    [_xmppAutoPing addDelegate:self delegateQueue:  dispatch_get_main_queue()];
    _xmppAutoPing.respondsToQueries = YES;
    _xmppAutoPing.pingInterval=2;//ping 间隔时间
    if (nil != strProxyServer)
    {
        _xmppAutoPing.targetJID = [XMPPJID jidWithString: strProxyServer ];//设置ping目标服务器，如果为nil,则监听socketstream当前连接上的那个服务器
    }
}

//卸载监听
- (void)deallocxmppAutoPing{
    [_xmppAutoPing  deactivate];
    [_xmppAutoPing  removeDelegate:self];
    _xmppAutoPing = nil;
}

#pragma mark XMPPAutoPing的代理方法
- (void)xmppAutoPingDidSendPing:(XMPPAutoPing *)sender
{
    NSLog(@"- (void)xmppAutoPingDidSendPing:(XMPPAutoPing *)sender");
}

- (void)xmppAutoPingDidReceivePong:(XMPPAutoPing *)sender
{
    NSLog(@"- (void)xmppAutoPingDidReceivePong:(XMPPAutoPing *)sender");
}

- (void)xmppAutoPingDidTimeout:(XMPPAutoPing *)sender
{
    NSLog(@"- (void)xmppAutoPingDidTimeout:(XMPPAutoPing *)sender");
}


@end
