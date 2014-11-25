//
//  DPVimeoPlayerViewController.m
//  DP
//
//  Created by Γεώργιος Γράβος on 3/27/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPVimeoPlayerViewController.h"
#import "DPConstants.h"
//#import "UIApplication+ScreenDimensions.h"
#import "DPAppDelegate.h"
#import "SVProgressHUD.h"

typedef void (^VimeoPlayerBlock)(MPMoviePlayerViewController *mpvc, NSError *error);


@interface DPVimeoPlayerViewController ()

//#pragma mark video playing
//
//@property (nonatomic, readonly) BOOL fullScreen;
//@property (strong, nonatomic) YTVimeoExtractor *extractor;
//@property (strong, nonatomic) MPMoviePlayerViewController *playerView;
//@property (nonatomic) YTVimeoVideoQuality quality;
//@property (strong, nonatomic) NSString *videoUrl;
//@property (strong, nonatomic) UIButton *btn;
//
//- (void)runPlayer:(NSURL *)url;
//- (void)playerViewDidExitFullScreen;
//
@end

@implementation DPVimeoPlayerViewController


//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
////        self.wantsFullScreenLayout = YES;
//    }
//    return self;
//}
//
//- (id) initWithUrl:(NSString *)aVideoUrl {
//    self = [super init];
//    if (self)
//        self.videoUrl = aVideoUrl;
//    
//    return self;
//}
//
//- (void) dealloc {
//    self.extractor = nil;
//    self.playerView = nil;
//    self.videoUrl = nil;
//    self.btn = nil;
//}
//
//- (void)viewDidLoad
//{
//    [super viewDidLoad];
//	// Do any additional setup after loading the view.
//    [[NSNotificationCenter defaultCenter] postNotificationName:DPN_VIMEO_PLAYER_WILL_APPEAR object:self];
//
//    self.view.backgroundColor = [UIColor blackColor];
//    self.quality = YTVimeoVideoQualityHigh;
//    [self playVideo];
//}
//
//- (void) doClose {
//    [[NSNotificationCenter defaultCenter] postNotificationName:DPN_VIMEO_PLAYER_WILL_DISAPPEAR object:self];
//
//    self.extractor = nil;
//    self.playerView = nil;
//    if (self.navigationController) {
//        [self.navigationController setNavigationBarHidden:NO];    // it shows
//        [self.navigationController popViewControllerAnimated:YES];
//    }else
//        [self dismissViewControllerAnimated:YES completion:^{ }];
//}
//
//-(void)viewWillAppear:(BOOL)animated{
//    [super viewWillAppear:animated];
//}
//
//-(void)viewWillDisappear:(BOOL)animated{
//    [super viewWillDisappear:animated];
//}
//
//- (void)didReceiveMemoryWarning
//{
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}
//
//- (void) doLayoutSubViews:(BOOL)fixtop {
//    CGRect vf = self.view.frame;
//    fixtop = IS_LANDSCAPE && !IS_IPAD;
//    int top = fixtop ? 12 : 0;
//    int h = vf.size.height - top;
//    int w = vf.size.width;
//
//    UIView *innerview = self.view.subviews.count == 1 ? self.view.subviews[0] : nil;
//    if (innerview) 
//        innerview.frame = CGRectMake(0, top, w, h);
//}
//
//#pragma mark -
//#pragma mark video playing
//
//- (void) playVideo {
//    self.extractor = [[YTVimeoExtractor alloc] initWithURL:self.videoUrl
//                                                   quality:self.quality];
//    self.extractor.delegate = self;
//    [_extractor start];
//}
//
//#pragma mark - YTVimeoExtractorDelegate
//
//- (void)vimeoExtractor:(YTVimeoExtractor *)extractor didSuccessfullyExtractVimeoURL:(NSURL *)videoURL
//{
//    NSLog(@"Extracted url : %@", [videoURL absoluteString]);
//    extractor = nil;
//    if (!_fullScreen)
//        [self runPlayer:videoURL];
//}
//
//- (void)vimeoExtractor:(YTVimeoExtractor *)extractor failedExtractingVimeoURLWithError:(NSError *)error;
//{
//    NSLog(@"ERROR: %@", [error localizedDescription]);
//    showAlertMessage(self,
//                     DPLocalizedString(kERR_TITLE_CONNECTION_FAILED),
//                     DPLocalizedString(kERR_MSG_TRY_LATER));
//}
//
//- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
//    [self doClose];    
//}
//#pragma mark - video playing private
//

//+ (void) playVideoUrl:(NSString *)vidUrl withCompletion:(VimeoPlayerBlock)onCompleted {
//    [SVProgressHUD setCustomHudColor: [UIColor blackColor]];
//    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeCustom];
//    [YTVimeoExtractor fetchVideoURLFromURL:vidUrl
//                                   quality:YTVimeoVideoQualityHigh
//                                   success:^(NSURL *videoURL) {
//                                       [SVProgressHUD dismiss];
//
//                                       UIGraphicsBeginImageContext(CGSizeMake(1,1));
//                                       
//                                       MPMoviePlayerViewController *mpvc = [[MPMoviePlayerViewController alloc] initWithContentURL:videoURL];
//                                       
//                                       UIGraphicsEndImageContext();
//                                       
//                                       mpvc.moviePlayer.fullscreen = YES;
//                                       [mpvc.moviePlayer prepareToPlay];
//                                       [mpvc.moviePlayer play];
//                                       
//                                       onCompleted(mpvc, nil);
//
//                                   } failure:^(NSError *error) {
//                                       [SVProgressHUD dismiss];
//                                       onCompleted(nil, error);
//                                   }];
//}

