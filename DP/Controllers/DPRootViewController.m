//
//  DPRootViewController.m
//  DP
//
//  Created by Γεώργιος Γράβος on 3/20/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPRootViewController.h"
#import "../External/OpenFlow/UIImageExtras.h"
#import "DPCategoriesViewController.h"
#import "../Classes/DPImageContentViewController.h"
#import "DPConstants.h"
#import "DPVimeoPlayerViewController.h"
#import "DPAppHelper.h"
#import "DPMainViewController.h"
#import "DPBuyViewController.h"
#import "Article.h"
#import "DPCategoryLoader.h"



@interface DPRootViewController ()

@property (strong, nonatomic) NSMutableDictionary *coverFlowDict;
@property (strong, nonatomic) DPBuyViewController *buyController;

@end

@implementation DPRootViewController {
    int currentIndex;
}

- (id) init {
    self = [super init];
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        currentIndex = -1;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self doLocalize];
    [self.bbiMore setAction:@selector(doMore:)];
    [self.bbiBuy setAction:@selector(doBuy:)];
}

- (void) doLocalize {
    [super doLocalize];
    self.bbiMore.title = DPLocalizedString(kbbiMore_Title);
    self.bbiBuy.title = DPLocalizedString(kbbiBuy_Title);
    
    if (self.bottomView.subviews.count > 0) {
        [self loadDetailView:YES];
        [self loadOpenFlow];
    }
}

- (void) showBuyDialog:(int)ctgId {
    if (IS_IPAD)
        [self showBuyDialog_iPads:ctgId];
    else
        [self showBuyDialog_iPhones:ctgId];
}

- (void) showBuyDialog_iPads:(int)ctgId {    
    self.buyController = [[DPBuyViewController alloc]
                                  initWithCategoryId:ctgId
                                  completion:^{
                                      self.view.userInteractionEnabled = YES;
                                      self.buyController = nil;
                                  }];
    
    self.view.userInteractionEnabled = NO;
    self.buyController.modalPresentationStyle = UIModalPresentationFormSheet;
    self.navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self.navigationController presentViewController:self.buyController animated:YES completion:nil];
    CGRect svfrm = [self.buyController calcFrame];
    if (IS_PORTRAIT)
        self.buyController.view.superview.frame = CGRectOffset(svfrm, 0, 170);
    else
        self.buyController.view.superview.frame = CGRectOffset(svfrm, 0, 180);
}

- (void) showBuyDialog_iPhones:(int)ctgId {
    id del = self.navigationController.delegate;
    DPMainViewController *main = del;
    
    DPBuyViewController *buyVC = [[DPBuyViewController alloc]
                                  initWithCategoryId:ctgId
                                  completion:^{
                                      self.view.userInteractionEnabled = YES;
                                      self.buyController = nil;
                                  }];

    self.view.userInteractionEnabled = NO;

    [main addChildViewController:buyVC];
    [main.view addSubview:buyVC.view];
}

- (void) doBuy:(id) sender {
    [self showBuyDialog:-1];
}

