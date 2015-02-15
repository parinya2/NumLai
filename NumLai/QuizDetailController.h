//
//  QuizDetailController.h
//  NumNao
//
//  Created by PRINYA on 4/12/2557 BE.
//  Copyright (c) 2557 PRINYA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GADBannerView.h"
#import "GAITrackedViewController.h"

@interface QuizDetailController : GAITrackedViewController <UIAlertViewDelegate, GADBannerViewDelegate> {
  GADBannerView *bannerView_;
}

@property (strong) IBOutlet UILabel *quizLabel;
@property (strong) IBOutlet UILabel *quizCounterLabel;
@property (strong) IBOutlet UILabel *scoreLabel;
@property (strong) IBOutlet UILabel *remainingTimeLabel;
@property (strong) IBOutlet UIButton *ans1Button;
@property (strong) IBOutlet UIButton *ans2Button;
@property (strong) IBOutlet UIButton *ans3Button;
@property (strong) IBOutlet UIButton *ans4Button;
@property (strong) IBOutlet UIButton *nextButton;
@property (strong) IBOutlet UIImageView *correctionImageView;
@property (nonatomic, strong) GADBannerView *bannerView;
@property (assign, nonatomic) NSInteger quizMode;

- (GADRequest *)createRequest;
@end
