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
#import <MediaPlayer/MediaPlayer.h>

@interface DPVimeoPlayerViewController : UINavContentViewController // <YTVimeoExtractorDelegate, UIAlertViewDelegate>

+ (void) clsPlayVideoUrl:(NSString *)vidUrl;
//+ (void) playVideoUrl:(NSString *)vidUrl withCompletion:(VimeoPlayerBlock)onCompleted;

//- (id) initWithUrl:(NSString *)videoUrl;

@end
