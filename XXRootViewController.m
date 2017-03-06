#import "XXRootViewController.h"
#import "fmdb.h"
#import "MsgCell.h"

@interface XXRootViewController()
@property(nonatomic,strong) NSMutableArray* allMsgs;
@end

@implementation XXRootViewController {
	NSMutableArray *_objects;
}

- (void)showAlertMessage:(NSString*) msg
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:msg message:nil delegate:nil cancelButtonTitle:nil  otherButtonTitles:@"OK", nil];
    [alertView show];
}

- (void)loadSMSData
{
    NSMutableArray* thisTimeFetch = [NSMutableArray array];

    NSString * path = @"/var/mobile/Library/SMS/sms.db";
    
    FMDatabase *db = [FMDatabase databaseWithPath:path];
    
    if (![db open]) {
        NSLog(@"Could not open db.");
        [self showAlertMessage:@"Could not open db."];
    }
    
    NSInteger count = [db intForQuery:@"SELECT count(*) FROM message"];
    
    NSString* countString = [NSString stringWithFormat:@"total msg count:%ld",(long)count];
    [self showAlertMessage:countString];
    NSDateFormatter* dateFormat = [NSDateFormatter new];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    FMResultSet *rs = [db executeQuery:@"SELECT guid,text,date FROM message"];
    while ([rs next]) {
        ;
        
        NSString* guid = [rs stringForColumn:@"guid"];
        NSString* text = [rs stringForColumn:@"text"];
        NSInteger interval = [rs intForColumn:@"date"];
        NSDate* sendDate = [NSDate dateWithTimeIntervalSince1970:interval];
        MsgModel* model = [MsgModel new];
        model.msgsender = guid;
        model.msgContent = text;
        model.msgTime = [dateFormat stringFromDate:sendDate];
        [thisTimeFetch addObject:model];
        
        
        
    }
    // close the result set.
    // it'll also close when it's dealloc'd, but we're closing the database before
    // the autorelease pool closes, so sqlite will complain about it.
    [rs close];
    
    [db close];
    self.allMsgs = thisTimeFetch;
    
}

- (void)setAllMsgs:(NSMutableArray *)allMsgs
{
    _allMsgs = allMsgs;
    [self.tableView reloadData];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerClass:[MsgCell class] forCellReuseIdentifier:@"MsgCell"];

    [self loadSMSData];
}
- (void)loadView {
	[super loadView];

	_objects = [[NSMutableArray alloc] init];

	self.title = @"Root View Controller";
	self.navigationItem.leftBarButtonItem = self.editButtonItem;
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonTapped:)] autorelease];
}

- (void)addButtonTapped:(id)sender {
	[_objects insertObject:[NSDate date] atIndex:0];
	[self.tableView insertRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:0 inSection:0] ] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self.allMsgs count] == 0)
    {
        return 0;
    }
    else
    {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.allMsgs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MsgCell* cell = [tableView dequeueReusableCellWithIdentifier:@"MsgCell" forIndexPath:indexPath];
    cell.model = self.allMsgs[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;

}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
