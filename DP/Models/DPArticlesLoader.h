//
//  DPArticlesLoader.h
//  DP
//
//  Created by Γεώργιος Γράβος on 3/31/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DPDataLoader.h"

@interface DPArticlesLoader : DPDataLoader

@property (strong, nonatomic, readonly) NSString *lang;

- (id) initWithView:(UIView *)indicatorcontainer category:(int)ctgID lang:(NSString *)aLang;

//- (id) initWithView:(UIView *)indicatorcontainer
//        useInternet:(BOOL)useInternet
//         useCaching:(BOOL)useCaching
//           category:(int)ctgID
//               lang:(NSString *)aLang
//      localResource:(NSString *)plistFile;

- (id) initWithView:(UIView *)indicatorcontainer
        useInternet:(BOOL)useInternet
         useCaching:(BOOL)useCaching
           category:(int)ctgID
               lang:(NSString *)aLang;
//          localData:(NSArray *)localData;


@end
