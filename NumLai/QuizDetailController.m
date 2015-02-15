//
//  QuizDetailController.m
//  NumNao
//
//  Created by PRINYA on 4/12/2557 BE.
//  Copyright (c) 2557 PRINYA. All rights reserved.
//

#import "QuizDetailController.h"
#import "QuizSetSelectorController.h"
#import "QuizManager.h"
#import "QuizObject.h"
#import "QuizResultController.h"
#import "NumLaiLoadingView.h"
#import "GADBannerView.h"
#import "GADRequest.h"
#import "appID.h"
#import "AVFoundation/AVAudioPlayer.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAITracker.h"
#import "GAIDictionaryBuilder.h"

const NSInteger QuizScoreToPassLevel1 = 8;
const NSInteger QuizScoreToPassLevel2 = 16;
const NSInteger StartCountDounTime = 60;
const NSInteger penaltyTime = 3;
const NSInteger bonusTime = 1;
const float LoadNextQuizDelayTime = 0.25;

@interface QuizDetailController ()

@property NSInteger quizCounter;
@property NSInteger quizScore;
@property NSInteger selectedAnswerIndex;
@property NSInteger correctAnswerIndex;
@property BOOL isAnswerConfirmed;
@property (strong, nonatomic) NSArray *quizList;
@property (strong, nonatomic) NSMutableArray *quizListLevel1;
@property (strong, nonatomic) NSMutableArray *quizListLevel2;
@property (strong, nonatomic) NSMutableArray *quizListLevel3;
@property (strong, nonatomic) UIColor *neutralButtonColor;
@property (strong, nonatomic) UIColor *rightButtonColor;
@property (strong, nonatomic) UIColor *wrongButtonColor;
@property (strong, nonatomic) QuizManager *quizManager;
@property (strong, nonatomic) NSTimer *countDownTimer;
@property (strong, nonatomic) NSTimer *changeQuizTimer;
@property (assign, nonatomic) NSInteger remainingTime;
@property (assign, nonatomic) BOOL canChooseAnswer;

@property (strong, nonatomic) UIActivityIndicatorView *spinnerView;
@property (strong, nonatomic) NumLaiLoadingView *loadingView;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

@property (strong, nonatomic) id quizManagerDidLoadQuizSuccessObserver;
@property (strong, nonatomic) id quizManagerDidLoadQuizFailObserver;

- (IBAction)chooseAnswer:(id)sender;
- (IBAction)goToNextQuiz:(id)sender;


@end

