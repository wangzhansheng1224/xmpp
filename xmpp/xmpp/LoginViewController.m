//
//  LoginViewController.m
//  xmpp
//
//  Created by 王战胜 on 2016/12/29.
//  Copyright © 2016年 gocomtech. All rights reserved.
//

#import "LoginViewController.h"
#import "NavViewController.h"
#import "MessageViewController.h"
#import "GOInfoInputView.h"
#import "UIView+PPCategory.h"
#import "MBProgressHUD+FX.h"
#import "XMPPManager.h"

@interface LoginViewController ()<UITextFieldDelegate>
@property (nonatomic, strong) GOInfoInputView *usrNameInputView;
@property (nonatomic, strong) GOInfoInputView *passwordInputView;
@property (nonatomic, strong) GOInfoInputView *fuwuqiInputView;
@property (nonatomic, strong) UIButton *loginButton;
@property (nonatomic, strong) UIButton *registerButton;
@property (nonatomic, strong) UIButton *getPassWordBtn;
@property (nonatomic, strong) UIButton *setNetWork;
@property (nonatomic, assign) CGPoint topCenterPoint;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=@"账号登录";
    [self creatUI];
    _usrNameInputView.textField.text=@"test001";
    _passwordInputView.textField.text=@"1";
    _fuwuqiInputView.textField.text=LOCALHOST;
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
    [self.loginButton addTarget:self action:@selector(loginTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.loginButton];
    
    self.registerButton = [[UIButton alloc]initWithFrame:inputBounds];
    [self.registerButton setBackgroundImage:[UIImage imageNamed:@"btn_yellow"] forState:UIControlStateNormal];
    [self.registerButton setTitle:@"注册" forState:UIControlStateNormal];
    self.registerButton.center = CGPointMake([UIScreen mainScreen].bounds.size.width * 0.5, _loginButton.center.y + deltaY);
    self.registerButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [self.registerButton addTarget:self action:@selector(registerTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.registerButton];
}

- (void)loginTapped{
    NSLog(@"点击登陆了");
    if (_usrNameInputView.textField.text.length==0 || _passwordInputView.textField.text.length==0) {
        NSLog(@"用户名和密码不能为空");
    }
    [[XMPPManager defaultManager]loginwithName:_usrNameInputView.textField.text andPassword:_passwordInputView.textField.text andFuwuqi:_fuwuqiInputView.textField.text];
}

- (void)registerTapped{
    NSLog(@"点击注册了");
    if (_usrNameInputView.textField.text.length==0 || _passwordInputView.textField.text.length==0) {
        NSLog(@"用户名和密码不能为空");
    }
    [[XMPPManager defaultManager]registerWithName:_usrNameInputView.textField.text andPassword:_passwordInputView.textField.text andFuwuqi:_fuwuqiInputView.textField.text];
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
