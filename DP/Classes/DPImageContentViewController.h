//
//  DPImageContentViewController.h
//  DP
//
//  Created by Γεώργιος Γράβος on 3/24/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "UINavContentViewController.h"
#import "Article.h"

@interface DPImageContentViewController : UINavContentViewController <UIGestureRecognizerDelegate>

- (id) initWithArticle:(Article *)aArticle;
- (id) initWithImage:(UIImage *)aImage;
- (id) initWithImageUrl:(NSURL *)imageUrl;
- (id) initWithImageName:(NSString *)imageName;

@end
