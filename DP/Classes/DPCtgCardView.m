//
//  DPCtgCardView.m
//  Untitled
//
//  Created by Γεώργιος Γράβος on 4/4/13.
//
//

#import "DPCtgCardView.h"
#import "DPConstants.h"
#import <Quartzcore/Quartzcore.h>
#import "DPAppHelper.h"
#import "ASIHTTPRequest.h"

#define IPHONE_LABEL_MARGIN_VERT ((int)2)
#define IPAD_LABEL_MARGIN_VERT ((int)2)

#define IPHONE_CARD_RESIZE_WIDTH ((int)-5)
#define IPHONE_CARD_RESIZE_HEIGHT ((int)-5)
#define IPAD_CARD_RESIZE_WIDTH ((int)-10)
#define IPAD_CARD_RESIZE_HEIGHT ((int)-10)

#define IPHONE_LABEL_HEIGHT ((int)18)
#define IPAD_LABEL_HEIGHT ((int)22)

@interface DPCtgCardView ()

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UILabel *label;

@property (strong, nonatomic) UIActivityIndicatorView *busyIndicator;
@property (strong, nonatomic) NSOperationQueue *downloadQueue;

@end

@implementation DPCtgCardView {
    CGSize cardSize;
    CGFloat baseFontSize, zoomFontSize;
    CGRect baseLabelFrame, zoomLabelFrame;
}

@synthesize category, imageView, label;

- (id)initWithFrame:(CGRect)frame category:(Category *)ctg {
    cardSize = IS_IPAD
                    ? CGSizeMake(IPAD_CARD_WIDTH, IPAD_CARD_HEIGHT)
                    : CGSizeMake(IPHONE_CARD_WIDTH, IPHONE_CARD_HEIGHT);
    
    frame.size.width = cardSize.width;
    frame.size.height =cardSize.height;
    
    self = [super initWithFrame:frame];
    if (self) {
        category = ctg;
        
        self.backgroundColor = [UIColor colorWithHue: (arc4random() % 1000) / 1000.0
                                          saturation:1.0
                                          brightness:1.0
                                               alpha:1.0];
    }
    return self;
}

- (void) layoutSubviews {
    if (self.subviews.count == 0) {
        if (!imageView) {
            imageView = [[UIImageView alloc] initWithFrame:self.bounds];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            
            if ([self isLocalUrl:category.imageUrl])
                imageView.image = [UIImage imageNamed:[self calcImageName: category.imageUrl]];
            else
                [self loadImageAsync:category inView:imageView];

            imageView.image = [UIImage imageNamed:category.imageUrl];
           // imageView.backgroundColor = [UIColor redColor];
        }
        
        if (!label) {
            label = [[UILabel alloc] init];
            [self setupLabel:category.title];
        }
        
        [self addSubview:imageView];
        [self addSubview:label];
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

- (void) zoomCard:(NSTimeInterval)duration {
    [UIView animateWithDuration:duration
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         int rw = IS_IPAD ? IPAD_CARD_RESIZE_WIDTH : IPHONE_CARD_RESIZE_WIDTH;
                         int rh = IS_IPAD ? IPAD_CARD_RESIZE_HEIGHT : IPHONE_CARD_RESIZE_HEIGHT;
                         CGRect zoomFrame = CGRectInset(self.frame, rw, rh);
                         self.frame = zoomFrame;
                         imageView.frame = CGRectMake(0, 0,
                                                      zoomFrame.size.width,
                                                      zoomFrame.size.height);
                         label.frame = zoomLabelFrame;
                         label.font = [label.font fontWithSize:zoomFontSize];
                     }
                     completion:nil];
}

- (void) cancelCardZoom:(NSTimeInterval)duration {
    [UIView animateWithDuration:duration
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         CGRect frm = [self presentationFrameOf:self];
                         int diffX = frm.size.width - cardSize.width;
                         int diffY = frm.size.height - cardSize.height;
                         self.frame = CGRectInset(frm, diffX / 2, diffY / 2);

                         imageView.frame = CGRectMake(0, 0,
                                                      cardSize.width,
                                                      cardSize.height);
                         label.frame = baseLabelFrame;
                         label.font = [label.font fontWithSize:baseFontSize];
                     }
                     completion:nil];
}


- (void) setupLabel:(NSString *)title {
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
    int fw = frm.size.width - (!zoomed ? 0 : 2 * (IS_IPAD ? IPAD_CARD_RESIZE_WIDTH : IPHONE_CARD_RESIZE_WIDTH));
    int fh = frm.size.height - (!zoomed ? 0 : 2 * (IS_IPAD ? IPAD_CARD_RESIZE_HEIGHT : IPHONE_CARD_RESIZE_HEIGHT));
    
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

- (NSString *) calcImageName:(NSString *)baseName {
    NSLog(@"**** imageUrl (base) = %@", baseName);
    
    @try {
        NSArray *parts = [baseName componentsSeparatedByString:@"."];
        if (parts && parts.count == 2) {
            NSString *orientation = IS_PORTRAIT ? @"v" : @"h";
            // pending also fix the format string below.... NSString *lang = [DPAppHelper sharedInstance].currentLang;
            NSString *result = [NSString stringWithFormat:@"FreeDetails/%@_%@.%@", parts[0], orientation, parts[1]];
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

- (BOOL) isLocalUrl:(NSString *)urlstr {
    NSURL *url = [NSURL URLWithString:urlstr];
    return url.isFileReferenceURL || url.host == nil;
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
        self.downloadQueue &&
        self.downloadQueue.operationCount == 0) {
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
    imgView.image = [UIImage imageWithData:imgData];
    if (addToCache)
        [[DPAppHelper sharedInstance] saveImageToCache:imageUrl data:imgData];
}

- (void) loadImageAsync:(DPDataElement *)elm inView:(UIImageView *)imgView {
    DPAppHelper *appHelper = [DPAppHelper sharedInstance];
    NSData *imgData = [appHelper loadImageFromCache:[self calcImageName: elm.imageUrl]];
    if (imgData)
        [self fix:elm imageView:imgView imageUrl:[self calcImageName: elm.imageUrl] data:imgData addToCache:NO];
    else
        [self doloadImageAsync:elm inView:imgView];
}

- (void) doloadImageAsync:(DPDataElement *)elm inView:(UIImageView *)imgView {
    if (!self.downloadQueue)
        self.downloadQueue = [[NSOperationQueue alloc] init];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[self calcImageName:elm.imageUrl]]];
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(requestDone:)];
    request.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                        elm, @"element",
                        imgView, @"imageView",
                        [self calcImageName:elm.imageUrl], @"imageUrl",
                        nil];
    [self.downloadQueue addOperation:request];
    
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

