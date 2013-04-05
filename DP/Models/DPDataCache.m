//
//  DPDataCache.m
//  DP
//
//  Created by Γεώργιος Γράβος on 4/1/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPDataCache.h"
#import "DPDataElement.h"


@interface DPDataCache () {
    NSString *_filePath;
    NSString *_fileName;
    NSArray *_dataList;
}

@property (strong, nonatomic, readonly, getter = getFilePath) NSString *filePath;

@end

@implementation DPDataCache


-(id) initWithFile:(NSString *)aDatafile {
	if(self = [super init]){
        _fileName = aDatafile;
	}
	return self;
}

- (NSArray *) getDataList {
    if (!_dataList)
        [self loadFromFile];
    
    return _dataList;
}

- (void) setDataList:(NSArray *)list {
    _dataList = list;
}

- (BOOL) getIsExpired {
    NSError *error;
    NSFileManager *fileman = [NSFileManager defaultManager];
    
    BOOL res = YES;
    
    if ([fileman fileExistsAtPath:self.filePath]) {
        NSDictionary *dictionary = [fileman attributesOfItemAtPath:self.filePath
                                                             error:&error];
        
        NSDate *fileDate =[dictionary objectForKey:NSFileModificationDate];
        fileDate = [fileDate dateByAddingTimeInterval:(60 * 60 * 2)]; // add two hours
        NSDate *now =[NSDate date];
        res = [fileDate compare:now] != NSOrderedDescending;
    }
    
    return res;
}

-(NSString *) getFilePath {
    if (!_filePath) {
        NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        _filePath = [docDir stringByAppendingPathComponent:self.fileName];
    }
    
    return _filePath;
}

-(void) saveToFile {
	[NSKeyedArchiver archiveRootObject:self.dataList toFile:self.filePath];
	//RotationAppDelegate* appDelegate = (RotationAppDelegate*)[[UIApplication sharedApplication] delegate];
	//appDelegate.cacheHasChanged = TRUE;
	
}

-(void) loadFromFile {
	NSArray *lst = [NSKeyedUnarchiver unarchiveObjectWithFile:self.filePath];
	if(lst)
        self.dataList = lst;
    else
		self.dataList = [[NSMutableArray alloc] init];
}

- (DPDataElement *) findForKey:(NSString *)aKey {
	DPDataElement *foundElement;
	for (DPDataElement* element in self.dataList)
        if ([aKey compare:element.key]==NSOrderedSame) {
            foundElement = element;
            break;
        }
    
	return foundElement;
}

-(BOOL) contains:(NSString *)aKey {
	return [self findForKey:aKey] != nil;
}

-(void) remove:(NSString *)aKey {
	DPDataElement *foundElement = [self findForKey:aKey];
    
	if (foundElement)
		[(NSMutableArray*)self.dataList removeObject:foundElement];
}

@end
