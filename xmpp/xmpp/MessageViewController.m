//
//  MessageViewController.m
//  xmpp
//
//  Created by 王战胜 on 2016/12/29.
//  Copyright © 2016年 gocomtech. All rights reserved.
//

#import "MessageViewController.h"
#import "XMPPManager.h"
#import "ChatViewController.h"
#import "AddViewController.h"

@interface MessageViewController ()<UITableViewDelegate,UITableViewDataSource,XMPPManagerDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *rosterArr;  //花名册数组
@end

@implementation MessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initnavigation];
    [self.view addSubview:self.tableView];
    //创建代理
    [XMPPManager defaultManager].delegate=self;
    
    // Do any additional setup after loading the view.
}

- (void)initnavigation{
    self.view.backgroundColor=[UIColor greenColor];
    self.title=@"通讯录";
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"注销" style:UIBarButtonItemStylePlain target:self action:@selector(rightClick)];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"添加好友" style:UIBarButtonItemStylePlain target:self action:@selector(leftClick)];
}

- (void)rightClick{
    //注销
    [[XMPPManager defaultManager]logout];
}

- (void)leftClick{
    //添加好友
    AddViewController *addVC=[[AddViewController alloc]init];
    [self.navigationController pushViewController:addVC animated:YES];
}

-(UITableView *)tableView{
    if (!_tableView) {
        _tableView=[[UITableView alloc]initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStylePlain];
        _tableView.delegate=self;
        _tableView.dataSource=self;
        _tableView.tableFooterView=[[UIView alloc]init];
    }
    return _tableView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.rosterArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier=@"Cell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    XMPPJID *xmppjid=self.rosterArr[indexPath.row];
    cell.textLabel.text=xmppjid.user;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ChatViewController *vc=[[ChatViewController alloc]init];
    XMPPJID *xmppjid=self.rosterArr[indexPath.row];
    vc.name=xmppjid.user;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - XMPPManagerDelegate
- (void)sendRosterArr:(NSArray *)rosterArr{
    self.rosterArr=[[NSArray alloc]initWithArray:rosterArr];
    [self.tableView reloadData];
}

@end
