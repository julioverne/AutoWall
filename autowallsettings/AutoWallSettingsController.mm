#import <notify.h>
#import <Social/Social.h>
#import <prefs.h>

#define NSLog(...)
#define PLIST_PATH_Settings "/var/mobile/Library/Preferences/com.julioverne.autowall.plist"

@interface AutoWallSettingsController : PSListController {
	UILabel* _label;
	UILabel* underLabel;
}
- (void)HeaderCell;
@end

@interface ManageWall : UITableViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic) NSArray* wallArr;
@property (nonatomic) NSString* timeSel;
@property (nonatomic) UIImage* imageSel;
@property (nonatomic) NSString* pathSel;
@property (nonatomic) UIDatePicker* datePickerSel;
+ (id) shared;
@end

@implementation AutoWallSettingsController
- (id)specifiers {
	if (!_specifiers) {
		NSMutableArray* specifiers = [NSMutableArray array];
		PSSpecifier* spec;
		spec = [PSSpecifier preferenceSpecifierNamed:@"Enabled"
                                                  target:self
											         set:@selector(setPreferenceValue:specifier:)
											         get:@selector(readPreferenceValue:)
                                                  detail:Nil
											        cell:PSSwitchCell
											        edit:Nil];
		[spec setProperty:@"Enabled" forKey:@"key"];
		[spec setProperty:@YES forKey:@"default"];
        [specifiers addObject:spec];
		spec = [PSSpecifier emptyGroupSpecifier];
        [specifiers addObject:spec];
		
		spec = [PSSpecifier preferenceSpecifierNamed:@"Manage Wallpapers"
                                              target:self
                                                 set:NULL
                                                 get:NULL
                                              detail:Nil
                                                cell:PSLinkCell
                                                edit:Nil];
        spec->action = @selector(pushWallList);
        [specifiers addObject:spec];
		
		spec = [PSSpecifier emptyGroupSpecifier];
        [specifiers addObject:spec];
		spec = [PSSpecifier preferenceSpecifierNamed:@"Reset Settings"
                                              target:self
                                                 set:NULL
                                                 get:NULL
                                              detail:Nil
                                                cell:PSLinkCell
                                                edit:Nil];
        spec->action = @selector(reset);
        [specifiers addObject:spec];
		spec = [PSSpecifier preferenceSpecifierNamed:@"Developer"
		                                      target:self
											  set:Nil
											  get:Nil
                                              detail:Nil
											  cell:PSGroupCell
											  edit:Nil];
		[spec setProperty:@"Developer" forKey:@"label"];
        [specifiers addObject:spec];
		spec = [PSSpecifier preferenceSpecifierNamed:@"Follow julioverne"
                                              target:self
                                                 set:NULL
                                                 get:NULL
                                              detail:Nil
                                                cell:PSLinkCell
                                                edit:Nil];
        spec->action = @selector(twitter);
		[spec setProperty:[NSNumber numberWithBool:TRUE] forKey:@"hasIcon"];
		[spec setProperty:[UIImage imageWithContentsOfFile:[[self bundle] pathForResource:@"twitter" ofType:@"png"]] forKey:@"iconImage"];
        [specifiers addObject:spec];
		spec = [PSSpecifier emptyGroupSpecifier];
        [spec setProperty:@"AutoWall © 2021" forKey:@"footerText"];
        [specifiers addObject:spec];
		_specifiers = [specifiers copy];
	}
	return _specifiers;
}
- (void)pushWallList
{
	@try {
		[self.navigationController pushViewController:[ManageWall shared] animated:YES];
	} @catch (NSException * e) {
	}
}
- (void)twitter
{
	UIApplication *app = [UIApplication sharedApplication];
	if ([app canOpenURL:[NSURL URLWithString:@"twitter://user?screen_name=ijulioverne"]]) {
		[app openURL:[NSURL URLWithString:@"twitter://user?screen_name=ijulioverne"]];
	} else if ([app canOpenURL:[NSURL URLWithString:@"tweetbot:///user_profile/ijulioverne"]]) {
		[app openURL:[NSURL URLWithString:@"tweetbot:///user_profile/ijulioverne"]];		
	} else {
		[app openURL:[NSURL URLWithString:@"https://mobile.twitter.com/ijulioverne"]];
	}
}
- (void)love
{
	SLComposeViewController *twitter = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
	[twitter setInitialText:@"#AutoWall by @ijulioverne is cool!"];
	if (twitter != nil) {
		[[self navigationController] presentViewController:twitter animated:YES completion:nil];
	}
}
- (void)reset
{
	[@{} writeToFile:@PLIST_PATH_Settings atomically:YES];
	NSFileManager *fm = [NSFileManager defaultManager];
	NSString* path = @"/var/mobile/Media/AutoWall";
	NSDirectoryEnumerator* en = [fm enumeratorAtPath:path];
	NSString* file;
	while (file = [en nextObject]) {
		[fm removeItemAtPath:[path stringByAppendingPathComponent:file] error:nil];
	}
	[self reloadSpecifiers];
	notify_post("com.julioverne.autowall/Settings");
}
- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier
{
	@autoreleasepool {
		NSMutableDictionary *CydiaEnablePrefsCheck = [[NSMutableDictionary alloc] initWithContentsOfFile:@PLIST_PATH_Settings]?:[NSMutableDictionary dictionary];
		[CydiaEnablePrefsCheck setObject:value forKey:[specifier identifier]];
		[CydiaEnablePrefsCheck writeToFile:@PLIST_PATH_Settings atomically:YES];
		notify_post("com.julioverne.autowall/Settings");
		if ([[specifier properties] objectForKey:@"PromptRespring"]) {
			
			if(objc_getClass("UIAlertController") != nil) {
				
				UIAlertController *alert = [objc_getClass("UIAlertController") alertControllerWithTitle:self.title message:@"An Respring is Requerid for this option." preferredStyle:UIAlertControllerStyleAlert];
				
				UIAlertAction* Action2 = [objc_getClass("UIAlertAction") actionWithTitle:@"Respring" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
					system("killall backboardd SpringBoard");
				}];
				[alert addAction:Action2];
				
				UIAlertAction *cancel = [objc_getClass("UIAlertAction") actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
				[alert addAction:cancel];
				[self presentViewController:alert animated:YES completion:nil];
				
			} else {
				
				UIAlertView *alert = [[objc_getClass("UIAlertView") alloc] initWithTitle:self.title message:@"An Respring is Requerid for this option." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Respring", nil];
				alert.tag = 55;
				[alert show];
				
			}
			
		}
	}
}
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 55 && buttonIndex == 1) {
        system("killall backboardd SpringBoard");
    }
}
- (id)readPreferenceValue:(PSSpecifier*)specifier
{
	@autoreleasepool {
		NSDictionary *CydiaEnablePrefsCheck = [[NSDictionary alloc] initWithContentsOfFile:@PLIST_PATH_Settings];
		return CydiaEnablePrefsCheck[[specifier identifier]]?:[[specifier properties] objectForKey:@"default"];
	}
}
- (void)_returnKeyPressed:(id)arg1
{
	[super _returnKeyPressed:arg1];
	[self.view endEditing:YES];
}

