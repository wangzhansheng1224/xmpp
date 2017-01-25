//
//  XMPPManager.m
//  xmpp
//
//  Created by 王战胜 on 2017/1/3.
//  Copyright © 2017年 gocomtech. All rights reserved.
//

#import "XMPPManager.h"
#import "AppDelegate.h"
#import "LoginViewController.h"
#import "TabBarViewController.h"
#import "MBProgressHUD.h"

@interface XMPPManager()<XMPPStreamDelegate,XMPPRosterDelegate>
@property(nonatomic, copy) NSString *username;
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
        self.xmppStream.hostName=kXMPP_HOST;
        self.xmppStream.hostPort=kXMPP_PORT;
         //为什么是addDelegate? 因为xmppFramework 大量使用了多播代理multicast-delegate ,代理一般是1对1的，但是这个多播代理是一对多得，而且可以在任意时候添加或者删除
        [self.xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        
//        //添加功能模块
//        //1.autoPing 发送的时一个stream:ping 对方如果想表示自己是活跃的，应该返回一个pong
//        _xmppAutoPing = [[XMPPAutoPing alloc] init];
//        //所有的Module模块，都要激活active
//        [_xmppAutoPing activate:self.xmppStream];
//        
//        //autoPing由于它会定时发送ping,要求对方返回pong,因此这个时间我们需要设置
//        [_xmppAutoPing setPingInterval:1000];
//        //不仅仅是服务器来得响应;如果是普通的用户，一样会响应
//        [_xmppAutoPing setRespondsToQueries:YES];
//        //这个过程是C---->S  ;观察 S--->C(需要在服务器设置）
//        
//        
//        
        //2.autoReconnect 自动重连，当我们被断开了，自动重新连接上去，并且将上一次的信息自动加上去
        _xmppReconnect = [[XMPPReconnect alloc] init];
        [_xmppReconnect activate:self.xmppStream];
        [_xmppReconnect setAutoReconnect:YES];
        
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
        
        
        //5、文件接收
//        _xmppIncomingFileTransfer = [[XMPPIncomingFileTransfer alloc] initWithDispatchQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)];
//        [_xmppIncomingFileTransfer activate:self.xmppStream];
//        [_xmppIncomingFileTransfer addDelegate:self delegateQueue:dispatch_get_main_queue()];
//        [_xmppIncomingFileTransfer setAutoAcceptFileTransfers:YES];
        
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
    self.username = userName;
    /**
     *  1.初始化一个xmppStream
     2.连接服务器（成功或者失败）
     3.成功的基础上，服务器验证（成功或者失败）
     4.成功的基础上，发送上线消息
     */
    
    
    // *  创建xmppjid（用户）
    // *  @param NSString 用户名，域名，登录服务器的方式（苹果，安卓等）
    
    XMPPJID *jid = [XMPPJID jidWithUser:userName domain:fuwuqi resource:kXMPP_RESOURCE];
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
    [self.xmppStream connectWithTimeout:5 error:&error];
    if (error) {
        NSLog(@"error = %@",error);
    }
}

#pragma mark 注销的方法
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
    UIApplication *application = [UIApplication sharedApplication];
    application.keyWindow.rootViewController=[[LoginViewController alloc]init];
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

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    NSLog(@"连接服务器失败的方法，请检查网络或服务器地址是否正常");
    if (error.code==7) {
        UIApplication *application = [UIApplication sharedApplication];
        application.keyWindow.rootViewController=[[LoginViewController alloc]init];
        
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"您的账号已在另一个地方登陆" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action=[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:action];
        [application.keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
    }
    NSLog(@"%@",error.localizedDescription);
    
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
    
    NSUserDefaults *userDefult = [NSUserDefaults standardUserDefaults];
    [userDefult setObject:_username forKey:@"username"];
    [userDefult setObject:_password forKey:@"password"];
    
    /**
     *  unavailable 离线
     available  上线
     away  离开
     do not disturb 忙碌
     */
    // 发送一个<presence/> 默认值avaliable 在线 是指服务器收到空的presence 会认为是这个
    // status ---自定义的内容，可以是任何的。
    // show 是固定的，有几种类型 dnd、xa、away、chat，在方法XMPPPresence 的intShow中可以看到
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"available"];
//    [presence addChild:[DDXMLNode elementWithName:@"status" stringValue:@"我现在很忙"]];
//    [presence addChild:[DDXMLNode elementWithName:@"show" stringValue:@"xa"]];
    [self.xmppStream sendElement:presence];
    
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
    [_xmppRoster acceptPresenceSubscriptionRequestFrom:presence.from andAddToRoster:YES];
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message: [NSString stringWithFormat:@"【%@】想加你为好友",presence.from.bare] preferredStyle:UIAlertControllerStyleAlert];
//    
//    //同意添加好友
//    UIAlertAction *acceptAction=[UIAlertAction actionWithTitle:@"接受" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        [_xmppRoster acceptPresenceSubscriptionRequestFrom:presence.from andAddToRoster:YES];
//    }];
//    [alert addAction:acceptAction];
//    
//    //拒绝添加好友
//    UIAlertAction *rejectAction=[UIAlertAction actionWithTitle:@"拒绝" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//        [self.xmppRoster rejectPresenceSubscriptionRequestFrom:presence.from];
//    }];
//    [alert addAction:rejectAction];
//    
//    UIApplication *application=[UIApplication sharedApplication];
//    [application.keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
    
}
//
//- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
//{
//    //收到对方取消定阅我得消息
//    if ([presence.type isEqualToString:@"unsubscribe"]) {
//        //从我的本地通讯录中将他移除
//        [self.xmppRoster removeUser:presence.from];
//    }
//}

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

