//
//  QuizSetSelectorController.m
//  NumNao
//
//  Created by PRINYA on 4/12/2557 BE.
//  Copyright (c) 2557 PRINYA. All rights reserved.
//

#import "QuizSetSelectorController.h"
#import "QuizDetailController.h"
#import <StoreKit/StoreKit.h>
#import "NumLaiIAPHelper.h"
#import "NumLaiLoadingView.h"
#import "GADBannerView.h"
#import "GADRequest.h"
#import "appID.h"
#import "QuizManager.h"
#import "AVFoundation/AVAudioPlayer.h"

@interface QuizSetSelectorController ()

@property (strong, nonatomic) UIActivityIndicatorView *spinnerView;
@property (strong, nonatomic) NumLaiLoadingView *loadingView;
@property (strong, nonatomic) id productDidPurchasedObserver;
@property (strong, nonatomic) id productDidRestoredObserver;
@property (strong, nonatomic) id productDidPurchasedFailedObserver;
@property (strong, nonatomic) id productDidRestoredFailedObserver;
@property (strong, nonatomic) NSTimer *theNewQuizLabelTimer;
@property (assign, nonatomic) NSInteger quizMode;
@property (assign, nonatomic) BOOL quizLabelAnimationGoForward;

@end

@implementation QuizSetSelectorController
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
  __typeof(self) __weak weakSelf = self;
  
  self.productDidPurchasedObserver = [[NSNotificationCenter defaultCenter]
                                addObserverForName:IAPHelperProductPurchasedNotification
                                object:nil
                                queue:[NSOperationQueue mainQueue]
                                usingBlock:^(NSNotification *note) {
                                  [weakSelf lockAllButtons:NO];
                                  [weakSelf renderLockIcon];
                                  [weakSelf.loadingView removeFromSuperview];
                                }];
 
  self.productDidRestoredObserver = [[NSNotificationCenter defaultCenter]
                                      addObserverForName:IAPHelperProductRestoredNotification
                                      object:nil
                                      queue:[NSOperationQueue mainQueue]
                                      usingBlock:^(NSNotification *note) {
                                        [weakSelf lockAllButtons:NO];
                                        [weakSelf renderLockIcon];
                                        [weakSelf.loadingView removeFromSuperview];
                                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Attention"
                                                  message:@"Products restoration completed"
                                                 delegate:nil
                                        cancelButtonTitle:@"OK"
                                        otherButtonTitles: nil];
                                        [alert show];
                                      }];
  
  self.productDidPurchasedFailedObserver = [[NSNotificationCenter defaultCenter]
                                            addObserverForName:IAPHelperProductPurchasedFailedNotification
                                            object:nil
                                            queue:[NSOperationQueue mainQueue]
                                            usingBlock:^(NSNotification *note) {
                                              [weakSelf lockAllButtons:NO];
                                              [weakSelf renderLockIcon];
                                              [weakSelf.loadingView removeFromSuperview];
                                              UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"โปรดทราบ"
                                                  message:@"การซื้อขายถูกยกเลิกนะจ๊ะ"
                                                  delegate:nil
                                                  cancelButtonTitle:@"ตกลงจ้ะ"
                                                  otherButtonTitles: nil];
                                              [alert show];
                                            }];
  
  self.productDidRestoredFailedObserver = [[NSNotificationCenter defaultCenter]
                                            addObserverForName:IAPHelperProductRestoredFailedNotification
                                            object:nil
                                            queue:[NSOperationQueue mainQueue]
                                            usingBlock:^(NSNotification *note) {
                                              [weakSelf lockAllButtons:NO];
                                              [weakSelf renderLockIcon];
                                              [weakSelf.loadingView removeFromSuperview];
                                              UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Attention"
                                                        message:@"Purchase restoration was cancelled"
                                                      delegate:nil
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles: nil];
                                              [alert show];
                                            }];
  
  __block float yPos = self.quizMode1Button.frame.origin.y +  self.quizMode1Button.frame.size.height + 10;
  self.bannerView = [[GADBannerView alloc] initWithFrame:CGRectMake(0, yPos, GAD_SIZE_320x50.width, GAD_SIZE_320x50.height)];

  self.bannerView.adUnitID = MyAdUnitID_Banner;
  self.bannerView.delegate = self;
  [self.bannerView setRootViewController:self];
  [self.view addSubview:self.bannerView];
  [self.bannerView loadRequest:[self createRequest]];
  
  [self decorateAllButtons];
  [self renderLockIcon];

}

