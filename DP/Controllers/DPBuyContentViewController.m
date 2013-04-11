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
//    NSArray *content = [[DPAppHelper sharedInstance] freeDetailsFor:[DPAppHelper sharedInstance].currentLang];

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

- (UILabel *) createLabel:(CGRect)frame title:(NSString *)title {
    UIFont *font = IS_IPAD
            ? [UIFont fontWithName:@"HelveticaNeue-Bold" size:24]
            : [UIFont fontWithName:@"HelveticaNeue-Bold" size:18];

    UILabel *label = createLabel(frame, title, font);
    label.frame = CGRectOffset(label.frame, 0, -label.frame.origin.y);
    return label;
}

- (UIView *) createViewFor:(int)contentIndex frame:(CGRect)frame {
    DPDataElement *elm = self.contentList[contentIndex];
    UILabel *label = [self createLabel:frame title:elm.title];
    int fixBy = label.bounds.size.height + 8;
    frame = CGRectMake(frame.origin.x,
                       frame.origin.y + fixBy,
                       frame.size.width,
                       frame.size.height - fixBy);

    UIImageView *imgView = [[UIImageView alloc] initWithFrame: frame];
    imgView.backgroundColor = [UIColor clearColor];
    imgView.contentMode = UIViewContentModeCenter; //ScaleAspectFit;//Center;//ScaleAspectFit;
    
    imgView.tag = contentIndex;
    UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc]
                                      initWithTarget:self action:@selector(handleTap:)];
    [imgView addGestureRecognizer:tapper];
    imgView.userInteractionEnabled = YES;
    
    return imgView;
}
//- (void) loadPage:(int)contentIndex
//           inView:(UIView *)container
//            frame:(CGRect)frame {
//    @try {
//        Category *ctg = self.contentList[contentIndex];
//        id v;
//        if (ctg.imageUrl) {
//            UIImageView *iv = [[UIImageView alloc] initWithFrame:frame];
//            iv.backgroundColor = [UIColor clearColor];
//            iv.contentMode = UIViewContentModeCenter; //ScaleAspectFit;//Center;//ScaleAspectFit;
//
//            if ([self isLocalUrl:ctg.imageUrl]) {
//                NSString *imgname =[self resolveImageName:ctg];
//                iv.image = [UIImage imageNamed:imgname];
//                
//                NSString *imghighname =[self resolveHighlightImageName:ctg];
//                if (imghighname)
//                    iv.highlightedImage = [UIImage imageNamed:imghighname];
//            }
////            else
////                [self loadImageAsync:ctg inView:iv];
//
//        }
//            
//            
//    }
//    @catch (NSException *exception) {
//       // UIView *v =
//    }
//   // [container addSubview:v];
//}

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

- (void) loadImageAsync:(DPDataElement *)elm inView:(UIImageView *)imgView cacheImage:(BOOL)cacheimage {
    [super loadImageAsync:elm inView:imgView cacheImage:YES];
}

#pragma mark - END virtual overrides

@end

