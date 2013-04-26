//
//  DPCtgCardView.m
//  Untitled
//
//  Created by Γεώργιος Γράβος on 4/4/13.
//
//

#import "DPCardView.h"
#import "DPConstants.h"
#import <Quartzcore/Quartzcore.h>
#import "DPAppHelper.h"
#import "ASIHTTPRequest.h"

#define IPHONE_LABEL_MARGIN_VERT ((int)2)
#define IPAD_LABEL_MARGIN_VERT ((int)2)

#define IPHONE_CARD_RESIZE_WIDTH ((int)15)
#define IPHONE_CARD_RESIZE_HEIGHT ((int)15)
#define IPAD_CARD_RESIZE_WIDTH ((int)30)
#define IPAD_CARD_RESIZE_HEIGHT ((int)30)

#define IPHONE_LABEL_HEIGHT ((int)18)
#define IPAD_LABEL_HEIGHT ((int)22)

@interface DPCardView ()

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIImageView *zoomImageView;
@property (strong, nonatomic) UILabel *label;

@property (strong, nonatomic) UIActivityIndicatorView *busyIndicator;
@property (strong, nonatomic) NSOperationQueue *queue;

@end

@implementation DPCardView {
    CGSize cardSize;
    CGFloat baseFontSize, zoomFontSize;
    CGRect baseLabelFrame, zoomLabelFrame;
    BOOL useLabel;
}

@synthesize element;

- (id)initWithFrame:(CGRect)frame dataElement:(Category *)elm {
    useLabel = NO;
    cardSize = IS_IPAD
                    ? CGSizeMake(IPAD_CARD_WIDTH, IPAD_CARD_HEIGHT)
                    : CGSizeMake(IPHONE_CARD_WIDTH, IPHONE_CARD_HEIGHT);
    
    frame.size.width = cardSize.width;
    frame.size.height =cardSize.height;
    
    self = [super initWithFrame:frame];
    if (self) {
        element = elm;
        
        self.backgroundColor = [UIColor redColor];//[UIColor clearColor];
//        self.backgroundColor = [UIColor colorWithHue: (arc4random() % 1000) / 1000.0
//                                          saturation:1.0
//                                          brightness:1.0
//                                               alpha:1.0];
    }
    return self;
}

-(void) cleanUp {
    if (self.queue) {
        [self.queue cancelAllOperations];
        [self stopIndicator];
        
        for (id op in self.queue.operations)
            if ([op isKindOfClass:[ASIHTTPRequest class]]) {
                [((ASIHTTPRequest *)op) setDidFinishSelector:nil];
                ((ASIHTTPRequest *)op).delegate = nil;
            }
    }
    
    self.queue = nil;
}

-(void) dealloc {
    [self cleanUp];
}

- (void) layoutSubviews {
    if (self.subviews.count == 0) {
        // normal image
        if (!self.imageView) {
            self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
            self.imageView.contentMode = UIViewContentModeCenter; //ScaleAspectFit;
            
            if (isLocalUrl(element.imageUrl))
                self.imageView.image = [UIImage imageNamed:[self calcImageName:element.imageUrl highlight:NO]];
            else
                [self loadImageAsync:element highlight:NO inView:self.imageView];
            
//            //TODO : this is here ONLY for testing
//            self.imageView.image = [UIImage imageNamed:@"balloon.png"];
        }
        if (!self.zoomImageView) {
            int rw = IS_IPAD ? IPAD_CARD_RESIZE_WIDTH : IPHONE_CARD_RESIZE_WIDTH;
            int rh = IS_IPAD ? IPAD_CARD_RESIZE_HEIGHT : IPHONE_CARD_RESIZE_HEIGHT;
            int w = IS_IPAD ? IPAD_CARD_WIDTH : IPHONE_CARD_WIDTH;
            int h = IS_IPAD ? IPAD_CARD_HEIGHT : IPHONE_CARD_HEIGHT;
            
            CGRect zoomFrame = CGRectMake(0, 0, w  + 2 * rw, h + 2 * rh);

            self.zoomImageView = [[UIImageView alloc] initWithFrame:zoomFrame];
            self.zoomImageView.contentMode = UIViewContentModeCenter; //ScaleAspectFit;
            
            if (isLocalUrl(element.imageRollUrl))
                self.zoomImageView.image = [UIImage imageNamed:[self calcImageName:element.imageRollUrl highlight:YES]];
            else
                [self loadImageAsync:element highlight:YES inView:self.zoomImageView];
            
//            //TODO : this is here ONLY for testing
//            self.zoomImageView.image = [UIImage imageNamed:@"balloon_roll.png"];
        }

        if (useLabel && !self.label) {
            self.label = [[UILabel alloc] init];
            [self setupLabel:element.title];
        }
        
        [self addSubview:self.imageView];
        if (useLabel)
            [self addSubview:self.label];
    }
}

