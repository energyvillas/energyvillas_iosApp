//
//  DPNextHouseViewController.m
//  energyVillas
//
//  Created by Γεώργιος Γράβος on 5/27/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "DPNextHouseViewController.h"
#import "DPHtmlContentViewController.h"
#import "DPConstants.h"
#import "DPAppHelper.h"

#define PICKER_COMP_DAYS ((int)0)
#define PICKER_COMP_HOURS ((int)1)
#define PICKER_COMP_MINUTES ((int)2)
#define PICKER_COMP_SECONDS ((int)3)


@interface DPNextHouseViewController ()

@property (nonatomic) int ctgID;

@property (strong, nonatomic) DPHtmlContentViewController *htmlVC;
@property (strong, nonatomic) Article *article;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSDate *targetDate;
@property (strong, nonatomic) NSCalendar *calendar;

@end

@implementation DPNextHouseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) initWithCategory:(int)ctgid {
    self = [super init];
    if (self) {
        self.ctgID = ctgid;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.htmlView.clipsToBounds = YES;
    self.countDownLabel.text = nil;
    [self glowLabel:self.countDownLabel glowColor:[UIColor whiteColor] glowRadius:5.0f];
}

- (void) glowLabel:(UILabel *)label glowColor:(UIColor *)glowcolor glowRadius:(CGFloat)glowradius {
    label.backgroundColor = [UIColor clearColor];
    label.layer.shadowColor = glowcolor.CGColor; // red
    label.layer.shadowOffset = CGSizeMake(0, 0);
    label.layer.shadowOpacity = 1;
    label.layer.shadowRadius = glowradius; // tried 1-10
    label.layer.masksToBounds = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self killTimer];
    
    if (self.htmlVC) {
        self.htmlVC.dataloaderDelegate = nil;
        self.htmlVC = nil;
    }

    [self setHtmlView:nil];
    [self setCountDownPicker:nil];
    [self setCountDownLabel:nil];
    [super viewDidUnload];
}

- (void) doLayoutSubViews:(BOOL)fixtop {
    CGRect frm = self.view.frame;
    
    fixtop = IS_LANDSCAPE && !IS_IPAD;
    int top = fixtop ? 12 : 0;
    int h = frm.size.height - top;
    int w = frm.size.width;
    
    CGFloat counterHeight = 80;
//    CGFloat counterHeight = self.countDownPicker.bounds.size.height;
    
    self.htmlView.frame = CGRectMake(0, top, w, h - counterHeight);
//    self.countDownPicker.frame = CGRectMake(0, top + h - counterHeight, w, counterHeight);

    self.countDownLabel.frame = CGRectMake(0, top + h - counterHeight, w, counterHeight);
    [self loadHtmlView:YES];
}

- (void) doLocalize {
    [super doLocalize];
    //[self killTimer];
    
    [self loadHtmlView:YES];
}

- (void) loadHtmlView:(BOOL)reload {
    if (reload && self.htmlVC) {
        self.htmlVC.dataloaderDelegate = nil;
        [self.htmlVC.view removeFromSuperview];
        [self.htmlVC removeFromParentViewController];
        self.htmlVC = nil;
    }
    
    if (!self.htmlVC) {
        self.htmlVC = [[DPHtmlContentViewController alloc] initWithCategory:self.ctgID
                                                                       lang:CURRENT_LANG];
        self.htmlVC.isInner = YES;
        self.htmlVC.dataloaderDelegate = self;
        self.htmlVC.view.frame = self.htmlView.bounds;
        [self addChildViewController:self.htmlVC];
        [self.htmlView addSubview:self.htmlVC.view];
    } else {
        self.htmlVC.view.frame = self.htmlView.bounds;
        [self.htmlVC.view setNeedsDisplay];
    }
}

- (void) loadFinished:(DPDataLoader *)loader {
    self.article = loader.datalist && loader.datalist.count > 0 ? loader.datalist[0] : nil;
    [self initCountDown];
}

- (void) loadFailed:(DPDataLoader *)loader {
    self.article = nil;
}

