//
//  QuizResultController.h
//  NumNao
//
//  Created by PRINYA on 4/12/2557 BE.
//  Copyright (c) 2557 PRINYA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuizManager.h"
#import "GADBannerView.h"
#import "GADInterstitial.h"

@interface QuizResultController : UIViewController <UIAlertViewDelegate, GADBannerViewDelegate, GADInterstitialDelegate> {
  GADBannerView *bannerView_;
}


@property (assign, nonatomic) NSInteger quizScore;
@property (assign, nonatomic) NSInteger quizMode;
@property (strong, nonatomic) IBOutlet UILabel *quizScoreLabel;
@property (strong, nonatomic) IBOutlet UILabel *quizScoreStaticLabel;
@property (strong, nonatomic) IBOutlet UILabel *quizResultLabel;
@property (strong, nonatomic) IBOutlet UIButton *shareFacebookButton;
@property (strong, nonatomic) IBOutlet UIButton *playAgainButton;
@property (strong, nonatomic) IBOutlet UIButton *backToMenuButton;
@property (strong, nonatomic) IBOutlet UIButton *submitScoreButton;
@property (strong, nonatomic) GADBannerView *bannerView;

- (GADRequest *)createRequest;
- (IBAction)playAgain:(id)sender;
- (IBAction)goToMainMenu:(id)sender;
- (IBAction)goToQuizRank:(id)sender;
- (IBAction)shareOnFacebook:(id)sender;

@end