- (CGRect) presentationFrameOf:(UIView *)target {
    CALayer *pl=target.layer.presentationLayer;
    return pl.frame;
    
}

- (CGPoint) presentationCenterOf:(UIView *)target {
    CGRect frm = [self presentationFrameOf:target];
    return CGPointMake(frm.origin.x + frm.size.width / 2,
                       frm.origin.y + frm.size.height /2);
    
}

CGRect CGRectChangeCenter(CGRect rect, CGPoint center) {
    CGFloat cx = rect.origin.x + rect.size.width / 2.0;
    CGFloat cy = rect.origin.y + rect.size.height / 2.0;
    CGRect result = CGRectOffset(rect, center.x - cx, center.y - cy);
    return result;
}

- (void)performTransition:(UIViewAnimationOptions)options
                 duration:(NSTimeInterval)duration
               completion:(void(^)(BOOL finished))completion
{
    UIView *fromView, *toView;
    
    if ([self.imageView superview] != nil)
    {
        fromView = self.imageView;
        toView = self.zoomImageView;
    }
    else
    {
        fromView = self.zoomImageView;
        toView = self.imageView;
    }
    
    [UIView transitionFromView:fromView
                        toView:toView
                      duration:duration
                       options:options
                    completion:completion];
}

//- (IBAction)fadeAction:(id)sender
//{
//    [self performTransition:UIViewAnimationOptionTransitionCrossDissolve];
//}

//- (IBAction)flipAction:(id)sender
//{
//    UIViewAnimationOptions transitionOptions = ([self.frontView superview] != nil) ?
//    UIViewAnimationOptionTransitionFlipFromLeft : UIViewAnimationOptionTransitionFlipFromRight;
//    
//    [self performTransition:transitionOptions];
//}

- (void) zoomCard:(NSTimeInterval)duration position:(CGPoint)newCenter{
//    int rw = IS_IPAD ? IPAD_CARD_RESIZE_WIDTH : IPHONE_CARD_RESIZE_WIDTH;
//    int rh = IS_IPAD ? IPAD_CARD_RESIZE_HEIGHT : IPHONE_CARD_RESIZE_HEIGHT;
//    int w = IS_IPAD ? IPAD_CARD_WIDTH : IPHONE_CARD_WIDTH;
//    int h = IS_IPAD ? IPAD_CARD_HEIGHT : IPHONE_CARD_HEIGHT;
//    
//    CGRect bigFrame = CGRectInset(self.frame, -1000, -1000);
//    self.frame = bigFrame;
//    
//    self.imageView.frame = CGRectOffset(self.imageView.frame, 1000, 1000);
//    CGPoint cp = [self convertPoint:newCenter fromView:self.superview];
//    self.zoomImageView.center = cp;
//    
//    [self performTransition:UIViewAnimationOptionTransitionCrossDissolve
//                   duration:duration
//                 completion:^(BOOL finished) {
//                     CGRect zoomFrame = CGRectInset(CGRectMake(0, 0, w, h), -rw, -rh);
//                     self.frame = CGRectChangeCenter(zoomFrame, newCenter);
//                     self.zoomImageView.frame = self.bounds;
//                 }];
//
//    return;
    
    int rw = IS_IPAD ? IPAD_CARD_RESIZE_WIDTH : IPHONE_CARD_RESIZE_WIDTH;
    int rh = IS_IPAD ? IPAD_CARD_RESIZE_HEIGHT : IPHONE_CARD_RESIZE_HEIGHT;
    int w = IS_IPAD ? IPAD_CARD_WIDTH : IPHONE_CARD_WIDTH;
    int h = IS_IPAD ? IPAD_CARD_HEIGHT : IPHONE_CARD_HEIGHT;
    
    CGRect zoomFrame = CGRectInset(CGRectMake(0, 0, w, h), -rw, -rh);
    zoomFrame = CGRectChangeCenter(zoomFrame, newCenter);

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDelay:0.0];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self cache:YES];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    
    self.frame = zoomFrame;
    [self.imageView removeFromSuperview];
    [self addSubview:self.zoomImageView];

    [UIView commitAnimations];
    
