//
//  DPCategoriesViewController.m
//  DP
//
//  Created by Γεώργιος Γράβος on 4/6/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "DPCategoriesViewController.h"
#import "DPConstants.h"
#import "DPAppHelper.h"
#import "DPDataElement.h"
#import "DPBuyViewController.h"
#import "DPMainViewController.h"
#import "DPCategoryLoader.h"
#import "DPRootViewController.h"

@interface DPCategoriesViewController ()

@property (nonatomic) int category;
@property (strong, nonatomic) NSString *lang;
@property (strong, nonatomic) NSString *plistFile;
@property (strong, nonatomic) DPDataLoader *dataLoader;

@property (weak, nonatomic) UIViewController *parentVC;

@end

@implementation DPCategoriesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) initWithCategory:(int)ctg
                   lang:(NSString *)lang
          localResource:(NSString *)resfile
                   rows:(int)rows
                columns:(int)cols
             autoScroll:(BOOL)autoscroll
                 parent:(UIViewController *)parentVC{
    self = [super initWithContent:nil rows:rows columns:cols autoScroll:autoscroll];
    if (self) {
        self.parentVC = parentVC;
        self.scrollableViewDelegate = self;
        self.category = ctg;
        self.lang = lang;
        self.plistFile = resfile;
        
        self.dataLoader = [[DPCategoryLoader alloc] initWithView:self.view
                                                      useCaching:YES
                                                        category:self.category
                                                            lang:self.lang
                                                   localResource:self.plistFile];
        self.dataLoader.delegate = self;
        [self.dataLoader loadData];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark dataloaderdelegate methods

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

#pragma mark - DPScrollableViewDelegate

- (void) elementTapped:(id)sender element:(id)element {
    DPDataElement *elm = element;
//    DPBuyViewController *buyVC = [[DPBuyViewController alloc] initWithCategoryId:elm.Id];
//    
//    id del = self.navigationController.delegate;
//    DPMainViewController *main = del;
//    
//    [main addChildViewController:buyVC];
//    [main.view addSubview:buyVC.view];
    
    id pvc = self.parentVC;
    if (pvc && [pvc conformsToProtocol:@protocol(DPBuyAppProtocol)])
        [pvc showBuyDialog:elm.Id];
}

#pragma mark overrides

//- (NSString *) resolveImageName:(DPDataElement *)elm {
//    return [self calcImageName: elm.imageUrl];
//}

- (NSString *) resolveHighlightImageName:(DPDataElement *)elm  {
    return [self calcImageName:elm.imageUrl isHighlight:YES];
}

- (NSString *) calcImageName:(NSString *)baseName {
    return [self calcImageName:baseName isHighlight:NO];
}
- (NSString *) calcImageName:(NSString *)baseName isHighlight:(BOOL)ishighlight {
    @try {
        NSArray *parts = [baseName componentsSeparatedByString:@"."];
        if (parts && parts.count == 2) {
            NSString *orientation = IS_PORTRAIT ? @"v" : @"h";
            NSString *high = ishighlight ? @"_Roll" : @"";
            //PENDING also fix the format string below.... NSString *lang = [DPAppHelper sharedInstance].currentLang;
            NSString *result = [NSString stringWithFormat:@"FreeImages/%@%@_%@.%@",
                                parts[0], high, orientation, parts[1]];
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


@end
