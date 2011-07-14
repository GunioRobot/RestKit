//
//  RKTwitterViewController.m
//  RKTwitter
//
//  Created by Blake Watters on 9/5/10.
//  Copyright Two Toasters 2010. All rights reserved.
//

#import "RKTwitterViewController.h"
#import "RKTStatus.h"

@interface RKTwitterViewController (Private)
- (void)loadData;
@end

@implementation RKTwitterViewController

- (void)loadTimeline {
    // Load the object model via RestKit	
    RKObjectManager* objectManager = [RKObjectManager sharedManager];
    objectManager.client.baseURL = @"https://api.twitter.com";
    objectManager.client.consumerKey = @"YOUR CONSUMER KEY HERE";
    objectManager.client.consumerSecret = @"YOUR CONSUMER SECRET HERE";
    objectManager.client.accessToken = @"YOUR ACCESS TOKEN HERE";
    objectManager.client.accessTokenSecret = @"YOUR ACCESS TOKEN SECRET HERE";
    objectManager.client.forceOAuthUse = YES;
    RKObjectMapping* statusMapping = nil;

    // Twitter returns statuses as a naked array in JSON, so we instruct the loader
    // to user the appropriate object mapping
    if ([objectManager.acceptMIMEType isEqualToString:RKMIMETypeJSON]) {
        statusMapping = [objectManager.mappingProvider objectMappingForKeyPath:@"status"];
    }

    [objectManager loadObjectsAtResourcePath:@"/1/statuses/home_timeline.json" objectMapping:statusMapping delegate:self];
}

- (void)loadView {
    [super loadView];
	
	// Setup View and Table View	
	self.title = @"RestKit Tweets";
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackTranslucent;
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(loadTimeline)] autorelease];
    
	UIImageView* imageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BG.png"]] autorelease];
	imageView.frame = CGRectOffset(imageView.frame, 0, -64);
	
	[self.view insertSubview:imageView atIndex:0];
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 480-64) style:UITableViewStylePlain];
	_tableView.dataSource = self;
	_tableView.delegate = self;		
	_tableView.backgroundColor = [UIColor clearColor];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
	
	[self loadTimeline];
}

- (void)dealloc {
	[_tableView release];
	[_statuses release];
    [super dealloc];
}

#pragma mark RKObjectLoaderDelegate methods

- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response {
    NSLog(@"Loaded payload: %@", [response bodyAsString]);
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObjects:(NSArray*)objects {
	NSLog(@"Loaded statuses: %@", objects);    
	[_statuses release];
	_statuses = [objects retain];
	[_tableView reloadData];
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
	UIAlertView* alert = [[[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
	[alert show];
	NSLog(@"Hit error: %@", error);
}

#pragma mark UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	CGSize size = [[[_statuses objectAtIndex:indexPath.row] text] sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(300, 9000)];
	return size.height + 10;
}

#pragma mark UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
	return [_statuses count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString* reuseIdentifier = @"Tweet Cell";
	UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
	if (nil == cell) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier] autorelease];
		cell.textLabel.font = [UIFont systemFontOfSize:14];
		cell.textLabel.numberOfLines = 0;
		cell.textLabel.backgroundColor = [UIColor clearColor];
		cell.contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"listbg.png"]];
	}
	cell.textLabel.text = [[_statuses objectAtIndex:indexPath.row] text];
	return cell;
}

@end
