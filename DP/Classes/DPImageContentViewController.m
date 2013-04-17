//
//  DPImageContentViewController.m
//  DP
//
//  Created by Γεώργιος Γράβος on 3/24/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "DPImageContentViewController.h"
#import "../External/ASIHttpRequest/ASIHTTPRequest.h"
#import "DPConstants.h"

@interface DPImageContentViewController ()

@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) UIActivityIndicatorView *busyIndicator;
@property (strong, nonatomic) NSOperationQueue *queue;

@end

@implementation DPImageContentViewController {
    
}

@synthesize image, busyIndicator, queue;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) initWithImage:(UIImage *)aImage {
    if (self = [super init]) {
        self.image = aImage;
    }
    
    return self;
}

- (id) initWithImageUrl:(NSURL *)imageUrl {
    if (self = [super init]) {
        [self downloadImageUrl:imageUrl];
    }
    
    return self;
}

- (id) initWithImageName:(NSString *)imageName {
    if (self = [super init]) {
        self.image = [UIImage imageNamed:imageName];
    }
    
    return self;
}

- (void) doInitImageView {
//    CGRect aframe = CGRectMake(0, 0, self.view.superview.frame.size.width, self.view.superview.frame.size.height);
    CGRect aframe = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:aframe];
    imgView.contentMode = UIViewContentModeScaleAspectFit;
    imgView.userInteractionEnabled = YES;
    imgView.image = self.image;
    [self addGestureRecognizersTo:imgView];
    [self.view addSubview:imgView];
}

// adds a set of gesture recognizers to one of our piece subviews
- (void)addGestureRecognizersTo:(UIView *)piece {
    UIRotationGestureRecognizer *rotationGesture = [[UIRotationGestureRecognizer alloc]
                                                    initWithTarget:self action:@selector(rotatePiece:)];
    [piece addGestureRecognizer:rotationGesture];
    
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc]
                                              initWithTarget:self action:@selector(scalePiece:)];
    [pinchGesture setDelegate:self];
    [piece addGestureRecognizer:pinchGesture];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(panPiece:)];
    [panGesture setMaximumNumberOfTouches:2];
    [panGesture setDelegate:self];
    [piece addGestureRecognizer:panGesture];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc]
                                                      initWithTarget:self action:@selector(showResetMenu:)];
    [piece addGestureRecognizer:longPressGesture];
}


#pragma mark -
#pragma mark === Utility methods  ===
#pragma mark

// scale and rotation transforms are applied relative to the layer's anchor point
// this method moves a gesture recognizer's view's anchor point between the user's fingers
- (void)adjustAnchorPointForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        UIView *piece = gestureRecognizer.view;
        CGPoint locationInView = [gestureRecognizer locationInView:piece];
        CGPoint locationInSuperview = [gestureRecognizer locationInView:piece.superview];
        
        piece.layer.anchorPoint = CGPointMake(locationInView.x / piece.bounds.size.width, locationInView.y / piece.bounds.size.height);
        piece.center = locationInSuperview;
    }
}

// display a menu with a single item to allow the piece's transform to be reset
- (void)showResetMenu:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        UIMenuController *menuController = [UIMenuController sharedMenuController];
        UIMenuItem *resetMenuItem = [[UIMenuItem alloc]
                                     initWithTitle:DPLocalizedString(kIMAGE_RESET_MENU)
                                     action:@selector(resetPiece:)];
        CGPoint location = [gestureRecognizer locationInView:[gestureRecognizer view]];
        
        [self becomeFirstResponder];
        [menuController setMenuItems:[NSArray arrayWithObject:resetMenuItem]];
        [menuController setTargetRect:CGRectMake(location.x, location.y, 0, 0) inView:[gestureRecognizer view]];
        [menuController setMenuVisible:YES animated:YES];
        
        //self.pieceForReset = [gestureRecognizer view];
    }
}

// animate back to the default anchor point and transform
- (void)resetPiece:(UIMenuController *)controller
{
    UIView *pieceForReset = self.view.subviews.count > 0 ? self.view.subviews[0] : nil;
    if (pieceForReset == nil) return;
    
    CGPoint locationInSuperview = [pieceForReset
                                   convertPoint:CGPointMake(CGRectGetMidX(pieceForReset.bounds),
                                                            CGRectGetMidY(pieceForReset.bounds))
                                   toView:[pieceForReset superview]];
    
    [[pieceForReset layer] setAnchorPoint:CGPointMake(0.5, 0.5)];
    [pieceForReset setCenter:locationInSuperview];
    
    [UIView beginAnimations:nil context:nil];
    [pieceForReset setTransform:CGAffineTransformIdentity];
    [UIView commitAnimations];
}

// UIMenuController requires that we can become first responder or it won't display
- (BOOL)canBecomeFirstResponder
{
    return YES;
}


#pragma mark -
#pragma mark === Touch handling  ===


