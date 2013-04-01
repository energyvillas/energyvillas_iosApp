//
//  DPDataCache.h
//  DP
//
//  Created by Γεώργιος Γράβος on 4/1/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DPDataCache : NSObject

@property (strong, nonatomic, readonly) NSString *fileName;
@property (nonatomic, strong, getter = getDataList, setter = setDataList:) NSArray *dataList;
@property (readonly, getter = getIsExpired) BOOL isExpired;

-(id)initWithFile:(NSString *)aDatafile;

-(void) saveToFile;
-(void) loadFromFile;
-(BOOL) contains:(NSString *)aKey;
-(void) remove:(NSString *)aKey;

@end
