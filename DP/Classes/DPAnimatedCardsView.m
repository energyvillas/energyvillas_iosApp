//
//  DPAnimatedCategoriesView.m
//  Untitled
//
//  Created by Γεώργιος Γράβος on 4/4/13.
//
//

#import "DPAnimatedCardsView.h"
#import "DPCardView.h"
#import "DPConstants.h"
#import <Quartzcore/Quartzcore.h>


@interface DPAnimatedCardsView () {
    int maxX;
    int maxY;
    int ofsX;
    int ofsY;
    CGFloat maxDistance;
    NSTimeInterval moveDuration, zoomDuration;
    CGRect confinementRect;
    int level;
}

@property (strong, nonatomic) NSMutableArray *cards;
@property (strong, nonatomic) NSArray *categories;
@property (strong, nonatomic) UIView *tapView;
@property (strong, nonatomic) UITapGestureRecognizer *tapGesture;
@property (strong, nonatomic) UIPanGestureRecognizer *panGesture;
@property (strong, nonatomic) DPCardView *currentCard;
@property (strong, nonatomic) DPCardView *panningCard;
@property (nonatomic) CGSize cardSize;
@property (nonatomic) CGSize cardInsetSize;

@end 


@implementation DPAnimatedCardsView

- (id)initWithFrame:(CGRect)frame
         categories:(NSArray *)aCategories
           cardSize:(CGSize)aCardSize
      cardInsetSize:(CGSize)aInsetSize
       moveDuration:(NSTimeInterval)movedur
       zoomDuration:(NSTimeInterval)zoomdur
              level:(int)alevel
{
    self = [self initWithFrame:frame];
    if (self) {
        level = alevel;
        self.currentCard = nil; // -1
        self.cardSize = aCardSize;
        self.cardInsetSize = aInsetSize;
        
        moveDuration = movedur;
        zoomDuration = zoomdur;
        self.categories = aCategories;
    }
    return self;
}

-  (void) didMoveToSuperview {
    [super didMoveToSuperview];
    if (self.superview != nil) {
        [self addCardAndTapViews];
        [self animateCards:moveDuration];
    }
}

- (void) removeFromSuperview {
    [self cancelAllAnimations];
    [self cleanCards];
    [super removeFromSuperview];
}

- (void) layoutSubviews {
    [super layoutSubviews];
    
/* ========= CAUTION ===========
    NEVER CALL animateCards, animateCard, etc....
    cause this method is called when we tap on a card 
    (zooming brings card tapped in front which causes the call to that method....)
*/
}

- (void) cleanCards {
    if  (self.cards)
        for (UIView *card in self.cards)
            [card removeFromSuperview];

    self.cards = nil;
}

- (void) addCardAndTapViews {
    [self setupCards];
    for (UIView *card in self.cards)
        [self addSubview:card];
    
    [self setupTapView];
}

- (void) setupTapView {
    if (!self.tapView) {
        self.tapView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,
                                                                self.bounds.size.width,
                                                                self.bounds.size.height)];
        self.tapView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.tapView];
    }

    if (!self.tapGesture) {
        self.tapGesture = [[UITapGestureRecognizer alloc]
                           initWithTarget:self
                           action:@selector(handleTapGesture:)];
        self.tapGesture.delegate = self;
        self.tapGesture.numberOfTapsRequired = 1;
    }

    if (!self.panGesture) {
        self.panGesture = [[UIPanGestureRecognizer alloc]
                           initWithTarget:self
                           action:@selector(hanldePanGesture:)];
        self.panGesture.minimumNumberOfTouches = 1;
        self.panGesture.maximumNumberOfTouches = 1;
        self.panGesture.delegate = self;
    }

    [self.tapView removeGestureRecognizer:self.tapGesture];
    [self.tapView addGestureRecognizer:self.tapGesture];

    [self.tapView removeGestureRecognizer:self.panGesture];
    [self.tapView addGestureRecognizer:self.panGesture];

    [self bringSubviewToFront:self.tapView];
}

- (BOOL) gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.panGesture) {
        CGPoint panPoint = [self.panGesture locationInView:self.tapView];
        BOOL onCard = [self findCardUnderPoint:panPoint] != nil;
        return onCard;
    }
    
    return YES;
}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if (gestureRecognizer.view != self.tapView)
        return NO;
    
    // if the gesture recognizers are on different views, don't allow simultaneous recognition
    if (gestureRecognizer.view != otherGestureRecognizer.view)
        return NO;
    
    if (gestureRecognizer == self.panGesture && otherGestureRecognizer == self.tapGesture)
        return NO;
    
    // so that the pagecontrol's gesture to go back and forth between pages works...
    return YES;
}

