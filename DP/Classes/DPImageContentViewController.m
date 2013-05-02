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
#import "AsyncImageView.h"


@interface DPImageContentViewController ()

@property (strong, nonatomic) Article *article;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) UIActivityIndicatorView *busyIndicator;
@property (strong, nonatomic) NSOperationQueue *queue;
@property (strong, nonatomic) ASIHTTPRequest *request;

@end

@implementation DPImageContentViewController {
	CGFloat lastScale;
	CGFloat lastRotation;
	
	CGFloat firstX;
	CGFloat firstY;
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

- (id) initWithArticle:(Article *)aArticle {
    if (self = [super init]) {
        self.article = aArticle;
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
//    CGRect aframe = self.view.bounds;
//    UIImageView *imgView = [[UIImageView alloc] initWithFrame:aframe];
//    imgView.contentMode = UIViewContentModeScaleAspectFit;
//    imgView.userInteractionEnabled = YES;
//    imgView.image = self.image;
//    [self addGestureRecognizersTo:imgView];
//    [self.view addSubview:imgView];
    
	
//	UIView *holderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,
//                                                                  self.image.size.width,
//                                                                  self.image.size.height)];
    UIView *holderView = [[UIView alloc] initWithFrame:self.view.bounds];
    //holderView.backgroundColor = [UIColor whiteColor];
    UIImageView *imageview = [[UIImageView alloc] initWithFrame:[holderView frame]];
    imageview.contentMode = UIViewContentModeScaleAspectFit;
    //imageview.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	[imageview setImage:image];
	[holderView addSubview:imageview];
    [self addGestureRecognizersTo:holderView];
    [self.view addSubview:holderView];
}


- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}


- (void) viewDidUnload {
    [super viewDidUnload];
}

-(void) cleanUp {
    if (self.queue) {
        [self.queue cancelAllOperations];
    }
    if (self.request) {
        [self.request cancel];
        self.request.delegate = nil;
    }
    self.request = nil;
    self.queue = nil;
}

-(void) dealloc {
    [self cleanUp];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) viewWillAppear:(BOOL)animated {
    if (image)// && !self.article)
        [self doInitImageView];
    else if (self.article) {
        if (isLocalUrl(self.article.imageUrl)) {
            self.image = [UIImage imageNamed:self.article.imageUrl];
            [self doInitImageView];
        } else
            [self downloadImageUrl:[NSURL URLWithString:self.article.imageUrl]];
    }
    
    [super viewWillAppear:animated];
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


//- (void)addGestureRecognizersTo:(UIView *)piece {
//
//    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scale:)];
//    [pinchRecognizer setDelegate:self];
//    [piece addGestureRecognizer:pinchRecognizer];
//    
//    UIRotationGestureRecognizer *rotationRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotate:)];
//    [rotationRecognizer setDelegate:self];
//    [piece addGestureRecognizer:rotationRecognizer];
//    
//    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
//    [panRecognizer setMinimumNumberOfTouches:1];
//    [panRecognizer setMaximumNumberOfTouches:1];
//    [panRecognizer setDelegate:self];
//    [piece addGestureRecognizer:panRecognizer];
//    
//    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
//    [tapRecognizer setNumberOfTapsRequired:1];
//    [tapRecognizer setDelegate:self];
//    [piece addGestureRecognizer:tapRecognizer];
//    
//    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc]
//                                                      initWithTarget:self action:@selector(showResetMenu:)];
//    [piece addGestureRecognizer:longPressGesture];
//
//}

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

///*
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
        
        ((UIView *)piece.subviews[0]).center = CGPointMake(piece.bounds.size.width / 2.0,
                                                           piece.bounds.size.height / 2.0);
    }
}

// rotate the piece by the current rotation
// reset the gesture recognizer's rotation to 0 after applying so the next callback is a delta from the current rotation
- (void)rotatePiece:(UIRotationGestureRecognizer *)gestureRecognizer
{
    UIView *piece = [gestureRecognizer view];
    [self adjustAnchorPointForGestureRecognizer:gestureRecognizer];
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        CGFloat rotation = [gestureRecognizer rotation];

        piece.transform = CGAffineTransformRotate([piece transform], rotation);

        NSLog(@"rotation => %f", rotation);
        [gestureRecognizer setRotation:0];
        ((UIView *)piece.subviews[0]).center = CGPointMake(piece.bounds.size.width / 2.0,
                                                           piece.bounds.size.height / 2.0);
    }
}

// scale the piece by the current scale
// reset the gesture recognizer's scale to 1 after applying so the next callback is a delta from the current scale
- (void)scalePiece:(UIPinchGestureRecognizer *)gestureRecognizer
{
    UIView *piece = [gestureRecognizer view];
    [self adjustAnchorPointForGestureRecognizer:gestureRecognizer];
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        CGFloat scale = gestureRecognizer.scale;
        piece.transform = CGAffineTransformScale([piece transform], scale, scale);
        NSLog(@"scaling => %f", scale);
        [gestureRecognizer setScale:1];
        ((UIView *)piece.subviews[0]).center = CGPointMake(piece.bounds.size.width / 2.0,
                                                           piece.bounds.size.height / 2.0);
    }
}

