//
//  CustomMenuBarItem.h
//  TLife
//
//  Created by Konstantinos Manos on 5/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIBarButtonItem (Customize)
- (UIBarButtonItem*) initBarItemWithImage:(UIImage*)image target:(id)target action:(SEL)action;

@end
