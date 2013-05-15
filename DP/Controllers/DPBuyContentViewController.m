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
#import "Article.h"
#import "DPArticlesLoader.h"

#import <MediaPlayer/MediaPlayer.h>



@interface DPBuyContentViewController ()

@property (strong, nonatomic) DPDataLoader *dataLoader;
@property (strong, nonatomic) MPMoviePlayerController *playerController;
@property (strong, nonatomic) YTVimeoExtractor *extractor;
@property (strong, nonatomic) UIView *videoContainerView;
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
    self = [super initWithContent:nil autoScroll:YES showPages:NO scrollDirection:DPScrollDirectionHorizontal];
    
    if (self) {
        category = ctgID;
        self.scrollableViewDelegate = self;
        self.dataDelegate = self;
        self.rowCount = 0;
        self.colCount = 0;
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
    
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadData];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    if (self.playerController) {
        MPMoviePlayerController *mpc = self.playerController;
        self.playerController = nil;
        [mpc stop];
        [mpc.view removeFromSuperview];
        mpc = nil;
    }
    
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
        [self loadLocalData];        
    } else {        
        [self contentLoaded:self.dataLoader.datalist];
        [self changeRows:1 columns:1];
    }
}

- (void)loadFailed:(DPDataLoader *)loader {
    [self loadLocalData];
}

-(void) loadLocalData {
    showAlertMessage(nil, @"Info", @"No data found!");
    return;
    
    NSArray *list = [[DPAppHelper sharedInstance]
                     freeBuyContentFor:category
                     lang:[DPAppHelper sharedInstance].currentLang];
    
    [self contentLoaded:list];
    [self changeRows:1 columns:1];
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
    if (title == nil || title.length==0)
        return nil;
    
    UIFont *font = IS_IPAD
            ? [UIFont fontWithName:@"HelveticaNeue-Bold" size:24]
            : [UIFont fontWithName:@"HelveticaNeue-Bold" size:18];

    UILabel *label = createLabel(frame, title, font);
    CGRect lblframe = label.frame;
    frame = CGRectMake(frame.origin.x, frame.origin.y + 6,
                       frame.size.width, lblframe.size.height);
    label.frame = frame;
    return label;
}

//pending
- (UIView *) createViewFor:(int)contentIndex frame:(CGRect)frame {
    Article *article = self.contentList[contentIndex];
    UILabel *label = [self createLabelFor:contentIndex frame:frame title:article.title];
    int fixBy = 0;
//    if (label !=nil) {
//        if (IS_IPHONE) {
//            if (IS_RETINA)
//                fixBy = label.bounds.size.height - 10;
//            else
//                fixBy = label.bounds.size.height + 2;
//        } else if (IS_IPHONE_5)
//            fixBy = label.bounds.size.height;
//        else if (IS_IPAD)
//            fixBy = label.bounds.size.height - 10;
//    }
//    frame = CGRectInset(CGRectOffset(frame, 0, fixBy), 2, 2);
    
    if (label !=nil) {
        if (IS_IPHONE) {
            if (IS_RETINA)
                fixBy = 8;
            else
                fixBy = 8;
        } else if (IS_IPHONE_5)
            fixBy = 8;
        else if (IS_IPAD)
            fixBy = 8;
    }
    frame = CGRectInset(CGRectOffset(frame, 0, fixBy), 2, 0);

    UIView *result = nil;
    if (article.videoUrl) {
        result = [self createAndConfigMoviePlayer:frame videoUrl:[self calcImageName:article.videoUrl]];
//        result = [self playVideo:article.videoUrl frame:frame];
    } else {
        UIImageView *imgView = [[UIImageView alloc] initWithFrame: frame];
        imgView.backgroundColor = [UIColor clearColor];
        imgView.contentMode = UIViewContentModeScaleAspectFit;//Center;//ScaleAspectFit;
        imgView.clipsToBounds = YES;
        result = imgView;
    }

    return result;
}

- (UIView *) playVideo:(NSString *)videoUrl frame:(CGRect)frame {
    UIView *result = [[UIView alloc] initWithFrame:frame];
    
    self.extractor = [[YTVimeoExtractor alloc] initWithURL:videoUrl
                                                   quality:YTVimeoVideoQualityHigh];
    self.extractor.delegate = self;
    [_extractor start];
    
    self.videoContainerView = result;
    
    return result;
}

