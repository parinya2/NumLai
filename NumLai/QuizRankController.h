//
//  QuizRankController.h
//  NumNao
//
//  Created by PRINYA on 11/30/2557 BE.
//  Copyright (c) 2557 PRINYA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AVFoundation/AVAudioPlayer.h"

@interface QuizRankController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *quizRankTable;
@property (strong, nonatomic) IBOutlet UIButton *backButton;
@property (strong, nonatomic) IBOutlet UILabel *quizModeLabel;
@property (strong, nonatomic) IBOutlet UILabel *quizRankLabel;
@property (strong, nonatomic) IBOutlet UILabel *playerNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *playerScoreLabel;
@property (strong, nonatomic) IBOutlet UILabel *deviceOSLabel;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (assign, nonatomic) NSInteger quizMode;
@property (assign, nonatomic) NSInteger playerScore;
@property (strong, nonatomic) NSString *playerName;
@property (assign, nonatomic) BOOL needSubmitScore;
@property (assign, nonatomic) BOOL navigatedFromMainMenu;

- (IBAction)goBack:(id)sender;
@end
