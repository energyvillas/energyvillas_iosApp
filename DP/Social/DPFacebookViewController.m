//
//  DPFacebookViewController.m
//  energyVillas
//
//  Created by Γεώργιος Γράβος on 4/18/13.
//  Copyright (c) 2013 Γεώργιος Γράβος. All rights reserved.
//

#import "DPFacebookViewController.h"
#import "DPConstants.h"

#define tbiCancel ((int)101)
#define tbiLogout ((int)102)
#define tbiShare ((int)103)

NSString *const kPlaceholderPostMessage = @"Say something about this...";

@interface DPFacebookViewController ()

@property (strong, nonatomic) NSMutableDictionary *postParams;

@end



@implementation DPFacebookViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.postParams =
        [[NSMutableDictionary alloc] initWithObjectsAndKeys:
         @"http://www.energyvillas.com", @"link",
         //@"", @"picture",
         @"some name for the above link", @"name",
         @"this is the caption.", @"caption",
         @"and this is the description", @"description",
         nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithRed:0.0f
                                                green:51.0f / 256.0f
                                                 blue:102.0f / 256.0f
                                                alpha:1.0f];

    self.postMessageTextView.delegate = self;
    
    // Show placeholder text
    [self resetPostMessage];
    // Set up the post information, hard-coded for this sample
//    self.postNameLabel.text = [self.postParams objectForKey:@"name"];
//    self.postCaptionLabel.text = [self.postParams
//                                  objectForKey:@"caption"];
//    [self.postCaptionLabel sizeToFit];
//    self.postDescriptionLabel.text = [self.postParams
//                                      objectForKey:@"description"];
//    [self.postDescriptionLabel sizeToFit];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setUserProfilePicture:nil];
    [self setUserName:nil];
    [self setPostMessageTextView:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self populateUserDetails];
}

//==============================================================================
#pragma mark - nav bar button selection
//- (BOOL) showNavBar {
//    return self.navigationController != nil;
//}
//- (BOOL) showNavBarLanguages {
//    return YES;
//}
//- (BOOL) showNavBarAddToFav {
//    return NO;
//}
//- (BOOL) showNavBarSocial {
//    return NO;
//}
//- (BOOL) showNavBarInfo {
//    return YES;
//}
//==============================================================================

- (void) populateUserDetails {
    if (FBSession.activeSession.isOpen) {
        [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                NSDictionary<FBGraphUser> *user = result;
                self.userName.text = user.name;
                self.userProfilePicture.profileID = user.id;
            }
        }];
    }
}

- (IBAction)toolBarItemTapped:(UIBarButtonItem *)sender {
    // Hide keyboard if showing when button clicked
    if ([self.postMessageTextView isFirstResponder]) {
        [self.postMessageTextView resignFirstResponder];
    }
    
    switch (sender.tag) {
        case tbiCancel: {
            [self.navigationController popViewControllerAnimated:YES];
            break;
        }
        case tbiLogout: {
            [FBSession.activeSession closeAndClearTokenInformation];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
            break;
        }
        case tbiShare: {
            // Add user message parameter if user filled it in
            if (![self.postMessageTextView.text isEqualToString:kPlaceholderPostMessage] &&
                ![self.postMessageTextView.text isEqualToString:@""]) {
                [self.postParams setObject:self.postMessageTextView.text
                                    forKey:@"message"];
            }
            
            [self doPublishStory];
            break;
        }
        default: 
            break;
    }
}

//==============================================================================

- (void)resetPostMessage {
    self.postMessageTextView.text = kPlaceholderPostMessage;
    self.postMessageTextView.textColor = [UIColor lightGrayColor];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    // Clear the message text when the user starts editing
    if ([textView.text isEqualToString:kPlaceholderPostMessage]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    // Reset to placeholder text if the user is done
    // editing and no message has been entered.
    if ([textView.text isEqualToString:@""]) {
        [self resetPostMessage];
    }
}

/*
 * A simple way to dismiss the message text view:
 * whenever the user clicks outside the view.
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *) event {
    UITouch *touch = [[event allTouches] anyObject];
    if ([self.postMessageTextView isFirstResponder] &&
        (self.postMessageTextView != touch.view))
    {
        [self.postMessageTextView resignFirstResponder];
    }
}

//==============================================================================

- (void) doPublishStory {
    // Ask for publish_actions permissions in context
    if ([FBSession.activeSession.permissions indexOfObject:@"publish_actions"] == NSNotFound) {
        // No permissions found in session, ask for it
        [FBSession.activeSession requestNewPublishPermissions: [NSArray arrayWithObject:@"publish_actions"]
                                              defaultAudience:FBSessionDefaultAudienceFriends
                                            completionHandler:^(FBSession *session, NSError *error) {
                                                if (!error) {
                                                    // If permissions granted, publish the story
                                                    [self publishStory];
                                                }
                                            }];
    } else {
        // If permissions present, publish the story
        [self publishStory];
    }

}
- (void) publishStory {
    [FBRequestConnection startWithGraphPath:@"me/feed"
                                 parameters:self.postParams
                                 HTTPMethod:@"POST"
                          completionHandler:^(FBRequestConnection *connection,
                                              id result,
                                              NSError *error) {
                              NSString *alertText;
                              if (error) {
                                  alertText = [NSString stringWithFormat:
                                               @"error: domain = %@, code = %d",
                                               error.domain, error.code];
                              } else {
                                  alertText = [NSString stringWithFormat:
                                               @"Posted action, id: %@",
                                               [result objectForKey:@"id"]];
                              }
                              // Show the result in an alert
                              showAlertMessage(self, @"Result", alertText);
                          }];
}

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
