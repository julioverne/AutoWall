#import <dlfcn.h>
#import <objc/runtime.h>
#import <substrate.h>
#import <notify.h>

#define NSLog(...)
#define PLIST_PATH_Settings "/var/mobile/Library/Preferences/com.julioverne.autowall.plist"

static BOOL Enabled;
static __strong NSArray* wallArr;
static int currentWallIndexForMode0;
static int currentWallIndexForMode1;
static int currentWallIndexForMode2;

static BOOL isBlackScreen;
static BOOL isOnSpringBoard;
static BOOL isLaunched;

static CGSize screenSize;
static int screenScale;

@interface PLStaticWallpaperImageViewController : UIViewController
@property (assign,nonatomic) BOOL saveWallpaperData;
-(id)initWithUIImage:(id)arg1 ;
-(void)_savePhoto;
@end

@interface SBApplication : NSObject
- (id)bundleIdentifier;
- (id)displayName;
@end

@interface UIApplication ()
- (UIDeviceOrientation)_frontMostAppOrientation;
- (SBApplication*)_accessibilityFrontMostApplication;

- (void)adjustCurrentWall;
@end

static void settingsChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
	@autoreleasepool {
		@try{
			NSDictionary *TweakPrefs = [[[NSDictionary alloc] initWithContentsOfFile:@PLIST_PATH_Settings]?:[NSDictionary dictionary] copy];
			Enabled = (BOOL)[[TweakPrefs objectForKey:@"Enabled"]?:@YES boolValue];
			NSMutableArray* wallArrMut = (NSMutableArray*)[[TweakPrefs objectForKey:@"wallArr"]?:@[] mutableCopy];
			[wallArrMut sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
				NSString* d1 = obj1[@"time"];
				NSString* d2 = obj2[@"time"];
				return [d2 compare:d1];
			}];
			wallArr = [wallArrMut copy];
			currentWallIndexForMode0 = -1;
			currentWallIndexForMode1 = -1;
			currentWallIndexForMode2 = -1;
		}@catch(NSException* ex) {
		}
	}
}

static void screenChanged(CFNotificationCenterRef center, void* observer, CFStringRef name, const void* object, CFDictionaryRef userInfo)
{
    @try{
		if(!isLaunched) {
			return;
		}
		SBApplication* nowApp = [[UIApplication sharedApplication] _accessibilityFrontMostApplication];
		if(nowApp) {
			isOnSpringBoard = NO;
		} else {
			isOnSpringBoard = YES;
		}
	}@catch(NSException* ex) {
	}
}

static void screenDisplayStatus(CFNotificationCenterRef center, void* observer, CFStringRef name, const void* object, CFDictionaryRef userInfo)
{
    uint64_t state;
    int token;
    notify_register_check("com.apple.iokit.hid.displayStatus", &token);
    notify_get_state(token, &state);
    notify_cancel(token);
    if(!state) {
		isBlackScreen = YES;
    } else {
		if(isBlackScreen) {
			isBlackScreen = NO;
			if(isLaunched) {
				[[UIApplication sharedApplication] adjustCurrentWall];
			}
		}
		isBlackScreen = NO;
	}
	screenChanged(NULL, NULL, NULL, NULL, NULL);
}

static UIImage *sizeImage(UIImage *orig, CGSize size)
{
    if(!orig) {
		return orig;
	}
	UIGraphicsBeginImageContext(size);
	[orig drawInRect:CGRectMake(0, 0, size.width, size.height)];
	UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return retImage?:orig;
}

static void setWallpaperForWallpaperMode(NSString* path, int wallpaperMode)
{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		UIImage *rawImage = [UIImage imageWithContentsOfFile:path];
		if(rawImage) {
			UIImage *image = sizeImage(rawImage, CGSizeMake(screenSize.width*screenScale, screenSize.height*screenScale));
			image = [UIImage imageWithCGImage:image.CGImage scale:rawImage.scale orientation:rawImage.imageOrientation];
    		[[NSOperationQueue mainQueue] addOperationWithBlock:^() {
				@try {
					PLStaticWallpaperImageViewController *wallpaperViewController = [[PLStaticWallpaperImageViewController alloc] initWithUIImage:image];
					wallpaperViewController.saveWallpaperData = YES;
					int wallpaperModeSet = wallpaperMode;
					object_setInstanceVariable(wallpaperViewController, "_wallpaperMode", *(int **)&wallpaperModeSet);
					[wallpaperViewController _savePhoto];
				} @catch(NSException* ex) {
				}
    		}];
		}
    });
}

