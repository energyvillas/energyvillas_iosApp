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

#import "DPArticlesViewController.h"

// 1st level
#define DURATION_MOVE_1st_Level ((NSTimeInterval)10.0)
#define DURATION_ZOOM_1st_Level ((NSTimeInterval)0.35)

#define IPHONE_CARD_RESIZE_WIDTH_1st_Level ((int)15)
#define IPHONE_CARD_RESIZE_HEIGHT_1st_Level ((int)15)
#define IPAD_CARD_RESIZE_WIDTH_1st_Level ((int)30)
#define IPAD_CARD_RESIZE_HEIGHT_1st_Level ((int)30)

#define IPHONE_CARD_WIDTH_1st_Level ((int)95)
#define IPHONE_CARD_HEIGHT_1st_Level ((int)95)
#define IPAD_CARD_WIDTH_1st_Level ((int)180)
#define IPAD_CARD_HEIGHT_1st_Level ((int)180)

// 2nd level
#define DURATION_MOVE_2nd_Level ((NSTimeInterval)10.0)
#define DURATION_ZOOM_2nd_Level ((NSTimeInterval)0.35)

#define IPHONE_CARD_RESIZE_WIDTH_2nd_Level ((int)15)
#define IPHONE_CARD_RESIZE_HEIGHT_2nd_Level ((int)15)
#define IPAD_CARD_RESIZE_WIDTH_2nd_Level ((int)30)
#define IPAD_CARD_RESIZE_HEIGHT_2nd_Level ((int)30)

#define IPHONE_CARD_WIDTH_2nd_Level ((int)70)
#define IPHONE_CARD_HEIGHT_2nd_Level ((int)70)
#define IPAD_CARD_WIDTH_2nd_Level ((int)150)
#define IPAD_CARD_HEIGHT_2nd_Level ((int)150)



@interface DPAnimatedScrollViewController ()

//@property (strong, nonatomic) DPSubCategoryViewController *subctgViewController;
@property (strong, nonatomic) DPDataLoader *dataLoader;

@end


@implementation DPAnimatedScrollViewController {
    bool isPortrait;
    BOOL isLeafCategory;
    CGRect initframe;
}

@synthesize category = _category;


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
        _category = ctgID;
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

#pragma mark - scrollableview delegate methods

- (void) elementTapped:(id)sender element:(id)element {
    Category *elm = element;
    
    if (!isLeafCategory) {
        DPSubCategoryViewController *ctrlr = [[DPSubCategoryViewController alloc] initWithCategory:elm];
        
        [self.navigationController pushViewController:ctrlr animated:YES];
    } else {
        DPArticlesViewController *avc = [[DPArticlesViewController alloc] initWithCategory:elm.Id];
        [self.navigationController pushViewController:avc animated:YES];
    }
}

#pragma mark - scrollabledatasource methods

- (void) loadPage:(int)contentIndex inView:(UIView *)container frame:(CGRect)frm {
    if (!self.contentList || self.contentList.count == 0) return;
    
    //CGRect frm = CGRectMake(0, 0, size.width, size.height);
    if (CGRectIsEmpty(frm)) return;
    
    CGSize sz, szInset;
    if (!isLeafCategory) {
        sz = IS_IPAD
                ? CGSizeMake(IPAD_CARD_WIDTH_1st_Level, IPAD_CARD_HEIGHT_1st_Level)
                : CGSizeMake(IPHONE_CARD_WIDTH_1st_Level, IPHONE_CARD_HEIGHT_1st_Level);
        
        szInset = IS_IPAD
                ? CGSizeMake(IPAD_CARD_RESIZE_WIDTH_1st_Level, IPAD_CARD_RESIZE_HEIGHT_1st_Level)
                : CGSizeMake(IPHONE_CARD_RESIZE_WIDTH_1st_Level, IPHONE_CARD_RESIZE_HEIGHT_1st_Level);
    } else {
        sz = IS_IPAD
                ? CGSizeMake(IPAD_CARD_WIDTH_2nd_Level, IPAD_CARD_HEIGHT_2nd_Level)
                : CGSizeMake(IPHONE_CARD_WIDTH_2nd_Level, IPHONE_CARD_HEIGHT_2nd_Level);
        szInset = IS_IPAD
                ? CGSizeMake(IPAD_CARD_RESIZE_WIDTH_2nd_Level, IPAD_CARD_RESIZE_HEIGHT_2nd_Level)
                : CGSizeMake(IPHONE_CARD_RESIZE_WIDTH_2nd_Level, IPHONE_CARD_RESIZE_HEIGHT_2nd_Level);
    }

    DPAnimatedCardsView *acv = [[DPAnimatedCardsView alloc] initWithFrame:frm
                                                               categories:self.contentList[contentIndex]
                                                                 cardSize:sz
                                                            cardInsetSize:szInset
                                                             moveDuration:isLeafCategory ? DURATION_MOVE_2nd_Level : DURATION_MOVE_1st_Level
                                                             zoomDuration:isLeafCategory ? DURATION_ZOOM_2nd_Level : DURATION_ZOOM_1st_Level
                                                                    level:isLeafCategory ? 1 : 0];
    acv.scrollableViewDelegate = self;
    [container addSubview:acv];
}

