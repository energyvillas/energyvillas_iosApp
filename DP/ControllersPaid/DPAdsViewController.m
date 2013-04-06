//
//  DPAdsViewController.m
//  DP
//
//  Created by Γεώργιος Γράβος on 3/31/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPAdsViewController.h"
#import "Banner.h"
#import "DPBannersLoader.h"
#import "DPConstants.h"

@interface DPAdsViewController ()

@property (strong, nonatomic) UIActivityIndicatorView *busyIndicator;
@property (strong, nonatomic) NSOperationQueue *queue;

@property (strong, nonatomic) DPDataLoader *dataLoader;
@property (nonatomic) int group;

@end

@implementation DPAdsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) initWithGroup:(int)aGroup {
    self = [super initWithContent:nil autoScroll:YES];
    
    if (self) {
        self.group = aGroup;
        self.rowCount = 1;
        self.colCount = 1;
        
        self.dataLoader = [[DPBannersLoader alloc] initWithController:self group:self.group];
        self.dataLoader.delegate = self;
        [self.dataLoader loadData];
    }
    
    return self;
}

- (void) reachabilityChanged {
    [super reachabilityChanged];
    if (self.contentList.count == 0 || self.dataLoader.dataRefreshNeeded)
        [self.dataLoader loadData];    
}

#pragma mark -
#pragma mark dataloaderdelegate methods

- (void)loadFinished:(DPDataLoader *)loader {
    if (loader.datalist.count == 0)
        ; // no worries....
        
//        showAlertMessage(nil,
//                         DPLocalizedString(kERR_TITLE_INFO),
//                         DPLocalizedString(kERR_MSG_NO_DATA_FOUND));
    else {
        [self contentLoaded:loader.datalist];
    }
}

//- (void) contentLoaded:(NSArray *)content {
//    [super contentLoaded:content];
//}

- (void)loadFailed:(DPDataLoader *)loader {
    // ok no worries....
//    showAlertMessage(nil,
//                     DPLocalizedString(kERR_TITLE_URL_NOT_FOUND),
//                     DPLocalizedString(kERR_MSG_DATA_LOAD_FAILED));
}

#pragma mark

//#pragma mark -
//#pragma mark === image downloading handling  ===
//
//- (void) downloadImageUrl:(NSURL *)imageUrl atIndex:(int)index{
//    if (!self.queue)
//        self.queue = [[NSOperationQueue alloc] init];
//    
//    ASIHTTPRequest *imageRequest = [ASIHTTPRequest requestWithURL:imageUrl];
//    [imageRequest setDelegate:self];
//    [imageRequest setDidFinishSelector:@selector(imageRequestDone:)];
//    imageRequest.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
//                             [NSNumber numberWithInt:index], @"imageIndex",
//                             nil];
//    
//    [self.queue addOperation:imageRequest];
////    [self startIndicator];
//}
//
//- (void) imageRequestDone:(ASIHTTPRequest *)request{
////    [self stopIndicator];
//    
////	self.datalist[request.userInfo[@"imageIndex"]].imageData = [UIImage imageWithData:[request responseData]];
////    [self doInitImageView];
//}
//
//- (void) requestFailed:(ASIHTTPRequest *)request {
//	NSLog(@"Request Failed: %@", [request error]);
//    
////	[self stopIndicator];
//    
//    showAlertMessage(nil,
//                     DPLocalizedString(kERR_TITLE_URL_NOT_FOUND),
//                     DPLocalizedString(kERR_MSG_DATA_LOAD_FAILED));
//}
//
//#pragma mark

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end