//
//  LoginController.m
//  Prey-iOS
//
//  Created by Carlos Yaconi on 29/09/2010.
//  Copyright 2010 Fork Ltd. All rights reserved.
//  License: GPLv3
//  Full license at "/LICENSE"
//

#import "LoginController.h"
#import "User.h"
#import "PreyConfig.h"
#import "Constants.h"
#import <CoreLocation/CoreLocation.h>
#import "PreyAppDelegate.h"
#import "PreferencesController.h"
#import "ReviewRequest.h"
#import "Constants.h"

@implementation LoginController

@synthesize loginImage, scrollView, loginPassword, nonCamuflageImage, preyLogo, devReady, detail, tipl;
@synthesize loginButton, panelButton, settingButton;


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	if (touch.tapCount > 0) {
        [self.view endEditing:YES];
		[self becomeFirstResponder];
	}
}

- (void) checkPassword
{
    PreyConfig *config = [PreyConfig instance];
    [User allocWithEmail:config.email password:loginPassword.text
               withBlock:^(User *user, NSError *error)
     {
         [MBProgressHUD hideHUDForView:self.navigationController.view animated:NO];
         
         if (!error) // User Login
         {
             [config setPro:user.isPro];
             
             PreferencesController *preferencesController = [[PreferencesController alloc] init];
             preferencesController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
             PreyAppDelegate *appDelegate = (PreyAppDelegate*)[[UIApplication sharedApplication] delegate];
             [appDelegate.viewController setNavigationBarHidden:NO animated:NO];
             [appDelegate.viewController pushViewController:preferencesController animated:YES];
         }
     }]; // End Block User
}

- (IBAction) checkLoginPassword: (id) sender
{
	if ([loginPassword.text length] <6)
    {
		UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Access Denied",nil) message:NSLocalizedString(@"Wrong password. Try again.",nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alertView show];
		return;
	}
    
	[self hideKeyboard];
    
    HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    HUD.delegate = self;
    HUD.labelText = NSLocalizedString(@"Please wait",nil);
    HUD.detailsLabelText = NSLocalizedString(@"Checking your password...",nil);
    [self checkPassword];
}

- (void) hideKeyboard {
	[loginPassword resignFirstResponder];
}

#pragma mark -
#pragma mark UI sliding methods
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self animateTextField: textField up: YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self animateTextField: textField up: NO];
}

- (void) animateTextField: (UITextField*) textField up: (BOOL) up
{
    const float movementDuration = 0.3f;
    int movementDistanceY;
    
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        // Configuracion iPhone
        if (UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation]))
            movementDistanceY = 160;
        else
            movementDistanceY = 200;
    }
    else
    {
        // Configuracion iPad
        if (UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation]))
            movementDistanceY = 340;
        else
            movementDistanceY = 240;
    }
    
    
    int movement = (up ? -movementDistanceY : movementDistanceY);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

#pragma mark view methods

- (IBAction)goToControlPanel:(UIButton *)sender
{
    UIViewController *controller = [UIWebViewController controllerToEnterdelegate:self setURL:URL_LOGIN_PANEL];
    
    if (controller)
    {
        if ([self.navigationController respondsToSelector:@selector(presentViewController:animated:completion:)]) // Check iOS 5.0 or later
            [self.navigationController presentViewController:controller animated:YES completion:NULL];
        else
            [self.navigationController presentModalViewController:controller animated:YES];
    }
}

- (IBAction)goToSettings:(UIButton *)sender
{
    [self.scrollView setContentOffset:CGPointMake(self.scrollView.frame.size.width, 0) animated:YES];
}

