//
//  FBLoginController.m
//  NumNao
//
//  Created by PRINYA on 6/17/2557 BE.
//  Copyright (c) 2557 PRINYA. All rights reserved.
//

#import "FBLoginController.h"

@interface FBLoginController ()

@end

@implementation FBLoginController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
      

      
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  
  // Custom initialization
  
  // Create a FBLoginView to log the user in with basic, email and friend list permissions
  // You should ALWAYS ask for basic permissions (public_profile) when logging the user in
self.facebookLoginView = [[FBLoginView alloc] initWithReadPermissions:@[@"public_profile", @"email", @"user_friends"]];
  
  // Set this loginUIViewController to be the loginView button's delegate
self.facebookLoginView.delegate = self;
  
  // Align the button in the center horizontally
  self.facebookLoginView.frame = CGRectOffset(self.facebookLoginView.frame,
                                 (self.view.center.x - (self.facebookLoginView.frame.size.width / 2)),
                                 5);
  
  // Align the button in the center vertically
  self.facebookLoginView.center = self.view.center;
  
  // Add the button to the view
  [self.view addSubview:self.facebookLoginView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