//    return;
//    
//    [UIView animateWithDuration:duration
//                          delay:0.0
//                        options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionBeginFromCurrentState
//                     animations:^{
//                         int rw = IS_IPAD ? IPAD_CARD_RESIZE_WIDTH : IPHONE_CARD_RESIZE_WIDTH;
//                         int rh = IS_IPAD ? IPAD_CARD_RESIZE_HEIGHT : IPHONE_CARD_RESIZE_HEIGHT;
//                         CGRect zoomFrame = CGRectInset(self.frame, -rw, -rh);
//                         self.frame = CGRectChangeCenter(zoomFrame, newCenter);
//                         self.imageView.frame = CGRectMake(0, 0,
//                                                      zoomFrame.size.width,
//                                                      zoomFrame.size.height);
//                         
//                         self.imageView.image = [UIImage imageNamed:@"balloon_roll.png"];
//                         
//                         if (useLabel) {
//                             self.label.frame = zoomLabelFrame;
//                             self.label.font = [self.label.font fontWithSize:zoomFontSize];
//                         }
//                     }
//                     completion:nil];
}

- (void) cancelCardZoom:(NSTimeInterval)duration {
//    CGRect frm = [self presentationFrameOf:self];
//    int diffX = frm.size.width - cardSize.width;
//    int diffY = frm.size.height - cardSize.height;
//    self.frame = CGRectInset(frm, diffX / 2, diffY / 2);
    
//    self.imageView.frame = CGRectMake(0, 0,
//                                      cardSize.width,
//                                      cardSize.height);
    
    int rw = IS_IPAD ? IPAD_CARD_RESIZE_WIDTH : IPHONE_CARD_RESIZE_WIDTH;
    int rh = IS_IPAD ? IPAD_CARD_RESIZE_HEIGHT : IPHONE_CARD_RESIZE_HEIGHT;
//    int w = IS_IPAD ? IPAD_CARD_WIDTH : IPHONE_CARD_WIDTH;
//    int h = IS_IPAD ? IPAD_CARD_HEIGHT : IPHONE_CARD_HEIGHT;
    
    CGRect unZoomFrame = CGRectInset(self.frame, rw, rh);
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDelay:0.0];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self cache:YES];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    
    self.frame = unZoomFrame;
    [self.zoomImageView removeFromSuperview];
    [self addSubview:self.imageView];
    
    [UIView commitAnimations];
    
    
//    return;
//    
//    [UIView animateWithDuration:duration
//                          delay:0.0
//                        options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionBeginFromCurrentState |UIViewAnimationOptionTransitionCrossDissolve
//                     animations:^{
//                         CGRect frm = [self presentationFrameOf:self];
//                         int diffX = frm.size.width - cardSize.width;
//                         int diffY = frm.size.height - cardSize.height;
//                         self.frame = CGRectInset(frm, diffX / 2, diffY / 2);
//
//                         self.imageView.frame = CGRectMake(0, 0,
//                                                      cardSize.width,
//                                                      cardSize.height);
//
//                         self.imageView.image = [UIImage imageNamed:@"balloon.png"];
//
//                         if (useLabel) {
//                             self.label.frame = baseLabelFrame;
//                             self.label.font = [self.label.font fontWithSize:baseFontSize];
//                         }
//                     }
//                     completion:nil];
}


- (void) setupLabel:(NSString *)title {
    if (!useLabel) return;
    
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.backgroundColor = [UIColor clearColor];
    self.label.text = title;
    
    [self calcLabelFonts:YES];
    [self calcLabelFonts:NO];

    // setup text shadow
    self.label.textColor = [UIColor blackColor];
    self.label.layer.shadowColor = [self.label.textColor CGColor];
    self.label.textColor = [UIColor whiteColor];
    self.label.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    self.label.layer.masksToBounds = NO;
    self.label.layer.shadowRadius = 1.5f;
    self.label.layer.shadowOpacity = 0.95;
    
    self.label.adjustsFontSizeToFitWidth = NO;
}