-(DPCardView *) findCardUnderPoint:(CGPoint)pnt {
    DPCardView *result = nil;
    int cnt = (int)self.cards.count - 1;
    // for loop downwards cause views are in stack fashion - i>j => v[i] in front/on top of v[j]
    for (int i = cnt; i >= 0 ; i--) {
        UIView *card = (UIView *)self.cards[i];
        if ( [self point:pnt inPresentationFrame:card] ) {
            result = self.cards[i];
            break;
        }
    };
    return result;
}

- (CGPoint) confinePoint:(CGPoint)point inRect:(CGRect)rect {
    if (!CGRectContainsPoint(rect, point)) {
        if (point.x < CGRectGetMinX(rect))
            point.x = CGRectGetMinX(rect);
        else if (point.x > CGRectGetMaxX(rect))
            point.x = CGRectGetMaxX(rect);
        
        if (point.y < CGRectGetMinY(rect))
            point.y = CGRectGetMinY(rect);
        else if (point.y > CGRectGetMaxY(rect))
            point.y = CGRectGetMaxY(rect);
    }
    
    return point;
}

- (void) hanldePanGesture:(UIGestureRecognizer *) sender {
    if (sender != self.panGesture) return;
        
    if (self.panGesture.state == UIGestureRecognizerStateBegan) {
        CGPoint panPoint = [self.panGesture locationInView:self.tapView];
        self.panningCard = [self findCardUnderPoint:panPoint];
        if (!self.panningCard) return;
        if (self.panningCard == self.currentCard)
            self.panningCard = nil;
        if (!self.panningCard) return;
    }
    
    if (!self.panningCard) return;
    
    [self.panningCard.layer removeAllAnimations];
    
    CGPoint translation = [self.panGesture translationInView:self.tapView];
    
    if (self.panGesture.state == UIGestureRecognizerStateBegan ||
        self.panGesture.state == UIGestureRecognizerStateChanged) {
        
        CGPoint newCenter = [self presentationCenterOf:self.panningCard];
        newCenter = CGPointMake(newCenter.x + translation.x,
                                newCenter.y + translation.y);
        newCenter = [self confinePoint:newCenter inRect:confinementRect];
        self.panningCard.center = newCenter;
        [self.panGesture setTranslation:CGPointZero inView:self.tapView];
    }

    if (self.panGesture.state == UIGestureRecognizerStateCancelled) {
        DPCardView *card = self.panningCard;        
        self.panningCard = nil;
        
        [self animateCard:card
                       to:[self calcNewCenter:card]
                 duration:moveDuration];
    } else if (self.panGesture.state == UIGestureRecognizerStateEnded) {
        CGPoint velocity = [self.panGesture velocityInView:self.tapView];
        CGPoint newCenter = [self presentationCenterOf:self.panningCard];
        newCenter = CGPointMake(newCenter.x + translation.x,
                                newCenter.y + translation.y);
        newCenter = CGPointMake(newCenter.x + 0.35f * velocity.x,
                                newCenter.y + 0.35f * velocity.y);
        newCenter = [self confinePoint:newCenter inRect:confinementRect];
        
        DPCardView *card = self.panningCard;
        self.panningCard = nil;
        
        [UIView animateWithDuration:0.35f
                              delay:0.0
                            options:UIViewAnimationCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                              card.center = newCenter;
                         }
                         completion:^(BOOL finished){
                             if (!finished)
                                 return;
                             
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 [self animateCard:card
                                                to:[self calcNewCenter:card]
                                          duration:moveDuration];
                             });
                         }
         ];
    }
}

-(void) handleTapGesture:(UIGestureRecognizer *) sender {
    CGPoint tapPoint = [sender locationInView:self.tapView];

    DPCardView *oldCurrent = self.currentCard;
    self.currentCard = [self findCardUnderPoint:tapPoint];
    
    if (oldCurrent == nil/*-1*/) {
        if (self.currentCard != nil/*-1*/) {
            // handle tap
            DPCardView *card = self.currentCard; //self.cards[self.currentCard];
            [self cancelCardAnimation:card];
			[self zoomCard:card duration:zoomDuration];
        }
    } else {
        if (self.currentCard == nil/*-1*/) {
            // resume card animation
            DPCardView *oldcard = oldCurrent; //self.cards[oldCurrent];
            self.currentCard = nil/*-1*/;
            [self cancelCardZoom:oldcard duration:zoomDuration];
            [self animateCard:oldcard to:[self calcNewCenter:oldcard] duration:moveDuration];
        } else if (self.currentCard == oldCurrent) {
            // stop ALL animations
            // launch the card's sub view
            DPDataElement *element = self.currentCard.element;//((DPCtgCardView *)self.cards[self.currentCard]).category;
            [self cancelAllAnimations];
            [self elementTapped:nil element:element];
        } else { // we tapped another card
            // we can either :
            //      resume old, stop and zoom curr,
            // i prefer that ====
            
            // resume
            DPCardView *oldcard = oldCurrent;//self.cards[oldCurrent];
            DPCardView *currcard = self.currentCard;//self.cards[self.currentCard];
            
            [self cancelCardZoom:oldcard duration:zoomDuration];
            [self animateCard:oldcard to:[self calcNewCenter:oldcard] duration:moveDuration];
            
            // stop
            [self cancelCardAnimation:currcard];
            [self zoomCard:currcard duration:zoomDuration];
            
            // or
            //      just resume old and set curr to -1...
        }
    }
}

