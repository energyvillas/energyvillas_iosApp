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
        self.dataDelegate = self;
        self.category = ctg;
        self.lang = lang;
        self.plistFile = resfile;
        
        self.dataLoader = [[DPCategoryLoader alloc] initWithView:self.view
                                                     useInternet:NO
                                                      useCaching:NO
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

-(void) dealloc {
    if (self.dataLoader) {
        self.dataLoader.delegate = nil;
    }
    self.dataLoader = nil;
    self.dataDelegate = nil;
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
    
//    [UIView animateWithDuration:12.5
//                          delay:0.0
//                        options:UIViewAnimationCurveLinear | UIViewAnimationOptionBeginFromCurrentState
//                     animations:^{
//                         [sender setHighlighted:YES];
//                     }
//                     completion:^(BOOL finished){
//                         if (!finished)
//                             return;
//                         
//                         dispatch_async(dispatch_get_main_queue(), ^{
//                             id pvc = self.parentVC;
//                             if (pvc && [pvc conformsToProtocol:@protocol(DPBuyAppProtocol)])
//                                 [pvc showBuyDialog:elm.Id];
//                         });
//                     }];
    
    id pvc = self.parentVC;
    if (pvc && [pvc conformsToProtocol:@protocol(DPBuyAppProtocol)])
        [pvc showBuyDialog:elm.Id];
}

#pragma mark - DPScrollableDataSourceDelegate

- (void) onTap:(id)sender {
        int indx = ((UIButton *)sender).tag;
        DPDataElement * element = self.contentList[indx];
        NSLog(@"Clicked image at index %i named %@", indx, element.title);
        
        [self elementTapped:sender element:element];
        
        // navigation logic goes here. create and push a new view controller;
        //        DPTestViewController *vc = [[DPTestViewController alloc] init];
        //        [self.navigationController pushViewController: vc animated: YES];

}
/**/
 - (UILabel *) createLabelFor:(int)contentIndex
                        frame:(CGRect)frame
                        title:(NSString *)title {
     UIFont *fnt = nil;
     if (IS_IPAD)
         fnt = [UIFont fontWithName:@"TrebuchetMS-Bold"/*HelveticaNeue-CondensedBold"*/ size:16];
     else  if (IS_IPHONE)
         fnt = [UIFont fontWithName:@"TrebuchetMS-Bold"/*HelveticaNeue-CondensedBold"*/ size:9];
     else
         fnt = [UIFont fontWithName:@"TrebuchetMS-Bold"/*HelveticaNeue-CondensedBold"*/ size:11];
     UILabel *label = createLabel(frame, title, fnt);
     label.frame = CGRectOffset(label.frame, 0, -2);
     return label;
}
/**/
/**/

- (UIView *) createViewFor:(int)contentIndex
                     frame:(CGRect)frame {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.showsTouchWhenHighlighted = YES;
    [button addTarget:self action:@selector(onTap:) forControlEvents:UIControlEventTouchUpInside];
    
    DPDataElement *element = self.contentList[contentIndex];
    
    NSString *imgname =[self resolveImageName:element];
    UIImage *img = [UIImage imageNamed:imgname];
    CGSize imgsize = img.size;
    button.frame = CGRectMake((frame.size.width - imgsize.width) / 2.0,
                              (frame.size.height - imgsize.height) / 2.0,
                              imgsize.width, imgsize.height);
    [button setImage:img forState:UIControlStateNormal];
    
    NSString *imghighname =[self resolveHighlightImageName:element];
    if (imghighname) {
        img = [UIImage imageNamed:imghighname];
        [button setImage:img forState:UIControlStateHighlighted];
    }
    
    [button setTag: contentIndex];
    
    return button;
}

//- (void) postProcessView:(UIView *)aView
//            contentIndex:(int)contentIndex
//                   frame:(CGRect)frame {
//    
//}

- (void) postProcessLabel:(UILabel *)aLabel
             contentIndex:(int)contentIndex
                    frame:(CGRect)frame {
    int ofs = 0;
    if (IS_IPAD) {
        ofs = IS_PORTRAIT ? -20 : -10;
    } else if (IS_IPHONE) {
        ofs = IS_PORTRAIT ? -5 : -2;
    } else if (IS_IPHONE_5) {
        ofs = IS_PORTRAIT ? -5 : -4;
    }
    aLabel.frame = CGRectOffset(aLabel.frame, 0, ofs);
}


//-(void) loadPage:(int)contentIndex inView:(UIView *)container frame:(CGRect)frame {
//    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//    button.showsTouchWhenHighlighted = YES;
//    [button addTarget:self action:@selector(onTap:) forControlEvents:UIControlEventTouchUpInside];
//    
//    DPDataElement *element = self.contentList[contentIndex];
//    
//    NSString *imgname =[self resolveImageName:element];
//    UIImage *img = [UIImage imageNamed:imgname];
//    CGSize imgsize = img.size;
//    button.frame = CGRectMake((frame.size.width - imgsize.width) / 2.0,
//                              (frame.size.height - imgsize.height) / 2.0,
//                              imgsize.width, imgsize.height);
//    [button setImage:img forState:UIControlStateNormal];
//    
//    NSString *imghighname =[self resolveHighlightImageName:element];
//    if (imghighname) {
//        img = [UIImage imageNamed:imghighname];
//        [button setImage:img forState:UIControlStateHighlighted];
//    }
//    
//    [button setTag: contentIndex];
//
//    UILabel *label = createLabel(frame, element.title, nil);
//    int ofs = 0; 
//    if (IS_IPAD) {
//        ofs = IS_PORTRAIT ? -20 : -10;
//    } else if (IS_IPHONE) {
//        ofs = IS_PORTRAIT ? -5 : -2;
//    } else if (IS_IPHONE_5) {
//        ofs = IS_PORTRAIT ? -5 : -4;
//    }
//    label.frame = CGRectOffset(label.frame, 0, ofs);
//
//    [container addSubview: button];
//    [container addSubview: label];
//}
/**/
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
        NSLog(@"CategoriesVC - calcImageName - baseName='%@'", baseName);
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