- (void)refreshNewQuizLabel {
  float currentSize = self.quizMode1NewQuizLabel.font.pointSize;
  float minSize = 7;
  float maxSize = 22;
  float newSize;
  NSInteger fontSizeGap = 1;
  if (self.quizLabelAnimationGoForward) {
    newSize = currentSize + fontSizeGap;
  } else {
    newSize = currentSize - fontSizeGap;
  }
  if (newSize >= maxSize) {
    self.quizLabelAnimationGoForward = NO;
  }
  if (newSize <= minSize) {
    self.quizLabelAnimationGoForward = YES;
  }
  [self.quizMode1NewQuizLabel setFont:[UIFont systemFontOfSize:newSize]];
  [self.quizMode2NewQuizLabel setFont:[UIFont systemFontOfSize:newSize]];
  [self.quizMode3NewQuizLabel setFont:[UIFont systemFontOfSize:newSize]];
  [self.quizMode4NewQuizLabel setFont:[UIFont systemFontOfSize:newSize]];
}

- (void)setUpAudioPlayer {
  NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"ominous_sounds" ofType:@"mp3"]];
  self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
  self.audioPlayer.volume = 1.0;
  self.audioPlayer.numberOfLoops = -1;
  [self.audioPlayer play];
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
  [self renderNewQuizLabel];
  self.theNewQuizLabelTimer = [NSTimer scheduledTimerWithTimeInterval:0.02
                                                               target:self
                                                             selector:@selector(refreshNewQuizLabel)
                                                             userInfo:nil
                                                              repeats:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
  
  [self.theNewQuizLabelTimer invalidate];
  self.theNewQuizLabelTimer = nil;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self.productDidPurchasedObserver];
  [[NSNotificationCenter defaultCenter] removeObserver:self.productDidRestoredObserver];
  [[NSNotificationCenter defaultCenter] removeObserver:self.productDidPurchasedFailedObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self.productDidRestoredFailedObserver];
  self.bannerView = nil;
}

- (GADRequest *)createRequest {
  GADRequest *request = [GADRequest request];
  request.testDevices = [NSArray arrayWithObjects:GAD_SIMULATOR_ID, nil];
  return request;
}

