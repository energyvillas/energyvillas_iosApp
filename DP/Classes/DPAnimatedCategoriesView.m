//
//  DPAnimatedCategoriesView.m
//  Untitled
//
//  Created by Γεώργιος Γράβος on 4/4/13.
//
//

#import "DPAnimatedCategoriesView.h"
#import "DPCtgCardView.h"
#import "DPConstants.h"
#import <Quartzcore/Quartzcore.h>

#define DURATION_MOVE ((NSTimeInterval)10.0)

@interface DPAnimatedCategoriesView () {
    int maxX;
    int maxY;
    int ofsX;
    int ofsY;
    NSTimeInterval moveDuration, zoomDuration;
}

@property (strong, nonatomic) NSArray *cards;
@property (strong, nonatomic) NSArray *categories;
@property (strong, nonatomic) UIView *tapView;
@property (strong, nonatomic) UITapGestureRecognizer *tapGesture;
@property (nonatomic, setter = setCurrentCard:) int currentCard;
@property (nonatomic) CGSize cardSize;

@end 


@implementation DPAnimatedCategoriesView

@synthesize cards, categories, tapView, cardSize;

- (void) setCurrentCard:(int)value {
    _currentCard = value;
    NSLog(@"*** currentCard = %i", value);
}

- (id)initWithFrame:(CGRect)frame categories:(NSArray *)aCategories {
    self = [self initWithFrame:frame];
    if (self) {
        self.currentCard = -1;
        cardSize = IS_IPAD
                ? CGSizeMake(IPAD_CARD_WIDTH, IPAD_CARD_HEIGHT)
                : CGSizeMake(IPHONE_CARD_WIDTH, IPHONE_CARD_HEIGHT);
        
        moveDuration = DURATION_MOVE;
        zoomDuration = DURATION_ZOOM;
        categories = aCategories;
    }
    return self;
}

-  (void) didMoveToSuperview {
    [super didMoveToSuperview];
    if (self.superview != nil) {
        [self setupCards];
        for (UIView *card in cards)
            [self addSubview:card];
        
        [self setupTapView];
        [self animateCards:moveDuration];
   }
}

- (void) removeFromSuperview {
    [self cancelAllAnimations];
    [super removeFromSuperview];
}

- (void) layoutSubviews {
    [super layoutSubviews];
}

- (void) setupTapView {
    if (!self.tapGesture) {
        self.tapGesture = [[UITapGestureRecognizer alloc]
                           initWithTarget:self
                           action:@selector(handleTapGesture:)];
        self.tapGesture.numberOfTapsRequired = 1;
    }
    
    if (!tapView) {
        tapView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,
                                                           self.bounds.size.width,
                                                           self.bounds.size.height)];
        tapView.backgroundColor = [UIColor clearColor];
        [self addSubview:tapView];
    }
    
    [tapView removeGestureRecognizer:self.tapGesture];
    [tapView addGestureRecognizer:self.tapGesture];
}