-(NSDate *) lclTimeFromUTCString:(NSString *)utcstring {
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy'-'MM'-'dd' 'HH':'mm':'ss' 'zzz";
    NSDate *utc = [fmt dateFromString:[NSString stringWithFormat:@"%@ UTC", utcstring]];
    return utc;
}
-(NSDate *) toLocalTime:(NSDate *)utcDate
{
    NSTimeZone *tz = [NSTimeZone defaultTimeZone];
    NSInteger seconds = [tz secondsFromGMTForDate: utcDate];
    return [NSDate dateWithTimeInterval: seconds sinceDate: utcDate];
}

- (void) initCountDown {
    NSLog(@"ARTICLE PUBLISH DATETIME is :'%@'", self.article.publishDate);
    self.targetDate = [self lclTimeFromUTCString:self.article.publishDate];
    self.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
//    self.countDownPicker.dataSource = self;
//    self.countDownPicker.delegate = self;
    if (self.timer == nil) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                      target:self
                                                    selector:@selector(onTimer)
                                                    userInfo:nil
                                                     repeats:YES];
    }
}

- (NSDateComponents *) calcDiffFromNow {
    NSDate *current = [NSDate date];
    NSUInteger flags = NSDayCalendarUnit | NSHourCalendarUnit |
    NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *components =  [self.calendar components:flags
                                                     fromDate:current
                                                       toDate:self.targetDate
                                                      options:0];
    return components;
}
- (void) onTimer {
    NSDateComponents *components = [self calcDiffFromNow];
    NSLog(@"%i days %.2d:%.2d:%.2d", components.day, components.hour, components.minute, components.second);
//    [self.countDownPicker selectRow:components.second inComponent:PICKER_COMP_SECONDS animated:YES];
//    [self.countDownPicker selectRow:components.minute inComponent:PICKER_COMP_MINUTES animated:YES];
//    [self.countDownPicker selectRow:components.hour inComponent:PICKER_COMP_HOURS animated:YES];
//    [self.countDownPicker selectRow:components.day inComponent:PICKER_COMP_DAYS animated:YES];
    
    NSString *counterfmt = @"%d %@ %d %@ %d' %d\"";
    NSString *daystr = components.day == 1 ? DPLocalizedString(@"COUNTDOWN_DAY") : DPLocalizedString(@"COUNTDOWN_DAYS");
    NSString *hourstr = components.hour == 1 ? DPLocalizedString(@"COUNTDOWN_HOUR") : DPLocalizedString(@"COUNTDOWN_HOURS");
    self.countDownLabel.text = [NSString stringWithFormat:counterfmt,
                                components.day, daystr,
                                components.hour, hourstr,
                                components.minute, components.second];
}

- (void) killTimer {
    [self.timer invalidate];
    self.timer = nil;
}

//==============================================================================
#pragma  mark - UIPickerViewDataSource<NSObject>

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return self.article ? 4 : 0;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSDateComponents *components = [self calcDiffFromNow];

    switch (component) {
        case PICKER_COMP_DAYS: return components.day + 1;
        case PICKER_COMP_HOURS: return 24;
        case PICKER_COMP_MINUTES: return 60;
        case PICKER_COMP_SECONDS: return 60;
    }
    
    return 0;
}

//==============================================================================
#pragma  mark - UIPickerViewDelegate<NSObject>

//// returns width of column and height of row for each component.
//- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component;
//- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component;

// these methods return either a plain NSString, a NSAttributedString, or a view (e.g UILabel) to display the row for the component.
// for the view versions, we cache any hidden and thus unused views and pass them back for reuse.
// If you return back a different object, the old one will be released. the view will be centered in the row rect
- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component {
    switch (component) {
        case PICKER_COMP_DAYS    : return [NSString stringWithFormat:@"%i", row];
        case PICKER_COMP_HOURS   : return [NSString stringWithFormat:@"%i", row];
        case PICKER_COMP_MINUTES :  return [NSString stringWithFormat:@"%i", row];
        case PICKER_COMP_SECONDS :  return [NSString stringWithFormat:@"%i", row];
    }
    
    return nil;
}
//- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component NS_AVAILABLE_IOS(6_0); // attributed title is favored if both methods are implemented
//- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view;

//- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component;

@end
