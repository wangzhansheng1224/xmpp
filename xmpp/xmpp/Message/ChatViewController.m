//
//  ChatViewController.m
//  xmpp
//
//  Created by 王战胜 on 2017/1/4.
//  Copyright © 2017年 gocomtech. All rights reserved.
//

#import "ChatViewController.h"
#import "XMPPManager.h"

@interface ChatViewController ()
@property (nonatomic, strong) UITextField *tf;

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=self.name;
    self.view.backgroundColor=[UIColor greenColor];
    _tf=[[UITextField alloc]initWithFrame:CGRectMake(100, 100, 200, 50)];
    _tf.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:_tf];
    UIButton *btn=[[UIButton alloc]initWithFrame:CGRectMake(100, 200, 100, 100)];
    btn.backgroundColor=[UIColor redColor];
    [btn setTitle:@"发送" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    // Do any additional setup after loading the view.
}

- (void)btnClick{
    [[XMPPManager defaultManager]sendMessage:_tf.text toUser:self.name];
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
