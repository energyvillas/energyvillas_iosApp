//
//  DPAnimatedScrollViewController.m
//  DP
//
//  Created by Γεώργιος Γράβος on 4/7/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPAnimatedScrollViewController.h"
#import "DPAnimatedCardsView.h"

#import "DPSubCategoryViewController.h"

#import "DPDataElement.h"
#import "Category.h"
#import "DPCategoryLoader.h"

#import "DPAppHelper.h"
#import "DPConstants.h"

@interface DPAnimatedScrollViewController ()

//@property (strong, nonatomic) DPSubCategoryViewController *subctgViewController;
@property (strong, nonatomic) DPDataLoader *dataLoader;

@end


@implementation DPAnimatedScrollViewController {
    bool isPortrait;
    int category;
    BOOL isLeafCategory;
    CGRect initframe;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) initWithCategory:(int)ctgID  isLeaf:(BOOL)isLeaf frame:(CGRect)frame {
    self = [super initWithContent:nil autoScroll:NO];
    
    if (self) {
        category = ctgID;
        isLeafCategory = isLeaf;
        //self.view.frame = frame;
        initframe = frame;
        self.scrollableViewDelegate = self;
        self.rowCount = 0;
        self.colCount = 0;
        //[self loadData];
    }
    
    return self;
}

#pragma mark -
#pragma mark scrollableview delegate methods

- (void) elementTapped:(id)sender element:(id)element {
    if (!isLeafCategory) {
        Category *elm = element;
        DPSubCategoryViewController *ctrlr = [[DPSubCategoryViewController alloc] initWithCategory:elm];
        
        [self.navigationController pushViewController:ctrlr animated:YES];
    }
}

//- (NSString *) calcImageName:(NSString *)baseName {
//    @try {
//        NSArray *parts = [baseName componentsSeparatedByString:@"."];
//        if (parts && parts.count == 2) {
//            NSString *orientation = IS_PORTRAIT ? @"h" : @"h";  //PENDING
//            // pending also fix the format string below.... NSString *lang = [DPAppHelper sharedInstance].currentLang;
//            NSString *result = [NSString stringWithFormat:/*PENDING*/@"FreeDetails/%@_%@.%@", parts[0], orientation, parts[1]];
//            return result;
//        }
//        else
//            return baseName;
//    }
//    @catch (NSException* exception) {
//        NSLog(@"Uncaught exception: %@", exception.description);
//        NSLog(@"Stack trace: %@", [exception callStackSymbols]);
//        return baseName;
//    }
//}
//


#pragma mark -
#pragma mark scrollabledatasource methods

- (void) loadPage:(int)contentIndex inView:(UIView *)container frame:(CGRect)frm {
    if (!self.contentList || self.contentList.count == 0) return;
    
    //CGRect frm = CGRectMake(0, 0, size.width, size.height);
    if (CGRectIsEmpty(frm)) return;
    
    DPAnimatedCardsView *acv = [[DPAnimatedCardsView alloc]
                                     initWithFrame:frm
                                     categories:self.contentList[contentIndex]];
    acv.scrollableViewDelegate = self;
    [container addSubview:acv];
}

#pragma mark -
#pragma mark data loading methods

- (void) reachabilityChanged {
    [super reachabilityChanged];
    [self loadData];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.frame = initframe;
    [self loadData];
}

-(void)viewDidUnload {
    [self clearDataLoader];
    [super viewDidUnload];
}
- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void) changeFrame:(CGRect)newFrame {
    self.view.frame = newFrame;
    [super changeRows:self.rowCount
              columns:self.colCount
      scrollDirection:self.scrollDirection];
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [super changeRows:self.rowCount
              columns:self.colCount
      scrollDirection:self.scrollDirection];
}