@implementation QuizDetailController
@synthesize bannerView = bannerView_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  [self enableNextButton:NO];
  
  [self setUpAudioPlayer];
  
  float yPos = self.ans2Button.frame.origin.y + self.ans2Button.frame.size.height - 5;
  self.bannerView = [[GADBannerView alloc] initWithFrame:CGRectMake(0, yPos, GAD_SIZE_320x50.width, GAD_SIZE_320x50.height)];
  self.bannerView.adUnitID = MyAdUnitID_Banner;
  self.bannerView.delegate = self;
  [self.bannerView setRootViewController:self];
  [self.view addSubview:self.bannerView];
  [self.bannerView loadRequest:[self createRequest]];

  [self hideEverything:YES];
  self.loadingView = [[NumLaiLoadingView alloc] init];
  [self.view addSubview:self.loadingView];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  self.screenName = @"Quiz-Playing Screen";
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  [self sendGoogleAnalyticsData];
  [self decorateAllButtonsAndLabel];
  
  if (!self.audioPlayer.isPlaying) {
    if (self.audioPlayer) {
      self.audioPlayer.currentTime = 0;
      [self.audioPlayer play];
    } else {
      [self setUpAudioPlayer];
    }
  }
  
  self.canChooseAnswer = YES;
  self.remainingTime = StartCountDounTime;
  self.quizCounter = 0;
  self.quizScore = 0;
  self.scoreLabel.text = [self stringForScoreLabel:self.quizScore];
  self.remainingTimeLabel.text = [self stringForRemainingTimeLabel:self.remainingTime];
  
  self.neutralButtonColor = [UIColor colorWithRed:227.0/255.0 green:214.0/255.0 blue:97.0/255.0 alpha:1.0];
  self.rightButtonColor = [UIColor greenColor];//[UIColor colorWithRed:180.0/255.0 green:223.0/255.0 blue:69.0/255.0 alpha:1.0];
  self.wrongButtonColor = [UIColor redColor];
  
  __typeof(self) __weak weakSelf = self;
  
  self.quizManagerDidLoadQuizSuccessObserver =
  [[NSNotificationCenter defaultCenter]
   addObserverForName:QuizManagerDidLoadQuizSuccess
   object:nil
   queue:[NSOperationQueue mainQueue]
   usingBlock:^(NSNotification *note) {
     QuizManager *quizManager = [QuizManager sharedInstance];
     switch (weakSelf.quizMode) {
       case NumLaiQuizMode1: {
         weakSelf.quizList = quizManager.quizListOnAir;
       } break;
         
       case NumLaiQuizMode2: {
         weakSelf.quizList = quizManager.quizListRetroCh3;
       } break;
         
       case NumLaiQuizMode3: {
         weakSelf.quizList = quizManager.quizListRetroCh5;
       } break;
         
       case NumLaiQuizMode4: {
         weakSelf.quizList = quizManager.quizListRetroCh7;
       } break;
         
       default:
         break;
     }
     [weakSelf.loadingView removeFromSuperview];
     [weakSelf hideEverything:NO];
     if (weakSelf.quizList) {
       [weakSelf extractQuizByLevel];
       QuizObject *quizObject = [weakSelf randomQuiz];
       [weakSelf renderPageWithQuizObject:quizObject quizNo:weakSelf.quizCounter+1];
       [weakSelf enableNextButton:NO];
       
       if (!weakSelf.countDownTimer) {
         weakSelf.countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                                    target:self
                                                                  selector:@selector(decreaseRemainingTime)
                                                                  userInfo:nil
                                                                   repeats:YES];
       }
     }
   }];
  
  self.quizManagerDidLoadQuizFailObserver =
  [[NSNotificationCenter defaultCenter]
   addObserverForName:QuizManagerDidLoadQuizFail
   object:nil
   queue:[NSOperationQueue mainQueue]
   usingBlock:^(NSNotification *note) {
     [weakSelf.loadingView removeFromSuperview];
     [weakSelf hideEverything:NO];
     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"เกิดข้อผิดพลาด"
                                                     message:@"เธอต้องต่อ internet ก่อนนะถึงจะเล่นได้น่ะ แต่ถ้ายังเล่นไม่ได้อีก แสดงว่าเซิร์ฟเวอร์มีปัญหาน่ะ รอสักพักแล้วลองใหม่นะ"
                                                    delegate:self
                                           cancelButtonTitle:@"ตกลงจ้ะ"
                                           otherButtonTitles:nil];
     alert.tag = 100;
     [alert show];
   }];

  
  [[QuizManager sharedInstance] loadQuizListFromServer:self.quizMode];
  [[QuizManager sharedInstance] loadQuizResultListFromServer];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];

  [self.audioPlayer stop];

  [self.countDownTimer invalidate];
  self.countDownTimer = nil;
  
  [self.changeQuizTimer invalidate];
  self.changeQuizTimer = nil;
  
  [[NSNotificationCenter defaultCenter] removeObserver:self.quizManagerDidLoadQuizSuccessObserver];
  [[NSNotificationCenter defaultCenter] removeObserver:self.quizManagerDidLoadQuizFailObserver];
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self.quizManagerDidLoadQuizSuccessObserver];
  [[NSNotificationCenter defaultCenter] removeObserver:self.quizManagerDidLoadQuizFailObserver];
  self.bannerView = nil;
}

- (void)sendGoogleAnalyticsData{
  [[GAI sharedInstance].defaultTracker set:kGAIScreenName value:@"Quiz-Playing Screen"];
  [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)setUpAudioPlayer {
  NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"a_day_in_the_sun" ofType:@"mp3"]];
  self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
  self.audioPlayer.volume = 1.0;
  self.audioPlayer.numberOfLoops = -1;
  [self.audioPlayer play];
}

- (void)extractQuizByLevel {
  NSIndexSet *quizLevel1Indexes = [self.quizList indexesOfObjectsPassingTest:^BOOL(QuizObject *quizObj, NSUInteger idx, BOOL *stop) {
    return quizObj.quizLevel == 1;
  }];
  
  NSIndexSet *quizLevel2Indexes = [self.quizList indexesOfObjectsPassingTest:^BOOL(QuizObject *quizObj, NSUInteger idx, BOOL *stop) {
    return quizObj.quizLevel == 2;
  }];
  
  NSIndexSet *quizLevel3Indexes = [self.quizList indexesOfObjectsPassingTest:^BOOL(QuizObject *quizObj, NSUInteger idx, BOOL *stop) {
    return quizObj.quizLevel == 3;
  }];
  self.quizListLevel1 = [[self.quizList objectsAtIndexes:quizLevel1Indexes] mutableCopy];
  self.quizListLevel2 = [[self.quizList objectsAtIndexes:quizLevel2Indexes] mutableCopy];
  self.quizListLevel3 = [[self.quizList objectsAtIndexes:quizLevel3Indexes] mutableCopy];
}

