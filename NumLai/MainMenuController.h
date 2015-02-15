//
//  MainMenuController.h
//  NumNao
//
//  Created by PRINYA on 4/12/2557 BE.
//  Copyright (c) 2557 PRINYA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GADBannerView.h"

@class GADBannerView, GADRequest;

@interface MainMenuController : UIViewController <UIAlertViewDelegate, GADBannerViewDelegate> {
  GADBannerView *bannerView_;
}

@property (nonatomic, strong) IBOutlet UIButton *startButton;
@property (nonatomic, strong) IBOutlet UIImageView *bgImageView;
@property (nonatomic, strong) GADBannerView *bannerView;

- (IBAction)contactUs:(id)sender;
- (IBAction)rateThisApp:(id)sender;
- (IBAction)recommendToFriend:(id)sender;
- (IBAction)goToQuizRank:(id)sender;
- (GADRequest *)createRequest;

@end