#pragma mark 添加好友
- (void)XMPPAddFriendSubscribe:(NSString *)name{
    
    XMPPJID *jid = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@",name,kXMPP_DOMAIN]];
    [_xmppRoster subscribePresenceToUser:jid];
}

#pragma mark 删除好友
- (void)removeBuddy:(NSString *)name{
    
    XMPPJID *jid = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@",name,kXMPP_DOMAIN]];
    [_xmppRoster removeUser:jid];
}







#pragma mark 接收消息(单聊群聊都走这条)
// -------- 流接收消息成功 --------
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    NSString *messageBody = [[message elementForName:@"body"] stringValue];
    NSString *from = [[message attributeForName:@"from"] stringValue];
    NSLog(@"%@\n%@",from,messageBody);
//    if (messageBody) {
//        NSRange range=[from rangeOfString:[NSString stringWithFormat:@"@%@",kXMPP_DOMAIN]];
//        from=[from substringToIndex:range.location];
//        NSLog(@"%@发来消息,内容为:%@",from,messageBody);
//    }
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

// -------- 流发送消息成功 --------
- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message
{
    NSLog(@"消息发送成功");
}

/** 发送二进制文件 */
- (void)sendMessageWithUrl:(NSString *)url size:(CGSize)size bodyName:(NSString *)name toUser:(XMPPJID *)user{
    
//    XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:user];
//    
//    [message addBody:name];
//    
    
    //生成XML消息文档
    NSXMLElement *mes = [NSXMLElement elementWithName:@"message"];
    
    //消息类型
    [mes addAttributeWithName:@"type" stringValue:@"chat"];
    
    //发送给谁
    [mes addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@@%@",user.user,kXMPP_DOMAIN]];
    
    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    [body setStringValue:name];
    [mes addChild:body];
    
    //下图下载地址
    NSXMLElement *URL = [NSXMLElement elementWithName:@"url"];
    [URL setStringValue:url];
    [mes addChild:URL];
    
    //图片尺寸
    NSXMLElement *frame = [NSXMLElement elementWithName:@"frame"];
    [frame setStringValue:[NSString stringWithFormat:@"%f %f",size.width,size.height]];
    [mes addChild:frame];

    
//    // 转换成base64的编码
//    NSString *base64str = [data base64EncodedStringWithOptions:0];
//    
//    // 设置节点内容
//    XMPPElement *attachment = [XMPPElement elementWithName:@"attachment" stringValue:base64str];
//    
//    // 包含子节点
//    [message addChild:attachment];
    
    // 发送消息
    [_xmppStream sendElement:mes];
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







//获取聊天室列表
- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
    NSLog(@"iq:%@",iq);
    // 以下两个判断其实只需要有一个就够了
    NSString *elementID = iq.elementID;
    if (![elementID isEqualToString:@"getMyRooms"]) {
        return YES;
    }
    
    NSArray *results = [iq elementsForXmlns:@"http://jabber.org/protocol/disco#items"];
    if (results.count < 1) {
        return YES;
    }
    
    NSMutableArray *array = [NSMutableArray array];
    for (DDXMLElement *element in iq.children) {
        if ([element.name isEqualToString:@"query"]) {
            for (DDXMLElement *item in element.children) {
                if ([item.name isEqualToString:@"item"]) {
                    [array addObject:item];          //array  就是你的群列表
                    
                }
            }
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kXMPP_GET_GROUPS object:array];
    
    return YES;
}

#pragma mark 创建聊天室
- (void)createRoom{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *currentTime = [formatter stringFromDate:[NSDate date]];
    NSString *roomId = [NSString stringWithFormat:@"%@@%@.%@",currentTime,kXMPP_SUBDOMAIN,kXMPP_DOMAIN];
    
//    XMPPJID *roomJID = [XMPPJID jidWithString:roomId];
    
    // 如果不需要使用自带的CoreData存储，则可以使用这个。
    //    XMPPRoomMemoryStorage *xmppRoomStorage = [[XMPPRoomMemoryStorage alloc] init];
    
    // 如果使用自带的CoreData存储，可以自己创建一个继承自XMPPCoreDataStorage，并且实现了XMPPRoomStorage协议的类
    // XMPPRoomHybridStorage在类注释中，写了这只是一个实现的示例，不太建议直接使用这个。
//    _xmppRoomStorage = [xmp sharedInstance];
//    
//    XMPPRoom *xmppRoom = [[XMPPRoom alloc] initWithRoomStorage:_xmppRoomStorage jid:roomJID dispatchQueue:dispatch_get_main_queue()];
//    
//    [xmppRoom activate:_xmppStream];
//    [xmppRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];
//    
//    [xmppRoom joinRoomUsingNickname:@"test001" history:nil password:nil];
}

- (void)joinRoomwithJID:(NSString *)roomjid{
    XMPPJID *roomJID = [XMPPJID jidWithString:roomjid];
    _roomjid=roomjid;
    
    _xmppRoomStorage = [XMPPRoomCoreDataStorage sharedInstance];
    _xmppRoom = [[XMPPRoom alloc] initWithRoomStorage:_xmppRoomStorage jid:roomJID];
    [_xmppRoom activate:_xmppStream];
    [_xmppRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    [_xmppRoom joinRoomUsingNickname:@"test001" history:nil password:nil];
}

#pragma mark -  XMPPRoomDelegate
- (void)xmppRoomDidCreate:(XMPPRoom *)sender
{
    NSLog(@"房间创建成功");
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSString *message = [NSString stringWithFormat:@"群<%@>已创建完成",sender.roomJID.user];
        
        MBProgressHUD *hdView = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:NO];
        hdView.labelText=message;
        hdView.mode=MBProgressHUDModeText;
        [hdView show:YES];
        [hdView hide:YES afterDelay:0.5];
        
    });
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kXMPP_CHANGE_GROUPS object:nil];
}

