//
//  DPArticleViewController.m
//  energyVillas
//
//  Created by Γεώργιος Γράβος on 5/22/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPArticleViewController.h"
#import "DPAppHelper.h"
#import "DPConstants.h"

#import "Article.h"
#import "DPArticlesLoader.h"


@interface DPArticleViewController ()

@property (strong, nonatomic) DPArticlesLoader *dataLoader;

@end



@implementation DPArticleViewController {
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
    self = [super initWithContent:nil
                             rows:0
                          columns:0
                       autoScroll:YES
                        showPages:NO
                  scrollDirection:DPScrollDirectionHorizontal
                      initialPage:0];
    
    if (self) {
        category = ctgID;
        self.scrollableViewDelegate = self;
        self.dataDelegate = self;
    }
    
    return self;
}

//==============================================================================

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(void)viewDidUnload {
    [super viewDidUnload];
   
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadData];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
        
    [self clearDataLoader];
}

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

//==============================================================================

- (void) reachabilityChanged {
    [super reachabilityChanged];
    [self loadData];
}

- (void) loadData {
    if (self.dataLoader == nil) {
        self.dataLoader = [[DPArticlesLoader alloc] initWithView:self.view
                                                        category:category
                                                            lang:CURRENT_LANG];
        self.dataLoader.delegate = self;
    }
    
    if (self.contentList.count == 0 || self.dataLoader.dataRefreshNeeded)
        [self.dataLoader loadData];
}

//==============================================================================

#pragma mark - START DPDataLoaderDelegate

- (void)loadFinished:(DPDataLoader *)loader {
    if (loader.datalist == nil || loader.datalist.count == 0) {
        //pending no data found!.....//[self loadLocalData];
    } else {
        [self contentLoaded:self.dataLoader.datalist];
        [self changeRows:1 columns:1];
    }
}

- (void)loadFailed:(DPDataLoader *)loader {
    // pending alert user....
}

#pragma mark END DPDataLoaderDelegate

//==============================================================================

#pragma mark - START DPScrollableViewDelegate

- (void) elementTapped:(id)sender element:(id)element {
    
}

#pragma mark END DPScrollableViewDelegate

//==============================================================================

#pragma mark - START DPScrollableDataSourceDelegate

- (UILabel *) createLabelFor:(int)contentIndex frame:(CGRect)frame title:(NSString *)title {
    return nil;

//    if (title == nil || title.length==0)
//        return nil;
//    
//    UIFont *font = IS_IPAD
//    ? [UIFont fontWithName:@"HelveticaNeue-Bold" size:24]
//    : [UIFont fontWithName:@"HelveticaNeue-Bold" size:18];
//    
//    UILabel *label = createLabel(frame, title, font);
//    CGRect lblframe = label.frame;
//    frame = CGRectMake(frame.origin.x, frame.origin.y + 6,
//                       frame.size.width, lblframe.size.height);
//    label.frame = frame;
//    return label;
}

-(void) postProcessView:(UIView *)aView contentIndex:(int)contentIndex frame:(CGRect)frame {
    if ([aView isKindOfClass:[UIImageView class]])
        ((UIImageView *)aView).contentMode = UIViewContentModeScaleAspectFit;
}

////pending
//- (UIView *) createViewFor:(int)contentIndex frame:(CGRect)frame {
//    Article *article = self.contentList[contentIndex];
//    UILabel *label = [self createLabelFor:contentIndex frame:frame title:article.title];
//    int fixBy = 0;
//    
//    if (label !=nil) {
//        if (IS_IPHONE) {
//            if (IS_RETINA)
//                fixBy = 8;
//            else
//                fixBy = 8;
//        } else if (IS_IPHONE_5)
//            fixBy = 8;
//        else if (IS_IPAD)
//            fixBy = 8;
//    }
//    frame = CGRectInset(CGRectOffset(frame, 0, fixBy), 2, 0);
//    
//    UIView *result = nil;
////    if (article.videoUrl) {
////        result = [self createAndConfigMoviePlayer:frame videoUrl:[self calcImageName:article.videoUrl]];
////        //        result = [self playVideo:article.videoUrl frame:frame];
////    } else {
//        UIImageView *imgView = [[UIImageView alloc] initWithFrame: frame];
//        imgView.backgroundColor = [UIColor clearColor];
//        imgView.contentMode = UIViewContentModeScaleAspectFit;//Center;//ScaleAspectFit;
//        imgView.clipsToBounds = YES;
//        result = imgView;
////    }
//    
//    return result;
//}

#pragma mark END DPScrollableDataSourceDelegate

//==============================================================================


@end
