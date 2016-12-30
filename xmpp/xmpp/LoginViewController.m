//
//  LoginViewController.m
//  xmpp
//
//  Created by 王战胜 on 2016/12/29.
//  Copyright © 2016年 gocomtech. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"
#import "NavViewController.h"
#import "MessageViewController.h"
#import "GOInfoInputView.h"
#import "UIView+PPCategory.h"
#import "MBProgressHUD+FX.h"

@interface LoginViewController ()<UITextFieldDelegate>
@property (strong, nonatomic) XMPPStream * xmppStream;
@property (nonatomic, retain) GOInfoInputView *usrNameInputView;
@property (nonatomic, retain) GOInfoInputView *passwordInputView;
@property (nonatomic, retain) GOInfoInputView *fuwuqiInputView;
@property (nonatomic, retain) UIButton *loginButton;
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
    [self initxmppSteam];
}

- (void)creatUI{
    //背景图
    [self.view setBackgroundImage:[UIImage imageNamed:@"BG"]];
    
    CGPoint topCenter = CGPointMake([UIScreen mainScreen].bounds.size.width / 2.0, 130.0/568*IMScreenHeight);
    CGFloat deltaY = 51/568.0*IMScreenHeight;
    CGRect inputBounds =  CGRectMake(0.0, 0.0, 290.0/320.0*IMScreenWidth, 42.0/568*IMScreenHeight);
    self.topCenterPoint = topCenter;

    //用户名输入框
    _usrNameInputView = [[GOInfoInputView alloc] initWithFrame:inputBounds fieldName:@"username" andLeftStr:@"用户名:"];
    _usrNameInputView.center = topCenter;
    _usrNameInputView.textField.returnKeyType = UIReturnKeyNext;
    _usrNameInputView.textField.delegate = self;
    _usrNameInputView.textField.keyboardType = UIKeyboardTypeEmailAddress;
    //默认自动纠错(关闭)
    _usrNameInputView.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    //默认首字母大写(关闭)
    _usrNameInputView.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    //切圆角
    [_usrNameInputView setCornerDirection:UIRectCornerAllCorners];
//    另一种方案
//    _usrNameInputView.layer.cornerRadius=5;
//    _usrNameInputView.layer.masksToBounds=YES;
    [self.view addSubview:_usrNameInputView];
    //进入界面成为第一响应
    [self.usrNameInputView.textField becomeFirstResponder];
    
    //密码输入框
    _passwordInputView = [[GOInfoInputView alloc] initWithFrame:inputBounds fieldName:@"password" andLeftStr:@"密    码:"];
    _passwordInputView.center = CGPointMake(topCenter.x, topCenter.y + deltaY);
    _passwordInputView.textField.returnKeyType = UIReturnKeyNext;
    _passwordInputView.textField.secureTextEntry = YES;
    _passwordInputView.textField.delegate = self;
    [_passwordInputView showPwdBtnShow];
    [_passwordInputView setCornerDirection:UIRectCornerAllCorners];
    [self.view addSubview:_passwordInputView];
    
    //服务器地址
    _fuwuqiInputView = [[GOInfoInputView alloc] initWithFrame:inputBounds fieldName:@"fuwuqi" andLeftStr:@"服务器:"];
    _fuwuqiInputView.center = CGPointMake(topCenter.x, topCenter.y + 2*deltaY);
    _fuwuqiInputView.textField.returnKeyType = UIReturnKeyDone;
    _fuwuqiInputView.textField.delegate = self;
    _fuwuqiInputView.textField.keyboardType = UIKeyboardTypeEmailAddress;
    _fuwuqiInputView.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    _fuwuqiInputView.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [_fuwuqiInputView setCornerDirection:UIRectCornerAllCorners];
    [self.view addSubview:_fuwuqiInputView];

    //监听文字改变(当编辑结束时执行)
    [_usrNameInputView.textField addTarget:self action:@selector(textDidChange:) forControlEvents:UIControlEventEditingDidEnd];
    
    //登录按钮
    self.loginButton = [[UIButton alloc]initWithFrame:inputBounds];
    [self.loginButton setBackgroundImage:[UIImage imageNamed:@"btn_yellow"] forState:UIControlStateNormal];
    [self.loginButton setTitle:@"登录" forState:UIControlStateNormal];
    self.loginButton.center = CGPointMake([UIScreen mainScreen].bounds.size.width * 0.5, _fuwuqiInputView.center.y + deltaY + 32.0);
    self.loginButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [self.loginButton addTarget:self action:@selector(loginTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.loginButton];
}

//登录
- (void)loginTapped:(UIButton *)sender
{
    //连接服务器
    [self xmppConnect];
}

- (void)initxmppSteam{
    //获取应用的xmppSteam(通过Application中的单例获取)
    UIApplication *application = [UIApplication sharedApplication];
    id delegate = [application delegate];
    self.xmppStream = [delegate xmppStream];
    
    //注册回调
    [self.xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
}

//连接服务器
-(void)xmppConnect
{
    //1.创建JID
    XMPPJID *jid = [XMPPJID jidWithUser:_usrNameInputView.textField.text domain:_fuwuqiInputView.textField.text resource:@"iPhone"];
    
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
    [self.xmppStream authenticateWithPassword:_passwordInputView.textField.text error:&error];
    if (error) {
        NSLog(@"认证错误：%@",[error localizedDescription]);
    }
}

//认证成功后的回调
-(void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    NSLog(@"登陆成功");
    NavViewController *nav=[[NavViewController alloc]initWithRootViewController:[[MessageViewController alloc]init]];
    UIApplication *application = [UIApplication sharedApplication];
    [application.keyWindow setRootViewController:nav];
    
    
}

//认证成功后的回调
-(void)xmppStream:sender didNotAuthenticate:(DDXMLElement *)error
{
    NSLog(@"登陆失败");
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

#pragma mark - UITextField Delegate Methods
//return按钮点击事件
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.usrNameInputView.textField) {
        [self.passwordInputView.textField becomeFirstResponder];
    }else if (textField == self.passwordInputView.textField) {
        [self.passwordInputView.textField becomeFirstResponder];
    }else if (textField == self.fuwuqiInputView.textField) {
        [self loginTapped:nil];
    }
    return YES;
}

//当输入密码时隐藏最新输入的按钮
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
