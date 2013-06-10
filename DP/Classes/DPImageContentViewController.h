//
//  DPImageContentViewController.h
//  DP
//
//  Created by Γεώργιος Γράβος on 3/24/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UINavContentViewController.h"
#import "Article.h"

@interface DPImageContentViewController : UINavContentViewController <UIScrollViewDelegate>

- (id) initWithArticle:(Article *)aArticle;
- (id) initWithArticle:(Article *)aArticle showNavItem:(BOOL)showNavItem;
//- (id) initWithImage:(UIImage *)aImage;
//- (id) initWithImageUrl:(NSURL *)imageUrl;
- (id) initWithImageName:(NSString *)imageName;

@end
