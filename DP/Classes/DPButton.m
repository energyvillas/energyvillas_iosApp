//
//  DPButton.m
//  energyVillas
//
//  Created by Γεώργιος Γράβος on 6/10/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPButton.h"
#import <QuartzCore/QuartzCore.h>

@interface DPButton ()
@property (strong,  nonatomic) CALayer *extraLayer;
@end

@implementation DPButton

@synthesize extraLayer;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) setShowExtraLayerOnHighlight:(BOOL)val {
    _showExtraLayerOnHighlight = val;
    [self setNeedsDisplay];
    [self setNeedsLayout];
    
    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self setHighlighted:YES];
        [self setHighlighted:NO];
    });
}

- (BOOL) calcExtraLayerIsHidden:(BOOL)highlight {
    return self.showExtraLayerOnHighlight ^ highlight;
}

- (void) layoutSublayersOfLayer:(CALayer *)layer {
    if (layer == self.layer) {
        CGRect frm = layer.frame;
        CGRect bnds = layer.bounds;
        CGPoint pos = CGPointMake(layer.position.x - frm.origin.x,
                                  layer.position.y - frm.origin.y);

        if (extraLayer == nil) {
            extraLayer = [CALayer layer];
            extraLayer.bounds = bnds;
            extraLayer.position = pos;
            extraLayer.masksToBounds = YES;
            extraLayer.contentsRect = CGRectMake(0.0, 0.0, 1.0, 1.0);
            extraLayer.backgroundColor = (self.extraLayerColor
                                          ? self.extraLayerColor.CGColor
                                          : [UIColor colorWithWhite:0.0f alpha:0.65f].CGColor);
            extraLayer.hidden = [self calcExtraLayerIsHidden:self.isHighlighted];
         
            // thse are for debugging...
//            extraLayer.borderColor = [UIColor redColor].CGColor;
//            extraLayer.borderWidth = 3.0f;
//            extraLayer.cornerRadius = 10.0f;
            
            [self.layer addSublayer:extraLayer];
            [self bringSublayerToFront:extraLayer];
        }
        
        extraLayer.bounds = bnds;
        extraLayer.position = pos;
    }
    
    [super layoutSublayersOfLayer:layer];
}

- (void) setHighlighted:(BOOL)highlight {
    if (extraLayer != nil)
        extraLayer.hidden = [self calcExtraLayerIsHidden:highlight];

    [self bringSublayerToFront:extraLayer];

    [super setHighlighted:highlight];
}

- (void)bringSublayerToFront:(CALayer *)layer {
    CALayer *superlayer = layer.superlayer;
    [layer removeFromSuperlayer];
    [superlayer insertSublayer:layer atIndex:[superlayer.sublayers count]];
}

- (void)sendSublayerToBack:(CALayer *)layer {
    CALayer *superlayer = layer.superlayer;
    [layer removeFromSuperlayer];
    [superlayer insertSublayer:layer atIndex:0];
}

- (void) dealloc {
    extraLayer = nil;
}

@end
