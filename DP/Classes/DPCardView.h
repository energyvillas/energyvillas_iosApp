//
//  DPCtgCardView.h
//  Untitled
//
//  Created by Γεώργιος Γράβος on 4/4/13.
//
//

#import <UIKit/UIKit.h>
#import "Category.h"


#define IPHONE_CARD_WIDTH ((int)95)
#define IPHONE_CARD_HEIGHT ((int)95)
#define IPAD_CARD_WIDTH ((int)180)
#define IPAD_CARD_HEIGHT ((int)180)

#define DURATION_ZOOM ((NSTimeInterval)0.35)

@interface DPCardView : UIView

@property (strong, nonatomic) DPDataElement *element;

- (id) initWithFrame:(CGRect)frame dataElement:(DPDataElement *)elm;

- (void) zoomCard:(NSTimeInterval)duration position:(CGPoint)newCenter;
- (void) cancelCardZoom:(NSTimeInterval)duration;

@end
