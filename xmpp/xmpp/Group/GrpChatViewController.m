//
//  GrpChatViewController.m
//  xmpp
//
//  Created by 王战胜 on 2017/1/10.
//  Copyright © 2017年 gocomtech. All rights reserved.
//

#import "GrpChatViewController.h"
#import "XMPPManager.h"
#import "LeftTableViewCell.h"
#import "RightTableViewCell.h"

@interface GrpChatViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) NSMutableArray *messageArr;
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation GrpChatViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(acceptMessage:) name:kXMPP_MESSAGE_GROUPS object:nil];
    }
    return self;
}

- (void)acceptMessage:(NSNotification *)notification
{
    NSArray *array = [notification object];
    
    NSLog(@"%@,群组列表：%@",[NSThread currentThread],array);
    
    self.messageArr=[[NSMutableArray alloc]initWithArray:array];
    [self.tableView reloadData];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=_roomName;
    self.view.backgroundColor=BGCOLOR;
    [self.view addSubview:self.tableView];
    
    // Do any additional setup after loading the view.
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, IMScreenWidth, IMScreenHeight-50) style:UITableViewStylePlain];
        _tableView.delegate=self;
        _tableView.dataSource=self;
        _tableView.backgroundColor=BGCOLOR;
        //消除分割线
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.tableFooterView=[[UIView alloc]init];
        [_tableView registerNib:[UINib nibWithNibName:@"LeftTableViewCell" bundle:nil] forCellReuseIdentifier:@"left"];
        [_tableView registerNib:[UINib nibWithNibName:@"RightTableViewCell" bundle:nil] forCellReuseIdentifier:@"right"];
        //点击隐藏输入框
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard)];
        [_tableView addGestureRecognizer:tapGesture];
        _tableView.rowHeight=70;
    }
    return _tableView;
}

- (void)hideKeyBoard
{
    [self.view endEditing:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.messageArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *messageDic = self.messageArr[indexPath.row];
    
    NSRange range1=[messageDic[@"to"] rangeOfString:@"@localhost"];
    NSString *to=[messageDic[@"to"] substringToIndex:range1.location];
    NSRange range2=[messageDic[@"from"] rangeOfString:@"/"];
    NSString *from=[messageDic[@"from"] substringFromIndex:range2.location];
    if ([to isEqualToString:from]) {
        RightTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"right" forIndexPath:indexPath];
        cell.RightLabel.text=messageDic[@"body"];
        CGSize titleSize = [messageDic[@"body"] sizeWithFont:cell.RightLabel.font constrainedToSize:CGSizeMake(MAXFLOAT, 30)];
        cell.MessageRightWidth.constant=titleSize.width+25;
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        return cell;
    }else{
        LeftTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"left" forIndexPath:indexPath];
        cell.LeftLabel.text=messageDic[@"body"];
        CGSize titleSize = [messageDic[@"body"] sizeWithFont:cell.LeftLabel.font constrainedToSize:CGSizeMake(MAXFLOAT, 30)];
        cell.LeftMessageWidth.constant=titleSize.width+25;
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        return cell;
    }
    
}

-(void)dealloc{
    [[XMPPManager defaultManager].xmppRoom leaveRoom];
}



@end
