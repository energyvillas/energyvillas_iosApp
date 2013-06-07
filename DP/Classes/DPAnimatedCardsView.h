//
//  DPAnimatedCategoriesView.h
//  Untitled
//
//  Created by Γεώργιος Γράβος on 4/4/13.
//
//

#import <UIKit/UIKit.h>
#import "DPScrollableViewDelegate.h"

@interface DPAnimatedCardsView : UIView <DPScrollableViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, weak) id <DPScrollableViewDelegate> scrollableViewDelegate;

- (id)initWithFrame:(CGRect)frame
         categories:(NSArray *)categories
           cardSize:(CGSize)aCardSize
      cardInsetSize:(CGSize)aInsetSize
       moveDuration:(NSTimeInterval)movedur
       zoomDuration:(NSTimeInterval)zoomdur
              level:(int)alevel;

- (void) startAnimation;
- (void) stopAnimation;
- (void) frameChanged;
@end
