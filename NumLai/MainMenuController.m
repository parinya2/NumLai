//
//  MainMenuController.m
//  NumNao
//
//  Created by PRINYA on 4/12/2557 BE.
//  Copyright (c) 2557 PRINYA. All rights reserved.
//

#import "MainMenuController.h"
#import "GADBannerView.h"
#import "GADRequest.h"
#import "appID.h"
#import "AVFoundation/AVAudioPlayer.h"
#import "QuizSetSelectorController.h"
#import <Social/Social.h>
#import "QuizManager.h"
#import "QuizRankController.h"

@interface MainMenuController ()

@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (assign, nonatomic) NSInteger quizRankMode;

@end

@implementation MainMenuController
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

  [self setUpAudioPlayer];
  [self decorateAllButtons];
  self.navigationController.navigationBarHidden = YES;
  [self randomBG];
  
/*  self.bannerView = [[GADBannerView alloc] initWithFrame:CGRectMake(0.0, 80.0, GAD_SIZE_320x50.width, GAD_SIZE_320x50.height)];
  self.bannerView.adUnitID = MyAdUnitID;
  self.bannerView.delegate = self;
  [self.bannerView setRootViewController:self];
  [self.view addSubview:self.bannerView];
  [self.bannerView loadRequest:[self createRequest]];*/
}

- (void)randomBG {
  NSUInteger r = arc4random_uniform(4) + 1;
  switch (r) {
    case 1: self.bgImageView.image = [UIImage imageNamed:@"bg5"]; break;
    case 2: self.bgImageView.image = [UIImage imageNamed:@"bg5-1"]; break;
    case 3: self.bgImageView.image = [UIImage imageNamed:@"bg5-2"]; break;
    case 4: self.bgImageView.image = [UIImage imageNamed:@"bg5-3"]; break;
      
    default:
      break;
  }
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  if (!self.audioPlayer.isPlaying) {
    if (self.audioPlayer) {
      [self.audioPlayer play];
    } else {
      [self setUpAudioPlayer];
    }
  }
}

- (void)setUpAudioPlayer {
  NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"ominous_sounds" ofType:@"mp3"]];
  self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
  self.audioPlayer.volume = 1.0;
  self.audioPlayer.numberOfLoops = -1;
  [self.audioPlayer play];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  
  [QuizManager sharedInstance].xmlDataQuizRank = nil;
  [QuizManager sharedInstance].quizRankList = nil;
  
  if ([segue.identifier isEqualToString:@"MainMenuToQuizSetSelectorSegue"]) {
    QuizSetSelectorController *quizSetSelectorController = [segue destinationViewController];
    quizSetSelectorController.audioPlayer = self.audioPlayer;
  } else if ([segue.identifier isEqualToString:@"MainMenuToQuizRankSegue"]) {
    QuizRankController *quizRankController = [segue destinationViewController];
    quizRankController.quizMode = self.quizRankMode;
    quizRankController.playerScore = -1;
    quizRankController.needSubmitScore = NO;
    quizRankController.navigatedFromMainMenu = YES;
    [self.audioPlayer stop];
  }

}

- (GADRequest *)createRequest {
  GADRequest *request = [GADRequest request];
  request.testDevices = [NSArray arrayWithObjects:GAD_SIMULATOR_ID, nil];
  return request;
}

- (void)adViewDidReceiveAd:(GADBannerView *)adView {
  NSLog(@"Ad Received");
  [UIView animateWithDuration:1.0 animations:^{
    adView.frame = CGRectMake(0.0, 80.0, adView.frame.size.width, adView.frame.size.height);
  }];
}

- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error {
  NSLog(@"Failed to receive ad due to: %@", [error localizedFailureReason]);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
  if (alertView.tag == 3) {
      [[UIApplication sharedApplication] openURL:[NSURL URLWithString:URLNumNaoAppStore]];
  } else if (alertView.tag == 4) {
    BOOL goToQuizRank = YES;
    switch (buttonIndex) {
      case 1: self.quizRankMode = NumLaiQuizMode1; break;
      case 2: self.quizRankMode = NumLaiQuizMode2; break;
      case 3: self.quizRankMode = NumLaiQuizMode3; break;
      case 4: self.quizRankMode = NumLaiQuizMode4; break;
      default: goToQuizRank = NO; break;
    }
    
    if (goToQuizRank) {
      [self performSegueWithIdentifier:@"MainMenuToQuizRankSegue" sender:self];
    }
  }
}

- (IBAction)contactUs:(id)sender {
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:URLNumNaoFacebookPage]];
}

- (IBAction)rateThisApp:(id)sender {
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                  message:@"ขอ 5 ดาวเลยนะค๊าาา งุงิ งุงิ "
                                                 delegate:self
                                        cancelButtonTitle:@"ตกลงจ้ะ"
                                        otherButtonTitles:nil];
  alert.tag = 3;
  [alert show];
}

- (IBAction)recommendToFriend:(id)sender {
  SLComposeViewController *fbVC = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
   [fbVC setInitialText:@"นี่ๆ เธอลองเล่นแอพนี้สิ 'น้ำลาย' ควิซแอพสุดมันส์บน AppStore ที่รวมคำถามจากเพลงดังมากมายจากอดีตถึงปัจจุบัน มาให้ทดสอบฝีมือกัน ถ้าเธอคิดว่าฟังเพลงมามากแล้ว เราขอท้าให้เธอเล่น 'น้ำลาย' นะจ๊ะ คิกคิก"];
   [fbVC addURL:[NSURL URLWithString:URLNumNaoAppStore]];
   [fbVC addImage:[UIImage imageNamed:@"bg5-1"]];
   [self presentViewController:fbVC animated:YES completion:nil];
  
  /*NSString *a = @"test";
   NSArray *postItems = @[a];
   UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:postItems applicationActivities:nil];
   [self presentViewController:activityVC animated:YES completion:nil];*/
}

- (IBAction)goToQuizRank:(id)sender {
  UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"ช้าก่อน" message:@"เธออยากดูคะแนนหมวดไหนจ้ะ" delegate:self cancelButtonTitle:@"ไม่ดูละ" otherButtonTitles:@"เพลงฮิตติดชาร์ท", @"เพลงประกอบละคร", @"เพลงยุคไนนตี้ 90s", @"เพลงเพราะหน้า B", nil];

  alert.tag = 4;
  [alert show];
}

- (void)decorateAllButtons {
  NSArray *buttons = [NSArray arrayWithObjects: self.startButton, nil];
  
  for(UIButton *btn in buttons)
  {
    // Set the button Text Color
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    
    // Draw a custom gradient
    // NOTE: 227 214 97 is yellow , 183 220 69 is green
    CAGradientLayer *btnGradient = [CAGradientLayer layer];
    btnGradient.frame = btn.bounds;
    btnGradient.colors = [NSArray arrayWithObjects:
                          (id)[[UIColor colorWithRed:227.0f / 255.0f green:214.0f / 255.0f blue:97.0f / 255.0f alpha:1.0f] CGColor],
                          (id)[[UIColor colorWithRed:227.0f / 255.0f green:214.0f / 255.0f blue:97.0f / 255.0f alpha:1.0f] CGColor],
                          nil];
    [btn.layer insertSublayer:btnGradient atIndex:0];
    
    // Round button corners
    CALayer *btnLayer = [btn layer];
    [btnLayer setMasksToBounds:YES];
    [btnLayer setCornerRadius:5.0f];
    
    // Apply a 1 pixel, black border around Buy Button
    [btnLayer setBorderWidth:2.0f];
    [btnLayer setBorderColor:[[UIColor whiteColor] CGColor]];
    
  }
}

@end
