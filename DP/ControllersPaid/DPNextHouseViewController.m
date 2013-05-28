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
    [self resetCountDownLabels];
}

- (void) resetCountDownLabels {
    UIFont *font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:IS_IPAD ? 20.0f : 16.0f];
    [self resetLabel:self.topLabel font:font];
    
    font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:IS_IPAD ? 36.0f : 28.0f];
    [self resetLabel:self.daysCounter font:font];
    [self resetLabel:self.hoursCounter font:font];
    [self resetLabel:self.minutesCounter font:font];
    [self resetLabel:self.secondsCounter font:font];
    
    font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:IS_IPAD ? 14.0f : 10.0f];
    [self resetLabel:self.daysLabel font:font];
    [self resetLabel:self.hoursLabel font:font];
    [self resetLabel:self.minutesLabel font:font];
    [self resetLabel:self.secondsLabel font:font];
}

- (void) resetLabel:(UILabel *)lbl font:(UIFont *)font{
    lbl.text = nil;
    lbl.font = font;
    [self glowLabel:lbl glowColor:[UIColor whiteColor] glowRadius:5.0f];
}

- (void) glowLabel:(UILabel *)label glowColor:(UIColor *)glowcolor glowRadius:(CGFloat)glowradius {
    label.backgroundColor = [UIColor clearColor];
    label.layer.shadowColor = glowcolor.CGColor; // red
    label.layer.shadowOffset = CGSizeMake(0, 0);
    label.layer.shadowOpacity = 1;
    label.layer.shadowRadius = glowradius; // tried 1-10
    label.layer.masksToBounds = NO;
}

- (void) layoutCounterLabels {
    int TOP_Height = [self topLabelHeight];
    int CNT_Height = [self counterLabelHeight];
    int LBL_Height = [self lblLabelHeight];

    CGFloat width = self.countDownContainerView.bounds.size.width;
    CGFloat widthInner = width / 4.0f;
    
    CGRect frm = CGRectMake(0, 0, width, TOP_Height);
    self.topLabel.frame = frm; 
    
    frm = CGRectMake(0, TOP_Height, width, CNT_Height);
    self.countersView.frame = frm;
    frm = CGRectMake(0, 0, widthInner, CNT_Height);
    self.daysCounter.frame = frm; frm = CGRectOffset(frm, widthInner, 0);
    self.hoursCounter.frame = frm; frm = CGRectOffset(frm, widthInner, 0);
    self.minutesCounter.frame = frm; frm = CGRectOffset(frm, widthInner, 0);
    self.secondsCounter.frame = frm; frm = CGRectOffset(frm, widthInner, 0);
    
    frm = CGRectMake(0, TOP_Height + CNT_Height, width, LBL_Height);
    self.labelsView.frame = frm;
    frm = CGRectMake(0, 0, widthInner, LBL_Height);
    self.daysLabel.frame = frm; frm = CGRectOffset(frm, widthInner, 0);
    self.hoursLabel.frame = frm; frm = CGRectOffset(frm, widthInner, 0);
    self.minutesLabel.frame = frm; frm = CGRectOffset(frm, widthInner, 0);
    self.secondsLabel.frame = frm; frm = CGRectOffset(frm, widthInner, 0);
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
    [self setCountDownContainerView:nil];
    [self setTopLabel:nil];
    [self setCountersView:nil];
    [self setLabelsView:nil];
    [self setDaysCounter:nil];
    [self setHoursCounter:nil];
    [self setMinutesCounter:nil];
    [self setSecondsCounter:nil];
    [self setDaysLabel:nil];
    [self setHoursLabel:nil];
    [self setMinutesLabel:nil];
    [self setSecondsLabel:nil];
    [self setCountDownContainerView:nil];
    [super viewDidUnload];
}

- (int) topLabelHeight {
    return IS_IPAD ? 28 : 24;
}
- (int) counterLabelHeight {
    return IS_IPAD ? 40 : 32;
}
- (int) lblLabelHeight {
    return IS_IPAD ? 20 : 16;
}

- (void) doLayoutSubViews:(BOOL)fixtop {
    CGRect frm = self.view.frame;
    
    fixtop = IS_LANDSCAPE && !IS_IPAD;
    int top = fixtop ? 12 : 0;
    int h = frm.size.height - top;
    int w = frm.size.width;
    
    int TOP_Height = [self topLabelHeight];
    int CNT_Height = [self counterLabelHeight];
    int LBL_Height = [self lblLabelHeight];
    
    int containerHeight = TOP_Height + CNT_Height + LBL_Height;
    
    self.htmlView.frame = CGRectMake(0, top, w, h - containerHeight);

    self.countDownContainerView.frame = CGRectMake(0, top + h - containerHeight,
                                                   w, containerHeight);
    [self loadHtmlView:YES];
    [self layoutCounterLabels];
}

- (void) doLocalize {
    [super doLocalize];
    [self killTimer];
    [self resetCountDownLabels];
    [self initCountDown];
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
    self.topLabel.text = DPLocalizedString(@"COUNTDOWN_COMING_IN");

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
        
    self.daysCounter.text = [NSString stringWithFormat:@"%d", components.day];
    self.hoursCounter.text = [NSString stringWithFormat:@"%.2d", components.hour];
    self.minutesCounter.text = [NSString stringWithFormat:@"%.2d'", components.minute];
    self.secondsCounter.text = [NSString stringWithFormat:@"%.2d\"", components.second];

    self.daysLabel.text = components.day == 1 ? DPLocalizedString(@"COUNTDOWN_DAY") : DPLocalizedString(@"COUNTDOWN_DAYS");
    self.hoursLabel.text = components.hour == 1 ? DPLocalizedString(@"COUNTDOWN_HOUR") : DPLocalizedString(@"COUNTDOWN_HOURS");
    self.minutesLabel.text = components.minute == 1 ? DPLocalizedString(@"COUNTDOWN_MINUTE") : DPLocalizedString(@"COUNTDOWN_MINUTES");
    self.secondsLabel.text = components.second == 1 ? DPLocalizedString(@"COUNTDOWN_SECOND") : DPLocalizedString(@"COUNTDOWN_SECONDS");
}

- (void) killTimer {
    [self.timer invalidate];
    self.timer = nil;
}


@end