//- (void) scrollViewDidScroll:(UIScrollView *)sender {
//    [super scrollViewDidScroll:sender];
//    
//}

#pragma mark - data loading methods

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

- (BOOL) overlapPageControl {
    return IS_LANDSCAPE && (!IS_IPAD);
}

- (void) loadData {
    if (self.dataLoader == nil) {
        self.dataLoader = [[DPCategoryLoader alloc] initWithView:self.view
                                                     useInternet:YES
                                                      useCaching:YES
                                                        category:_category
                                                            lang:[DPAppHelper sharedInstance].currentLang
                                                   useDeviceType:!isLeafCategory
                                                       localData:nil];
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

- (NSString *) calcLeafImageName:(NSString *)baseName
                       highlight:(BOOL)highlight
                    translatable:(BOOL)isPerLang{
    @try {
        NSArray *parts = [baseName componentsSeparatedByString:@"."];
        if (parts && parts.count == 2) {
            NSString *roll = highlight ? @"_roll" : @"";
            NSString *lang = isPerLang ? [NSString stringWithFormat:@"_%@", CURRENT_LANG] : @"";
            NSString *result = [NSString stringWithFormat:@"HouseInfo/HIKIcons/level-2_icons%@_%@%@.%@",
                                roll, parts[0], lang, parts[1]];
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



- (void)loadFinished:(DPDataLoader *)loader {
    if (loader.datalist.count == 0)
        showAlertMessage(nil,
                         DPLocalizedString(kERR_TITLE_INFO),
                         DPLocalizedString(kERR_MSG_NO_DATA_FOUND));
    else {
        // keep only children of category
        NSMutableArray *children = [[NSMutableArray alloc] init];
        
        NSDictionary *hikdict = nil;
        if (isLeafCategory) {
            NSString *path = [[NSBundle mainBundle] bundlePath];
            NSString *finalPath = [path stringByAppendingPathComponent:@"HIK_ImageNames.plist"];
            hikdict = [NSDictionary dictionaryWithContentsOfFile:finalPath];
        }
        
        for (Category *ctg in loader.datalist)
            if (ctg.parentId == _category) {
                if (isLeafCategory && (ctg.hikId != HIKID_CUSTOM)) {
                    NSString *imgbase = [hikdict valueForKey:[NSString stringWithFormat:@"%d", ctg.hikId]];
                    BOOL isPerLang = ctg.hikId != HIKID_COMING_SOON_COMMON && ctg.hikId != HIKID_COMING_SOON_ART && ctg.hikId != HIKID_COMING_SOON_DESIGNER;
                    ctg.imageUrl = [self calcLeafImageName:imgbase highlight:NO translatable:isPerLang];
                    ctg.imageRollUrl = [self calcLeafImageName:imgbase highlight:YES translatable:isPerLang];
                }
                
                [children addObject:ctg];
            }

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
