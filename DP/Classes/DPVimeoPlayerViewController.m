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
        self.wantsFullScreenLayout = YES;
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
    if (self.navigationController)
        [self.navigationController popToRootViewControllerAnimated:YES];    
}

-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES];   //it hides
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO];    // it shows
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
- (void) layoutForOrientation:(UIInterfaceOrientation) toOrientation fixtop:(BOOL)fixtop{
    CGRect svf = self.view.superview.frame;
    CGRect vf = self.view.frame;
    
    int sbh = [UIApplication sharedApplication].statusBarFrame.size.height;
    vf = CGRectMake(0, 0, svf.size.width, svf.origin.y + svf.size.height + sbh);
    NSLog(@"======> vimeo vf : (x, y, w, h) = ****** (%f, %f, %f, %f) ********",
          vf.origin.x, vf.origin.y, vf.size.width, vf.size.height);
 //   self.view.frame = vf;

    //self.view.frame = []
    UIView *innerview = self.view.subviews.count == 1 ? self.view.subviews[0] : nil;
    if (innerview) {
        CGRect frm = CGRectMake(0, 0,
                                vf.size.width,
                                vf.size.height);
//        innerview.frame = frm;
    }
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
                     @"Αποτυχία Σύνδεσης",
                     @"Παρακαλούμε δοκιμάστε αργότερα...");
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self doClose];    
}
#pragma mark - video playing private

- (void)runPlayer:(NSURL *)url
{
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
    
    //self.playerView.moviePlayer.fullscreen = YES;
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
