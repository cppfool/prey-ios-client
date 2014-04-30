//
//  CongratulationsController.m
//  Prey-iOS
//
//  Created by Carlos Yaconi on 04/10/2010.
//  Copyright 2010 Fork Ltd. All rights reserved.
//  License: GPLv3
//  Full license at "/LICENSE"
//

#import <CoreLocation/CoreLocation.h>
#import "CongratulationsController.h"
#import "PreyAppDelegate.h"
#import "LoginController.h"
#import "PreferencesController.h"
#import "Constants.h"

@implementation CongratulationsController

@synthesize congratsTitle, congratsMsg, ok, txtToShow, authLocation;

#pragma mark -
#pragma mark IBActions
- (IBAction) okPressed: (id) sender
{
    @try
    {
        PreyAppDelegate *appDelegate = (PreyAppDelegate*)[[UIApplication sharedApplication] delegate];
        
        LoginController *loginController;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            if (IS_IPHONE5)
                loginController = [[LoginController alloc] initWithNibName:@"LoginController-iPhone-568h" bundle:nil];
            else
                loginController = [[LoginController alloc] initWithNibName:@"LoginController-iPhone" bundle:nil];
        }
        else
            loginController = [[LoginController alloc] initWithNibName:@"LoginController-iPad" bundle:nil];
        
        PreferencesController *preferencesController = [[PreferencesController alloc] initWithStyle:UITableViewStyleGrouped];
        [appDelegate.viewController popToRootViewControllerAnimated:NO];
        [appDelegate.viewController setViewControllers:[NSArray arrayWithObjects:loginController, preferencesController, nil] animated:YES];
        [preferencesController release];
        [loginController release];
    }
    @catch (NSException *exception) {
        PreyLogMessage(@"CongratulationsController", 0, @"CongratulationsController bug: %@", [exception reason]);
    }
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    self.screenName = @"Congratulations";
    
    congratsMsg.font             = [UIFont fontWithName:@"Helvetica" size:20];
    congratsMsg.numberOfLines    = 5;
    congratsMsg.textAlignment    = UITextAlignmentCenter;
    congratsMsg.backgroundColor  = [UIColor clearColor];
    congratsMsg.text             = txtToShow;
    
    authLocation = [[CLLocationManager alloc] init];
    [authLocation  startUpdatingLocation];
    [authLocation stopUpdatingLocation];
	[self.ok setTitle:NSLocalizedString(@"OK",nil) forState:UIControlStateNormal];
    
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	/*
    self.title = @"Congratulations";
    self.congratsTitle.text = NSLocalizedString(@"Congratulations!",nil);
     */
	//self.congratsMsg.text = NSLocalizedString(@"You have successfully associated this device with your Prey Control Panel account.",nil);

	[super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[congratsMsg release];
	[congratsTitle release];
	[ok release];
    [authLocation release];
	[super dealloc];
}


@end
