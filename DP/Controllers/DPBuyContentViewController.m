//
//  DPBuyContentViewController.m
//  DP
//
//  Created by Γεώργιος Γράβος on 4/10/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPBuyContentViewController.h"

#import "DPAppHelper.h"
#import "DPConstants.h"

#import "DPDataElement.h"
#import "Category.h"
#import "DPCategoryLoader.h"



@interface DPBuyContentViewController ()

@property (strong, nonatomic) DPDataLoader *dataLoader;

@end

@implementation DPBuyContentViewController {
    int category;

}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) initWithCategory:(int)ctgID {
    self = [super initWithContent:nil rows:0 columns:0 autoScroll:YES];
    
    if (self) {
        category = ctgID;
        self.scrollableViewDelegate = self;
    }
    
    return self;
}

//==============================================================================

- (void)viewDidLoad
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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//==============================================================================

- (void) reachabilityChanged {
    [super reachabilityChanged];
    if (self.contentList.count == 0 || self.dataLoader.dataRefreshNeeded)
        [self.dataLoader loadData];
}

- (void) loadData {
    if (category == -1) {
        NSArray *list = [NSArray arrayWithObject:[[Category alloc] initWithValues:@"-1"
                                                                            title:@"General"
                                                                         imageUrl:@"BuyGeneral/words_%.3d.jpg"]];
        [self contentLoaded:list];
        [self changeRows:1 columns:1];        
    }
    else {
        self.dataLoader = [[DPCategoryLoader alloc] initWithView:self.view
                                                     useInternet:NO //PENDING::GGSE
                                                      useCaching:NO
                                                        category:category
                                                            lang:[DPAppHelper sharedInstance].currentLang
                                                       localData:[[DPAppHelper sharedInstance]
                                                                  freeBuyContentFor:category
                                                                  lang:[DPAppHelper sharedInstance].currentLang]];
        self.dataLoader.delegate = self;
        [self.dataLoader loadData];
    }
}

//==============================================================================

#pragma mark - START DPDataLoaderDelegate

- (void)loadFinished:(DPDataLoader *)loader {
    if (loader.datalist.count == 0) {
//        showAlertMessage(nil,
//                         DPLocalizedString(kERR_TITLE_INFO),
//                         DPLocalizedString(kERR_MSG_NO_DATA_FOUND));
    } else {
        // keep only children of category
//        NSMutableArray *children = [[NSMutableArray alloc] init];
//        for (Category *ctg in loader.datalist)
//            if (ctg.parentId == category)
//                [children addObject:ctg];
//        
//        // and split in batches of 5
//        NSMutableArray *datalists = [[NSMutableArray alloc] init];
//        NSMutableArray *partDatalist = nil;
//        
//        for (int i = 0; i < children.count; i++) {
//            if ((i % 5) == 0) {
//                if (partDatalist)
//                    [datalists addObject:[NSArray arrayWithArray:partDatalist]];
//                partDatalist = [[NSMutableArray alloc] init];
//            }
//            
//            [partDatalist addObject:children[i]];
//        }
//        if (partDatalist)
//            [datalists addObject:[NSArray arrayWithArray:partDatalist]];
//        
//        [self contentLoaded:datalists];
//        [self changeRows:1 columns:1];
        
        [self contentLoaded:self.dataLoader.datalist];
        [self changeRows:1 columns:1];
    }
}

- (void)loadFailed:(DPDataLoader *)loader {
    
}

#pragma mark END DPDataLoaderDelegate

//==============================================================================

#pragma mark - START DPScrollableViewDelegate

- (void) elementTapped:(id)sender element:(id)element {
    
}

#pragma mark END DPScrollableViewDelegate

//==============================================================================

#pragma mark - START DPScrollableDataSourceDelegate

//- (void) onTap:(id)sender {
//    int indx = ((UIButton *)sender).tag;
//    DPDataElement * element = self.contentList[indx];
//    NSLog(@"Clicked image at index %i named %@", indx, element.title);
//    
//    [self elementTapped:sender element:element];
//    
//    // navigation logic goes here. create and push a new view controller;
//    //        DPTestViewController *vc = [[DPTestViewController alloc] init];
//    //        [self.navigationController pushViewController: vc animated: YES];
//    
//}

