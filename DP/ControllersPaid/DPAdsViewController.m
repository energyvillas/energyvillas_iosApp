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
#import "DPAppHelper.h"

int ADS_COMMON_CURR_PAGE = 0;

int GET_ADS_COMMON_CURR_PAGE() {
    return ADS_COMMON_CURR_PAGE;
}
void SET_ADS_COMMON_CURR_PAGE(int val){
    ADS_COMMON_CURR_PAGE = val;
}

@interface DPAdsViewController ()

@property (strong, nonatomic) UIActivityIndicatorView *busyIndicator;
@property (strong, nonatomic) NSOperationQueue *queue;

@property (strong, nonatomic) DPDataLoader *dataLoader;

@end

@implementation DPAdsViewController

@synthesize group = _group;
@synthesize currentAdPage = _currentAdPage;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) initWithGroup:(int)aGroup initialPage:(int)aInitialPage {
    self = [super initWithContent:nil
                             rows:1
                          columns:1
                       autoScroll:YES
                        showPages:NO
                  scrollDirection:DPScrollDirectionHorizontal
                      initialPage:aInitialPage];
    
    if (self) {
        _group = aGroup;
        
        self.dataDelegate = self;
        self.scrollableViewDelegate = self;
    }
    
    return self;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    [self loadData];
}

- (NSArray *) createLocalData {
    NSString *bannername = nil;

    switch (self.group) {
        case BANNER_GROUP_COMMON_MAIN: {
            bannername = @"Banners/Banner_CMN_MAIN_%@_%@.jpg";
            bannername = [NSString stringWithFormat:bannername, CURRENT_LANG, @"%@"];
            break;
        }

        case BANNER_GROUP_COMMON_LVL1: {
            bannername = @"Banners/Banner_CMN_LVL1_%@_%@.jpg";
            bannername = [NSString stringWithFormat:bannername, CURRENT_LANG,  @"%@"];
            break;
        }

        case BANNER_GROUP_EXCLUSIVE: {
            bannername = @"Banners/Banner_EXCL_%@.jpg";
            break;
        }

    }

    NSString *bannernameP = [NSString stringWithFormat:bannername, @"v"];
    NSString *bannernameL = [NSString stringWithFormat:bannername, @"h"];

    Banner *bnr = [[Banner alloc] initWithValues:[NSString stringWithFormat:@"%d", (-100 - self.group)]
                                            lang:CURRENT_LANG
                                         orderNo:1
                                           title:nil
                                        imageUrl:bannernameP
                               imageUrlLandscape:bannernameL
                                             url:nil];
    
    NSArray *list = [NSArray arrayWithObject:bnr];
    
    return list;
}

- (void) loadData {
    if (!self.dataLoader) {
        self.dataLoader = [[DPBannersLoader alloc] initWithView:self.view
                                                          group:self.group
                                                           lang:CURRENT_LANG
                                                      localData:[self createLocalData]];
        self.dataLoader.delegate = self;
    }
    
    if (self.contentList == nil || self.contentList.count == 0 || self.dataLoader.dataRefreshNeeded)
        [self.dataLoader loadData];
}

- (void) reachabilityChanged {
    [super reachabilityChanged];
        [self loadData];    
}

#pragma mark - dataloaderdelegate methods

- (void)loadFinished:(DPDataLoader *)loader {
    if (loader.datalist.count == 0)
        ; // no worries....
    else 
        [self contentLoaded:loader.datalist];
    
    [self.view setNeedsLayout];
    [self.view setNeedsDisplay];
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
//
//- (void) postProcessView:(UIView *)aView contentIndex:(int)contentIndex frame:(CGRect)frame {
//    aView.frame = CGRectInset(aView.frame, 1, 1);
//    aView.contentMode = UIViewContentModeScaleAspectFit;
//}

- (NSString *) getBaseImageUrlToLoadFor:(DPDataElement *)elm {
    Banner *banner = (Banner *)elm;
    return NilIfEmpty( IS_PORTRAIT ? banner.imageUrl : banner.imageUrlLandsape );
}

- (UIView *)createViewFor:(int)contentIndex frame:(CGRect)frame {
    //[self stopIndicator];
    UIImageView *result = [[UIImageView alloc] initWithFrame:frame];
    result.contentMode = UIViewContentModeCenter; //ScaleAspectFit;
    result.backgroundColor = [UIColor clearColor];
    
    result.tag = contentIndex;
    UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc]
                                      initWithTarget:self action:@selector(handleTap:)];
    [result addGestureRecognizer:tapper];
    result.userInteractionEnabled = YES;
        
    return result;
}

- (NSString *) resolveImageName:(DPDataElement *)elm {
    return [self getBaseImageUrlToLoadFor:elm];
}

#pragma mark -

-(void) dealloc {
    if (self.dataLoader) {
        self.dataLoader.delegate = nil;
    }
    self.dataLoader = nil;
    self.dataDelegate = nil;
    self.busyIndicator = nil;
    self.queue = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//======
- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    SET_ADS_COMMON_CURR_PAGE(_currentAdPage);
}
- (void) elementTapped:(id)sender element:(id)element {
    
}

- (void) scrolledToPage:(int)newPage fromPage:(int)oldPage {
    _currentAdPage = newPage;
    NSLog(@"scrolledToPage:%d", _currentAdPage);
}

- (int) getCurrentAdPage {
    return _currentAdPage;
}


@end