- (QuizObject *)randomQuiz {
  QuizObject *quizObject = nil;
  if (self.quizMode == NumLaiQuizMode1 &&
      self.quizListLevel1.count &&
      self.quizListLevel2.count &&
      self.quizListLevel3.count) {
    if (self.quizScore < QuizScoreToPassLevel1) {
      if ([self.quizListLevel1 count] == 0) {
        [self extractQuizByLevel];
      }
      NSUInteger randomIndex;
      randomIndex = arc4random() % [self.quizListLevel1 count];
      quizObject = [self.quizListLevel1 objectAtIndex:randomIndex];
      [self.quizListLevel1 removeObjectAtIndex:randomIndex];
    } else if (self.quizScore < QuizScoreToPassLevel2) {
      if ([self.quizListLevel2 count] == 0) {
        [self extractQuizByLevel];
      }
      NSUInteger randomIndex = arc4random() % [self.quizListLevel2 count];
      quizObject = [self.quizListLevel2 objectAtIndex:randomIndex];
      [self.quizListLevel2 removeObjectAtIndex:randomIndex];
      
    } else {
      if ([self.quizListLevel3 count] == 0) {
        [self extractQuizByLevel];
      }
      NSUInteger randomIndex = arc4random() % [self.quizListLevel3 count];
      quizObject = [self.quizListLevel3 objectAtIndex:randomIndex];
      [self.quizListLevel3 removeObjectAtIndex:randomIndex];
    }
  } else {
    if ([self.quizListLevel1 count] == 0) {
      [self extractQuizByLevel];
    }
    NSUInteger randomIndex = arc4random() % [self.quizListLevel1 count];
    quizObject = [self.quizListLevel1 objectAtIndex:randomIndex];
    [self.quizListLevel1 removeObjectAtIndex:randomIndex];
  }
  return quizObject;
}

- (GADRequest *)createRequest {
  GADRequest *request = [GADRequest request];
  request.testDevices = [NSArray arrayWithObjects:GAD_SIMULATOR_ID, nil];
  return request;
}

- (void)adViewDidReceiveAd:(GADBannerView *)adView {
  __block float yPos = self.ans2Button.frame.origin.y + self.ans2Button.frame.size.height + 5;
  [UIView animateWithDuration:0 animations:^{
    adView.frame = CGRectMake(0.0, yPos, adView.frame.size.width, adView.frame.size.height);
  }];
}

- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error {
  NSLog(@"Failed to receive ad due to: %@", [error localizedFailureReason]);
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
  switch (alertView.tag) {
    case 100: {
      [self.navigationController popViewControllerAnimated:YES];
    } break;
    default: break;
  }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)decreaseRemainingTime {
  self.remainingTime--;
  self.remainingTimeLabel.text = [self stringForRemainingTimeLabel:self.remainingTime];
  if (self.remainingTime <= 0) {
    [self goToSummaryPage];
  }
}

- (NSString *)stringForRemainingTimeLabel:(NSInteger) remainingTime {
  NSInteger time = remainingTime < 0 ? 0 : remainingTime;
  return [NSString stringWithFormat:@"เหลือ %ld วินาที",time];
}

- (NSString *)stringForScoreLabel:(NSInteger) score {
  return [NSString stringWithFormat:@"คุณได้ %ld คะแนน",score];
}

- (void)renderPageWithQuizObject:(QuizObject *) quizObject quizNo:(NSInteger) quizNo{
  self.quizCounterLabel.text = [NSString stringWithFormat:@"ข้อที่ %ld",quizNo];
  self.quizLabel.text = quizObject.quizText;
  self.correctAnswerIndex = quizObject.answerIndex;
  self.scoreLabel.text = [self stringForScoreLabel:self.quizScore];
  
  [self.ans1Button setTitle:quizObject.ansChoice1 forState:UIControlStateNormal];
  [self.ans2Button setTitle:quizObject.ansChoice2 forState:UIControlStateNormal];
  [self.ans3Button setTitle:quizObject.ansChoice3 forState:UIControlStateNormal];
  [self.ans4Button setTitle:quizObject.ansChoice4 forState:UIControlStateNormal];

  self.ans1Button.backgroundColor = self.neutralButtonColor;
  self.ans2Button.backgroundColor = self.neutralButtonColor;
  self.ans3Button.backgroundColor = self.neutralButtonColor;
  self.ans4Button.backgroundColor = self.neutralButtonColor;

  self.correctionImageView.image = nil;
}