// ensure that the pinch, pan and rotate gesture recognizers on a particular view can all recognize simultaneously
// prevent other gesture recognizers from recognizing simultaneously
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    UIView *piece = self.view.subviews.count > 0 ? self.view.subviews[0] : nil;
    
    // if the gesture recognizers's view isn't one of our pieces, don't allow simultaneous recognition
    if (gestureRecognizer.view != piece)
        return NO;
    
    // if the gesture recognizers are on different views, don't allow simultaneous recognition
    if (gestureRecognizer.view != otherGestureRecognizer.view)
        return NO;
    
    // if either of the gesture recognizers is the long press, don't allow simultaneous recognition
    if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]] || [otherGestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]])
        return NO;
    
    return YES;
}
//*/
/*
-(void)scale:(id)sender {
	
	[self.view bringSubviewToFront:[(UIPinchGestureRecognizer*)sender view]];
	
    [self adjustAnchorPointForGestureRecognizer:sender];

	if([(UIPinchGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
		
		lastScale = 1.0;
		return;
	}
	
	CGFloat scale = 1.0 - (lastScale - [(UIPinchGestureRecognizer*)sender scale]);
	
	CGAffineTransform currentTransform = [(UIPinchGestureRecognizer*)sender view].transform;
	CGAffineTransform newTransform = CGAffineTransformScale(currentTransform, scale, scale);
	
	[[(UIPinchGestureRecognizer*)sender view] setTransform:newTransform];
	
	lastScale = [(UIPinchGestureRecognizer*)sender scale];
}

-(void)rotate:(id)sender {
	
	[self.view bringSubviewToFront:[(UIRotationGestureRecognizer*)sender view]];
	
    [self adjustAnchorPointForGestureRecognizer:sender];
    
	if([(UIRotationGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
		
		lastRotation = 0.0;
		return;
	}
	
	CGFloat rotation = 0.0 - (lastRotation - [(UIRotationGestureRecognizer*)sender rotation]);
	
	CGAffineTransform currentTransform = [(UIPinchGestureRecognizer*)sender view].transform;
	CGAffineTransform newTransform = CGAffineTransformRotate(currentTransform,rotation);
	
	[[(UIRotationGestureRecognizer*)sender view] setTransform:newTransform];
	
	lastRotation = [(UIRotationGestureRecognizer*)sender rotation];
}

-(void)move:(id)sender {
	
	[[[(UITapGestureRecognizer*)sender view] layer] removeAllAnimations];
	
	[self.view bringSubviewToFront:[(UIPanGestureRecognizer*)sender view]];

    [self adjustAnchorPointForGestureRecognizer:sender];

    CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:self.view];
	
	if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
		
		firstX = [[sender view] center].x;
		firstY = [[sender view] center].y;
	}
	
	translatedPoint = CGPointMake(firstX+translatedPoint.x, firstY+translatedPoint.y);
	
	[[sender view] setCenter:translatedPoint];
	
	if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
		
		CGFloat finalX = translatedPoint.x + (.35*[(UIPanGestureRecognizer*)sender velocityInView:self.view].x);
		CGFloat finalY = translatedPoint.y + (.35*[(UIPanGestureRecognizer*)sender velocityInView:self.view].y);
		
        CGFloat maxX =  self.view.bounds.size.width;
        CGFloat maxY =  self.view.bounds.size.height;
        
        if(finalX < 0)
            finalX = 0;
        else if(finalX > maxX)
            finalX = maxX;
        
        if(finalY < 0)
            finalY = 0;
        else if(finalY > maxY)
            finalY = maxY;
		
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:.35];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		[[sender view] setCenter:CGPointMake(finalX, finalY)];
		[UIView commitAnimations];
	}
}

-(void)tapped:(id)sender {
	
	[[[(UITapGestureRecognizer*)sender view] layer] removeAllAnimations];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
	
    // if the gesture recognizers are on different views, don't allow simultaneous recognition
    if (gestureRecognizer.view != otherGestureRecognizer.view)
        return NO;
    
    // if either of the gesture recognizers is the long press, don't allow simultaneous recognition
    if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]] ||
        [otherGestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]])
        return NO;
    
	if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] ||
        [otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]])
        return NO;
    
    return YES;
}
//*/


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

    if (!self.request) {
        self.request = [ASIHTTPRequest requestWithURL:imageUrl];
        [self.request setDelegate:self];
        [self.request setDidFinishSelector:@selector(imageRequestDone:)];
        //imageRequest.userInfo = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithInt:aIndex], @"imageIndex", nil];
        [self.queue addOperation:self.request];
    }
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
//    int h = vf.size.height - vf.origin.y; //IS_PORTRAIT ? vf.size.height : vf.size.height - vf.origin.y;
//    int w = vf.size.width;
    fixtop = IS_LANDSCAPE && !IS_IPAD;
    int top = fixtop ? 12 : 0;
    int h = vf.size.height - top;
    int w = vf.size.width;
    
    UIView *innerview = self.view.subviews.count == 1 ? self.view.subviews[0] : nil;
    if (innerview) {
        innerview.frame = CGRectMake(0, top,
                                     w,
                                     h);
    }
}

//==============================================================================
#pragma mark - nav bar button selection
//- (BOOL) showNavBar {
//    return self.navigationController != nil;
//}
- (BOOL) showNavBarLanguages {
    return NO;
}
- (BOOL) showNavBarAddToFav {
    return YES;
}
- (BOOL) showNavBarSocial {
    return YES;
}
//- (BOOL) showNavBarInfo {
//    return YES;
//}
//==============================================================================

@end
