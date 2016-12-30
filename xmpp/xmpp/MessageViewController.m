//
//  MessageViewController.m
//  xmpp
//
//  Created by 王战胜 on 2016/12/29.
//  Copyright © 2016年 gocomtech. All rights reserved.
//

#import "MessageViewController.h"
#import "AppDelegate.h"
#import "XMPPUserCoreDataStorageObject.h"
#import "FriendModelClass.h"

@interface MessageViewController ()<UITableViewDelegate,UITableViewDataSource,XMPPStreamDelegate,NSFetchedResultsControllerDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) XMPPStream * xmppStream;
//从数据库中获取发送内容的xmppManagedObjectContext
@property(nonatomic,strong)NSManagedObjectContext *xmppRosterManagedObjectContext;
//显示在tableView上
@property(nonatomic,strong)NSFetchedResultsController *fetchedResultsController;
@end

@implementation MessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor greenColor];
    
    [self initnavigation];
    [self initxmppStream];
    //获取应用的xmppSteam(通过Application中的单例获取)
    
    [self.view addSubview:self.tableView];
    // Do any additional setup after loading the view.
}

- (void)initnavigation{
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"注销" style:UIBarButtonItemStylePlain target:self action:@selector(rightClick)];
}

- (void)rightClick{
    [self disconnect];
    NSLog(@"下线了");
    UIApplication *application = [UIApplication sharedApplication];
    id delegate=[application delegate];
    [delegate logout];
    
}

- (void)initxmppStream{
    UIApplication *application = [UIApplication sharedApplication];
    id delegate = [application delegate];
    self.xmppStream = [delegate xmppStream];
    self.xmppRosterManagedObjectContext = [delegate xmppRosterManagedObjectContext];
    
    //从CoreData中获取数据
    //通过实体获取FetchRequest实体
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([XMPPUserCoreDataStorageObject class])];
    //添加排序规则
    NSSortDescriptor * sortD = [NSSortDescriptor sortDescriptorWithKey:@"jidStr" ascending:YES];
    [request setSortDescriptors:@[sortD]];
    
    //获取FRC
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.xmppRosterManagedObjectContext sectionNameKeyPath:nil cacheName:nil];
    self.fetchedResultsController.delegate = self;
    
    //获取内容
    
    NSError * error;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"%s  %@",__FUNCTION__,[error localizedDescription]);
    }

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
    NSArray *sectoins = [self.fetchedResultsController sections];
    id<NSFetchedResultsSectionInfo> sectionInfo = sectoins[section];
    
    NSLog(@"%ld", [sectionInfo numberOfObjects]);
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier=@"Cell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    XMPPUserCoreDataStorageObject *roster = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text=roster.nickname;
    return cell;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //做一个类型的转换
    UITableViewCell *cell = (UITableViewCell *)sender;
    
    //通过tableView获取cell对应的索引，然后通过索引获取实体对象
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    //获取数据
    XMPPUserCoreDataStorageObject *roster = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    //通过segue来获取我们目的视图控制器
    UIViewController *nextView = [segue destinationViewController];
    
    
    //通过KVC把参数传入目的控制器
    [nextView setValue:roster.nickname forKey:@"sendUserName"];
    [nextView setValue:roster.jidStr forKey:@"jidStr"];
    
    FriendModelClass *historyFriend = [[FriendModelClass alloc] init];
    [historyFriend saveHistoryFriend:roster.nickname WithJid:roster.jidStr];
}


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

-(void)goOffline{
    
    //发送下线状态
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [[self xmppStream] sendElement:presence];
}

-(void)disconnect{
    
    [self goOffline];
    [self.xmppStream disconnect];
    
}
@end
