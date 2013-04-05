//
//  DPDataLoader.m
//  DP
//
//  Created by Γεώργιος Γράβος on 3/25/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPDataLoader.h"
#import <CommonCrypto/CommonDigest.h>
#import "DPConstants.h"
#import "DPAppHelper.h"
#import "DPDataCache.h"


@interface DPDataLoader () {
    DPDataCache *_dataCache;
}

@property (weak, nonatomic) UIViewController *controller;
@property (strong, nonatomic) UIActivityIndicatorView *busyIndicator;
@property (strong, nonatomic) NSOperationQueue *queue;
@property (strong, nonatomic, readonly, getter = getDataCache) DPDataCache *dataCache;

@end

@implementation DPDataLoader


- (id) initWithController:(UIViewController *)controller {
    self = [super init];
    if (self) {
        self.controller = controller;
    }
    
    return self;
}

+(NSString*) digestSHA1:(NSString*)input {
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

#pragma mark -
#pragma mark === busy indication handling  ===

- (void) startIndicator {
    if(!self.busyIndicator) {
		self.busyIndicator = [[UIActivityIndicatorView alloc]
                              initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		self.busyIndicator.frame = CGRectMake((self.controller.view.frame.size.width-25)/2,
                                              (self.controller.view.frame.size.height-25)/2,
                                              25, 25);
		self.busyIndicator.hidesWhenStopped = TRUE;
        [self.controller.view addSubview:self.busyIndicator];
	}
    [self.busyIndicator startAnimating];
}

- (void) stopIndicator {
    if(self.busyIndicator) {
        [self.busyIndicator stopAnimating];
        [self.busyIndicator removeFromSuperview];
        self.busyIndicator = nil;
    }
}

#pragma mark -
#pragma mark === downloading handling  ===
- (BOOL) getDataRefreshNeeded {
    BOOL cacheValid = [[DPAppHelper sharedInstance] useCache] && !self.dataCache.isExpired;
    return !cacheValid;
}

- (void) loadData {
    BOOL cacheValid = [[DPAppHelper sharedInstance] useCache] && !self.dataCache.isExpired;
    BOOL netIsAlive = [[DPAppHelper sharedInstance] hostIsReachable];

    if (!cacheValid && netIsAlive) {
        ASIFormDataRequest *request = [self createAndPrepareRequest];
        [self startRequest:request];
    } else {
        self.datalist = self.dataCache.dataList;
        
        if (self.datalist)
            [self notifySuccess];
        else
            [self notifyFailure];
    }
}

- (DPDataCache *) getDataCache {
    if (!_dataCache)
        _dataCache = [self createDataCache];
    
    return _dataCache;
}

- (DPDataCache *) createDataCache {
    return nil;
}

- (void) updateCachedData {
    self.dataCache.dataList = self.datalist;
    [self.dataCache saveToFile];
}

- (ASIFormDataRequest *) createAndPrepareRequest {
    return nil;
}

- (ASIFormDataRequest *) createRequest:(NSURL *)aUrl keysAndValues:(NSDictionary *)kvlist {
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:aUrl];
	request.defaultResponseEncoding = NSUTF8StringEncoding;
	[request setPostValue:USER_NAME forKey:@"user"];
	[request setPostValue:[DPDataLoader digestSHA1:PASSWORD] forKey:@"pass"];
    
    for (id key in kvlist) {
        [request setPostValue:[kvlist objectForKey:key] forKey:key];
    }
    
    return request;
}

- (void) startRequest:(ASIFormDataRequest *)request  {
    if (!self.queue)
        self.queue = [[NSOperationQueue alloc] init];
    
    
    [request setDelegate:self];
    [self.queue addOperation:request];
    [self startIndicator];
}

- (void) requestFinished:(ASIHTTPRequest *)request{
    [self stopIndicator];
    
    NSString *resp = [request responseString];
	NSLog(@"Response: \n%@", resp);
    
    self.datalist = [self parseResponse:resp];
    
    NSDictionary *images = [[NSDictionary alloc] init];
    
    [self updateCachedData];
    [self notifySuccess];
}

- (NSArray *) parseResponse:(NSString *)response {
    return nil;
}

- (void) requestFailed:(ASIHTTPRequest *)request {
	NSLog(@"Request Failed: %@", [request error]);
    
	[self stopIndicator];

    [self notifyFailure];
}

- (void) notifySuccess {
    if ([self.delegate respondsToSelector:@selector(loadFinished:)])
        [self.delegate loadFinished:self];
}
- (void) notifyFailure {
    if ([self.delegate respondsToSelector:@selector(loadFailed:)])
        [self.delegate loadFailed:self];
}

@end