- (void) calcLabelFonts:(BOOL)zoomed {    
    int lblheight = IS_IPAD ? IPAD_LABEL_HEIGHT : IPHONE_LABEL_HEIGHT;
    int offsetfix = IS_IPAD ? IPAD_LABEL_MARGIN_VERT : IPHONE_LABEL_MARGIN_VERT;
    CGRect frm = self.frame;
    int fw = frm.size.width + (!zoomed ? 0 : 2 * (IS_IPAD ? IPAD_CARD_RESIZE_WIDTH : IPHONE_CARD_RESIZE_WIDTH));
    int fh = frm.size.height + (!zoomed ? 0 : 2 * (IS_IPAD ? IPAD_CARD_RESIZE_HEIGHT : IPHONE_CARD_RESIZE_HEIGHT));
    
    frm = CGRectMake(0, fh - offsetfix - lblheight, fw, lblheight);
    
    if (!zoomed) {
        if (IS_IPAD)
            self.label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16];
        else
            self.label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12];
    } else {
        if (IS_IPAD)
            self.label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17];
        else
            self.label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:13];
    }

    self.label.adjustsFontSizeToFitWidth = YES;
    [self.label sizeToFit];
    
    if (!zoomed) {
        baseLabelFrame = frm;
        self.label.frame = frm;
        baseFontSize = self.label.font.pointSize;
    } else {
        zoomLabelFrame = frm;
        zoomFontSize = self.label.font.pointSize;
    }
}

#pragma mark - loading of image data

- (NSString *) calcImageName:(NSString *)baseName highlight:(BOOL)highlight{
    NSLog(@"**** imageUrl (base) = %@", baseName);
    
    @try {
        NSArray *parts = [baseName componentsSeparatedByString:@"."];
        if (parts && parts.count == 2) {
            NSString *roll = highlight ? @"_roll" : @"";
            NSString *result = [NSString stringWithFormat:@"%@%@.%@",
                                parts[0], roll, parts[1]];
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

- (void) startIndicator {
    if(!self.busyIndicator) {
		self.busyIndicator = [[UIActivityIndicatorView alloc]
                              initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		self.busyIndicator.frame = CGRectMake((self.frame.size.width-25)/2,
                                              (self.frame.size.height-25)/2,
                                              25, 25);
		self.busyIndicator.hidesWhenStopped = TRUE;
        [self addSubview:self.busyIndicator];
	}
    
    if (!self.busyIndicator.isAnimating)
        [self.busyIndicator startAnimating];
}

- (void) stopIndicator {
    if (self.busyIndicator &&
        self.queue &&
        self.queue.operationCount == 0) {
        [self.busyIndicator stopAnimating];
        [self.busyIndicator removeFromSuperview];
        self.busyIndicator = nil;
    }
}

- (void) fix:(DPDataElement *)elm
   imageView:(UIImageView *)imgView
    imageUrl:(NSString *)imageUrl
        data:(NSData *)imgData
  addToCache:(BOOL)addToCache{
    //elm.imageData = [request responseData];
    imgView.image = [UIImage imageWithData:imgData scale:DEVICE_SCALE];
    if (addToCache)
        [[DPAppHelper sharedInstance] saveImageToCache:imageUrl data:imgData];
}

- (void) loadImageAsync:(Category *)elm highlight:(BOOL)highlight inView:(UIImageView *)imgView {
    DPAppHelper *appHelper = [DPAppHelper sharedInstance];
    NSData *imgData = [appHelper loadImageFromCache:highlight ? elm.imageRollUrl : elm.imageUrl];
    if (imgData)
        [self fix:elm
        imageView:imgView
         imageUrl:highlight ? elm.imageRollUrl : elm.imageUrl
             data:imgData addToCache:NO];
    else
        [self doloadImageAsync:elm highlight:highlight inView:imgView];
}

- (void) doloadImageAsync:(Category *)elm highlight:(BOOL)highlight inView:(UIImageView *)imgView {
    if (!self.queue)
        self.queue = [[NSOperationQueue alloc] init];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:highlight ? elm.imageRollUrl : elm.imageUrl]];
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(requestDone:)];
    request.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                        elm, @"element",
                        imgView, @"imageView",
                        highlight ? elm.imageRollUrl : elm.imageUrl, @"imageUrl",
                        nil];
    [self.queue addOperation:request];
    
    [self startIndicator];
}

- (void)requestDone:(ASIHTTPRequest *)request{
    [self stopIndicator];
    
    NSDictionary *uiDict = request.userInfo;
    
    [self fix:uiDict[@"element"]
    imageView:uiDict[@"imageView"]
     imageUrl:uiDict[@"imageUrl"]
         data:[request responseData]
   addToCache:YES];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [self stopIndicator];
	NSLog(@"Request Failed: %@", [request error]);
}


@end

