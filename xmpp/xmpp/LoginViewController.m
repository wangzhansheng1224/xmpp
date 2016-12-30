//
//  LoginViewController.m
//  xmpp
//
//  Created by 王战胜 on 2016/12/29.
//  Copyright © 2016年 gocomtech. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"
#import "MessageViewController.h"
#import "GOInfoInputView.h"
#import "UIView+PPCategory.h"

@interface LoginViewController ()<UITextFieldDelegate>
@property (strong, nonatomic) XMPPStream * xmppStream;
@property (nonatomic, retain) GOInfoInputView *usrNameInputView;
@property (nonatomic, retain) GOInfoInputView *passwordInputView;
@property (nonatomic, strong) UIButton *loginButton;
@property (nonatomic, retain) UIButton *registerButton;
@property (nonatomic, retain) UIButton *getPassWordBtn;
@property (nonatomic, retain) UIButton *setNetWork;
@property (nonatomic, assign) CGPoint topCenterPoint;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=@"账号登录";
    [self creatUI];
    [self.usrNameInputView.textField becomeFirstResponder];
    [self initxmppSteam];
    
}

- (void)creatUI{
    //背景图
    [self.view setBackgroundImage:[UIImage imageNamed:@"BG-"]];
    
    CGPoint topCenter = CGPointMake([UIScreen mainScreen].bounds.size.width / 2.0, 130.0/568*IMScreenHeight);
    CGFloat deltaY = 51/568.0*IMScreenHeight;
    CGRect inputBounds =  CGRectMake(0.0, 0.0, 290.0/320.0*IMScreenWidth, 42.0/568*IMScreenHeight);
    self.topCenterPoint = topCenter;

    _usrNameInputView = [[GOInfoInputView alloc] initWithFrame:inputBounds fieldName:@"username" andLeftStr:@"用户名:"];
    _usrNameInputView.center = topCenter;
    _usrNameInputView.textField.returnKeyType = UIReturnKeyNext;
    _usrNameInputView.textField.delegate = self;
    _usrNameInputView.textField.keyboardType = UIKeyboardTypeEmailAddress;
    _usrNameInputView.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    _usrNameInputView.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [_usrNameInputView setCornerDirection:UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomLeft | UIRectCornerAllCorners];
    [self.view addSubview:_usrNameInputView];
    
    
    _passwordInputView = [[GOInfoInputView alloc] initWithFrame:inputBounds fieldName:@"password" andLeftStr:@"密    码:"];
    _passwordInputView.center = CGPointMake(topCenter.x, topCenter.y + deltaY);
    _passwordInputView.textField.returnKeyType = UIReturnKeyDone;
    _passwordInputView.textField.clearsOnBeginEditing = NO;
    _passwordInputView.textField.secureTextEntry = YES;
    _passwordInputView.textField.delegate = self;
    [_passwordInputView showPwdBtnShow];
    [_passwordInputView setCornerDirection:UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomLeft | UIRectCornerAllCorners];
    [self.view addSubview:_passwordInputView];
    
    //监听文字改变
    [_usrNameInputView.textField addTarget:self action:@selector(textDidChange:) forControlEvents:UIControlEventEditingDidEnd];
    
    self.loginButton = [[UIButton alloc]initWithFrame:inputBounds];
    [self.loginButton setBackgroundImage:[UIImage imageNamed:@"btn_yellow"] forState:UIControlStateNormal];
    [self.loginButton setTitle:@"登录" forState:UIControlStateNormal];
    self.loginButton.center = CGPointMake([UIScreen mainScreen].bounds.size.width * 0.5, _passwordInputView.center.y + deltaY + 32.0);
    self.loginButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [self.loginButton addTarget:self action:@selector(loginTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.loginButton];
}

//登录
- (void)loginTapped:(UIButton *)sender
{
    
    
    if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.hudOverlayView animated:YES];
        hud.frame = CGRectMake(0.0, 100.0, IMScreenWidth, 100.0);
        hud.mode = MBProgressHUDModeText;
        hud.completionBlock = ^{self.hudOverlayView.hidden = YES;};
        hud.labelText = LOCALIZEDSTRING(@"无网络连接");
        [hud hide:NO afterDelay:2.0];
        return;
    }
    
    if (self.usrNameInputView.textField.text.length == 0) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.hudOverlayView animated:YES];
        hud.frame = CGRectMake(0.0, 100.0, IMScreenWidth, 100.0);
        hud.mode = MBProgressHUDModeText;
        hud.completionBlock = ^{self.hudOverlayView.hidden = YES;};
        hud.labelText = LOCALIZEDSTRING(@"请输入用户名");
        [hud hide:NO afterDelay:2.0];
    }
    else if (self.serverStr.length == 0) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.hudOverlayView animated:YES];
        hud.frame = CGRectMake(0.0, 100.0, IMScreenWidth, 100.0);
        hud.mode = MBProgressHUDModeText;
        hud.completionBlock = ^{self.hudOverlayView.hidden = YES;};
        hud.labelText = LOCALIZEDSTRING(@"请配置网络");
        [hud hide:NO afterDelay:2.0];
    }
    else if ([self.passwordInputView.textField.text length] < 1) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.hudOverlayView animated:YES];
        hud.frame = CGRectMake(0.0, 100.0, IMScreenWidth, 100.0);
        hud.mode = MBProgressHUDModeText;
        hud.completionBlock = ^{self.hudOverlayView.hidden = YES;};
        hud.labelText = LOCALIZEDSTRING(@"请输入密码");
        [hud hide:NO afterDelay:2.0];
    }
    else {
        //输入都合法后,发送请求给服务器
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccessCallbackNotificationReceived:) name:kGOCOMLoginSuccessNote object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginFailedCallbackNotificationReceived:) name:kGOCOMLoginFailedNote object:nil];
        //断网处理
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(talksShouldBeDelete:) name:@"talksShouldBeDelete" object:nil];
        //取得域
        NSString *userNameDomain = [[NSUserDefaults standardUserDefaults] objectForKey:@"loginDomain"];
        if (userNameDomain.length == 0) {
            userNameDomain = [@"@" stringByAppendingString:GOCOMDOMAIN];
        }
        
        NSString *userNameResult = [NSString string];
        NSString *userNameStr = _usrNameInputView.textField.text;
        
        //判断用户名或密码是否带有域
        if ([userNameStr rangeOfString:@"@"].location != NSNotFound) {
            userNameResult = _usrNameInputView.textField.text;
        }
        else{
            userNameResult = [NSString stringWithFormat:@"%@%@", self.usrNameInputView.textField.text, userNameDomain];
        }
        
        [del.imAgent loginGoComServerWithUserID:[userNameResult lowercaseString] passwd:self.passwordInputView.textField.text server:self.serverStr retry:NO];
        self.loginHUD = [MBProgressHUD showHUDAddedTo:self.hudOverlayView animated:YES];
        self.loginHUD.mode = MBProgressHUDModeIndeterminate;
        
        self.loginHUD.completionBlock = ^{self.hudOverlayView.hidden = YES;};
        self.loginHUD.labelText = LOCALIZEDSTRING(@"登录中");
        self.loginButton.enabled = NO;
        
        
        /** "username" 为不带域的用户名，用来显示在用户名输入框内  "userName" 为带域的用户名，用来进行登录 */
        NSData *secretPwd = [[self.passwordInputView.textField.text dataUsingEncoding:NSUTF8StringEncoding] AES256EncryptWithKey:SECRETKEY];
        self.loginInfos = @{@"username": [self.usrNameInputView.textField.text lowercaseString], @"password": secretPwd, @"server": self.serverStr, @"userName": [userNameResult lowercaseString]};
        [[NSUserDefaults standardUserDefaults] setObject:self.loginInfos forKey:@"SecretLastLogin"];
        //        self.loginInfos = @{@"username": [self.usrNameInputView.textField.text lowercaseString], @"password": self.passwordInputView.textField.text, @"server": self.serverStr, @"userName": [userNameResult lowercaseString]};
        //
        //        [[NSUserDefaults standardUserDefaults] setObject:self.loginInfos forKey:@"lastlogin"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
}

