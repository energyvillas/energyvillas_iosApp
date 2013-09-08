//
//  DPImageListDownloader.h
//  energyVillas
//
//  Created by Γεώργιος Γράβος on 9/8/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^DPImageListDownloadCompleteBlock)(BOOL success);

@interface DPImageListDownloader : NSObject

-(id) initWithList:(NSArray *)imgUrlList onComplete:(DPImageListDownloadCompleteBlock)completed;

@end