// shift the piece's center by the pan amount
// reset the gesture recognizer's translation to {0, 0} after applying so the next callback is a delta from the current position
- (void)panPiece:(UIPanGestureRecognizer *)gestureRecognizer
{
    UIView *piece = [gestureRecognizer view];
    
    [self adjustAnchorPointForGestureRecognizer:gestureRecognizer];
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gestureRecognizer translationInView:[piece superview]];
        
        [piece setCenter:CGPointMake([piece center].x + translation.x, [piece center].y + translation.y)];
        [gestureRecognizer setTranslation:CGPointZero inView:[piece superview]];
    }
}

// rotate the piece by the current rotation
// reset the gesture recognizer's rotation to 0 after applying so the next callback is a delta from the current rotation
- (void)rotatePiece:(UIRotationGestureRecognizer *)gestureRecognizer
{
    [self adjustAnchorPointForGestureRecognizer:gestureRecognizer];
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        [gestureRecognizer view].transform = CGAffineTransformRotate([[gestureRecognizer view] transform], [gestureRecognizer rotation]);
        [gestureRecognizer setRotation:0];
    }
}

// scale the piece by the current scale
// reset the gesture recognizer's rotation to 0 after applying so the next callback is a delta from the current scale
- (void)scalePiece:(UIPinchGestureRecognizer *)gestureRecognizer
{
    [self adjustAnchorPointForGestureRecognizer:gestureRecognizer];
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        [gestureRecognizer view].transform = CGAffineTransformScale([[gestureRecognizer view] transform], [gestureRecognizer scale], [gestureRecognizer scale]);
        [gestureRecognizer setScale:1];
    }
}

// ensure that the pinch, pan and rotate gesture recognizers on a particular view can all recognize simultaneously
// prevent other gesture recognizers from recognizing simultaneously
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    UIView *imgview = self.view.subviews.count > 0 ? self.view.subviews[0] : nil;
    
    // if the gesture recognizers's view isn't one of our pieces, don't allow simultaneous recognition
    if (gestureRecognizer.view != imgview)
        return NO;
    
    // if the gesture recognizers are on different views, don't allow simultaneous recognition
    if (gestureRecognizer.view != otherGestureRecognizer.view)
        return NO;
    
    // if either of the gesture recognizers is the long press, don't allow simultaneous recognition
    if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]] || [otherGestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]])
        return NO;
    
    return YES;
}


- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void) viewWillAppear:(BOOL)animated {
    if (image)
        [self doInitImageView];
    
    [super viewWillAppear:animated];
}

#pragma mark - === busy indication handling  ===

- (void) startIndicator {
    if(!self.busyIndicator) {
		self.busyIndicator = [[UIActivityIndicatorView alloc]
                              initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		self.busyIndicator.frame = CGRectMake((self.view.frame.size.width-25)/2,
                                              (self.view.frame.size.height-25)/2,
                                              25, 25);
		self.busyIndicator.hidesWhenStopped = TRUE;
        [self.view addSubview:self.busyIndicator];
	}
    [self.busyIndicator startAnimating];
}

- (void) stopIndicator {
    if(self.busyIndicator) {
        [self.busyIndicator stopAnimating];
        [self.busyIndicator removeFromSuperview];
        self.busyIndicator = nil;
    }
}

#pragma mark -
#pragma mark === image downloading handling  ===

- (void) downloadImageUrl:(NSURL *)imageUrl {
    if (!self.queue)
        self.queue = [[NSOperationQueue alloc] init];

    ASIHTTPRequest *imageRequest = [ASIHTTPRequest requestWithURL:imageUrl];
    [imageRequest setDelegate:self];
    [imageRequest setDidFinishSelector:@selector(imageRequestDone:)];
    //imageRequest.userInfo = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithInt:aIndex], @"imageIndex", nil];
    [self.queue addOperation:imageRequest];
    [self startIndicator];
}

- (void) imageRequestDone:(ASIHTTPRequest *)request{
    [self stopIndicator];
    
	self.image = [UIImage imageWithData:[request responseData]];
    [self doInitImageView];
}

- (void) requestFailed:(ASIHTTPRequest *)request {
	NSLog(@"Request Failed: %@", [request error]);

	[self stopIndicator];

    showAlertMessage(nil,
                     DPLocalizedString(kERR_TITLE_URL_NOT_FOUND),
                     DPLocalizedString(kERR_MSG_DATA_LOAD_FAILED));
}

-(void) doLayoutSubViews:(BOOL)fixtop {
    CGRect vf = self.view.frame;
    int h = vf.size.height - vf.origin.y; //IS_PORTRAIT ? vf.size.height : vf.size.height - vf.origin.y;
    int w = vf.size.width;

    UIView *innerview = self.view.subviews.count == 1 ? self.view.subviews[0] : nil;
    if (innerview) {
        innerview.frame = CGRectMake(0, 0,
                                     w,
                                     h);
    }
}
#pragma mark -
#pragma mark === device orientation change handling  ===

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidUnload {
    [super viewDidUnload];
}

@end