static BOOL isTimeFuture(NSString* time)
{
	BOOL ret = NO;
	static NSDateFormatter *formatter;
	if(!formatter || ![formatter isKindOfClass:[NSDateFormatter class]]) {
		formatter = [[NSDateFormatter alloc] init];
		formatter.dateFormat = @"HH:mm:ss";
	}
	@autoreleasepool {
		ret = ([[formatter stringFromDate:[NSDate date]] compare:time] == NSOrderedAscending);
	}
	return ret;
}

static BOOL isProssess = NO;
static void adjustCurrentWall()
{
	if(isProssess) {
		return;
	}
	isProssess = YES;
	@try {
		if(!wallArr || ![wallArr isKindOfClass:[NSArray class]]) {
			settingsChanged(NULL, NULL, NULL, NULL, NULL);
		}
	int lastIndexWall = -1;
	BOOL lastIndexWallBoth = NO;
	for(NSDictionary* wallDicNow in wallArr) {
		NSString* time = wallDicNow[@"time"];
		if(!isTimeFuture(time)) {
			lastIndexWall = [wallArr indexOfObject:wallDicNow];
			if([wallDicNow[@"mode"] intValue]==0) {
				lastIndexWallBoth = YES;
			}
			break;
		}
	}
	
	if(lastIndexWallBoth) {
		int newCurrentWallIndexForMode0 = lastIndexWall;
		if(currentWallIndexForMode0 != newCurrentWallIndexForMode0) {
			currentWallIndexForMode0 = newCurrentWallIndexForMode0;
			if(currentWallIndexForMode0 != -1) {
				NSDictionary* wallSet = wallArr[currentWallIndexForMode0];
				setWallpaperForWallpaperMode(wallSet[@"path"], [wallSet[@"mode"] intValue]);
			}
		}
		isProssess = NO;
		return;
	}
	
	int newCurrentWallIndexForMode1 = -1;
	for(NSDictionary* wallDicNow in wallArr) {
		NSString* time = wallDicNow[@"time"];
		if(!isTimeFuture(time)) {
			if([wallDicNow[@"mode"] intValue]==1) {
				newCurrentWallIndexForMode1 = [wallArr indexOfObject:wallDicNow];
				break;
			}
		}
	}
	if(currentWallIndexForMode1 != newCurrentWallIndexForMode1) {
		currentWallIndexForMode1 = newCurrentWallIndexForMode1;
		if(currentWallIndexForMode1 != -1) {
			NSDictionary* wallSet = wallArr[currentWallIndexForMode1];
			setWallpaperForWallpaperMode(wallSet[@"path"], [wallSet[@"mode"] intValue]);
		}
	}
	
	
	int newCurrentWallIndexForMode2 = -1;
	for(NSDictionary* wallDicNow in wallArr) {
		NSString* time = wallDicNow[@"time"];
		if(!isTimeFuture(time)) {
			if([wallDicNow[@"mode"] intValue]==2) {
				newCurrentWallIndexForMode2 = [wallArr indexOfObject:wallDicNow];
				break;
			}
		}
	}
	if(currentWallIndexForMode2 != newCurrentWallIndexForMode2) {
		currentWallIndexForMode2 = newCurrentWallIndexForMode2;
		if(currentWallIndexForMode2 != -1) {
			NSDictionary* wallSet = wallArr[currentWallIndexForMode2];
			setWallpaperForWallpaperMode(wallSet[@"path"], [wallSet[@"mode"] intValue]);
		}
	}
	isProssess = NO;
	}@catch(NSException* ex) {
		isProssess = NO;
	}
}


%hook SpringBoard
- (void)applicationDidFinishLaunching:(id)application
{
	%orig;
	
	screenSize = [[UIScreen mainScreen] bounds].size;
	screenScale = [UIScreen mainScreen].scale;
	
	[NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(adjustCurrentWall) userInfo:nil repeats:YES];
}
%new
- (void)adjustCurrentWall
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_adjustCurrentWall) object:nil];
	[self performSelector:@selector(_adjustCurrentWall) withObject:nil afterDelay:0.3f];
}
%new
- (void)_adjustCurrentWall
{
	if(Enabled && isLaunched && !isBlackScreen /*&& isOnSpringBoard*/) {
		adjustCurrentWall();
	}
}
%end






%ctor
{
	[[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
		isLaunched = YES;
		screenChanged(NULL, NULL, NULL, NULL, NULL);
	}];
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, screenDisplayStatus, CFSTR("com.apple.iokit.hid.displayStatus"), NULL, 0);
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, screenChanged, CFSTR("com.apple.springboard.screenchanged"), NULL, 0);
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, settingsChanged, CFSTR("com.julioverne.autowall/Settings"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	settingsChanged(NULL, NULL, NULL, NULL, NULL);
	%init;
}