- (IBAction)chooseAnswer:(id)sender {
  
  if (self.canChooseAnswer) {
    self.selectedAnswerIndex = ((UIButton *)sender).tag;
    
    self.ans1Button.backgroundColor = self.neutralButtonColor;
    self.ans2Button.backgroundColor = self.neutralButtonColor;
    self.ans3Button.backgroundColor = self.neutralButtonColor;
    self.ans4Button.backgroundColor = self.neutralButtonColor;
    
    [self checkAnswer];
  }
}

- (void)checkAnswer {
  // Check whether users selected the correct answer
  self.canChooseAnswer = NO;
  UIColor *buttonColor = nil;
  
  if (self.selectedAnswerIndex != 0) {
    if (self.selectedAnswerIndex == self.correctAnswerIndex) {
      //self.correctionImageView.image = [UIImage imageNamed:@"right_icon"];
      self.quizScore++;
      self.scoreLabel.text = [self stringForScoreLabel:self.quizScore];
      self.remainingTime = self.remainingTime + bonusTime;
      buttonColor = self.rightButtonColor;
    } else {
      //self.correctionImageView.image = [UIImage imageNamed:@"wrong_icon"];
      self.remainingTime = (self.remainingTime - penaltyTime) < 0 ? 0 : (self.remainingTime - penaltyTime);
      buttonColor = self.wrongButtonColor;
    }
    
    switch (self.selectedAnswerIndex) {
      case 1:
        self.ans1Button.backgroundColor = buttonColor;
        break;
      case 2:
        self.ans2Button.backgroundColor = buttonColor;
        break;
      case 3:
        self.ans3Button.backgroundColor = buttonColor;
        break;
      case 4:
        self.ans4Button.backgroundColor = buttonColor;
        break;
      default:
        break;
    }
    
    if (self.changeQuizTimer && [self.changeQuizTimer isValid]) {
      [self.changeQuizTimer invalidate];
      self.changeQuizTimer = nil;
    }
    self.changeQuizTimer = [NSTimer scheduledTimerWithTimeInterval:LoadNextQuizDelayTime
                                                               target:self
                                                             selector:@selector(loadNextQuiz)
                                                             userInfo:nil
                                                              repeats:NO];
  }
}

- (void)loadNextQuiz {
  self.quizCounter++;
  
  QuizObject *nextQuiz = [self randomQuiz];
  self.selectedAnswerIndex = 0;
  [self renderPageWithQuizObject:nextQuiz quizNo:self.quizCounter+1];
  self.canChooseAnswer = YES;
}

- (IBAction)goToNextQuiz:(id)sender {
  
  // Users already confirm the answer, so we go to the next quiz
  self.quizCounter++;
  
  QuizObject *nextQuiz = [self randomQuiz];
  self.selectedAnswerIndex = 0;
  [self renderPageWithQuizObject:nextQuiz quizNo:self.quizCounter+1];
  
  [self enableNextButton:NO];
}

- (void)goToSummaryPage {
  [self hideEverything:YES];
  UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
  QuizResultController *quizResultController = [storyboard instantiateViewControllerWithIdentifier:@"QuizResult"];
  quizResultController.quizScore = self.quizScore;
  quizResultController.quizMode = self.quizMode;
  [self.navigationController pushViewController:quizResultController animated:YES];
}

- (void)enableNextButton:(BOOL)flag {
  [self.nextButton setEnabled:flag];
  [self.nextButton setHidden:!flag];
}

- (void)decorateAllButtonsAndLabel {

  self.correctionImageView.backgroundColor = [UIColor clearColor];
  [[self.correctionImageView layer] setOpaque:NO];
  [self.correctionImageView setOpaque:NO];

  
  NSArray *buttons = [NSArray arrayWithObjects: self.ans1Button, self.ans2Button, self.ans3Button, self.ans4Button, self.nextButton, nil];
  
  for(UIButton *btn in buttons) {
    [[btn layer] setCornerRadius:5.0];
  }
}

- (void)hideEverything:(BOOL)flag {
  [self.ans1Button setHidden:flag];
  [self.ans2Button setHidden:flag];
  [self.ans3Button setHidden:flag];
  [self.ans4Button setHidden:flag];
  [self.remainingTimeLabel setHidden:flag];
  [self.scoreLabel setHidden:flag];
  [self.quizLabel setHidden:flag];
  [self.quizCounterLabel setHidden:flag];
  [self.correctionImageView setHidden:flag];
}
@end
