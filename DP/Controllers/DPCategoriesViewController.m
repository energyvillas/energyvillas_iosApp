//
//  DPCategoriesViewController.m
//  DP
//
//  Created by Γεώργιος Γράβος on 4/6/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPCategoriesViewController.h"
#import "DPConstants.h"
#import "DPAppHelper.h"
#import "DPDataElement.h"
#import "DPBuyViewController.h"
#import "DPMainViewController.h"
#import "DPCategoryLoader.h"

@interface DPCategoriesViewController ()

@property (nonatomic) int category;
@property (strong, nonatomic) NSString *lang;
@property (strong, nonatomic) NSString *plistFile;
@property (strong, nonatomic) DPDataLoader *dataLoader;

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
             autoScroll:(BOOL)autoscroll {
    self = [super initWithContent:nil rows:rows columns:cols autoScroll:autoscroll];
    if (self) {
        self.viewDelegate = self;
        self.category = ctg;
        self.lang = lang;
        self.plistFile = resfile;
        
        self.dataLoader = [[DPCategoryLoader alloc] initWithController:self
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

#pragma mark

- (void) elementTapped:(id)element {
    DPDataElement *elm = element;
    DPBuyViewController *buyVC = [[DPBuyViewController alloc] initWithCategoryId:elm.Id];
    
    id del = self.navigationController.delegate;
    DPMainViewController *main = del;
    
    [main addChildViewController:buyVC];
    [main.view addSubview:buyVC.view];    
}

- (NSString *) calcImageName:(NSString *)baseName {
    @try {
        NSArray *parts = [baseName componentsSeparatedByString:@"."];
        if (parts && parts.count == 2) {
            NSString *orientation = IS_PORTRAIT ? @"v" : @"h";
            // pending also fix the format string below.... NSString *lang = [DPAppHelper sharedInstance].currentLang;
            NSString *result = [NSString stringWithFormat:@"FreeDetails/%@_%@.%@", parts[0], orientation, parts[1]];
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
