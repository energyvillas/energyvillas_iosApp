//
//  DPAnimatedCategoriesView.h
//  Untitled
//
//  Created by Γεώργιος Γράβος on 4/4/13.
//
//

#import <UIKit/UIKit.h>
#import "DPScrollableViewDelegate.h"

@interface DPAnimatedCardsView : UIView <DPScrollableViewDelegate>

@property (nonatomic, weak) id <DPScrollableViewDelegate> scrollableViewDelegate;

- (id)initWithFrame:(CGRect)frame categories:(NSArray *)categories;

- (void) frameChanged;
@end