//
//  CustomMenuBarItem.m
//  TLife
//
//  Created by Konstantinos Manos on 5/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CustomMenuBarItem.h"


@implementation UIBarButtonItem (Customize)

- (UIBarButtonItem*) initBarItemWithImage:(UIImage*)image target:(id)aTarget action:(SEL)aAction{
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	[button setBackgroundImage: [image stretchableImageWithLeftCapWidth:7.0 topCapHeight:0.0] forState:UIControlStateNormal];	
	button.frame= CGRectMake(0.0, 0.0, image.size.width, image.size.height);
	
	[button addTarget:aTarget action:aAction forControlEvents:UIControlEventTouchUpInside];
	
	UIView *v=[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, image.size.width, image.size.height) ];
	[v addSubview:button];
	
	return [[UIBarButtonItem alloc] initWithCustomView:v];
}

@end
