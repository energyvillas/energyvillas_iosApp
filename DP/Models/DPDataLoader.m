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

@property (weak, nonatomic) UIView *indicatorContainer;
@property (strong, nonatomic) UIActivityIndicatorView *busyIndicator;
@property (strong, nonatomic) NSOperationQueue *queue;
@property (strong, nonatomic) ASIFormDataRequest *request;
@property (strong, nonatomic, readonly, getter = getDataCache) DPDataCache *dataCache;
@property BOOL useCaching;
@property BOOL useInternet;

@end

@implementation DPDataLoader


- (id) initWithView:(UIView *)indicatorcontainer
        useInternet:(BOOL)useInternet
         useCaching:(BOOL)useCaching{
    self = [self init];
    if (self) {
        self.indicatorContainer = indicatorcontainer;
        self.useCaching = useCaching;
        self.useInternet = useInternet;
    }
    
    return self;
}

-(void) cleanUp {
    if (self.queue) {
        [self.queue cancelAllOperations];
    }
    if (self.request) {
        [self.request cancel];
        self.request.delegate = nil;
    }
    self.request = nil;
    self.queue = nil;
}

-(void) dealloc {
    [self cleanUp];
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
    if (!self.indicatorContainer) return;
    
    if(!self.busyIndicator) {
		self.busyIndicator = [[UIActivityIndicatorView alloc]
                              initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		self.busyIndicator.frame = CGRectMake((self.indicatorContainer.frame.size.width-25)/2,
                                              (self.indicatorContainer.frame.size.height-25)/2,
                                              25, 25);
		self.busyIndicator.hidesWhenStopped = TRUE;
        [self.indicatorContainer addSubview:self.busyIndicator];
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
    if (self.useCaching) {
        BOOL cacheValid = [[DPAppHelper sharedInstance] useCache] && !self.dataCache.isExpired;
        return !cacheValid;
    }
    else
        return NO;
 }

- (void) loadData {
    BOOL cacheValid = self.useCaching && [[DPAppHelper sharedInstance] useCache] && !self.dataCache.isExpired;
    BOOL netIsAlive = [[DPAppHelper sharedInstance] hostIsReachable];
    
    if (!cacheValid && netIsAlive && self.useInternet) {
        self.request = [self createAndPrepareRequest];
        [self startRequest];
    } else {
        BOOL fromcache;
        [self loadLocalData:&fromcache];
        
        if (self.datalist)
            [self notifySuccess];
        else
            [self notifyFailure];
    }
}

- (void) loadLocalData:(BOOL *)loadedfromcache{
    if (self.useCaching)
        self.datalist = self.dataCache.dataList;
    
    *loadedfromcache = self.datalist != nil;
    if (!(*loadedfromcache)) {
        //            NSString *file = self.plistFile;
        //            if (file) {
        [self loadFromPlist];
        //            }
    }
}

- (void) loadFromPlist {
    
}


- (DPDataCache *) getDataCache {
    if (!_dataCache)
        _dataCache = [self createDataCache];
    
    return _dataCache;
}

- (NSString *) cacheFileName {
    return nil;
}

- (DPDataCache *) createDataCache {
    return [[DPDataCache alloc] initWithFile:[self cacheFileName]];
}

- (void) updateCachedData {
    if (self.useCaching)
        [self.dataCache updateDataList: self.datalist];
}

- (ASIFormDataRequest *) createAndPrepareRequest {
    return nil;
}

- (ASIFormDataRequest *) createRequest:(NSURL *)aUrl keysAndValues:(NSDictionary *)kvlist {
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:aUrl];
	request.defaultResponseEncoding = NSUTF8StringEncoding;
	[request setPostValue:USER_NAME forKey:@"user"];
	[request setPostValue:[DPDataLoader digestSHA1:PASSWORD] forKey:@"pass"];
    
    NSLog(@"POST :: URL='%@' ", aUrl);
    for (id key in kvlist) {
        [request setPostValue:[kvlist objectForKey:key] forKey:key];
        NSLog(@"POST :: KEY='%@' VALUE='%@'", key, [kvlist objectForKey:key]);
    }
    
    return request;
}

- (void) startRequest  {
    if (self.request == nil)
        return;
    
    if (!self.queue)
        self.queue = [[NSOperationQueue alloc] init];
    
    [self.request setDelegate:self];
    [self.queue addOperation:self.request];
    [self startIndicator];
}

- (void) requestFinished:(ASIHTTPRequest *)request{
    [self stopIndicator];
    
    NSString *resp = [request responseString];
	NSLog(@"Response: \n%@", resp);
    
    self.datalist = [self parseResponse:resp];
    
    BOOL fromcache = NO;
    if ((!self.datalist) || self.datalist.count == 0) {
        [self loadLocalData:&fromcache];
    }
    
    if (!fromcache)
        [self updateCachedData];
    
    [self notifySuccess];
}

- (NSArray *) parseResponse:(NSString *)response {
    return nil;
}

- (void) requestFailed:(ASIHTTPRequest *)request {
	NSLog(@"Request Failed: %@", [request error]);
    
	[self stopIndicator];
    
    BOOL fromcache;
    [self loadLocalData:&fromcache];
    if ((!self.datalist) && self.datalist.count == 0)
        self.datalist = nil;
    
    if (self.datalist)
        [self notifySuccess];
    else
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
