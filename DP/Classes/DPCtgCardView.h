//
//  DPCtgCardView.h
//  Untitled
//
//  Created by Γεώργιος Γράβος on 4/4/13.
//
//

#import <UIKit/UIKit.h>
#import "Category.h"


#define IPHONE_CARD_WIDTH ((int)85)
#define IPHONE_CARD_HEIGHT ((int)85)
#define IPAD_CARD_WIDTH ((int)170)
#define IPAD_CARD_HEIGHT ((int)170)

#define DURATION_ZOOM ((NSTimeInterval)0.1)

@interface DPCtgCardView : UIView

@property (strong, nonatomic) Category *category;

- (id) initWithFrame:(CGRect)frame category:(Category *)ctg;

- (void) zoomCard:(NSTimeInterval)duration;
- (void) cancelCardZoom:(NSTimeInterval)duration;

@end