// DPScrollableViewDelegate method
- (void) elementTapped:(id)sender element:(id)element {
    if (self.scrollableViewDelegate != nil) {
        if([self.scrollableViewDelegate respondsToSelector:@selector(elementTapped:element:)]) {
            [self.scrollableViewDelegate elementTapped:nil element:element];
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
    for (id card in self.cards)
        [self animateCard:card to:[self calcNewCenter:card] duration:duration];
    
}

- (void) cancelAllAnimations {
    for (id card in self.cards) {
        [self cancelCardAnimation:card];
        [self cancelCardZoom:card duration:0.0];
    }
    
    self.currentCard = nil/*-1*/;
}

- (CGFloat) distance:(CGPoint)p1 from:(CGPoint)p2 {
    CGFloat result = sqrt((p1.x - p2.x)*(p1.x - p2.x) + (p1.y - p2.y)*(p1.y - p2.y));
    return result;
}

- (NSTimeInterval) duration:(NSTimeInterval)duration forDistance:(CGFloat)distance {
    NSTimeInterval result = (distance * duration)/ maxDistance;
    return result;
}

- (void) animateCard:(DPCardView *)card to:(CGPoint)newCenter
              duration:(NSTimeInterval)duration {
    NSTimeInterval newDuration = [self duration:duration
                                    forDistance:[self distance:newCenter
                                                          from:[self presentationCenterOf:card]]];

    [UIView animateWithDuration:newDuration
                          delay:0.0
                        options:UIViewAnimationCurveLinear | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         card.center = newCenter;
                     }
                     completion:^(BOOL finished){                       
                         if (!finished)
                             return;
                         
                         dispatch_async(dispatch_get_main_queue(), ^{
                             [self animateCard:card to:[self calcNewCenter:card] duration:duration];
                         });
                     }
     ];
}

- (void) cancelCardAnimation:(DPCardView *)card {
	CGPoint cntr = [self presentationCenterOf:card];
	[card.layer removeAllAnimations];
	card.center = cntr;
}

- (void) bringCardForward:(DPCardView *)card {
    if (self.currentCard != nil/*-1*/ && self.currentCard == card) {
        int cardIndex = (int)[self.subviews indexOfObject:card];
        int topCardIndex = (int)[self.subviews indexOfObject:self.tapView] - 1;
        if (cardIndex < topCardIndex) {
            [self.cards exchangeObjectAtIndex:cardIndex withObjectAtIndex:topCardIndex];
            [self bringSubviewToFront:card];
            [self bringSubviewToFront:self.tapView];
        }
    }
}

- (void) zoomCard:(DPCardView *)card duration:(NSTimeInterval)duration {
    [self bringCardForward:card];

    CGFloat xCenter = (IS_IPAD || IS_PORTRAIT || level == 1)
                        ? self.bounds.size.width / 2.0
                        : 20.0 + ((self.cardSize.width + self.cardInsetSize.width) / 2.0);
    CGFloat yCenter = (IS_IPAD || IS_PORTRAIT || level == 1)
                        ? self.bounds.size.height / 2.0
                        : self.bounds.size.height - 8.0f - ((self.cardSize.height + self.cardInsetSize.height) / 2.0);
    
    CGPoint where = CGPointMake(xCenter, yCenter);
    
    [card zoomCard:duration position:where];
}

- (void) cancelCardZoom:(DPCardView *)card duration:(NSTimeInterval)duration {
    [card cancelCardZoom:duration];
}

//- (int) findCardWithKey:(NSString *)key {
//    int indx = -1;
//    
//    for (int i = 0; i < cards.count; i++) {
//        DPCtgCardView *card = cards[i];
//        if ( [card.category.key isEqualToString:key] ) {
//            indx = i;
//            break;
//        }
//    }
//    
//    return indx;
//}

- (CGPoint) calcNewCenter:(DPCardView *)target {
    [self calcSizes];
#ifdef LOG_CARDS
    NSLog(@"max (X, Y) = (%d, %d)", maxX, maxY);
    NSLogFrame(@"CARDS CONTAINER FRAME", self.frame);
    NSLogFrame(@"CARDS CONTAINER BOUNDS", self.bounds);
#endif
    CGPoint c = [self presentationCenterOf:target]; //target.center;
    BOOL atLeft = c.x < (maxX / 2);
    BOOL atTop = c.y < (maxY / 2);
    
    BOOL flipHorz = (arc4random() % 2) == 0;
    BOOL toLeft = flipHorz ? !atLeft : atLeft;
    BOOL flipVert = /*flipHorz ||*/ (arc4random() % 2) == 0;
    BOOL toTop = flipVert ? !atTop : atTop;
    
    CGFloat x = (arc4random() % (maxX / 2)) + (toLeft ? 0 : (maxX / 2));
    CGFloat y = (arc4random() % (maxY / 2)) + (toTop ? 0 : (maxY / 2));
#ifdef LOG_CARDS
    NSLog(@"random (X, Y) = (%.0f, %.0f)", x, y);
#endif
    int edge = arc4random() % 2; //(arc4random() % 3) == 0;
    if (edge == 0) /* top or bottom */{
        if (toLeft)
            x = x < ofsX ? ofsX : x;
        else
            x = x > (maxX - ofsX) ? maxX - ofsX : x;
        y = toTop ? ofsY : maxY - ofsY;
    } else if (edge == 1) {
        x = toLeft ? ofsX : maxX - ofsX;
        if (toTop)
            y = y < ofsY ? ofsY : y;
        else
            y = y > (maxY - ofsY) ? maxY - ofsY : y;
    }
/*
    else {
        if (toLeft)
            x = x < ofsX ? ofsX : x;
        else
            x = x > (maxX - ofsX) ? maxX - ofsX : x;

        if (toTop)
            y = y < ofsY ? ofsY : y;
        else
            y = y > (maxY - ofsY) ? maxY - ofsY : y;
    }
*/    
#ifdef LOG_CARDS
    NSLog(@"NEW CENTER : (%.0f, %.0f)", x, y);
#endif
    return CGPointMake(x, y);
}

- (void) calcSizes {
//    if (maxX > 0) return; // means we have done it.
    CGSize containerSize = self.frame.size;
    maxX = containerSize.width;// - self.cardSize.width;
    maxY = containerSize.height;// - self.cardSize.height;
    ofsX = self.cardSize.width / 2;
    ofsY = self.cardSize.height / 2;
    maxDistance = sqrt((maxX - 2 * ofsX) * (maxX - 2 * ofsX) +
                       (maxY - 2 * ofsY) * (maxY - 2 * ofsY));
    confinementRect = CGRectMake(ofsX, ofsY, maxX - 2 * ofsX, maxY - 2 * ofsY);
#ifdef LOG_CARDS
    NSLogFrame(@"ANIM frame", self.frame);
#endif
}

- (void) setupCards {
    if (self.cards) return;

    [self calcSizes];
    
    NSMutableArray *mcards = [[NSMutableArray alloc] init];
    for (int i = 0; i < self.categories.count; i++) {
        NSInteger rx = (arc4random() % maxX);// + ofsX;
        NSInteger ry = (arc4random() % maxY);// + ofsY;
        DPCardView *card = [[DPCardView alloc] initWithFrame:CGRectMake(rx, ry,
                                                                        self.cardSize.width,
                                                                        self.cardSize.height)
                                                 dataElement:self.categories[i]
                                                    cardSize:self.cardSize
                                               cardInsetSize:self.cardInsetSize];
        card.center = [self calcNewCenter:card];        
        [mcards addObject:card];
    }
    self.cards = mcards;
}

- (void) frameChanged {
    [self cancelAllAnimations];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        maxX = 0;
        [self cleanCards];
        [self addCardAndTapViews];
        [self animateCards:moveDuration];
    });
}

- (void) startAnimation {
    if (self.cards)
        [self animateCards:moveDuration];
}

- (void) stopAnimation {
    if (self.cards)
        [self cancelAllAnimations];
}

- (void) dealloc {
    [self cancelAllAnimations];
    [self cleanCards];

    self.cards = nil;
    self.categories = nil;
    self.tapView = nil;
    self.tapGesture = nil;
    self.panGesture = nil;
    self.currentCard = nil;
    self.panningCard = nil;
}

@end
