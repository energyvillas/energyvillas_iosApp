//
//  DPWebContentViewController.h
//  DP
//
//  Created by Γεώργιος Γράβος on 3/25/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "UINavContentViewController.h"

@interface DPHtmlContentViewController : UINavContentViewController

- (id) initWithHTML:(NSString *)aHtml;
- (id) initWithContentUrl:(NSURL *)aUrl;

@end
