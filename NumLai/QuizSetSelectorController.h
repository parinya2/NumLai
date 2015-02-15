//
//  QuizSetSelectorController.h
//  NumNao
//
//  Created by PRINYA on 4/12/2557 BE.
//  Copyright (c) 2557 PRINYA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GADBannerView.h"

@interface QuizSetSelectorController : UIViewController <UIAlertViewDelegate, GADBannerViewDelegate> {
  GADBannerView *bannerView_;
}


@property (strong, nonatomic) IBOutlet UIButton *quizMode1Button;
@property (strong, nonatomic) IBOutlet UIButton *quizMode2Button;
@property (strong, nonatomic) IBOutlet UIButton *quizMode3Button;
@property (strong, nonatomic) IBOutlet UIButton *quizMode4Button;
@property (strong, nonatomic) IBOutlet UIButton *restorePurchaseButton;

@property (strong, nonatomic) IBOutlet UIImageView *quizMode2LockImageView;
@property (strong, nonatomic) IBOutlet UIImageView *quizMode3LockImageView;
@property (strong, nonatomic) IBOutlet UIImageView *quizMode4LockImageView;

@property (strong, nonatomic) IBOutlet UILabel *quizMode1NewQuizLabel;
@property (strong, nonatomic) IBOutlet UILabel *quizMode2NewQuizLabel;
@property (strong, nonatomic) IBOutlet UILabel *quizMode3NewQuizLabel;
@property (strong, nonatomic) IBOutlet UILabel *quizMode4NewQuizLabel;

@property (strong, nonatomic) GADBannerView *bannerView;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

- (GADRequest *)createRequest;
- (IBAction)goToQuiz:(id)sender;
- (IBAction)restorePurchase:(id)sender;

@end
