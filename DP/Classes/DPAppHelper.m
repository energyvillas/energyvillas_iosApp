//
//  DPAppHelper.m
//  DP
//
//  Created by Γεώργιος Γράβος on 3/30/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPAppHelper.h"
#import "DPImageInfo.h"
#import "Reachability.h"



NSString *const FREE_DET_IMGNAME_FMT = @"free_detimage_10%i_%@.jpg";
NSString *const FREE_DET_IMGTITLE_FMT = @"FREE_DET_TITLE_10%i";

@interface DPAppHelper ()

@property (strong, nonatomic) Reachability* hostReach;
//@property (strong, nonatomic) Reachability* internetReach;
//@property (strong, nonatomic) Reachability* wifiReach;

@end

@implementation DPAppHelper {

}

@synthesize connectionRequired = _connectionRequired;
@synthesize hostIsReachable = _hostIsReachable;

+ (DPAppHelper *)sharedInstance {
    static dispatch_once_t once;
    static DPAppHelper * sharedInstance;
    
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        _connectionRequired = true;
        _hostIsReachable = false;
        [self configureReachability];
        [self addFreeDetails];
        [self addFreeBuyContent];
    }
    
    return self;
}

#define FREE_DET_CNT ((int) 8)
#define FREE_BUY_CNT ((int) 3)


- (void) addFreeDetails {
    NSString *lang = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSMutableArray *list = [[NSMutableArray alloc] initWithCapacity:FREE_DET_CNT];

    for (int i = 0; i < FREE_DET_CNT; i++) {
        NSString *imgName = [NSString stringWithFormat:FREE_DET_IMGNAME_FMT, i, lang];
        NSString *dispName = [NSString stringWithFormat: FREE_DET_IMGTITLE_FMT, i];
        
        DPImageInfo *imginfo = [[DPImageInfo alloc] initWithName: imgName
                                                           image: [UIImage imageNamed:imgName]
                                                     displayName: NSLocalizedString(dispName, nil)];
        [list addObject:imginfo];
    }

    
    self.freeDetails = [NSArray arrayWithArray:list];
}

- (void) addFreeBuyContent{
    NSString *lang = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSMutableArray *list = [[NSMutableArray alloc] initWithCapacity:FREE_BUY_CNT];
    
    for (int i = 0; i < FREE_BUY_CNT; i++) {
        NSString *imgName = [NSString stringWithFormat:FREE_DET_IMGNAME_FMT, i, lang];
        NSString *dispName = [NSString stringWithFormat: FREE_DET_IMGTITLE_FMT, i];
        
        DPImageInfo *imginfo = [[DPImageInfo alloc] initWithName: imgName
                                                           image: [UIImage imageNamed:imgName]
                                                     displayName: NSLocalizedString(dispName, nil)];
        [list addObject:imginfo];
    }
    
    
    self.freeBuyContent = [NSArray arrayWithArray:list];
}


#pragma -
#pragma reachability handling

- (void) configureReachability {
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
    
    //Change the host name here to change the server your monitoring
	self.hostReach = [Reachability reachabilityWithHostName: @"www.designprojectsapps.com"];
	[self.hostReach startNotifier];
	[self updateWithReachability: self.hostReach];
	
//    self.internetReach = [Reachability reachabilityForInternetConnection];
//	[self.internetReach startNotifier];
//	[self updateWithReachability: self.internetReach];
//    
//    self.wifiReach = [Reachability reachabilityForLocalWiFi];
//	[self.wifiReach startNotifier];
//	[self updateWithReachability: self.wifiReach];
}

- (void) reachabilityChanged: (NSNotification* )note
{
	Reachability* curReach = [note object];
	NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
	[self updateWithReachability: curReach];
}

- (void) updateWithReachability: (Reachability*) curReach
{
    if(curReach == self.hostReach)
	{
        _hostIsReachable = [curReach currentReachabilityStatus] != NotReachable;
        _connectionRequired = [curReach connectionRequired];
    }
    
//	if(curReach == self.internetReach)
//	{
//		[self configureTextField: internetConnectionStatusField imageView: internetConnectionIcon reachability: curReach];
//	}
    
//	if(curReach == self.wifiReach)
//	{
//		[self configureTextField: localWiFiConnectionStatusField imageView: localWiFiConnectionIcon reachability: curReach];
//	}
}


@end
