//
//  DPAppHelper.m
//  DP
//
//  Created by Γεώργιος Γράβος on 3/30/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPAppHelper.h"
#import "DPImageInfo.h"

NSString *const FREE_DET_IMGNAME_FMT = @"free_detimage_10%i_%@.jpg";
NSString *const FREE_DET_IMGTITLE_FMT = @"FREE_DET_TITLE_10%i";

@interface DPAppHelper ()

@end

@implementation DPAppHelper {

}


+ (DPAppHelper *)sharedInstance {
    static dispatch_once_t once;
    static DPAppHelper * sharedInstance;
    
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self)
        [self addFreeDetails];
    
    return self;
}

#define FREE_DET_CNT ((int) 8)


- (void) addFreeDetails {
    NSString *lang = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSMutableArray *list = [[NSMutableArray alloc] initWithCapacity:FREE_DET_CNT];

    for (int i = 0; i < FREE_DET_CNT; i++) {
        NSString *imgName = [NSString stringWithFormat:FREE_DET_IMGNAME_FMT, i, lang];
        NSString *dispName = [NSString stringWithFormat: FREE_DET_IMGTITLE_FMT, i];
        
        DPImageInfo *imginfo = [[DPImageInfo alloc] initWithName: imgName
                                                           image: [UIImage imageNamed:imgName]
                                                     displayName: NSLocalizedString(dispName, nil)];
        [list addObject:imginfo];
    }

    
    self.freeDetails = [NSArray arrayWithArray:list];
}

@end
