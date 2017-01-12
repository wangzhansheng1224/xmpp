//
//  GroupViewController.m
//  xmpp
//
//  Created by 王战胜 on 2017/1/5.
//  Copyright © 2017年 gocomtech. All rights reserved.
//

#import "GroupViewController.h"
#import "XMPPManager.h"
#import "GrpChatViewController.h"

@interface GroupViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView    * tableView;
@property (nonatomic, strong) NSMutableArray * roomArr;
@property (nonatomic, strong) NSMutableArray * messageArr;
@end

@implementation GroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpNavigation];
    
    //发送获取聊天室列表请求
    [self loadRooms];
    [self.view addSubview:self.tableView];
    
    //用户传过来群组列表
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getRoomsResult:) name:kXMPP_GET_GROUPS object:nil];
    //群组列表改变
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(roomChange) name:kXMPP_CHANGE_GROUPS object:nil];
    
    
}
- (void)setUpNavigation{
    
    self.title=@"群组";
    
    self.view.backgroundColor=BGCOLOR;
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(freshClick)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addClick)];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)addClick
{
    [[XMPPManager defaultManager] createRoom];
}

- (void)freshClick
{
    [self.roomArr removeAllObjects];
    [self loadRooms];
}

- (void)loadRooms
{
    NSXMLElement *queryElement= [NSXMLElement elementWithName:@"query" xmlns:@"http://jabber.org/protocol/disco#items"];
    NSXMLElement *iqElement = [NSXMLElement elementWithName:@"iq"];
    [iqElement addAttributeWithName:@"type" stringValue:@"get"];
    [iqElement addAttributeWithName:@"from" stringValue:[XMPPManager defaultManager].xmppStream.myJID.bare];
    NSString *service = [NSString stringWithFormat:@"%@.%@",kXMPP_SUBDOMAIN,kXMPP_DOMAIN];
    [iqElement addAttributeWithName:@"to" stringValue:service];
    [iqElement addAttributeWithName:@"id" stringValue:@"getMyRooms"];
    [iqElement addChild:queryElement];
    [[XMPPManager defaultManager].xmppStream sendElement:iqElement];
}

#pragma mark - NSNotification Event
- (void)getRoomsResult:(NSNotification *)notification
{
    NSArray *array = [notification object];
    
    NSLog(@"%@,群组列表：%@",[NSThread currentThread],array);
    
    [self.roomArr addObjectsFromArray:array];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
    
}

- (void)roomChange{
    [self freshClick];
}


- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, IMScreenWidth, IMScreenHeight-50) style:UITableViewStylePlain];
        _tableView.delegate=self;
        _tableView.dataSource=self;
        _tableView.backgroundColor=BGCOLOR;
        _tableView.rowHeight=60;
        //分割符边距
        self.tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _tableView.tableFooterView=[[UIView alloc]init];
    }
    return _tableView;
}

#pragma mark - TableView三法则
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.roomArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"roomCell"];
    if (!cell) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"roomCell"];
    }
    
    // Configure the cell...
    DDXMLElement *item = self.roomArr[indexPath.row];
    
    NSString *text = [NSString stringWithFormat:@"房间名:%@",[item attributeForName:@"name"].stringValue];
    cell.textLabel.text = text;
    cell.detailTextLabel.text = [item attributeForName:@"jid"].stringValue;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    DDXMLElement *item = self.roomArr[indexPath.row];
    XMPPJID *roomJID = [XMPPJID jidWithString:[item attributeForName:@"jid"].stringValue];
    
    GrpChatViewController *groupVC = [[GrpChatViewController alloc]init];
    groupVC.roomName=[item attributeForName:@"name"].stringValue;
    groupVC.hidesBottomBarWhenPushed=YES;
    
    [[XMPPManager defaultManager]joinRoomwithJID:roomJID];
    [self.navigationController pushViewController:groupVC animated:YES];
}

- (NSMutableArray *)roomArr{
    ArrayLazyLoad(_roomArr);
}

@end
