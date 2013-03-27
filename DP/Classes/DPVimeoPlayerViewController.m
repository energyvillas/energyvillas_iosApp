//
//  DPVimeoPlayerViewController.m
//  DP
//
//  Created by Γεώργιος Γράβος on 3/27/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPVimeoPlayerViewController.h"
#import <MediaPlayer/MediaPlayer.h>

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
    self.view.backgroundColor = nil;
    self.quality = YTVimeoVideoQualityHigh;
    [self playVideo];
}

- (void) doClose {
    self.extractor = nil;
    self.playerView = nil;
    if (self.navigationController)
        [self.navigationController popToRootViewControllerAnimated:YES];    
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL) shouldAutorotate {
    return NO;
}

- (NSUInteger) supportedInterfaceOrientations {
    return UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
    
    [self.playerView.moviePlayer prepareToPlay];
    [self.playerView.view setFrame:self.view.frame];
    
    [self presentMoviePlayerViewControllerAnimated:self.playerView];
}

- (void)playerViewDidExitFullScreen
{
    _fullScreen = NO;
    [self.playerView dismissMoviePlayerViewControllerAnimated];

    [self doClose];
}

@end