- (void)xmppRoomDidJoin:(XMPPRoom *)sender
{
    NSLog(@"加入房间成功");
    
//    [self configNewRoom:sender];
    
    /* 配置房间 */
//    [sender configureRoomUsingOptions:nil];
    /* 查询房间配置 */
//    [sender fetchConfigurationForm];
    
    /* 邀请人到房间 */
    
    /**
     *  参数1: 邀请对象的 jid
     *  参数2: 邀请信息
     */
//    [sender inviteUser:[XMPPJID jidWithUser:@"test002" domain:kXMPP_DOMAIN resource:nil] withMessage:@"今天晚上放学别走"];
//    
//    [sender inviteUser:[XMPPJID jidWithUser:@"test003" domain:kXMPP_DOMAIN resource:nil] withMessage:@"今晚放学别走"];
    
    
//    [sender fetchBanList];
//    [sender fetchMembersList];
//    [sender fetchModeratorsList];
}

- (void)xmppRoomDidLeave:(XMPPRoom *)sender{
    NSLog(@"离开了聊天室");
    [_xmppRoom removeDelegate:self delegateQueue:dispatch_get_main_queue()];
//    [_xmppRoom deactivate];
//    _xmppRoom=nil;
    
}

- (void)configNewRoom:(XMPPRoom *)xmppRoom{
    NSXMLElement *x = [NSXMLElement elementWithName:@"x"xmlns:@"jabber:x:data"];
    NSXMLElement *p = [NSXMLElement elementWithName:@"field" ];
    [p addAttributeWithName:@"var"stringValue:@"muc#roomconfig_persistentroom"];//永久房间
    [p addChild:[NSXMLElement elementWithName:@"value"stringValue:@"1"]];
    [x addChild:p];
    
    p = [NSXMLElement elementWithName:@"field" ];
    [p addAttributeWithName:@"var"stringValue:@"muc#roomconfig_maxusers"];//最大用户
    [p addChild:[NSXMLElement elementWithName:@"value"stringValue:@"10000"]];
    [x addChild:p];
    
    p = [NSXMLElement elementWithName:@"field" ];
    [p addAttributeWithName:@"var"stringValue:@"muc#roomconfig_changesubject"];//允许改变主题
    [p addChild:[NSXMLElement elementWithName:@"value"stringValue:@"1"]];
    [x addChild:p];
    
    p = [NSXMLElement elementWithName:@"field" ];
    [p addAttributeWithName:@"var"stringValue:@"muc#roomconfig_publicroom"];//公共房间
    [p addChild:[NSXMLElement elementWithName:@"value"stringValue:@"0"]];
    [x addChild:p];
    
    p = [NSXMLElement elementWithName:@"field" ];
    [p addAttributeWithName:@"var"stringValue:@"muc#roomconfig_allowinvites"];//允许邀请
    [p addChild:[NSXMLElement elementWithName:@"value"stringValue:@"1"]];
    [x addChild:p];
    
    [xmppRoom configureRoomUsingOptions:x];
}

