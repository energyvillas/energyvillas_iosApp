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
    self = [super initWithContent:nil
                       autoScroll:YES
                        showPages:NO
                  scrollDirection:DPScrollDirectionHorizontal];
    
    if (self) {
        self.group = aGroup;
        self.rowCount = 1;
        self.colCount = 1;
        
        self.dataDelegate = self;
        self.dataLoader = [[DPBannersLoader alloc] initWithView:self.view group:self.group];
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

#pragma mark - dataloaderdelegate methods

- (void)loadFinished:(DPDataLoader *)loader {
    if (loader.datalist.count == 0)
        ; // no worries....
    else 
        [self contentLoaded:loader.datalist];
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

#pragma mark - DPScrollableDataSourceDelegate

- (UILabel *) createLabelFor:(int)contentIndex
                       frame:(CGRect)frame
                       title:(NSString *)title {
    return nil;
}

//- (void) postProcessView:(UIView *)aView contentIndex:(int)contentIndex frame:(CGRect)frame {
//    aView.frame = CGRectInset(aView.frame, 3, 3);
//    aView.contentMode = UIViewContentModeScaleToFill;
//}

#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(void) dealloc {
    if (self.dataLoader) {
        self.dataLoader.delegate = nil;
    }
    self.dataLoader = nil;
    self.dataDelegate = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
