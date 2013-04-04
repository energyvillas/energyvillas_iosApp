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

@end

@implementation DPCtgCardView {
    CGSize cardSize;
    CGFloat baseFontSize, zoomFontSize;
    CGRect baseLabelFrame, zoomLabelFrame;
}

@synthesize category, imageView, label;

- (id)initWithFrame:(CGRect)frame category:(Category *)ctg {
    self = [super initWithFrame:frame];
    if (self) {
        category = ctg;
        cardSize = IS_IPAD
                ? CGSizeMake(IPAD_CARD_WIDTH, IPAD_CARD_HEIGHT)
                : CGSizeMake(IPHONE_CARD_WIDTH, IPHONE_CARD_HEIGHT);
        
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
            imageView.image = [UIImage imageNamed:category.imageUrl];
            imageView.backgroundColor = [UIColor redColor];
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

- (void) zoomCard {
    [UIView animateWithDuration:DURATION_ZOOM
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

- (void) cancelCardZoom {
    [UIView animateWithDuration:DURATION_ZOOM
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

@end

