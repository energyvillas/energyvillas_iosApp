//
//  DPSubCategoryViewController.m
//  DP
//
//  Created by Γεώργιος Γράβος on 4/7/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPSubCategoryViewController.h"

#import "DPImageContentViewController.h"
#import "DPVimeoPlayerViewController.h"
#import "DPHtmlContentViewController.h"
#import "DPAnimatedScrollViewController.h"

#import "DPArticlesViewController.h"

#import "HouseOverview.h"
#import "HouseOverviewLoader.h"
#import "Category.h"
#import "DPCategoryLoader.h"

#import "DPConstants.h"
#import "DPAppHelper.h"

#import <QuartzCore/QuartzCore.h>

@interface DPSubCategoryViewController ()

@property (strong, nonatomic) Category *category;

//@property (strong, nonatomic) DPImageContentViewController *imageContentViewController;
//@property (strong, nonatomic) DPHtmlContentViewController *htmlContentViewController;
@property (strong, nonatomic) DPAnimatedScrollViewController *subCtgsViewController;


@property (strong, nonatomic) HouseOverview *houseOverview;
//@property (strong, nonatomic) NSArray *hikCategories;

@property (strong, nonatomic) HouseOverviewLoader *hovLoader;
//@property (strong, nonatomic) DPCategoryLoader *ctgLoader;

@property (strong, nonatomic) UIView *titleLine;

@end

@implementation DPSubCategoryViewController {
    bool isPortrait;
}


- (id) initWithCategory:(Category *)ctg {
    if (self = [super init]) {
        self.category = ctg;
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.titleView.backgroundColor = [UIColor clearColor];
    self.titleView.opaque = NO;
    
    self.photoView.backgroundColor = [UIColor clearColor];
    
    self.htmlView.backgroundColor = [UIColor clearColor];    

    self.subCtgView.backgroundColor = [UIColor clearColor];
    
//    self.label.text = self.category.title;
    
    [self loadData];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.view setNeedsDisplay];
    [self.view setNeedsLayout];
//    if (self.subCtgsViewController)
//        [self.subCtgsViewController changeRows:self.subCtgsViewController.rowCount
//                                       columns:self.subCtgsViewController.colCount
//                               scrollDirection:self.subCtgsViewController.scrollDirection];
    if (self.category)
        [[NSNotificationCenter defaultCenter] postNotificationName:DPN_PAID_SelectedCategoryChanged_Notification
                                                            object:self
                                                          userInfo:[NSDictionary
                                                                    dictionaryWithObject:[NSNumber numberWithInt:self.category.parentId]
                                                                    forKey:@"menuCategory"]];

}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}


-(void) doLocalize {
    [super doLocalize];
    [self loadData];
    
    if (self.subCtgView.subviews.count > 0)
        [self loadCategoryView:YES];
    
    [self loadInfoDescView];
}

- (void) loadData {
    [self clearDataLoaders];
    
    self.hovLoader = [[HouseOverviewLoader alloc] initWithView:self.view
                                                          lang:CURRENT_LANG
                                                        category:self.category.Id];
    self.hovLoader.delegate = self;
    [self.hovLoader loadData];
}

#pragma mark - dataloader delegate

-(void) hovLoaded {
    if (self.houseOverview) 
        [self.titleView loadHTMLString:self.houseOverview.title baseURL:nil];
    
    [self loadPhotoView];
}
- (void) hovLoadFinished:(HouseOverviewLoader *)loader {
    if (loader.datalist.count == 0) {
        stopActivityIndicators(self.photoView);
        showAlertMessage(nil,
                         DPLocalizedString(kERR_TITLE_INFO),
                         DPLocalizedString(kERR_MSG_NO_DATA_FOUND));
    } else {
        self.houseOverview = loader.datalist[0];
        [self hovLoaded];
    }
}

- (void) loadFinished:(DPDataLoader *)loader {
    if (loader == self.hovLoader)
        [self hovLoadFinished:(HouseOverviewLoader *)loader];
}

