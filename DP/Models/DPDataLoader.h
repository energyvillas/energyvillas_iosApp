//
//  DPDataLoader.h
//  DP
//
//  Created by Γεώργιος Γράβος on 3/25/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIFormDataRequest.h"
#import "DPDataCache.h"


@class DPDataLoader;

@protocol DPDataLoaderDelegate <NSObject>

@optional

- (void)loadFinished:(DPDataLoader *)loader;
- (void)loadFailed:(DPDataLoader *)loader;

@end

@interface DPDataLoader : NSObject

@property (weak, nonatomic) id <DPDataLoaderDelegate> delegate;
@property (strong, nonatomic) NSArray *datalist;
@property (readonly, getter = getDataRefreshNeeded) BOOL dataRefreshNeeded;


+(NSString*) digestSHA1:(NSString*)input;

- (id) initWithController:(UIViewController *)controller;

#pragma -
#pragma public methods
- (void) loadData;

#pragma -
#pragma "protected" helper methods
- (ASIFormDataRequest *) createRequest:(NSURL *)aUrl keysAndValues:(NSDictionary *)kvlist;

#pragma -
#pragma "abstract" methods
- (DPDataCache *) createDataCache;
- (ASIFormDataRequest *) createAndPrepareRequest;
- (NSArray *) parseResponse:(NSString *)response;

@end

