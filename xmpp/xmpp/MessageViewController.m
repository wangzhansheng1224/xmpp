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
#import "UserTableViewCell.h"

@interface MessageViewController ()<UITableViewDelegate,UITableViewDataSource,XMPPManagerDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *rosterArr;  //花名册数组
@end

@implementation MessageViewController
- (instancetype)init
{
    self = [super init];
    if (self) {
        
        [self initnavigation];
        [self.view addSubview:self.tableView];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rosterChange) name:kXMPP_ROSTER_CHANGE object:nil];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)rosterChange
{
    //从存储器中取出我得好友数组，更新数据源
    self.rosterArr = [NSMutableArray arrayWithArray:[XMPPManager defaultManager].xmppRosterMemoryStorage.unsortedUsers];
    [self.tableView reloadData];
    
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
    addVC.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:addVC animated:YES];
}

-(UITableView *)tableView{
    if (!_tableView) {
        _tableView=[[UITableView alloc]initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStylePlain];
        _tableView.delegate=self;
        _tableView.dataSource=self;
        _tableView.backgroundColor=BGCOLOR;
        _tableView.tableFooterView=[[UIView alloc]init];
        _tableView.rowHeight=60;
        //分割符边距
        self.tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        [_tableView registerNib:[UINib nibWithNibName:@"UserTableViewCell" bundle:nil] forCellReuseIdentifier:@"user"];
    }
    return _tableView;
}

//先要设Cell可编辑(那几行可编辑)
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //设置删除按钮
    UITableViewRowAction *deleteRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction *action,NSIndexPath *indexPath) {
        
        XMPPUserMemoryStorageObject *user = self.rosterArr[indexPath.row];
        [[XMPPManager defaultManager]removeBuddy:user.jid.user];
        
    }];
    
    NSArray *resultArray=@[deleteRowAction];
    return  resultArray;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.rosterArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UserTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"user" forIndexPath:indexPath];
    XMPPUserMemoryStorageObject *user = self.rosterArr[indexPath.row];
    cell.FriendNameLabel.text=user.jid.user;
    if ([user isOnline]) {
        cell.StateLabel.text=@"[在线]";
        cell.StateLabel.textColor=[UIColor colorWithRed:25/255.0 green:210/255.0 blue:33/255.0 alpha:1];
    }else{
        cell.StateLabel.text=@"[离线]";
        cell.StateLabel.textColor=[UIColor grayColor];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ChatViewController *vc=[[ChatViewController alloc]init];
    vc.hidesBottomBarWhenPushed=YES;
    XMPPUserMemoryStorageObject *user = self.rosterArr[indexPath.row];
    vc.chatJID=user.jid;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - XMPPManagerDelegate
- (void)sendRosterArr:(NSArray *)rosterArr{
    self.rosterArr=[[NSArray alloc]initWithArray:rosterArr];
    [self.tableView reloadData];
}

@end
