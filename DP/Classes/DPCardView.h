//
//  DPCtgCardView.h
//  Untitled
//
//  Created by Γεώργιος Γράβος on 4/4/13.
//
//

#import <UIKit/UIKit.h>
#import "Category.h"

@interface DPCardView : UIView

@property (strong, nonatomic) Category *element;

- (id) initWithFrame:(CGRect)frame
         dataElement:(Category *)elm
            cardSize:(CGSize)aCardSize
       cardInsetSize:(CGSize)aInsetSize;

- (void) zoomCard:(NSTimeInterval)duration position:(CGPoint)newCenter;
- (void) cancelCardZoom:(NSTimeInterval)duration;

@end