- (void)loadFailed:(DPDataLoader *)loader {
    stopActivityIndicators(self.photoView);

    showAlertMessage(nil,
                     DPLocalizedString(kERR_TITLE_CONNECTION_FAILED),
                     DPLocalizedString(kERR_MSG_DATA_LOAD_FAILED));
}

#pragma

- (void) doLayoutSubViews:(BOOL)fixtop {    
    CGRect vf = self.view.frame;
    
    fixtop = IS_LANDSCAPE && !IS_IPAD;
    int top = fixtop ? 12 : 0;
    int h = vf.size.height - top;
    int w = vf.size.width;
    
    // iphone sizes
    //portrait
    int PH_LBL = 26; //24; // font helvetica neue bold 18
    int PH_PHT = 126;
    int PH_HTM = 60; //80;
    //landscape
    int LH_LBL = 26; //24;
    int LH_PHT = 130;
    int LW_PHT = 200;
    
    // iphone5 sizes
    //portrait
    int P5H_LBL = 26; //24; // font helvetica neue bold 18
    int P5H_PHT = 170;//126;
    int P5H_HTM = 60;//80;
    //landscape
    int L5H_LBL = 26; //24;
    int L5H_PHT = 130;
    int L5W_PHT = 230;
    
    // ipad sizes
    //portrait
    int PAD_PH_LBL = 32; //30; // // font helvetica neue bold 24
    int PAD_PH_PHT = 320;//80;
    int PAD_PH_HTM = 110; //184;
    //landscape
    int PAD_LH_LBL = 32; //30;
    int PAD_LH_PHT = 350;
    int PAD_LW_PHT = 450;
    
    
    if (IS_IPHONE) {
        if (IS_PORTRAIT) {
            self.titleView.frame = CGRectMake(0, top - 5,
                                          w, PH_LBL + 5);
            
            self.photoView.frame = CGRectMake(0, top + PH_LBL,
                                              w, PH_PHT);
            
            self.htmlView.frame = CGRectMake(0, top + PH_LBL + PH_PHT,
                                             w, PH_HTM);

            self.subCtgView.frame = CGRectMake(0, top + PH_LBL + PH_PHT + PH_HTM,
                                               w, h - (PH_LBL + PH_PHT + PH_HTM));
        } else {
            self.titleView.frame = CGRectMake(0, top - 5, //LW_PHT, top - 5,
                                              w, LH_LBL + 5); //w - LW_PHT, LH_LBL + 5);
            
            self.photoView.frame = CGRectMake(0, top + LH_LBL, //0, top,
                                              LW_PHT, LH_PHT);//LW_PHT, LH_PHT);
            
            self.htmlView.frame = CGRectMake(0, top + LH_LBL + LH_PHT, //0, top + LH_PHT,
                                             LW_PHT, h - LH_LBL - LH_PHT); // LW_PHT, h - LH_PHT);
            
            self.subCtgView.frame = CGRectMake(LW_PHT, top + LH_LBL,
                                               w - LW_PHT, h - LH_LBL);
        }
    } else if (IS_IPHONE_5) {
        if (IS_PORTRAIT) {
            self.titleView.frame = CGRectMake(0, top - 5,
                                          w, P5H_LBL + 5);
            
            self.photoView.frame = CGRectMake(0, top + P5H_LBL,
                                              w, P5H_PHT);
            
            self.htmlView.frame = CGRectMake(0, top + P5H_LBL + P5H_PHT,
                                             w, P5H_HTM);
            
            self.subCtgView.frame = CGRectMake(0, top + P5H_LBL + P5H_PHT + P5H_HTM,
                                               w, h - (P5H_LBL + P5H_PHT + P5H_HTM));
        } else {
            self.titleView.frame = CGRectMake(0, top - 5, // L5W_PHT, top - 5,
                                              w, L5H_LBL + 5);//w - L5W_PHT, L5H_LBL + 5);
            
            self.photoView.frame = CGRectMake(0, top + L5H_LBL, //0, top,
                                              L5W_PHT, L5H_PHT);
            
            self.htmlView.frame = CGRectMake(0, top + L5H_LBL + L5H_PHT, // 0, top + L5H_PHT,
                                             L5W_PHT, h - L5H_LBL - L5H_PHT);//L5W_PHT, h - L5H_PHT);
            
            self.subCtgView.frame = CGRectMake(L5W_PHT, top + L5H_LBL,
                                               w - L5W_PHT, h - L5H_LBL);
        }
    } else /* IF (IS_IPAD) */{
        if (IS_PORTRAIT) {
            self.titleView.frame = CGRectMake(0, top,
                                          w, PAD_PH_LBL);
            
            self.photoView.frame = CGRectMake(0, top + PAD_PH_LBL,
                                              w, PAD_PH_PHT);
            
            self.htmlView.frame = CGRectMake(0, top + PAD_PH_LBL + PAD_PH_PHT,
                                             w, PAD_PH_HTM);
            
            self.subCtgView.frame = CGRectMake(0, top + PAD_PH_LBL + PAD_PH_PHT + PAD_PH_HTM,
                                               w, h - (PAD_PH_LBL + PAD_PH_PHT + PAD_PH_HTM));
        } else {
            self.titleView.frame = CGRectMake(0, top - 5, //PAD_LW_PHT, top,
                                              w, PAD_LH_LBL + 5); //w - PAD_LW_PHT, PAD_LH_LBL);
            
            self.photoView.frame = CGRectMake(0, top + PAD_LH_LBL, //0, top,
                                              PAD_LW_PHT, PAD_LH_PHT); //PAD_LW_PHT, PAD_LH_PHT);
            
            self.htmlView.frame = CGRectMake(0, top + PAD_LH_LBL + PAD_LH_PHT, //0, top + PAD_LH_PHT,
                                             PAD_LW_PHT, h - PAD_LH_LBL - PAD_LH_PHT); //PAD_LW_PHT, h - PAD_LH_PHT);
            
            self.subCtgView.frame = CGRectMake(PAD_LW_PHT, top + PAD_LH_LBL,
                                               w - PAD_LW_PHT, h - PAD_LH_LBL);
       }
    }
    
    // this is a fix for when returning from vimeo player in landscape
    CGRect nbf = self.navigationController.navigationBar.frame;
    nbf.size.height = 44;
    nbf.origin = CGPointZero;
    self.navigationController.navigationBar.frame = nbf;
    //

    [self hovLoaded];
    [self drawTitleLine];
    [self loadCategoryView:NO];
    [self loadInfoDescView];
}