#pragma mark - YTVimeoExtractorDelegate

- (void)vimeoExtractor:(YTVimeoExtractor *)extractor didSuccessfullyExtractVimeoURL:(NSURL *)videoURL
{
    NSLog(@"Extracted url : %@", [videoURL absoluteString]);
    extractor = nil;
    if (!self.playerController)
        [self createAndConfigMoviePlayer:videoURL];
}

- (void)vimeoExtractor:(YTVimeoExtractor *)extractor failedExtractingVimeoURLWithError:(NSError *)error;
{
    NSLog(@"ERROR: %@", [error localizedDescription]);
    showAlertMessage(self,
                     DPLocalizedString(kERR_TITLE_CONNECTION_FAILED),
                     DPLocalizedString(kERR_MSG_TRY_LATER));
}

- (void) createAndConfigMoviePlayer:(NSURL *)movieURL {
    if (!self.playerController) {
        self.playerController= [[MPMoviePlayerController alloc] initWithContentURL: movieURL];
        self.playerController.view.frame = self.videoContainerView.bounds;
        
        self.playerController.controlStyle = MPMovieControlStyleNone;
        
        [self.playerController prepareToPlay];
        self.playerController.scalingMode = MPMovieScalingModeAspectFit;
        self.playerController.repeatMode = MPMovieRepeatModeNone;
        
        [self.videoContainerView addSubview:self.playerController.view];
        [self.playerController play];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(moviePlayBackDidFinished:)
                                                     name:MPMoviePlayerPlaybackDidFinishNotification
                                                   object:self.playerController];
    }
//    else {
//        NSTimeInterval pos = self.playerController.currentPlaybackTime;
//        [self.playerController pause];
//        self.playerController.view.frame = frame;//CGRectInset(containerView.bounds, 2, 2);
//        self.playerController.currentPlaybackTime = pos;
//    }
}

- (UIView *) createAndConfigMoviePlayer:(CGRect)frame videoUrl:(NSString *)vidurl {
    if (!self.playerController) {
        NSURL *movieURL = nil;
        if (!isLocalUrl(vidurl))
            movieURL = [NSURL URLWithString: vidurl];
        else {
            NSBundle *bundle = [NSBundle mainBundle];
            NSString *moviePath = moviePath = [bundle pathForResource:vidurl ofType:nil];
            
            if (moviePath == nil)
                return [[UIView alloc] initWithFrame:frame];
            
            movieURL = [NSURL fileURLWithPath:moviePath];
        }
        
        self.playerController= [[MPMoviePlayerController alloc] initWithContentURL: movieURL];
        self.playerController.view.frame = frame; //CGRectInset(containerView.bounds, 2, 2);
        
        self.playerController.controlStyle = MPMovieControlStyleNone;
        
        [self.playerController prepareToPlay];
        self.playerController.scalingMode = MPMovieScalingModeAspectFit;
        self.playerController.repeatMode = MPMovieRepeatModeNone;
        
//        [containerView addSubview:self.playerController.view];
        [self.playerController play];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(moviePlayBackDidFinished:)
                                                     name:MPMoviePlayerPlaybackDidFinishNotification
                                                   object:self.playerController];
    }
    else {
        NSTimeInterval pos = self.playerController.currentPlaybackTime;
        [self.playerController pause];
//        self.playerController.view.frame = frame;//CGRectInset(containerView.bounds, 2, 2);
        self.playerController.currentPlaybackTime = pos;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.playerController play];
        });
    }
    
    return self.playerController.view;
}

-(void)moviePlayBackDidFinished:(NSNotification *)notification {
    if ([[notification name] isEqualToString:MPMoviePlayerPlaybackDidFinishNotification]) {
        NSLog (@"Successfully received the ==MPMoviePlayerPlaybackDidFinishNotification== notification!");
        
        //        notification.userInfo[MPMoviePlayerPlaybackDidFinishReasonUserInfoKey]
        if (self.playerController != nil)
            [self.playerController play];
    }
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
                NSString *result = nil;
                if ([parts[1] isEqualToString:@"png"])
                    result = [NSString stringWithFormat:@"BuyDialogImages/%@_%@.%@",
                              parts[0], CURRENT_LANG, parts[1]];
                else
                    result = [NSString stringWithFormat:@"Videos/%@_%@.%@",
                                              parts[0], CURRENT_LANG, parts[1]];
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