- (void)HeaderCell
{
	@autoreleasepool {
	UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 120)];
	int width = [[UIScreen mainScreen] bounds].size.width;
	CGRect frame = CGRectMake(0, 20, width, 60);
		CGRect botFrame = CGRectMake(0, 55, width, 60);
 
		_label = [[UILabel alloc] initWithFrame:frame];
		[_label setNumberOfLines:1];
		_label.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:48];
		[_label setText:self.title];
		[_label setBackgroundColor:[UIColor clearColor]];
		//_label.textColor = [UIColor blackColor];
		_label.textAlignment = NSTextAlignmentCenter;
		_label.alpha = 0;

		underLabel = [[UILabel alloc] initWithFrame:botFrame];
		[underLabel setNumberOfLines:1];
		underLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
		[underLabel setText:@"Scheduled Wallpapers"];
		[underLabel setBackgroundColor:[UIColor clearColor]];
		underLabel.textColor = [UIColor grayColor];
		underLabel.textAlignment = NSTextAlignmentCenter;
		underLabel.alpha = 0;
		
		[headerView addSubview:_label];
		[headerView addSubview:underLabel];
		
	[_table setTableHeaderView:headerView];
	
	[NSTimer scheduledTimerWithTimeInterval:0.5
                                     target:self
                                   selector:@selector(increaseAlpha)
                                   userInfo:nil
                                    repeats:NO];
				
	}
}
- (void) loadView
{
	[super loadView];
	self.title = @"AutoWall";	
	[UISwitch appearanceWhenContainedIn:self.class, nil].onTintColor = [UIColor colorWithRed:0.09 green:0.99 blue:0.99 alpha:1.0];
	UIButton *heart = [[UIButton alloc] initWithFrame:CGRectZero];
	[heart setImage:[[UIImage alloc] initWithContentsOfFile:[[self bundle] pathForResource:@"Heart" ofType:@"png"]] forState:UIControlStateNormal];
	[heart sizeToFit];
	[heart addTarget:self action:@selector(love) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:heart];
	[self HeaderCell];
}
- (void)increaseAlpha
{
	[UIView animateWithDuration:0.5 animations:^{
		_label.alpha = 1;
	}completion:^(BOOL finished) {
		[UIView animateWithDuration:0.5 animations:^{
			underLabel.alpha = 1;
		}completion:nil];
	}];
}			
@end