- (void) doMore:(id) sender {
    // do the more stuff here
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillLayoutSubviews {    
    CGRect vf = self.view.frame;
    
    int h = IS_PORTRAIT ? vf.size.height : vf.size.height - vf.origin.y ;
    int w = vf.size.width;
        
    int toolbarHeight = self.toolbar.frame.size.height;

    int BOTTOM_HEIGHT;
    if (IS_IPHONE)
        BOTTOM_HEIGHT = (IS_PORTRAIT) ? 170 : 64;
    else if (IS_IPHONE_5)
        BOTTOM_HEIGHT = (IS_PORTRAIT) ? 170 : 75;
    else // if (IS_IPAD)
        BOTTOM_HEIGHT = (IS_PORTRAIT) ? 408 : 136;;
    
    // adjust for pagecontrol
    BOTTOM_HEIGHT = BOTTOM_HEIGHT + PAGE_CONTROL_HEIGHT;

    int topHeight = h - toolbarHeight - BOTTOM_HEIGHT;
    
    self.topView.frame = CGRectMake(0, 0, w, topHeight);
    
    self.toolbar.frame = CGRectMake(0, topHeight,
                                    w, toolbarHeight);
    
    self.bottomView.frame = CGRectMake(0, topHeight + toolbarHeight,
                                       w, BOTTOM_HEIGHT);
    
    [self loadOpenFlow];
    [self loadDetailView:NO];
    
    if (/*IS_IPAD && */self.buyController) {
        int ctgid = self.buyController.category;
        [self.navigationController dismissViewControllerAnimated:NO completion:nil];
        self.view.userInteractionEnabled = YES;
        self.buyController = nil;
        [self showBuyDialog:ctgid];
    }
}

- (void) loadDetailView:(BOOL)reload{
    UIView *bcv = self.bottomView;

    DPCategoriesViewController *detvc;
    if (reload && bcv.subviews.count > 0) {
        detvc = (DPCategoriesViewController *)self.childViewControllers[0];
        [detvc.view removeFromSuperview];
        [detvc removeFromParentViewController];
        detvc = nil;
    }        
    
    if (bcv.subviews.count == 0) {
        DPAppHelper *apphelper = [DPAppHelper sharedInstance];
        if (IS_PORTRAIT)
            detvc = [[DPCategoriesViewController alloc] initWithCategory:-1
                                                                    lang:apphelper.currentLang
                                                           localResource:@"free-details.plist"
                                                                    rows:2
                                                                 columns:2
                                                              autoScroll:YES
                                                                  parent:self];
        else
            detvc = [[DPCategoriesViewController alloc] initWithCategory:-1
                                                                    lang:apphelper.currentLang
                                                           localResource:@"free-details.plist"
                                                                    rows:1
                                                                 columns:4
                                                              autoScroll:YES
                                                                  parent:self];
        
        
        [self addChildViewController: detvc];
        [bcv addSubview: detvc.view];
        
        detvc = nil;
    } else {
        detvc = (DPCategoriesViewController *)self.childViewControllers[0];
        detvc.view.frame = self.bottomView.bounds;
        if (IS_PORTRAIT) 
            [detvc changeRows:2 columns:2];
        else
            [detvc changeRows:1 columns:4];
    }
}

- (void) loadOpenFlow {
    UIView *ofvc = self.topView;
    AFOpenFlowView *ofv = nil;

    ofv = ofvc.subviews.count == 0 ? nil : ofvc.subviews[0];
    if (ofv)
        [ofv removeFromSuperview];
    ofv = nil;

    if (ofvc.subviews.count == 0) {
        ofv = [[AFOpenFlowView alloc] initWithFrame:ofvc.bounds];
        ofv.viewDelegate = self;
        ofv.dataSource = self;

        [ofvc addSubview:ofv];
        
        NSArray *langCoverFlow = [self currlangCoverFlow];
        
        [ofv setNumberOfImages:langCoverFlow.count];
        if (currentIndex != -1)
            [ofv setSelectedCover: currentIndex];
    }
    else {
        ofv = ofvc.subviews[0];
        if (currentIndex != -1)
            [ofv setSelectedCover: currentIndex];
    }
}

- (NSArray *) currlangCoverFlow {
    DPAppHelper *apphelper = [DPAppHelper sharedInstance];

    if (!self.coverFlowDict)
        self.coverFlowDict = [[NSMutableDictionary alloc] initWithCapacity:2];

    NSArray *langCoverFlow = self.coverFlowDict[apphelper.currentLang];
    if (!langCoverFlow) {
        langCoverFlow = [apphelper freeCoverFlowFor:apphelper.currentLang];
        [self.coverFlowDict setValue:langCoverFlow forKey:apphelper.currentLang];
    }
    
    return langCoverFlow;
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    UIView *ofvc = self.topView;
    AFOpenFlowView *ofv = nil;

    if (ofvc.subviews.count != 0) {
        ofv = ofvc.subviews[0];
        if (currentIndex != -1)
            [ofv setSelectedCover: currentIndex];
        [ofv centerOnSelectedCover:YES];
    }
}

// protocol AFOpenFlowViewDelegate
- (void) openFlowView:(AFOpenFlowView *)openFlowView click:(int)index {
    
    Article *article = [self currlangCoverFlow][index];

    if (article.videoUrl == nil) {
        DPImageContentViewController *vc = [[DPImageContentViewController alloc]
                                            initWithImageName:[self calcImageName:article.imageUrl]];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        NSString *videourl = article.videoUrl;
        DPVimeoPlayerViewController *vimeo = [[DPVimeoPlayerViewController alloc]
                                              initWithUrl:videourl];
        [self.navigationController pushViewController:vimeo animated:YES];
    }
}

- (void) openFlowView:(AFOpenFlowView *)openFlowView selectionDidChange:(int)index {
    currentIndex = index;
}

// protocol AFOpenFlowViewDatasource
- (void) openFlowView:(AFOpenFlowView *)openFlowView requestImageForIndex:(int)index {
    Article *article = [self currlangCoverFlow][index];
    NSString *imgName = [self calcImageName:article.imageUrl];
    UIImage *img = [UIImage imageNamed:imgName];
    
    [openFlowView setImage:img forIndex:index];
}

- (NSString *) calcImageName:(NSString *)baseName {
    @try {
        NSArray *parts = [baseName componentsSeparatedByString:@"."];
        if (parts && parts.count == 2) {
            NSString *lang = @"el";// [DPAppHelper sharedInstance].currentLang;
            NSString *orientation = IS_PORTRAIT ? @"v" : @"h";
            NSString *result = [NSString stringWithFormat:@"Carousel/%@_%@_%@.%@",
                                parts[0], lang, orientation, parts[1]];
            return result;
        }
        else
            return baseName;
    }
    @catch (NSException* exception) {
        NSLog(@"Uncaught exception: %@", exception.description);
        NSLog(@"Stack trace: %@", [exception callStackSymbols]);
        return baseName;
    }
}

- (UIImage *) defaultImage {
    return nil; // this should return the missing image replacement
}

- (void)viewDidUnload {
    [self setToolbar:nil];
    [self setBbiMore:nil];
    [self setBbiBuy:nil];
    [self setTopView:nil];
    [self setBottomView:nil];
    [super viewDidUnload];
}

@end