- (void) drawTitleLine {
    if (self.titleLine)
        [self.titleLine removeFromSuperview];
    self.titleLine = nil;
    
    if (IS_LANDSCAPE) {
        self.titleLine = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                  CGRectGetMaxY(self.titleView.frame),
                                                                  self.titleView.frame.size.width,
                                                                  1.0f)];
        self.titleLine.layer.borderColor = [UIColor colorWithWhite:0.7f alpha:1.0f].CGColor;
        self.titleLine.layer.borderWidth = 1.0f;
        [self.view addSubview:self.titleLine];
    }
}

-(void) loadPhotoView {
    releaseSubViews(self.photoView);
    
    if (!self.houseOverview) {
        UIView *v = createImageViewLoading(self.photoView.bounds, NO, NO);
        [self.photoView addSubview:v];
    } else {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectInset(self.photoView.bounds, 0, 1);
        btn.showsTouchWhenHighlighted = YES;
        btn.contentMode = UIViewContentModeCenter;
        NSString *imgName = nil;
        if (self.category.parentId == CTGID_EXCLUSIVE_ART) {
            imgName = (self.houseOverview.isMaster)
            ? @"HouseInfo/Posters/poster_frame_play_art_%@.jpg"
            : @"HouseInfo/Posters/poster_frame_gallery_art_%@.jpg";
            imgName = [NSString stringWithFormat:imgName, IS_PORTRAIT ? @"v" : @"h"];
        } else if (self.category.parentId == CTGID_EXCLUSIVE_DESIGNER) {
            imgName = (self.houseOverview.isMaster)
            ? @"HouseInfo/Posters/poster_frame_play_designer_%@.jpg"
            : @"HouseInfo/Posters/poster_frame_gallery_designer_%@.jpg";
            imgName = [NSString stringWithFormat:imgName, IS_PORTRAIT ? @"v" : @"h"];
        } else {
            imgName = (self.houseOverview.isMaster)
            ? @"HouseInfo/Posters/poster_frame_play_%@_%@.png"
            : @"HouseInfo/Posters/poster_frame_gallery_%@_%@.png";
            imgName = [NSString stringWithFormat:imgName, IS_PORTRAIT ? @"v" : @"h", CURRENT_LANG];
        }
        [btn setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(photoTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.photoView addSubview:btn];
    }
}

-(void) loadInfoDescView {
    while (self.htmlView.subviews.count > 0) {
        [self.htmlView.subviews[self.htmlView.subviews.count - 1] removeFromSuperview];
    }
    
    UIView * inner = [self loadInnerHtmlView];
    BOOL sideBySide = !(IS_IPAD && IS_LANDSCAPE);
    [self loadInfoView: inner sideBySide:sideBySide];
    [self drawLine:inner sideBySide:sideBySide];
    [self loadDescrView:inner sideBySide:sideBySide];
}

-(UIView *) loadInnerHtmlView {
    CGFloat grayPcnt = 65.0f / 256.0f; //70.0f / 256.0f;
    UIView *innerHtmlView = [[UIView alloc] initWithFrame:CGRectInset(self.htmlView.bounds, 0, 2)];
//    innerHtmlView.backgroundColor = [UIColor colorWithRed:grayPcnt green:grayPcnt blue:grayPcnt alpha:0.9f];
    innerHtmlView.backgroundColor = [UIColor colorWithRed:grayPcnt green:grayPcnt blue:grayPcnt alpha:1.0f]; //[UIColor colorWithWhite:grayPcnt alpha:0.9f];
    innerHtmlView.layer.borderColor = [UIColor colorWithWhite:0.6f alpha:1.0f].CGColor;
    innerHtmlView.layer.borderWidth = 2.0f;
    
    [self.htmlView addSubview:innerHtmlView];
    return innerHtmlView;
}

#define IPAD_LANDSCAPE_INFO_HEIGHT ((int)110)

-(void) loadInfoView:(UIView *)container sideBySide:(BOOL)sidebyside {
    CGRect frm;
    if (sidebyside) {
        CGSize sz = container.bounds.size;
        frm = CGRectMake(0, 0, sz.height, sz.height);
    } else {
        CGSize sz = container.bounds.size;
        frm = CGRectMake(0, 0, sz.width, IPAD_LANDSCAPE_INFO_HEIGHT);
    }
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = frm;
    btn.showsTouchWhenHighlighted = YES;
    btn.contentMode = UIViewContentModeCenter;
    if (self.category.parentId == CTGID_EXCLUSIVE_ART || self.category.parentId == CTGID_EXCLUSIVE_DESIGNER)
        [btn setImage:[UIImage imageNamed:@"HouseInfo/Info/info_exclusive.png"] forState:UIControlStateNormal];
    else
        [btn setImage:[UIImage imageNamed:@"HouseInfo/Info/info.png"] forState:UIControlStateNormal];
    
    [btn addTarget:self action:@selector(infoTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [container addSubview:btn];
}

-(void) drawLine:(UIView *)container sideBySide:(BOOL)sidebyside {
    CGRect frm;
    CGSize sz = container.bounds.size;
    if (sidebyside) {
        frm = CGRectInset(CGRectMake(sz.height, 0, 1.0f, sz.height), 0, 6.0f);
    } else {
        frm = CGRectInset(CGRectMake(0, IPAD_LANDSCAPE_INFO_HEIGHT, sz.width, 1.0f), 6.0f, 0);
    }
    UIView *line = [[UIView alloc] initWithFrame:frm];
    line.frame = frm;
    line.layer.borderColor = [UIColor colorWithWhite:0.7f alpha:1.0f].CGColor;
    line.layer.borderWidth = 1.0f;
    [container addSubview:line];
}

-(void) loadDescrView:(UIView *)container sideBySide:(BOOL)sidebyside {
    CGRect frm;
    CGSize sz = container.bounds.size;
    if (sidebyside) {
        frm = CGRectMake(sz.height, 0, sz.width - sz.height, sz.height);
    } else {
        frm = CGRectMake(0, IPAD_LANDSCAPE_INFO_HEIGHT,
                         sz.width, sz.height - IPAD_LANDSCAPE_INFO_HEIGHT);
    }
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = frm;
    btn.showsTouchWhenHighlighted = YES;
    btn.contentMode = UIViewContentModeCenter;
    //[btn setImage:[UIImage imageNamed:@"HouseInfo/Info/info.png"] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:IS_IPAD ? 24.0f : 18.0f];
    [btn setTitle:DPLocalizedString(@"HIK_HouseDescription") forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    btn.reversesTitleShadowWhenHighlighted = YES;
    
    btn.layer.shadowColor = [UIColor whiteColor].CGColor;
    btn.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    btn.layer.shadowRadius = 1.6f;
    btn.layer.shadowOpacity = 0.95;

    
    [btn addTarget:self action:@selector(descrTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [container addSubview:btn];
}

-(void) photoTapped:(id)sender {
    if (self.houseOverview.isMaster) {
        // play video
        NSString *videourl = self.houseOverview.videoUrl;
        [DPVimeoPlayerViewController clsPlayVideoUrl:videourl];
    } else {
        // show images
        DPArticlesViewController *avc = [[DPArticlesViewController alloc] initWithCategory:self.houseOverview.ctgid showSocials:YES];
        [self.navigationController pushViewController:avc animated:YES];
    }
}

-(void) infoTapped:(id)sender {
    DPHtmlContentViewController *info = [[DPHtmlContentViewController alloc]
                                             initWithHTML:self.houseOverview.info];
    [self.navigationController pushViewController:info animated:YES];
}
-(void) descrTapped:(id)sender {
    DPHtmlContentViewController *descr = [[DPHtmlContentViewController alloc]
                                         initWithHTML:self.houseOverview.description];
    [self.navigationController pushViewController:descr animated:YES];
}

- (void) loadCategoryView:(BOOL)reload {
    if (self.category == nil)
        return;
    
    //if (reload)
    {
        if (self.subCtgsViewController)
        {
            [self.subCtgsViewController.view removeFromSuperview];
            [self.subCtgsViewController removeFromParentViewController];
            self.subCtgsViewController = nil;
        }
    }
    
    CGRect frm = self.subCtgView.bounds;
    if (self.subCtgView.subviews.count == 0)
    {
        self.subCtgsViewController = [[DPAnimatedScrollViewController alloc] initWithCategory:self.category.Id
                                                                                       isLeaf:YES
                                                                                        frame:frm];
        
        //[self.ctgViewController changeFrame:self.actualCtgView.bounds];
        [self addChildViewController:self.subCtgsViewController];
        [self.subCtgView addSubview:self.subCtgsViewController.view];
    }
    else {
        [self.subCtgsViewController changeFrame:frm];
        [self.subCtgsViewController changeRows:1 columns:1];
    }
}


-(void) clearDataLoaders {
    if (self.hovLoader) {
        self.hovLoader.delegate = nil;
    }
    self.hovLoader = nil;
    
    
//    if (self.ctgLoader) {
//        self.ctgLoader.delegate = nil;
//    }
//    self.ctgLoader = nil;
}

-(void) dealloc {
    [self clearDataLoaders];
    
    self.titleView = nil;
    self.photoView = nil;
    self.htmlView = nil;
    self.subCtgView = nil;
    
    self.category = nil;
    self.subCtgsViewController = nil;
    self.houseOverview = nil;
    self.hovLoader = nil;
    self.titleLine = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self clearDataLoaders];
    [self setTitleView:nil];
    [self setPhotoView:nil];
    [self setHtmlView:nil];
    [self setSubCtgView:nil];
    [super viewDidUnload];
}
@end
