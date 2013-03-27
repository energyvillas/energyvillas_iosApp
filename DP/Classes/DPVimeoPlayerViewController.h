//
//  DPVimeoPlayerViewController.h
//  DP
//
//  Created by Γεώργιος Γράβος on 3/27/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UINavContentViewController.h"
#import "YTVimeoExtractor.h"

@interface DPVimeoPlayerViewController : UINavContentViewController <YTVimeoExtractorDelegate>

- (id) initWithUrl:(NSString *)videoUrl;

@end
