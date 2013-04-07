//
//  DPAnimatedScrollViewController.m
//  DP
//
//  Created by Γεώργιος Γράβος on 4/7/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPAnimatedScrollViewController.h"
#import "DPAnimatedCategoriesView.h"

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
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) initWithCategory:(int)ctgID  isLeaf:(BOOL)isLeaf{
    self = [super initWithContent:nil autoScroll:NO];
    
    if (self) {
        category = ctgID;
        isLeafCategory = isLeaf;
        self.scrollableViewDelegate = self;
        self.rowCount = 0;
        self.colCount = 0;
    }
    
    return self;
}

#pragma mark -
#pragma mark scrollableview delegate methods

- (void) elementTapped:(id)element {
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

- (void) loadPage:(int)contentIndex inView:(UIView *)container frameSize:(CGSize)size {
    if (!self.contentList || self.contentList.count == 0) return;
    
    CGRect frm = CGRectMake(0, 0, size.width, size.height);
    if (CGRectIsEmpty(frm)) return;
    
    DPAnimatedCategoriesView *acv = [[DPAnimatedCategoriesView alloc]
                                     initWithFrame:frm
                                     categories:self.contentList[contentIndex]];
    acv.scrollableViewDelegate = self;
    [container addSubview:acv];
}

#pragma mark -
#pragma mark data loading methods

- (void) reachabilityChanged {
    [super reachabilityChanged];
    if (self.contentList.count == 0 || self.dataLoader.dataRefreshNeeded)
        [self.dataLoader loadData];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadData];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void) loadData {
    self.dataLoader = [[DPCategoryLoader alloc] initWithView:self.view
                                                    category:category
                                                        lang:[DPAppHelper sharedInstance].currentLang
                                               localResource:nil];
    self.dataLoader.delegate = self;
    [self.dataLoader loadData];
}

#pragma mark -
#pragma mark dataloaderdelegate methods

- (void)loadFinished:(DPDataLoader *)loader {
    if (loader.datalist.count == 0)
        showAlertMessage(nil, kERR_TITLE_INFO, kERR_MSG_NO_DATA_FOUND);
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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
