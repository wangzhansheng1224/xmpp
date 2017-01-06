//
//  AddViewController.m
//  xmpp
//
//  Created by 王战胜 on 2017/1/4.
//  Copyright © 2017年 gocomtech. All rights reserved.
//

#import "AddViewController.h"
#import "XMPPManager.h"
#import "MBProgressHUD+FX.h"
#import "UIView+PPCategory.h"

@interface AddViewController ()
@property (nonatomic, strong) UITextField *tf;
@end

@implementation AddViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=@"添加好友";
    self.view.backgroundColor=[UIColor greenColor];
    
    _tf=[[UITextField alloc]initWithFrame:CGRectMake(0 , 0, 300, 50)];
    _tf.center=CGPointMake(IMScreenWidth/2, 100);
    _tf.backgroundColor=[UIColor whiteColor];
    _tf.placeholder=@"请输入想要添加好友的名字";
    _tf.returnKeyType = UIReturnKeyDone;
    _tf.keyboardType = UIKeyboardTypeEmailAddress;
    //默认自动纠错(关闭)
    _tf.autocorrectionType = UITextAutocorrectionTypeNo;
    //默认首字母大写(关闭)
    _tf.autocapitalizationType = UITextAutocapitalizationTypeNone;
    //切圆角
    _tf.layer.cornerRadius=5;
    _tf.layer.masksToBounds=YES;
    [self.view addSubview:_tf];
    
    UIButton *btn=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
    btn.center=CGPointMake(IMScreenWidth/2, 200);
    btn.backgroundColor=[UIColor redColor];
    [btn setTitle:@"确定" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    // Do any additional setup after loading the view.
}

- (void)btnClick{
    
    MBProgressHUD *hdView = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:NO];
    hdView.labelText=@"添加好友成功";
    hdView.mode=MBProgressHUDModeText;
    [hdView show:YES];
    [hdView hide:YES afterDelay:0.5];
    [[XMPPManager defaultManager]XMPPAddFriendSubscribe:_tf.text];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