- (void)adViewDidReceiveAd:(GADBannerView *)adView {
  __block float yPos = self.quizMode1Button.frame.origin.y + self.quizMode1Button.frame.size.height + 10;
  [UIView animateWithDuration:0 animations:^{
    adView.frame = CGRectMake(0.0, yPos, adView.frame.size.width, adView.frame.size.height);
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
  NumLaiIAPHelper *IAPInstance = [NumLaiIAPHelper sharedInstance];
  switch (alertView.tag) {
    case 100: {
      [self goToQuizDetail:NumLaiQuizMode1];
    } break;

    case 101: {
      [self goToQuizDetail:NumLaiQuizMode2];
    } break;

    case 102: {
      [self goToQuizDetail:NumLaiQuizMode3];
    } break;
      
    case 201 : {
      if (buttonIndex == 1) {
        if (IAPInstance.products) {
          SKProduct *product = IAPInstance.products[0];
          [self lockAllButtons:YES];
          self.loadingView = [[NumLaiLoadingView alloc] init];
          [self.view addSubview:self.loadingView];
          [[NumLaiIAPHelper sharedInstance] buyProduct:product];
        } else {
          [self alertSKProductNotReady];
        }
      }
    } break;
      
    case 202 : {
      if (buttonIndex == 1) {
        if (IAPInstance.products) {
          SKProduct *product = IAPInstance.products[1];
          [self lockAllButtons:YES];
          self.loadingView = [[NumLaiLoadingView alloc] init];
          [self.view addSubview:self.loadingView];
          [[NumLaiIAPHelper sharedInstance] buyProduct:product];
        } else {
          [self alertSKProductNotReady];
        }
      }
    } break;
      
    case 203 : {
      if (buttonIndex == 1) {
        if (IAPInstance.products) {
          SKProduct *product = IAPInstance.products[2];
          [self lockAllButtons:YES];
          self.loadingView = [[NumLaiLoadingView alloc] init];
          [self.view addSubview:self.loadingView];
          [[NumLaiIAPHelper sharedInstance] buyProduct:product];
        } else {
          [self alertSKProductNotReady];
        }
      }
    } break;
      
    default:
      break;
  }
}

#pragma mark - Table view data source

- (IBAction)goToQuiz:(id)sender {
  NSInteger tag = ((UIButton *)sender).tag;
  NumLaiIAPHelper *IAPInstance = [NumLaiIAPHelper sharedInstance];
  if (tag == 0) {
    
    // Mode: ON AIR
    if (IAPInstance.quizMode2Purchased) {
      [self goToQuizDetail:NumLaiQuizMode1];
    } else {
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"โปรดทราบ"
                                                      message:@"เธอสามารถปลดล๊อดโหมดเพลงประกอบละคร ได้อย่างง่ายๆ เพียงแค่เล่นโหมดเพลงฮิตติดชาร์ทให้ได้ 30 คะแนนเท่านั้นนะจ๊ะ !!"
                                                     delegate:self
                                            cancelButtonTitle:@"ตกลงจ้ะ"
                                            otherButtonTitles:nil];
      alert.tag = 100;
      [alert show];
    }
  } else if (tag == 1){
    
    // Mode: Retro CH 3
    if (IAPInstance.quizMode2Purchased) {
      if (IAPInstance.quizMode3Purchased) {
        [self goToQuizDetail:NumLaiQuizMode2];
      } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"โปรดทราบ"
                                                        message:@"เธอสามารถปลดล๊อดโหมดเพลงยุคไนนตี้ 90s ได้อย่างง่ายๆ เพียงแค่เล่นโหมดเพลงประกอบละคร ให้ได้ 30 คะแนนเท่านั้นนะจ๊ะ !!"
                                                       delegate:self
                                              cancelButtonTitle:@"ตกลงจ้ะ"
                                              otherButtonTitles:nil];
        alert.tag = 101;
        [alert show];
      }
    } else {
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"โปรดทราบ"
                                                      message:@"ถ้าไม่อยากจ่ายเงินซื้อ เธอสามารถปลดล๊อคโหมดเพลงประกอบละคร ได้ง่ายๆ โดยการเล่นโหมดเพลงฮิตติดชาร์ทให้ได้ 30 คะแนนเท่านั้นนะจ๊ะ ต้องการซื้อต่อมั้ย"
                                                     delegate:self
                                            cancelButtonTitle:@"ไม่ล่ะฮะ"
                                            otherButtonTitles:@"ซื้อจ้ะ",nil];
      alert.tag = 201;
      [alert show];
    }
    
  } else if (tag == 2){
    
    // Mode: Retro CH 5
    if (IAPInstance.quizMode3Purchased) {
      if (IAPInstance.quizMode4Purchased) {
        [self goToQuizDetail:NumLaiQuizMode3];
      } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"โปรดทราบ"
                                                        message:@"เธอสามารถปลดล๊อดโหมดเพลงเพราะหน้า B ได้อย่างง่ายๆ เพียงแค่เล่นโหมดเพลงยุคไนนตี้ 90s ให้ได้ 30 คะแนนเท่านั้นนะจ๊ะ !!"
                                                       delegate:self
                                              cancelButtonTitle:@"ตกลงจ้ะ"
                                              otherButtonTitles:nil];
        alert.tag = 102;
        [alert show];
      }
    } else {
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"โปรดทราบ"
                                                      message:@"ถ้าไม่อยากจ่ายเงินซื้อ เธอสามารถปลดล๊อคโหมดเพลงยุคไนนตี้ 90s ได้ง่ายๆ โดยการเล่นโหมดเพลงประกอบละคร ให้ได้ 30 คะแนนเท่านั้นนะจ๊ะ ต้องการซื้อต่อมั้ย"
                                                     delegate:self
                                            cancelButtonTitle:@"ไม่ซื้อ"
                                            otherButtonTitles:@"ซื้อต่อ",nil];
      alert.tag = 202;
      [alert show];
    }
  } else if (tag == 3){
    
    // Mode: Retro CH 7
    if (IAPInstance.quizMode4Purchased) {
      [self goToQuizDetail:NumLaiQuizMode4];
    } else {
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"โปรดทราบ"
                                                      message:@"ถ้าไม่อยากจ่ายเงินซื้อ เธอสามารถปลดล๊อคโหมดเพลงเพราะหน้า B ได้ง่ายๆ โดยการเล่นโหมดเพลงยุคไนนตี้ 90s ให้ได้ 30 คะแนนเท่านั้นนะจ๊ะ ต้องการซื้อต่อมั้ย"
                                                     delegate:self
                                            cancelButtonTitle:@"ไม่ซื้อ"
                                            otherButtonTitles:@"ซื้อต่อ",nil];
      alert.tag = 203;
      [alert show];
    }
  }
}

- (IBAction)restorePurchase:(id)sender {
  [self lockAllButtons:YES];
   self.loadingView = [[NumLaiLoadingView alloc] init];
  [self.view addSubview:self.loadingView];
  [[NumLaiIAPHelper sharedInstance] restorePurchasedProducts];
}

- (void)alertSKProductNotReady {
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ขออภัยนะจ๊ะ"
                                                  message:@"ตอนนี้ระบบกำลังดำเนินการเชื่อมต่อกับ iTune อยู่ รอสัก 2-3 นาทีแล้วลองอีกทีนะจ๊ะ!!"
                                                 delegate:self
                                        cancelButtonTitle:@"ตกลงจ้ะ"
                                        otherButtonTitles:nil];
  alert.tag = 110;
  [alert show];
}