- (void)viewDidLoad
{
    if ([ReviewRequest shouldAskForReview])
        [ReviewRequest askForReview];
    
    self.screenName = @"Login";
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        [devReady setFont:[UIFont fontWithName:@"Roboto-Regular" size:24]];
        [detail   setFont:[UIFont fontWithName:@"OpenSans" size:14]];
        [tipl     setFont:[UIFont fontWithName:@"OpenSans" size:14]];
        
        [loginButton.titleLabel   setFont:[UIFont fontWithName:@"OpenSans" size:14]];
        [panelButton.titleLabel   setFont:[UIFont fontWithName:@"OpenSans" size:14]];
        [settingButton.titleLabel setFont:[UIFont fontWithName:@"OpenSans" size:14]];
    }
    else
    {
        [devReady setFont:[UIFont fontWithName:@"Roboto-Regular" size:34]];
        [detail   setFont:[UIFont fontWithName:@"OpenSans" size:20]];
        [tipl     setFont:[UIFont fontWithName:@"OpenSans" size:20]];
        
        [loginButton.titleLabel   setFont:[UIFont fontWithName:@"OpenSans" size:20]];
        [panelButton.titleLabel   setFont:[UIFont fontWithName:@"OpenSans" size:20]];
        [settingButton.titleLabel setFont:[UIFont fontWithName:@"OpenSans" size:20]];
    }
    
    [settingButton setTitle:[NSLocalizedString(@"Manage Prey settings", nil) uppercaseString] forState: UIControlStateNormal];
    [panelButton setTitle:[NSLocalizedString(@"Go to Control Panel", nil) uppercaseString] forState: UIControlStateNormal];
    [loginButton setTitle:[NSLocalizedString(@"Log in to Prey", nil) uppercaseString] forState: UIControlStateNormal];
    [loginPassword setPlaceholder:NSLocalizedString(@"Type in your password", nil)];
    [tipl setText:NSLocalizedString(@"Swipe to go back", nil)];
    
    PreyConfig *config = [PreyConfig instance];
    [self.scrollView setContentSize:CGSizeMake(scrollView.frame.size.width*2, scrollView.frame.size.height)];
    [self.loginPassword setBorderStyle:UITextBorderStyleRoundedRect];
    
    if (config.camouflageMode)
    {
        [self.nonCamuflageImage setHidden:YES];
        [self.loginImage setHidden:NO];
        [self.detail setHidden:YES];
        [self.devReady setHidden:YES];
        [self.preyLogo setHidden:YES];
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.frame.size.width*1, 0) animated:NO];
        [self.tipl setHidden:YES];
        [self configButtonsForCamouflage:YES];
    }
    else
    {
        [self.tipl setHidden:NO];
        [self.nonCamuflageImage setHidden:NO];
        [self.loginImage setHidden:YES];
        [self.detail setHidden:NO];
        [self.devReady setHidden:NO];
        [self.preyLogo setHidden:NO];
        [self configButtonsForCamouflage:NO];
    }
    
    [self.loginPassword addTarget:self action:@selector(checkLoginPassword:) forControlEvents:UIControlEventEditingDidEndOnExit];
    
    [super viewDidLoad];
}

- (void)configButtonsForCamouflage:(BOOL)isCamouflage
{
    if (isCamouflage)
    {
        [loginButton setBackgroundImage:[UIImage imageNamed:@"bt-camouflage"] forState:UIControlStateNormal];
        [loginButton setBackgroundImage:[UIImage imageNamed:@"bt-camouflage"] forState:UIControlStateHighlighted];
    }
    else
    {
        [loginButton setBackgroundImage:[UIImage imageNamed:@"bt-welcome"] forState:UIControlStateNormal];
        [loginButton setBackgroundImage:[UIImage imageNamed:@"bt-welcome"] forState:UIControlStateHighlighted];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized)
    {
        [self.devReady setText:[NSLocalizedString(@"Device not ready!", nil) uppercaseString]];
        [self.detail   setText:NSLocalizedString(@"Location services are disabled for Prey. Reports will not be sent.", nil)];
        [nonCamuflageImage setImage:[UIImage imageNamed:@"unprotected.png"]];
    }
    else
    {
        [self.devReady setText:[NSLocalizedString(@"Device ready", nil) uppercaseString]];
        [self.detail   setText:NSLocalizedString(@"Your device is protected and waiting for the activation signal.", nil)];
        [nonCamuflageImage setImage:[UIImage imageNamed:@"protected.png"]];
    }
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

-(void)viewDidAppear:(BOOL)animated
{
    BOOL isRegisteredNotifications = NO;
    
    if (IS_OS_8_OR_LATER)
    {
        if ([[UIApplication sharedApplication] isRegisteredForRemoteNotifications] && [[PreyConfig instance] isNotificationSettingsEnabled])
            isRegisteredNotifications = YES;
    }
    else
    {
        UIRemoteNotificationType notificationTypes = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
        if (notificationTypes & UIRemoteNotificationTypeAlert) {
            isRegisteredNotifications = YES;
        }
    }
    
    if (isRegisteredNotifications)
        PreyLogMessage(@"App Delegate", 10, @"Alert notification set. Good!");
    else
    {
        PreyLogMessage(@"App Delegate", 10, @"User has disabled alert notifications");
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert notification disabled",nil)
                                                            message:NSLocalizedString(@"You need to grant Prey access to show alert notifications in order to remotely mark it as missing.",nil)
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK",nil)
                                                  otherButtonTitles:nil];
		[alertView show];
    }

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    int page = floor(self.scrollView.contentOffset.x/self.scrollView.frame.size.width);
    if (page != 0) {
        PreyConfig *config = [PreyConfig instance];
        if (!config.camouflageMode) {
            [self.scrollView setScrollEnabled:YES];
        }
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (self.scrollView.contentOffset.x < 20) {
        [self.scrollView setScrollEnabled:NO];
        [self.view endEditing:YES];
    }
}

@end