-(NSArray *) generateLocalData {
    NSMutableArray *list = [[NSMutableArray alloc] init];
    [list addObject:[[Category alloc] initWithValues:@"10001" lang:CURRENT_LANG title:nil imageUrl:@"balloon.png" parent:@"52"]];
    [list addObject:[[Category alloc] initWithValues:@"10002" lang:CURRENT_LANG title:nil imageUrl:@"balloon_01.png" parent:@"52"]];
    [list addObject:[[Category alloc] initWithValues:@"10003" lang:CURRENT_LANG title:nil imageUrl:@"balloon_02.png" parent:@"52"]];
    [list addObject:[[Category alloc] initWithValues:@"10004" lang:CURRENT_LANG title:nil imageUrl:@"balloon_01.png" parent:@"52"]];
    [list addObject:[[Category alloc] initWithValues:@"10005" lang:CURRENT_LANG title:nil imageUrl:@"balloon_02.png" parent:@"52"]];
    
    return list;
}
- (void) loadData {
    if (self.dataLoader == nil) {
        self.dataLoader = [[DPCategoryLoader alloc] initWithView:self.view
                                                     useInternet:NO//!isLeafCategory
                                                      useCaching:YES
                                                        category:category
                                                            lang:[DPAppHelper sharedInstance].currentLang
                                                   localData:[self generateLocalData]];
        self.dataLoader.delegate = self;
    }
    if (self.contentList.count == 0 || self.dataLoader.dataRefreshNeeded)
        [self.dataLoader loadData];
}

- (DPAnimatedCardsView *) findAnimCtgView {
    DPAnimatedCardsView *result = nil;
    int pg = self.pageControl.currentPage;
    if (pg>=0){
        UIView *container = self.scrollView.subviews[pg];
        if (container.subviews.count == 1 &&
            [container.subviews[0] isKindOfClass:[DPAnimatedCardsView class]]) {
            result = container.subviews[0];
        }
    }
    
    return result;
}

- (void) changeRows:(int)rows
            columns:(int)columns
    scrollDirection:(DPScrollDirection)scrolldir {
    [super changeRows:rows columns:columns scrollDirection:scrolldir];
    
    DPAnimatedCardsView *acv = [self findAnimCtgView];
    if (acv)
        [acv frameChanged];
}

#pragma mark -
#pragma mark dataloaderdelegate methods

- (void)loadFinished:(DPDataLoader *)loader {
    if (loader.datalist.count == 0)
        showAlertMessage(nil,
                         DPLocalizedString(kERR_TITLE_INFO),
                         DPLocalizedString(kERR_MSG_NO_DATA_FOUND));
    else {
        // keep only children of category
        NSMutableArray *children = [[NSMutableArray alloc] init];
        for (Category *ctg in loader.datalist)
            if (ctg.parentId == category)
                [children addObject:ctg];

        // and split in batches of 5
        NSMutableArray *datalists = [[NSMutableArray alloc] init];
        NSMutableArray *partDatalist = nil;

        for (int i = 0; i < children.count; i++) {
            if ((i % 5) == 0) {
                if (partDatalist)
                    [datalists addObject:[NSArray arrayWithArray:partDatalist]];
                partDatalist = [[NSMutableArray alloc] init];
            }
            
            [partDatalist addObject:children[i]];
        }
        if (partDatalist)
            [datalists addObject:[NSArray arrayWithArray:partDatalist]];
        
        [self contentLoaded:datalists];
        [self changeRows:1 columns:1];
    }
}


//- (void) contentLoaded:(NSArray *)content {
//    [super contentLoaded:content];
//}

- (void)loadFailed:(DPDataLoader *)loader {
    showAlertMessage(nil,
                     DPLocalizedString(kERR_TITLE_URL_NOT_FOUND),
                     DPLocalizedString(kERR_MSG_DATA_LOAD_FAILED));
}

#pragma mark

-(void) clearDataLoader {
    if (self.dataLoader) {
        self.dataLoader.delegate = nil;
    }
    self.dataLoader = nil;
}

-(void) dealloc {
    [self clearDataLoader];
    self.dataDelegate = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