- (void)xmppRoom:(XMPPRoom *)sender didFetchConfigurationForm:(NSXMLElement *)configForm
{
    NSLog(@"configForm:%@",configForm);
}

// 收到禁止名单列表
- (void)xmppRoom:(XMPPRoom *)sender didFetchBanList:(NSArray *)items
{
    NSLog(@"%s",__func__);
}

// 收到成员名单列表
- (void)xmppRoom:(XMPPRoom *)sender didFetchMembersList:(NSArray *)items
{
    NSLog(@"%s",__func__);
}

// 收到主持人名单列表
- (void)xmppRoom:(XMPPRoom *)sender didFetchModeratorsList:(NSArray *)items
{
    NSLog(@"%s",__func__);
}


//如果房间存在，会调用委托
- (void)xmppRoom:(XMPPRoom *)sender didNotFetchBanList:(XMPPIQ *)iqError
{
    NSLog(@"%s",__func__);
}
- (void)xmppRoom:(XMPPRoom *)sender didNotFetchMembersList:(XMPPIQ *)iqError
{
    NSLog(@"%s",__func__);
}
- (void)xmppRoom:(XMPPRoom *)sender didNotFetchModeratorsList:(XMPPIQ *)iqError
{
    NSLog(@"%s",__func__);
}


//新人加入群聊
- (void)xmppRoom:(XMPPRoom *)sender occupantDidJoin:(XMPPJID *)occupantJID
{
    NSLog(@"%s",__func__);
}
//有人退出群聊
- (void)xmppRoom:(XMPPRoom *)sender occupantDidLeave:(XMPPJID *)occupantJID
{
    NSLog(@"%s",__func__);
}

-(void)xmppRoom:(XMPPRoom *)sender didReceiveMessage:(XMPPMessage *)message fromOccupant:(XMPPJID *)occupantJID{
    NSLog(@"群发言了。。。。");
    
    NSString *type = [[message attributeForName:@"type"] stringValue];
    if ([type isEqualToString:@"groupchat"]) {
        NSString *msg = [[message elementForName:@"body"] stringValue];
        //        NSString *timexx = [[timex attributeForName:@"stamp"] stringValue];
        NSString *from = [[message attributeForName:@"from"] stringValue];
        NSString *to = [[message attributeForName:@"to"] stringValue];
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:msg forKey:@"body"];
        [dict setObject:from forKey:@"from"];
        [dict setObject:to forKey:@"to"];
        NSLog(@"%@",dict);
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kXMPP_MESSAGE_GROUPS object:dict];
    }
    
}

//发送群消息
- (void)sendGrpMessage:(NSString *)message{
    //本地输入框中的信息
//    NSString *message = self.sendtextfield.text;
//    self.sendtextfield.text = @"";
//    [self.sendtextfield resignFirstResponder];
    
    if (message.length > 0){
        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        [body setStringValue:message];
        
        //生成XML消息文档
        NSXMLElement *mes = [NSXMLElement elementWithName:@"message"];
        
        //消息类型
        [mes addAttributeWithName:@"type" stringValue:@"groupchat"];
        
        //发送给谁
        [mes addAttributeWithName:@"to" stringValue:_roomjid];
        
        NSUserDefaults *userDefult = [NSUserDefaults standardUserDefaults];
        
        NSString *userName = [userDefult objectForKey:@"username"];
        
        [mes addAttributeWithName:@"from" stringValue:[NSString stringWithFormat:@"%@/%@",_roomjid,userName]];
        
        //组合
        [mes addChild:body];
        
        //发送消息
        [_xmppStream sendElement:mes];
    
    }
}

@end
