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

//#import "DPAnimatedCategoriesView.h"

#import "HouseOverview.h"
#import "HouseOverviewLoader.h"
#import "Category.h"
#import "DPCategoryLoader.h"

#import "DPConstants.h"
#import "DPAppHelper.h"

@interface DPSubCategoryViewController ()

@property (strong, nonatomic) Category *category;

@property (strong, nonatomic) DPImageContentViewController *imageContentViewController;
@property (strong, nonatomic) DPHtmlContentViewController *htmlContentViewController;
@property (strong, nonatomic) DPAnimatedScrollViewController *subCtgsViewController;


@property (strong, nonatomic) HouseOverview *houseOverview;
@property (strong, nonatomic) NSArray *categories;

@property (strong, nonatomic) HouseOverviewLoader *hovLoader;
@property (strong, nonatomic) DPCategoryLoader *ctgLoader;

@end

@implementation DPSubCategoryViewController {
    bool isPortrait;
}


- (id) initWithCategory:(Category *)ctg {
    if (self = [super init]) {
        self.category = ctg;
        //        self.categories = [[DPAppHelper sharedInstance] getSubCategoriesOf:ctgID];
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
    self.photoView.backgroundColor = [UIColor orangeColor];//]clearColor];
    self.htmlView.backgroundColor = [UIColor whiteColor];//clearColor];
    self.subCtgView.backgroundColor = [UIColor clearColor];
    
//    self.label.text = self.category.title;
    
    [self loadData];
}

- (void) loadData {
    self.ctgLoader = [[DPCategoryLoader alloc] initWithView:self.subCtgView
                                                useInternet:YES
                                                 useCaching:YES
                                                   category:self.category.Id
                                                       lang:CURRENT_LANG
                                              useDeviceType:NO
                                                  localData:nil];
    self.ctgLoader.delegate = self;
    [self.ctgLoader loadData];
    
    self.hovLoader = [[HouseOverviewLoader alloc] initWithView:self.view
                                                          lang:CURRENT_LANG
                                                        category:self.category.Id];
    self.hovLoader.delegate = self;
    [self.hovLoader loadData];
}

#pragma mark - dataloader delegate

- (void) ctgLoadFinished:(DPCategoryLoader *)loader {
}

-(void) hovLoaded {
    [self.titleView loadHTMLString:self.houseOverview.title baseURL:nil];
}
- (void) hovLoadFinished:(HouseOverviewLoader *)loader {
    if (loader.datalist.count == 0)
        showAlertMessage(nil,
                         DPLocalizedString(kERR_TITLE_INFO),
                         DPLocalizedString(kERR_MSG_NO_DATA_FOUND));
    else {
        self.houseOverview = loader.datalist[0];
        [self hovLoaded];
    }
}

- (void) loadFinished:(DPDataLoader *)loader {
    if (loader == self.ctgLoader) 
        [self ctgLoadFinished:(DPCategoryLoader *)loader];
    else if (loader == self.hovLoader)
        [self hovLoadFinished:(HouseOverviewLoader *)loader];
//====
//    else  { // if (loader == self.categoriesLoader)
//        if (loader.datalist.count == 0)
//            showAlertMessage(nil, DPLocalizedString(kERR_TITLE_INFO), DPLocalizedString(kERR_MSG_NO_DATA_FOUND));
//        else {
//            NSMutableArray *children = [[NSMutableArray alloc] init];
//            for (Category *ctg in loader.datalist)
//                if (ctg.parentId == self.category.Id)
//                    [children addObject:ctg];
//            self.categories = [[NSArray alloc] initWithArray:children];
//            [self loadCategoryView];
//        }
//    }
}

- (void)loadFailed:(DPDataLoader *)loader {
    showAlertMessage(nil,
                     DPLocalizedString(kERR_TITLE_CONNECTION_FAILED),
                     DPLocalizedString(kERR_MSG_DATA_LOAD_FAILED));
}

#pragma

- (void) doLayoutSubViews:(BOOL)fixtop {    
    CGRect vf = self.view.frame;
    //    CGRect svf = self.view.superview.frame;
    
    fixtop = IS_LANDSCAPE;
    int top = fixtop ? 12 : 0;
    int h = vf.size.height - top;
    int w = vf.size.width;
    //BOOL fixtop = NO;
//    int h = IS_PORTRAIT ? vf.size.height : vf.size.height - vf.origin.y;
//    int w = vf.size.width;
//    int top = fixtop ? vf.origin.y : 0;
    
    // iphone sizes
    //portrait
    int PH_LBL = 24; // font helvetica neue bold 18
    int PH_PHT = 126;
    int PH_HTM = 80;
    //landscape
    int LH_LBL = 24;
    int LH_PHT = 130;
    int LW_PHT = 200;
    
    // iphone5 sizes
    //portrait
    int P5H_LBL = 24; // font helvetica neue bold 18
    int P5H_PHT = 126;
    int P5H_HTM = 80;
    //landscape
    int L5H_LBL = 24;
    int L5H_PHT = 130;
    int L5W_PHT = 230;
    
    // ipad sizes
    //portrait
    int PAD_PH_LBL = 30; // // font helvetica neue bold 24
    int PAD_PH_PHT = 320;//80;
    int PAD_PH_HTM = 184;
    //landscape
    int PAD_LH_LBL = 30;
    int PAD_LH_PHT = 350;
    int PAD_LW_PHT = 450;
    
    
    if (IS_IPHONE) {
        if (IS_PORTRAIT) {
            self.titleView.frame = CGRectMake(0, top,
                                          w, PH_LBL);
            
            self.photoView.frame = CGRectMake(0, top + PH_LBL,
                                              w, PH_PHT);
            
            self.htmlView.frame = CGRectMake(0, top + PH_LBL + PH_PHT,
                                             w, PH_HTM);

            self.subCtgView.frame = CGRectMake(0, top + PH_LBL + PH_PHT + PH_HTM,
                                               w, h - (PH_LBL + PH_PHT + PH_HTM));
        } else {
            self.titleView.frame = CGRectMake(LW_PHT, top,
                                          w - LW_PHT, LH_LBL);
            
            self.photoView.frame = CGRectMake(0, top,
                                              LW_PHT, LH_PHT);
            
            self.htmlView.frame = CGRectMake(0, top + LH_PHT,
                                             LW_PHT, h - LH_PHT);
            
            self.subCtgView.frame = CGRectMake(LW_PHT, top + LH_LBL,
                                               w - LW_PHT, h - LH_LBL);
        }
    } else if (IS_IPHONE_5) {
        if (IS_PORTRAIT) {
            self.titleView.frame = CGRectMake(0, top,
                                          w, P5H_LBL);
            
            self.photoView.frame = CGRectMake(0, top + P5H_LBL,
                                              w, P5H_PHT);
            
            self.htmlView.frame = CGRectMake(0, top + P5H_LBL + P5H_PHT,
                                             w, P5H_HTM);
            
            self.subCtgView.frame = CGRectMake(0, top + P5H_LBL + P5H_PHT + P5H_HTM,
                                               w, h - (P5H_LBL + P5H_PHT + P5H_HTM));
        } else {
            self.titleView.frame = CGRectMake(L5W_PHT, top,
                                          w - L5W_PHT, L5H_LBL);
            
            self.photoView.frame = CGRectMake(0, top,
                                              L5W_PHT, L5H_PHT);
            
            self.htmlView.frame = CGRectMake(0, top + L5H_PHT,
                                             L5W_PHT, h - L5H_PHT);
            
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
            self.titleView.frame = CGRectMake(PAD_LW_PHT, top,
                                          w - PAD_LW_PHT, PAD_LH_LBL);
            
            self.photoView.frame = CGRectMake(0, top,
                                              PAD_LW_PHT, PAD_LH_PHT);
            
            self.htmlView.frame = CGRectMake(0, top + PAD_LH_PHT,
                                             PAD_LW_PHT, h - PAD_LH_PHT);
            
            self.subCtgView.frame = CGRectMake(PAD_LW_PHT, top + PAD_LH_LBL,
                                               w - PAD_LW_PHT, h - PAD_LH_LBL);
       }
    }
    
//    [self loadAdsView];
    [self loadCategoryView];
//    [self loadMenuView];
}


- (void) loadCategoryView {
    if (self.subCtgView.subviews.count == 0)
    {
        self.subCtgsViewController = [[DPAnimatedScrollViewController alloc] initWithCategory:self.category.Id isLeaf:YES frame:self.subCtgView.bounds];
        
        [self addChildViewController:self.subCtgsViewController];
        [self.subCtgView addSubview:self.subCtgsViewController.view];
    }
    else
        [self.subCtgsViewController changeRows:1 columns:1];
}

-(void) clearDataLoaders {
    if (self.hovLoader) {
        self.hovLoader.delegate = nil;
    }
    self.hovLoader = nil;
    
    
    if (self.ctgLoader) {
        self.ctgLoader.delegate = nil;
    }
    self.ctgLoader = nil;
}

-(void) dealloc {
    [self clearDataLoaders];
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