//=========================
static MPMoviePlayerViewController *moviePlayerViewController = nil;

+ (void) clsPlayerViewDidExitFullScreen:(NSNotification *)notification {
    if ([notification.name isEqualToString:MPMoviePlayerPlaybackDidFinishNotification] &&
        notification.object == [moviePlayerViewController moviePlayer]) {
        [moviePlayerViewController dismissMoviePlayerViewControllerAnimated];
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:MPMoviePlayerPlaybackDidFinishNotification
                                                      object:moviePlayerViewController.moviePlayer];
        moviePlayerViewController = nil;
        
        MPMovieFinishReason mfr = [notification.userInfo[MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
        switch (mfr) {
            case MPMovieFinishReasonPlaybackEnded : break;
            case MPMovieFinishReasonPlaybackError :
            {
                NSError *err = [notification.userInfo valueForKey:@"error"];
                if (err)
                    showAlertMessage(nil, DPLocalizedString(kERR_TITLE_ERROR), err.localizedDescription);
                break;
            }
            case MPMovieFinishReasonUserExited : break;
            default:
                break;
        }
    }

	double delayInSeconds = 0.150;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		[[NSNotificationCenter defaultCenter] postNotificationName:@"VIDEO_PALYER_FINISHED_NOTIFICATION" object:nil];
	});
}

//+ (void) clsPlayVideoUrl:(NSString *)vidUrl {
//        
//        [DPVimeoPlayerViewController playVideoUrl:vidUrl
//                                   withCompletion:^(MPMoviePlayerViewController *mpvc, NSError *error) {
//                                       if (error) {
//                                           showAlertMessage(nil,
//                                                            DPLocalizedString(kERR_TITLE_CONNECTION_FAILED),
//                                                            DPLocalizedString(kERR_MSG_TRY_LATER));
//                                       } else {
//                                           moviePlayerViewController = mpvc;
//                                           [[NSNotificationCenter defaultCenter] addObserver:self
//                                                                                    selector:@selector(clsPlayerViewDidExitFullScreen:)
//                                                                                        name:MPMoviePlayerPlaybackDidFinishNotification
//                                                                                      object:mpvc.moviePlayer];
//                                           
//                                           DPAppDelegate *appdel = [UIApplication sharedApplication].delegate;
//                                           UIViewController *main = appdel.controller;
//                                           [main presentViewController:mpvc animated:YES completion:nil];
//                                       }
//                                   }];
//}



+ (void) clsPlayVideoUrl:(NSString *)vidUrl {
    if (moviePlayerViewController != nil)
        return;
    
    //NSString *tmpurl = @"http://player.vimeo.com/external/75641764.m3u8?p=high,standard,mobile&s=ec677039d79b4a53832100962b63acd1";
    
    UIGraphicsBeginImageContext(CGSizeMake(1,1));
    moviePlayerViewController = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString: vidUrl]];
    UIGraphicsEndImageContext();
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clsPlayerViewDidExitFullScreen:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:moviePlayerViewController.moviePlayer];

    moviePlayerViewController.moviePlayer.fullscreen = YES;
    [moviePlayerViewController.moviePlayer prepareToPlay];
    [moviePlayerViewController.moviePlayer play];

    DPAppDelegate *appdel = [UIApplication sharedApplication].delegate;
    UIViewController *main = appdel.controller;
    [main presentViewController:moviePlayerViewController animated:YES completion:nil];
}

//=========================

//- (void)runPlayer:(NSURL *)url
//{
//    [self.navigationController setNavigationBarHidden:YES];   //it hides
//    _fullScreen = YES;
//    
//    // wrap controller initialization call in an artificial drawing context
//    // to avoid invalid context error messages
//    
//    UIGraphicsBeginImageContext(CGSizeMake(1,1));
//    
//    self.playerView = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
//    
//    UIGraphicsEndImageContext();
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(playerViewDidExitFullScreen)
//                                                 name:MPMoviePlayerPlaybackDidFinishNotification
//                                               object:self.playerView.moviePlayer];
//    
//    self.playerView.moviePlayer.fullscreen = YES;
//    [self.playerView.moviePlayer prepareToPlay];
//    [self.playerView.moviePlayer play];
//    CGRect frm = CGRectMake(0, 0,
//                            self.view.superview.frame.size.width,
//                            self.view.superview.frame.size.height);
//    self.playerView.view.frame = frm;
//
////    [self.view addSubview:self.playerView.view];
//    [self presentMoviePlayerViewControllerAnimated:self.playerView];
//}
//
//- (void)playerViewDidExitFullScreen
//{
//    _fullScreen = NO;
////    [self.playerView.view removeFromSuperview];
//    [self.playerView dismissMoviePlayerViewControllerAnimated];
//    [self doClose];
//}

@end
