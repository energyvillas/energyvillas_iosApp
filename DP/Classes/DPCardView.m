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
    CGSize cardSize, insetSize;
    CGFloat baseFontSize, zoomFontSize;
    CGRect baseLabelFrame, zoomLabelFrame;
    BOOL useLabel;
}

@synthesize element;

- (id)initWithFrame:(CGRect)frame
        dataElement:(Category *)elm
           cardSize:(CGSize)aCardSize
      cardInsetSize:(CGSize)aInsetSize {
    useLabel = NO;
    cardSize = aCardSize;
    insetSize = aInsetSize;
    
    frame.size.width = cardSize.width;
    frame.size.height =cardSize.height;
    
    self = [super initWithFrame:frame];
    if (self) {
        element = elm;
        
        self.backgroundColor = [UIColor clearColor];//[UIColor redColor];//
    }
    return self;
}

-(void) cleanUp {
    if (self.queue) {
        [self stopIndicator];
        
        for (id op in self.queue.operations)
            if ([op isKindOfClass:[ASIHTTPRequest class]]) {
                [((ASIHTTPRequest *)op) clearDelegatesAndCancel];
                [((ASIHTTPRequest *)op) setDidFinishSelector:nil];
                ((ASIHTTPRequest *)op).delegate = nil;
            }
        
        [self.queue cancelAllOperations];
    }
    
    self.queue = nil;
    
    self.imageView = nil;
    self.zoomImageView = nil;
    self.busyIndicator = nil;
    self.label = nil;
    self.element = nil;
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
                self.imageView.image = [UIImage imageNamed:element.imageUrl];
//            self.imageView.image = [UIImage imageNamed:[self calcImageName:element.imageUrl highlight:NO]];
            else
                [self loadImageAsync:element highlight:NO inView:self.imageView];
        }
        
        if (!self.zoomImageView) {            
            CGRect zoomFrame = CGRectMake(0, 0,
                                          cardSize.width  + 2 * insetSize.width,
                                          cardSize.height + 2 * insetSize.height);

            self.zoomImageView = [[UIImageView alloc] initWithFrame:zoomFrame];
            self.zoomImageView.contentMode = UIViewContentModeCenter; //ScaleAspectFit;
            
            if (isLocalUrl(element.imageRollUrl))
                self.zoomImageView.image = [UIImage imageNamed:element.imageRollUrl];
//            self.zoomImageView.image = [UIImage imageNamed:[self calcImageName:element.imageRollUrl highlight:YES]];
            else
                [self loadImageAsync:element highlight:YES inView:self.zoomImageView];
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


- (void) zoomCard:(NSTimeInterval)duration position:(CGPoint)newCenter{
    CGRect zoomFrame = CGRectInset(CGRectMake(0, 0, cardSize.width, cardSize.height),
                                   -insetSize.width, -insetSize.height);
    zoomFrame = CGRectChangeCenter(zoomFrame, newCenter);

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDelay:0.0];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self cache:YES];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    
    self.frame = zoomFrame;
    self.imageView.center = calcBoundsCenterOfView(self);
    self.zoomImageView.center = calcBoundsCenterOfView(self);
    if (self.busyIndicator)
        self.busyIndicator.center = calcBoundsCenterOfView(self);
    [self.imageView removeFromSuperview];
    [self addSubview:self.zoomImageView];

    if (self.busyIndicator)
        [self bringSubviewToFront:self.busyIndicator];

    [UIView commitAnimations];
}

- (void) cancelCardZoom:(NSTimeInterval)duration {
    CGRect unZoomFrame = CGRectInset(self.frame, insetSize.width, insetSize.height);
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDelay:0.0];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self cache:YES];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    
    self.frame = unZoomFrame;
    self.imageView.center = calcBoundsCenterOfView(self);
    self.zoomImageView.center = calcBoundsCenterOfView(self);
    if (self.busyIndicator)
        self.busyIndicator.center = calcBoundsCenterOfView(self);
    [self.zoomImageView removeFromSuperview];
    [self addSubview:self.imageView];
    
    if (self.busyIndicator)
        [self bringSubviewToFront:self.busyIndicator];
    
    [UIView commitAnimations];
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
    int fw = frm.size.width + (!zoomed ? 0 : 2 * insetSize.width);
    int fh = frm.size.height + (!zoomed ? 0 : 2 * insetSize.height);
    
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

- (void) startIndicator {
    if(!self.busyIndicator) {
        self.busyIndicator = [[UIActivityIndicatorView alloc]
                              initWithActivityIndicatorStyle:(IS_IPAD
                                                              ? UIActivityIndicatorViewStyleWhiteLarge
                                                              : UIActivityIndicatorViewStyleWhite)];
        
		self.busyIndicator.hidesWhenStopped = TRUE;
        [self addSubview:self.busyIndicator];
        self.busyIndicator.center = calcBoundsCenterOfView(self);
    }

    if (!self.busyIndicator.isAnimating) {
        [self.busyIndicator startAnimating];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self bringSubviewToFront:self.busyIndicator];
        });
    }
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
    
    releaseSubViews(imgView);
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
    {
        [imgView addSubview: createImageViewLoading(imgView.bounds, YES, YES)];

        [self doloadImageAsync:elm highlight:highlight inView:imgView];
    }
}

- (void) doloadImageAsync:(Category *)elm highlight:(BOOL)highlight inView:(UIImageView *)imgView {
    if (!self.queue)
        self.queue = [[NSOperationQueue alloc] init];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:highlight ? elm.imageRollUrl : elm.imageUrl]];
    __block ASIHTTPRequest *ir = request;
    __block id this = self;
    [request setCompletionBlock:^{ [this requestDone:ir]; }];
    [request setFailedBlock:^{ [this requestFailed:ir]; }];

    request.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                        elm, @"element",
                        imgView, @"imageView",
                        highlight ? elm.imageRollUrl : elm.imageUrl, @"imageUrl",
                        nil];
    [self.queue addOperation:request];
    
    [self startIndicator];
}

- (void)requestDone:(ASIHTTPRequest *)request {
    [self stopIndicator];

    NSDictionary *uiDict = request.userInfo;
    
    [self fix:uiDict[@"element"]
    imageView:uiDict[@"imageView"]
     imageUrl:uiDict[@"imageUrl"]
         data:[request responseData]
   addToCache:YES];
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    [self stopIndicator];
}


@end

