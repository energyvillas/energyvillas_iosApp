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

#import "DPArticlesLoader.h"
#import "DPCategoryLoader.h"

#import "DPConstants.h"
#import "DPAppHelper.h"

@interface DPSubCategoryViewController ()

@property (strong, nonatomic) Category *category;

@property (strong, nonatomic) DPImageContentViewController *imageContentViewController;
@property (strong, nonatomic) DPHtmlContentViewController *htmlContentViewController;
@property (strong, nonatomic) DPAnimatedScrollViewController *subCtgsViewController;


@property (strong, nonatomic) NSArray *articles;
//@property (strong, nonatomic) NSArray *categories;

@property (strong, nonatomic) DPDataLoader *articlesLoader;
//@property (strong, nonatomic) DPDataLoader *categoriesLoader;

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
    self.photoView.backgroundColor = [UIColor orangeColor];//]clearColor];
    self.htmlView.backgroundColor = [UIColor whiteColor];//clearColor];
    self.subCtgView.backgroundColor = [UIColor clearColor];
    
    self.label.text = self.category.title;
    
    [self loadData];
}

- (void) loadData {
//    self.categoriesLoader = [[DPCategoryLoader alloc] initWithView:self.subCtgView
//                                                          category:self.category.Id
//                                                              lang:[DPAppHelper sharedInstance].currentLang
//                                                     localResource:nil /*PENDING localresource*/];
//    self.categoriesLoader.delegate = self;
//    [self.categoriesLoader loadData];
    
    self.articlesLoader = [[DPArticlesLoader alloc] initWithView:self.view
                                                        category:self.category.Id
                                                            lang:[DPAppHelper sharedInstance].currentLang];
    self.articlesLoader.delegate = self;
    [self.articlesLoader loadData];
}

#pragma mark - dataloader delegate

- (void) loadFinished:(DPDataLoader *)loader {
    if (loader == self.articlesLoader) {
        //PENDING
    }
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
    
    //BOOL fixtop = NO;
    int h = IS_PORTRAIT ? vf.size.height : vf.size.height - vf.origin.y;
    int w = vf.size.width;
    int top = fixtop ? vf.origin.y : 0;
    
    // iphone sizes
    //portrait
    int PH_LBL = 24; // font helvetica neue bold 18
    int PH_PHT = 126;
    int PH_HTM = 80;
    //landscape
    int LH_LBL = 24;
    int LH_PHT = 130;
    int LW_PHT = 280;
    
    // ipad sizes
    //portrait
    int PAD_PH_LBL = 30; // // font helvetica neue bold 24
    int PAD_PH_PHT = 320;//80;
    int PAD_PH_HTM = 184;
    //landscape
    int PAD_LH_LBL = 30;
    int PAD_LH_PHT = 350;
    int PAD_LW_PHT = 450;
    
    
    if (IS_IPHONE || IS_IPHONE_5) {
        if (IS_PORTRAIT) {
            self.label.frame = CGRectMake(0, top,
                                          w, PH_LBL);
            
            self.photoView.frame = CGRectMake(0, top + PH_LBL,
                                              w, PH_PHT);
            
            self.htmlView.frame = CGRectMake(0, top + PH_LBL + PH_PHT,
                                             w, PH_HTM);

            self.subCtgView.frame = CGRectMake(0, top + PH_LBL + PH_PHT + PH_HTM,
                                               w, h - (top + PH_LBL + PH_PHT + PH_HTM));
        } else {
            self.label.frame = CGRectMake(LW_PHT, top,
                                          w - LW_PHT, LH_LBL);
            
            self.photoView.frame = CGRectMake(0, top,
                                              LW_PHT, LH_PHT);
            
            self.htmlView.frame = CGRectMake(0, top + LH_PHT,
                                             LW_PHT, h - (top + LH_PHT));
            
            self.subCtgView.frame = CGRectMake(LW_PHT, top + LH_LBL,
                                               w - LW_PHT, h - top + LH_LBL);
        }
    } else /* IF (IS_IPAD) */{
        if (IS_PORTRAIT) {
            self.label.frame = CGRectMake(0, top,
                                          w, PAD_PH_LBL);
            
            self.photoView.frame = CGRectMake(0, top + PAD_PH_LBL,
                                              w, PAD_PH_PHT);
            
            self.htmlView.frame = CGRectMake(0, top + PAD_PH_LBL + PAD_PH_PHT,
                                             w, PAD_PH_HTM);
            
            self.subCtgView.frame = CGRectMake(0, top + PAD_PH_LBL + PAD_PH_PHT + PAD_PH_HTM,
                                               w, h - (top + PAD_PH_LBL + PAD_PH_PHT + PAD_PH_HTM));
        } else {
            self.label.frame = CGRectMake(PAD_LW_PHT, top,
                                          w - PAD_LW_PHT, PAD_LH_LBL);
            
            self.photoView.frame = CGRectMake(0, top,
                                              PAD_LW_PHT, PAD_LH_PHT);
            
            self.htmlView.frame = CGRectMake(0, top + PAD_LH_PHT,
                                             PAD_LW_PHT, h - (top + PAD_LH_PHT));
            
            self.subCtgView.frame = CGRectMake(PAD_LW_PHT, top + PAD_LH_LBL,
                                               w - PAD_LW_PHT, h - top + PAD_LH_LBL);
       }
    }
    
//    [self loadAdsView];
    [self loadCategoryView];
//    [self loadMenuView];
}


- (void) loadCategoryView {
    if (self.subCtgView.subviews.count == 0)
    {
        self.subCtgsViewController = [[DPAnimatedScrollViewController alloc] initWithCategory:self.category.Id isLeaf:YES];
        
        [self addChildViewController:self.subCtgsViewController];
        [self.subCtgView addSubview:self.subCtgsViewController.view];
    }
    else
        [self.subCtgsViewController changeRows:1 columns:1];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setLabel:nil];
    [self setPhotoView:nil];
    [self setHtmlView:nil];
    [self setSubCtgView:nil];
    [super viewDidUnload];
}
@end