- (void)goToQuizDetail:(NSInteger) mode {
  [self.audioPlayer stop];
  [[QuizManager sharedInstance] updateVersionNumberForQuizMode:mode];
  UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
  QuizDetailController *quizDetailController = [storyboard instantiateViewControllerWithIdentifier:@"QuizDetail"];
  quizDetailController.quizMode = mode;
  [self.navigationController pushViewController:quizDetailController animated:YES];
}

- (void)renderNewQuizLabel {
  [self.quizMode1NewQuizLabel setHidden:![QuizManager sharedInstance].isTheNewMode1Available];
  [self.quizMode2NewQuizLabel setHidden:![QuizManager sharedInstance].isTheNewMode2Available];
  [self.quizMode3NewQuizLabel setHidden:![QuizManager sharedInstance].isTheNewMode3Available];
  [self.quizMode4NewQuizLabel setHidden:![QuizManager sharedInstance].isTheNewMode4Available];
}

- (void)renderLockIcon {
  NumLaiIAPHelper *IAPinstance = [NumLaiIAPHelper sharedInstance];

  BOOL isRetroCH3Purchased = IAPinstance.quizMode2Purchased;
  BOOL isRetroCH5Purchased = IAPinstance.quizMode3Purchased;
  BOOL isRetroCH7Purchased = IAPinstance.quizMode4Purchased;
  
  if (isRetroCH3Purchased) {
    self.quizMode2LockImageView.image = nil;
  } else {
    self.quizMode2LockImageView.image = [UIImage imageNamed:@"blue_lock_icon"];
  }
  
  if (isRetroCH5Purchased) {
    self.quizMode3LockImageView.image = nil;
  } else {
    self.quizMode3LockImageView.image = [UIImage imageNamed:@"blue_lock_icon"];
  }
  
  if (isRetroCH7Purchased) {
    self.quizMode4LockImageView.image = nil;
  } else {
    self.quizMode4LockImageView.image = [UIImage imageNamed:@"blue_lock_icon"];
  }
}

- (void)lockAllButtons:(BOOL)flag {
  self.quizMode1Button.enabled = !flag;
  self.quizMode2Button.enabled = !flag;
  self.quizMode3Button.enabled = !flag;
  self.quizMode4Button.enabled = !flag;
}

- (void)decorateAllButtons {
  NSArray *gameModeButtons = [NSArray arrayWithObjects: self.quizMode1Button, self.quizMode2Button, self.quizMode3Button, self.quizMode4Button, self.restorePurchaseButton, nil];
  
  for(UIButton *btn in gameModeButtons)
  {
    // Set the button Text Color
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    
    // Draw a custom gradient
    CAGradientLayer *btnGradient = [CAGradientLayer layer];
    btnGradient.frame = btn.bounds;
    btnGradient.colors = [NSArray arrayWithObjects:
                          (id)[[UIColor colorWithRed:227.0f / 255.0f green:214.0f / 255.0f blue:97.0f / 255.0f alpha:1.0f] CGColor],
                          (id)[[UIColor colorWithRed:227.0f / 255.0f green:214.0f / 255.0f blue:97.0f / 255.0f alpha:1.0f] CGColor],
                          nil];
    
    if ([btn isEqual:self.restorePurchaseButton]) {
      UIColor *grayColor = [UIColor colorWithWhite:150.0f / 255.0f alpha:1.0f];
      btnGradient.colors = [NSArray arrayWithObjects:
                            (id)[grayColor CGColor],
                            (id)[grayColor CGColor],
                            nil];
    }
    
    [btn.layer insertSublayer:btnGradient atIndex:0];
    
    // Round button corners
    CALayer *btnLayer = [btn layer];
    [btnLayer setMasksToBounds:YES];
    [btnLayer setCornerRadius:5.0f];
    
    // Apply a 1 pixel, black border around Buy Button
    [btnLayer setBorderWidth:1.0f];
    [btnLayer setBorderColor:[[UIColor blackColor] CGColor]];
    
  }
  
  NSArray *allQuizLabels = [NSArray arrayWithObjects: self.quizMode1NewQuizLabel,
                            self.quizMode2NewQuizLabel, self.quizMode3NewQuizLabel,
                            self.quizMode4NewQuizLabel, nil];
  for (UILabel *label in allQuizLabels) {
    // Round label corners
    CALayer *labelLayer = [label layer];
    [labelLayer setMasksToBounds:YES];
    [labelLayer setCornerRadius:20.0f];
  }
}

@end