@implementation ManageWall
@synthesize wallArr, imageSel, timeSel, pathSel, datePickerSel;
+ (id) shared
{
	static __strong ManageWall *ManageWallC;
	if (!ManageWallC) {
		ManageWallC = [[self alloc] init];
	}
	return ManageWallC;
}
-(void)Refresh
{
	@try {
		NSDictionary *TweakPrefs = [[[NSDictionary alloc] initWithContentsOfFile:@PLIST_PATH_Settings]?:[NSDictionary dictionary] copy];
		NSMutableArray* wallArrMut = (NSMutableArray*)[[TweakPrefs objectForKey:@"wallArr"]?:@[] mutableCopy];
		
		[wallArrMut sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
			NSString* d1 = obj1[@"time"];
			NSString* d2 = obj2[@"time"];
			return [d2 compare:d1];
		}];
		
		wallArr = [wallArrMut copy];
		
		[self.tableView reloadData];
	} @catch (NSException * e) {
	}
}
- (void)refreshView:(UIRefreshControl *)refresh
{
	[self Refresh];
	[refresh endRefreshing];
}
- (void)viewDidLoad
{
	[super viewDidLoad];
	UIBarButtonItem *shareButton = [[UIBarButtonItem alloc]
                                initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                target:self
                                action:@selector(addAction)];
	self.navigationItem.rightBarButtonItem = shareButton;
	
	UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
	[refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
	[self.tableView addSubview:refreshControl];
	[self.tableView setRowHeight:73];
	[self Refresh];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	[self Refresh];
}
- (void)addAction
{
	UIImagePickerController * picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:true completion:nil];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
	imageSel = nil;
	pathSel = nil;
    imageSel = [info objectForKey:UIImagePickerControllerOriginalImage];
	pathSel = [NSString stringWithFormat:@"/var/mobile/Media/AutoWall/%d.png", (int)[[NSDate date] timeIntervalSince1970]];
	[UIImagePNGRepresentation(imageSel) writeToFile:pathSel atomically:YES];
    [picker dismissViewControllerAnimated:YES completion:^{
        [self alertForImage];
    }];
}

- (void)saveWallWithMode:(int)buttonIndex
{
	NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"HH:mm:ss"];
	//formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
	timeSel = [formatter stringFromDate:datePickerSel.date];
	
	NSDictionary *TweakPrefs = [[[NSDictionary alloc] initWithContentsOfFile:@PLIST_PATH_Settings]?:[NSDictionary dictionary] copy];
	NSMutableArray* wallArrMut = (NSMutableArray*)[[TweakPrefs objectForKey:@"wallArr"]?:@[] mutableCopy];
	
	id removeWallDic = nil;
	for(NSDictionary* wallNow in wallArrMut) {
		if([pathSel isEqualToString:wallNow[@"path"]]) {
			removeWallDic = wallNow;
			break;
		}
	}
	if(removeWallDic) {
		[wallArrMut removeObject:removeWallDic];
	}
	
	[wallArrMut addObject:@{@"path": pathSel, @"mode": @(buttonIndex-1), @"time": timeSel,}];
	
	[wallArrMut sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
		NSString* d1 = obj1[@"time"];
		NSString* d2 = obj2[@"time"];
		return [d2 compare:d1];
	}];
	
	@autoreleasepool {
		NSMutableDictionary *CydiaEnablePrefsCheck = [[NSMutableDictionary alloc] initWithContentsOfFile:@PLIST_PATH_Settings]?:[NSMutableDictionary dictionary];
		[CydiaEnablePrefsCheck setObject:wallArrMut forKey:@"wallArr"];
		[CydiaEnablePrefsCheck writeToFile:@PLIST_PATH_Settings atomically:YES];
		notify_post("com.julioverne.autowall/Settings");
	}
	[self Refresh];
}

