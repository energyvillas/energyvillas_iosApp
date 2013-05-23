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

@interface DPAdsViewController ()

@property (strong, nonatomic) UIActivityIndicatorView *busyIndicator;
@property (strong, nonatomic) NSOperationQueue *queue;

@property (strong, nonatomic) DPDataLoader *dataLoader;

@end

@implementation DPAdsViewController

@synthesize group = _group;

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
        _group = aGroup;
        self.rowCount = 1;
        self.colCount = 1;
        
        self.dataDelegate = self;
    }
    
    return self;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    [self loadData];
}

- (void) loadData {
    self.dataLoader = [[DPBannersLoader alloc] initWithView:self.view
                                                      group:self.group
                                                       lang:CURRENT_LANG];
    self.dataLoader.delegate = self;
    [self.dataLoader loadData];
}

- (void) reachabilityChanged {
    [super reachabilityChanged];
    if (self.contentList.count == 0 || self.dataLoader == nil || self.dataLoader.dataRefreshNeeded)
        [self loadData];    
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
//
//- (void) postProcessView:(UIView *)aView contentIndex:(int)contentIndex frame:(CGRect)frame {
//    aView.frame = CGRectInset(aView.frame, 1, 1);
//    aView.contentMode = UIViewContentModeScaleAspectFit;
//}

- (NSString *) getBaseImageUrlToLoadFor:(DPDataElement *)elm {
    Banner *banner = (Banner *)elm;
    return NullIfEmpty( IS_PORTRAIT ? banner.imageUrl : banner.imageUrlLandsape );
}

- (UIView *)createViewFor:(int)contentIndex frame:(CGRect)frame {
    UIImageView *result = [[UIImageView alloc] initWithFrame:frame];
    result.contentMode = UIViewContentModeScaleAspectFit;
    result.backgroundColor = [UIColor clearColor];
    
    result.tag = contentIndex;
    UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc]
                                      initWithTarget:self action:@selector(handleTap:)];
    [result addGestureRecognizer:tapper];
    result.userInteractionEnabled = YES;
    
//    Banner *banner = self.contentList[contentIndex];
//    NSString *imgName = NullIfEmpty( IS_PORTRAIT ? banner.imageUrl : banner.imageUrlLandsape );
//    if (imgName != nil) {
//        if (isLocalUrl(imgName))
//            result.image = [UIImage imageNamed:imgName];
//        else
//            [self loadImageAsync:banner imageUrl:imgName inView:result cacheImage:YES];
//    }
    
    return result;
}

#pragma mark -

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