-(void) handleTapGesture:(UIGestureRecognizer *) sender {
    CGPoint tapPoint = [sender locationInView:tapView];
    int tapX = (int) tapPoint.x;
    int tapY = (int) tapPoint.y;
    NSLog(@"TAPPED X:%d Y:%d", tapX, tapY);

    int oldCurrent = self.currentCard;
    int cnt = cards.count - 1;
    self.currentCard = -1;
    
    // downwards cause views are in stack fashion - i>j => v[i] in front/on top of v[j]
    for (int i = cnt; i >= 0 ; i--) { 
        UIView *card = (UIView *)cards[i];
        if ( [self point:tapPoint inPresentationFrame:card] ) {
            self.currentCard = i;
            break;
        }
    };
   
    if (oldCurrent == -1) {
        if (self.currentCard != -1) {
            // handle tap
            DPCtgCardView *card = cards[self.currentCard];
            [self cancelCardAnimation:card];
            [self zoomCard:cards[self.currentCard]];
        }
    } else {
        if (self.currentCard == -1) {
            // resume card animation
            self.currentCard = -1;
            [self cancelCardZoom:cards[oldCurrent]];
            [self animateCard:cards[oldCurrent]
                     duration:moveDuration];
        } else if (self.currentCard == oldCurrent) {
            // stop ALL animations
            // launch the card's sub view
        } else { // we tapped another card
            // we can either :
            //      resume old, stop and zoom curr,
            // i prefer that ====
            
            // resume
            [self cancelCardZoom:cards[oldCurrent]];
            [self animateCard:cards[oldCurrent]
                     duration:moveDuration];
            
            // stop
            [self cancelCardAnimation:cards[self.currentCard]];
            [self zoomCard:cards[self.currentCard]];
            
            // or
            //      just resume old and set curr to -1...
        }
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

-(BOOL) point:(CGPoint)aPoint inPresentationFrame:(UIView *)target {
    // this is valid since the target has the same parent as the point's view.
    return CGRectContainsPoint([self presentationFrameOf:target], aPoint);
}

- (void) animateCards:(NSTimeInterval)duration {
    for (id card in cards)
        [self animateCard:card duration:duration];
    
}

- (void) cancelAllAnimations {
    for (id card in cards) {
        [self cancelCardAnimation:card];
        [self cancelCardZoom:card];
    }
}

- (void) animateCard:(DPCtgCardView *)card
              duration:(NSTimeInterval)duration {
    [UIView animateWithDuration:duration
                          delay:0.0
                        options:UIViewAnimationCurveLinear | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         card.center = [self calcNewCenter];
                     }
                     completion:^(BOOL finished){                       
                         if (finished)
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 [self animateCard:card duration:duration];
                             });
                     }
     ];
}

- (void) cancelCardAnimation:(DPCtgCardView *)card {
    [UIView animateWithDuration:0.0
                          delay:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         card.center = [self presentationCenterOf:card];
                     }
                     completion:NULL //^(BOOL finished){}
     ];
}

- (void) bringCardForward:(DPCtgCardView *)card {
    if (self.currentCard != -1 && cards[self.currentCard] == card) {
        int vi = [self.subviews indexOfObject:card];
        int tvi = [self.subviews indexOfObject:tapView];
        if (vi < tvi - 1) {
            [self bringSubviewToFront:card];
            [self bringSubviewToFront:tapView];
        }
    }
}

- (void) zoomCard:(DPCtgCardView *)card {
    [self bringCardForward:card];

    [card zoomCard];
}

- (void) cancelCardZoom:(DPCtgCardView *)card {
    [card cancelCardZoom];
}

- (int) findCardWithKey:(NSString *)key {
    int indx = -1;
    
    for (int i = 0; i < cards.count; i++) {
        DPCtgCardView *card = cards[i];
        if ( [card.category.key isEqualToString:key] ) {
            indx = i;
            break;
        }
    }
    
    return indx;
}

- (CGPoint) calcNewCenter {
    [self calcSizes];
    
    return CGPointMake((arc4random() % maxX) + ofsX,
                       (arc4random() % maxY) + ofsY);
}

- (void) calcSizes {
    if (maxX > 0) return; // means we have done it.
    CGSize containerSize = self.frame.size;
    maxX = containerSize.width - cardSize.width;
    maxY = containerSize.height - cardSize.height;
    ofsX = cardSize.width / 2;
    ofsY = cardSize.height / 2;
}

- (void) setupCards {
    if (cards) return;

    [self calcSizes];
    
    NSMutableArray *mcards = [[NSMutableArray alloc] init];
    for (int i = 0; i < categories.count; i++) {
        NSInteger rx = (arc4random() % maxX);// + ofsX;
        NSInteger ry = (arc4random() % maxY);// + ofsY;
        DPCtgCardView *card = [[DPCtgCardView alloc]
                               initWithFrame:CGRectMake(rx, ry, cardSize.width, cardSize.height)
                                    category:categories[i]];
        
        [mcards addObject:card];
    }
    cards = [NSArray arrayWithArray:mcards];
}

@end