- (void)alertForImage
{
	datePickerSel = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
	datePickerSel.datePickerMode = UIDatePickerModeTime;
	
	if(objc_getClass("UIAlertController") != nil) {
		
		UIAlertController *alert = [objc_getClass("UIAlertController") alertControllerWithTitle:self.title message:@"Choose Time:" preferredStyle:UIAlertControllerStyleAlert];
		
		[alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
			textField.hidden = YES;
			textField.inputView = datePickerSel;
		}];
		
		UIAlertAction* Action1 = [objc_getClass("UIAlertAction") actionWithTitle:@"LockSreen + HomeScreen" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
			[self saveWallWithMode:1];
		}];
		[alert addAction:Action1];
		
		UIAlertAction* Action2 = [objc_getClass("UIAlertAction") actionWithTitle:@"HomeScreen" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
			[self saveWallWithMode:2];
		}];
		[alert addAction:Action2];
		
		UIAlertAction* Action3 = [objc_getClass("UIAlertAction") actionWithTitle:@"LockSreen" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
			[self saveWallWithMode:3];
		}];
		[alert addAction:Action3];
		
		UIAlertAction *cancel = [objc_getClass("UIAlertAction") actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
		[alert addAction:cancel];
		[self presentViewController:alert animated:YES completion:nil];
		
	} else {
		UIAlertView *alert = [[objc_getClass("UIAlertView") alloc] initWithTitle:self.title message:@"Choose Time:" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"LockSreen + HomeScreen", @"HomeScreen", @"LockSreen", nil];
		
		[alert setValue:datePickerSel forKey:@"accessoryView"];
		
		[alert show];
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(buttonIndex == [alertView cancelButtonIndex]) {
		imageSel = nil;
		return;
	}
	[self saveWallWithMode:buttonIndex];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellWall"];
	if(cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CellWall"];
	}
	cell.accessoryType = UITableViewCellAccessoryNone;
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	cell.accessoryView = nil;
	cell.imageView.image = nil;
	cell.textLabel.text = nil;
	cell.detailTextLabel.text = nil;
	//cell.textLabel.textColor = [UIColor blackColor];
	
	NSDictionary* wallDic = wallArr[indexPath.row];
	int mode = [wallDic[@"mode"] intValue];
	
	cell.imageView.image = [[UIImage alloc] initWithContentsOfFile:wallDic[@"path"]];
	cell.textLabel.text = wallDic[@"time"];
	cell.detailTextLabel.text = mode==0?@"LockSreen + HomeScreen":mode==1?@"HomeScreen":mode==2?@"LockSreen":@"Unknown";
	
	return cell;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [wallArr count];
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	@autoreleasepool {
		NSMutableDictionary *CydiaEnablePrefsCheck = [[NSMutableDictionary alloc] initWithContentsOfFile:@PLIST_PATH_Settings]?:[NSMutableDictionary dictionary];
		NSMutableArray* wallArrMut = (NSMutableArray*)[[CydiaEnablePrefsCheck objectForKey:@"wallArr"]?:@[] mutableCopy];
		NSDictionary* wallDic = wallArrMut[indexPath.row];
		[[NSFileManager defaultManager] removeItemAtPath:wallDic[@"path"] error:nil];
		[wallArrMut removeObjectAtIndex:indexPath.row];
		[CydiaEnablePrefsCheck setObject:wallArrMut forKey:@"wallArr"];
		[CydiaEnablePrefsCheck writeToFile:@PLIST_PATH_Settings atomically:YES];
		notify_post("com.julioverne.autowall/Settings");
		[self Refresh];
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	
	NSDictionary* wallDic = wallArr[indexPath.row];
	pathSel = wallDic[@"path"];
	[self alertForImage];
	
	static NSDateFormatter *formatter;
	if(!formatter || ![formatter isKindOfClass:[NSDateFormatter class]]) {
		formatter = [[NSDateFormatter alloc] init];
		formatter.dateFormat = @"HH:mm:ss";
	}
	datePickerSel.date = [formatter dateFromString:wallDic[@"time"]];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return @"Scheduled Wallpapers";
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath 
{
	return YES;
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [[NSBundle bundleWithPath:@"/System/Library/Frameworks/UIKit.framework"] localizedStringForKey:@"Delete" value:@"Delete" table:nil]?:@"Delete";
}
@end