- (UILabel *) createLabelFor:(int)contentIndex frame:(CGRect)frame title:(NSString *)title {
    UIFont *font = IS_IPAD
            ? [UIFont fontWithName:@"HelveticaNeue-Bold" size:24]
            : [UIFont fontWithName:@"HelveticaNeue-Bold" size:18];

    UILabel *label = createLabel(frame, title, font);
    CGRect lblframe = label.frame;
    frame = CGRectMake(frame.origin.x, frame.origin.y,
                       frame.size.width, lblframe.size.height);
    label.frame = frame;
    return label;
}

- (void) postProcessView:(UIView *)aView
            contentIndex:(int)contentIndex
                   frame:(CGRect)frame {
    if (category == -1) {
        Category *ctg = self.contentList[0];
        UIImageView *imgView = (UIImageView *)aView;
        NSMutableArray *list = [[NSMutableArray alloc] initWithCapacity:121];
        for (int i = 1; i<=121; i++)
            [list addObject:[UIImage imageNamed:[NSString stringWithFormat:ctg.imageUrl, i]]];
            
        imgView.animationImages = list;
        imgView.animationDuration = 121 / 25.0;
        [imgView startAnimating];
    }
}

- (UIView *) createViewFor:(int)contentIndex frame:(CGRect)frame {
    DPDataElement *elm = self.contentList[contentIndex];
    UILabel *label = [self createLabelFor:contentIndex frame:frame title:elm.title];
    int fixBy = label.bounds.size.height + 8;
    frame = CGRectMake(frame.origin.x +2,
                       frame.origin.y + fixBy,
                       frame.size.width - 4,
                       frame.size.height - fixBy);

    UIImageView *imgView = [[UIImageView alloc] initWithFrame: frame];
    imgView.backgroundColor = [UIColor clearColor];
    imgView.contentMode = UIViewContentModeCenter; //ScaleAspectFit;//Center;//ScaleAspectFit;
    imgView.clipsToBounds = YES;
    
    // nothing to do when tapped 
//    imgView.tag = contentIndex;
//    UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc]
//                                      initWithTarget:self action:@selector(handleTap:)];
//    [imgView addGestureRecognizer:tapper];
//    imgView.userInteractionEnabled = YES;
    
    if (category == -1) {
        Category *ctg = self.contentList[0];
        //UIImageView *imgView = (UIImageView *)aView;
        NSMutableArray *list = [[NSMutableArray alloc] init];
        int cnt = 121;
        for (int i = 1; i <= cnt; i++) {
            UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:ctg.imageUrl, i]];
            if (img == nil) break;
            [list addObject: img];
        }
        
        if (list.count > 0) {
            imgView.animationImages = list;
            imgView.animationDuration = 121 / 25.0;
            [imgView startAnimating];
        }
    }
    
    return imgView;
}

#pragma mark END DPScrollableDataSourceDelegate

//==============================================================================

#pragma mark - START virtual overrides

- (NSString *) calcImageName:(NSString *)baseName {
    NSLog(@"buy content ::: '%@'", baseName);
    if ([self isLocalUrl:baseName]) {
        @try {
            NSArray *parts = [baseName componentsSeparatedByString:@"."];
            if (parts && parts.count == 2) {
//                NSString *orientation = IS_PORTRAIT ? @"v" : @"h";
//                NSString *high = ishighlight ? @"_Roll" : @"";
                NSString *lang = [DPAppHelper sharedInstance].currentLang;
                NSString *result = [NSString stringWithFormat:@"BuyDialogImages/%@_%@.%@",
                                    parts[0], lang, parts[1]];
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
    } else
        return baseName;
}

//- (void) loadImageAsync:(DPDataElement *)elm inView:(UIImageView *)imgView cacheImage:(BOOL)cacheimage {
//    [super loadImageAsync:elm inView:imgView cacheImage:YES];
//}

#pragma mark - END virtual overrides

@end

