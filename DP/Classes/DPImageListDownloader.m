//
//  DPImageListDownloader.m
//  energyVillas
//
//  Created by Γεώργιος Γράβος on 9/8/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPImageListDownloader.h"
#import "ASINetworkQueue.h"
#import "ASIHTTPRequest.h"
#import "DPAppHelper.h"
#import "DPConstants.h"


@interface DPImageListDownloader ()

@property (strong, nonatomic) DPImageListDownloadCompleteBlock onCompleted;
@property (strong, nonatomic) NSMutableArray *imageUrlList;
@property (strong, nonatomic) ASINetworkQueue *queue;

@end


@implementation DPImageListDownloader 

-(id) initWithList:(NSArray *)imgUrlList
        onComplete:(DPImageListDownloadCompleteBlock)completed {
    self = [super init];
    if (self) {
        self.onCompleted = [completed copy];
        self.imageUrlList = [NSMutableArray arrayWithArray: imgUrlList];
        [self start];
    }
    return self;
}

-(void) dealloc {
    if (self.queue)
        [self.queue reset];
    
    self.queue = nil;
    self.imageUrlList = nil;
    self.onCompleted = nil;
}

-(void) queueDidFinish:(ASINetworkQueue *)q {
    [self processList];
    
    if (self.imageUrlList.count == 0)
        [self doCompleted:YES];
    else
        [self doCompleted:NO];
}

- (void) processList {
    DPAppHelper *apphelper = [DPAppHelper sharedInstance];
    for (int i = self.imageUrlList.count - 1; i>=0; i--) {
        NSLog(@"Process Image : %@", self.imageUrlList[i]);
        if (self.imageUrlList[i] == [NSNull null] || (NilIfEmpty(self.imageUrlList[i]) == nil) ||
            ([apphelper isImageInCache:self.imageUrlList[i]]))
            [self.imageUrlList removeObjectAtIndex:i];
    }
}

-(void) start {
    // preprocess list to 'remove' image already loaded...
    [self processList];
    
    if (self.imageUrlList.count == 0)
        [self doCompleted:YES];
    
    self.queue = [[ASINetworkQueue alloc] init];
    self.queue.delegate = self;
    [self.queue setQueueDidFinishSelector:@selector(queueDidFinish:)];
    [self.queue setRequestDidFinishSelector:@selector(requestDone:)];
    [self.queue setRequestDidFailSelector:@selector(requestFailed:)];
    
    for (int i = 0; i < self.imageUrlList.count; i++) {
        NSURL *url = [NSURL URLWithString:self.imageUrlList[i]];
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
        request.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithInt:i], @"imageIndex",
                                 self.imageUrlList[i], @"imageName",
                                 nil];
        
        [self.queue addOperation:request];
    }
    
    [self.queue go];
}

- (void) requestDone:(ASIHTTPRequest *)request{
//	int aIndex = [[request.userInfo objectForKey:@"imageIndex"] intValue];
    NSString *imgName = [request.userInfo objectForKey:@"imageName"];
    NSLog(@"Request Image Done: %@", imgName);
    
    NSData *imgData = [request responseData];
	UIImage *aImage = [UIImage imageWithData:imgData scale:DEVICE_SCALE];
    
	if (aImage) {
        [[DPAppHelper sharedInstance] saveImageToCache:imgName data:imgData];
	}
}

- (void) requestFailed:(ASIHTTPRequest *)request {
    NSString *imgName = [request.userInfo objectForKey:@"imageName"];
	NSLog(@"Request Failed: Image: %@, Error: %@", imgName, [request error]);
}

- (void) doCompleted:(BOOL)success {
    if (self.onCompleted) {
        BOOL ok = success;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.onCompleted(ok);
        });
    }
}

@end