//智能输入
-(void)textDidChange:(UITextField *)textInput
{
    //过滤非法字符
    if (textInput == self.usrNameInputView.textField) {
        NSCharacterSet *doNotWant = [NSCharacterSet characterSetWithCharactersInString:@"[]{}（#%*+=）\\|~(＜＞$%^&*)+ "];
        textInput.text = [[textInput.text componentsSeparatedByCharactersInSet: doNotWant]componentsJoinedByString: @""];
    }
}


- (void)initxmppSteam{
    //获取应用的xmppSteam(通过Application中的单例获取)
    UIApplication *application = [UIApplication sharedApplication];
    id delegate = [application delegate];
    self.xmppStream = [delegate xmppStream];
    
    //注册回调
    [self.xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    //连接服务器
    [self xmppConnect];
}

//连接服务器
-(void)xmppConnect
{
    //1.创建JID
    XMPPJID *jid = [XMPPJID jidWithUser:@"test001" domain:@"localhost" resource:@"iPhone"];
    
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
    
    MessageViewController *vc=[[MessageViewController alloc]init];
//    [self.navigationController pushViewController:vc animated:YES];
    
}

//认证成功后的回调
-(void)xmppStream:sender didNotAuthenticate:(DDXMLElement *)error
{
    NSLog(@"登陆失败");
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (textField == self.passwordInputView.textField && textField.secureTextEntry == YES) {
        NSString *updatedString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        textField.text = updatedString;
        
        return NO;
    }
    else
        return YES;
}

@end
