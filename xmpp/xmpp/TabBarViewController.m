//
//  TabBarViewController.m
//  xmpp
//
//  Created by 王战胜 on 2017/1/5.
//  Copyright © 2017年 gocomtech. All rights reserved.
//

#import "TabBarViewController.h"
#import "NavViewController.h"
#import "MessageViewController.h"
#import "GroupViewController.h"

@interface TabBarViewController ()

@end

@implementation TabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    MessageViewController *messageVc=[[MessageViewController alloc]init];
    NavViewController *messageNav=[[NavViewController alloc]initWithRootViewController:messageVc];
    messageNav.tabBarItem.title=@"通讯录";
    messageNav.tabBarItem.image = [UIImage imageNamed:@"tongxunlu_btn"];
    [self addChildViewController:messageNav];
    
    GroupViewController *groupVc=[[GroupViewController alloc]init];
    NavViewController *groupNav=[[NavViewController alloc]initWithRootViewController:groupVc];
    groupNav.tabBarItem.title=@"群组";
    groupNav.tabBarItem.image = [UIImage imageNamed:@"touxiang2_icon_normal_white"];
    [self addChildViewController:groupNav];
    
    self.tabBar.selectedImageTintColor = [UIColor colorWithRed:25/255.0 green:180/255.0 blue:33/255.0 alpha:1];
    self.tabBar.barTintColor=[UIColor whiteColor];
    // Do any additional setup after loading the view.
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
