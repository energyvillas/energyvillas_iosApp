//
//  DPCtgCardView.h
//  Untitled
//
//  Created by Γεώργιος Γράβος on 4/4/13.
//
//

#import <UIKit/UIKit.h>
#import "Category.h"


#define IPHONE_CARD_WIDTH ((int)80)
#define IPHONE_CARD_HEIGHT ((int)80)
#define IPAD_CARD_WIDTH ((int)160)
#define IPAD_CARD_HEIGHT ((int)160)

#define DURATION_ZOOM ((NSTimeInterval)0.1)

@interface DPCtgCardView : UIView

@property (strong, nonatomic) Category *category;

- (id) initWithFrame:(CGRect)frame category:(Category *)ctg;

- (void) zoomCard:(NSTimeInterval)duration;
- (void) cancelCardZoom:(NSTimeInterval)duration;

@end
