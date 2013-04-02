//
//  DPImageInfo.h
//  DP
//
//  Created by Γεώργιος Γράβος on 3/22/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DPImageInfoxx : NSObject

@property (strong, nonatomic) NSString *displayNname;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic, readonly, getter = getImage) UIImage *image;
@property int tag;

- (id) initWithName:(NSString *)aName
        displayName:(NSString *)aDisplayName;

@end
