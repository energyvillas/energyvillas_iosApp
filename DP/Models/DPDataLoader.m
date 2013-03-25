//
//  DPDataLoader.m
//  DP
//
//  Created by Γεώργιος Γράβος on 3/25/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPDataLoader.h"
#import <CommonCrypto/CommonDigest.h>

NSString *const ARTICLES_URL = @"http://designprojectsapps.com/iphonenews.php";
NSString *const USER_NAME = @"phone";
NSString *const PASSWORD = @"phone";

@implementation DPDataLoader

+(NSString*) digestSHA1:(NSString*)input
{
    NSData *data = [input dataUsingEncoding:NSUTF8StringEncoding
                       allowLossyConversion:NO];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(data.bytes, data.length, digest);
    NSMutableString* output = [NSMutableString
                               stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    return output;
}
@end
