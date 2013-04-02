//
//  DPWebContentViewController.h
//  DP
//
//  Created by Γεώργιος Γράβος on 3/25/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "UINavContentViewController.h"
#import "DPDataLoader.h"

@interface DPHtmlContentViewController : UINavContentViewController <DPDataLoaderDelegate>

- (id) initWithUrl:(NSURL *)aUrl;
- (id) initWithData:(NSData *)aData mimetype:(NSString *)aMimeType;
- (id) initWithHTML:(NSString *)aHtml;
- (id) initWithCategory:(int)ctgid lang:(NSString *) aLang;

@end
