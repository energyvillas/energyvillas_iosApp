//
//  DPVimeoPlayerViewController.m
//  DP
//
//  Created by Γεώργιος Γράβος on 3/27/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPVimeoPlayerViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "DPConstants.h"
#import "UIApplication+ScreenDimensions.h"


@interface DPVimeoPlayerViewController ()

#pragma mark video playing

@property (nonatomic, readonly) BOOL fullScreen;
@property (strong, nonatomic) YTVimeoExtractor *extractor;
@property (strong, nonatomic) MPMoviePlayerViewController *playerView;
@property (nonatomic) YTVimeoVideoQuality quality;
@property (strong, nonatomic) NSString *videoUrl;
@property (strong, nonatomic) UIButton *btn;

- (void)runPlayer:(NSURL *)url;
- (void)playerViewDidExitFullScreen;

@end

@implementation DPVimeoPlayerViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
//        self.wantsFullScreenLayout = YES;
    }
    return self;
}

- (id) initWithUrl:(NSString *)aVideoUrl {
    self = [super init];
    if (self)
        self.videoUrl = aVideoUrl;
    
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    self.quality = YTVimeoVideoQualityHigh;
    [self playVideo];
}

- (void) doClose {
    self.extractor = nil;
    self.playerView = nil;
    if (self.navigationController) {
        [self.navigationController setNavigationBarHidden:NO];    // it shows
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else
        [self dismissViewControllerAnimated:YES completion:^{ }];
}

-(void)viewWillAppear:(BOOL)animated{
//    [self.navigationController setNavigationBarHidden:YES];   //it hides
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated{
//    [self.navigationController setNavigationBarHidden:NO];    // it shows
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*
- (BOOL) shouldAutorotate {
    return NO;
}

- (NSUInteger) supportedInterfaceOrientations {
    return UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    //return YES;
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];

    CGSize nextViewSize = [UIApplication sizeInOrientation:toInterfaceOrientation];
    self.view.frame = CGRectMake(0, 0, nextViewSize.width, nextViewSize.height);
}
- (void) doLayoutSubViews:(BOOL)fixtop {
    CGRect vf = self.view.frame;
    fixtop = IS_LANDSCAPE;
    int top = fixtop ? 12 : 0;
    int h = vf.size.height - top;
    int w = vf.size.width;

    UIView *innerview = self.view.subviews.count == 1 ? self.view.subviews[0] : nil;
    if (innerview) 
        innerview.frame = CGRectMake(0, top, w, h);
}

#pragma mark -
#pragma mark video playing

- (void) playVideo {
    self.extractor = [[YTVimeoExtractor alloc] initWithURL:self.videoUrl
                                                   quality:self.quality];
    self.extractor.delegate = self;
    [_extractor start];
}

#pragma mark - YTVimeoExtractorDelegate

- (void)vimeoExtractor:(YTVimeoExtractor *)extractor didSuccessfullyExtractVimeoURL:(NSURL *)videoURL
{
    NSLog(@"Extracted url : %@", [videoURL absoluteString]);
    extractor = nil;
    if (!_fullScreen)
        [self runPlayer:videoURL];
}

- (void)vimeoExtractor:(YTVimeoExtractor *)extractor failedExtractingVimeoURLWithError:(NSError *)error;
{
    NSLog(@"ERROR: %@", [error localizedDescription]);
    showAlertMessage(self,
                     DPLocalizedString(kERR_TITLE_CONNECTION_FAILED),
                     DPLocalizedString(kERR_MSG_TRY_LATER));
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self doClose];    
}
#pragma mark - video playing private

- (void)runPlayer:(NSURL *)url
{
    [self.navigationController setNavigationBarHidden:YES];   //it hides
    _fullScreen = YES;
    
    // wrap controller initialization call in an artificial drawing context
    // to avoid invalid context error messages
    
    UIGraphicsBeginImageContext(CGSizeMake(1,1));
    
    self.playerView = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
    
    UIGraphicsEndImageContext();
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerViewDidExitFullScreen)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:self.playerView.moviePlayer];
    
    self.playerView.moviePlayer.fullscreen = YES;
    [self.playerView.moviePlayer prepareToPlay];
    [self.playerView.moviePlayer play];
    CGRect frm = CGRectMake(0, 0,
                            self.view.superview.frame.size.width,
                            self.view.superview.frame.size.height);
    UIView *pv = self.playerView.view;
    pv.frame = frm;

    [self.view addSubview:self.playerView.view];
}

- (void)playerViewDidExitFullScreen
{
    _fullScreen = NO;
    [self.playerView.view removeFromSuperview];    
    [self doClose];
}

@end
