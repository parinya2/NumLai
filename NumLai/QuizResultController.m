//
//  QuizResultController.m
//  NumNao
//
//  Created by PRINYA on 4/12/2557 BE.
//  Copyright (c) 2557 PRINYA. All rights reserved.
//

#import "QuizResultController.h"
#import "QuizSetSelectorController.h"
#import "QuizRankController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "NumLaiAppDelegate.h"
#import "NumLaiIAPHelper.h"
#import "GADBannerView.h"
#import "GADInterstitial.h"
#import "GADRequest.h"
#import "appID.h"
#import "AVFoundation/AVAudioPlayer.h"
#import <Social/Social.h>

NSString * const PlayCountKey = @"PlayCountKey";
NSString * const RateAppisVisitedKey = @"RateAppIsVisited";
NSInteger const PlayCountForAlert = 10;
NSInteger const PlayCountForInterstitial = 3;
NSInteger const PlayerNameMaxLength = 40;

@interface QuizResultController ()

@property (strong, nonatomic) NSDictionary *backLinkInfo;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (strong, nonatomic) NSString *quizResultText;
@property (weak, nonatomic) UIView *backLinkView;
@property (weak, nonatomic) UILabel *backLinkLabel;
@property (assign, nonatomic) NSInteger quizResultLevel;
@property (strong, nonatomic) NSString *playerName;
@property (assign, nonatomic) BOOL needSubmitScore;
@property (assign, nonatomic) BOOL allowShowRateAppAlert;
@property (strong, nonatomic) GADInterstitial *interstitial;
@property (strong, nonatomic) NSTimer *quizRankButtonTimer;
@property (assign, nonatomic) float quizRankButtonGreenValue;
@property (assign, nonatomic) BOOL quizRankAnimationGoForward;

@end

@implementation QuizResultController
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
  
  // Banner Ads
  float yPos = self.backToMenuButton.frame.origin.y + self.backToMenuButton.frame.size.height + 5;
  self.bannerView = [[GADBannerView alloc] initWithFrame:CGRectMake(0.0, yPos, GAD_SIZE_320x50.width, GAD_SIZE_320x50.height)];
  self.bannerView.adUnitID = MyAdUnitID_Banner;
  self.bannerView.delegate = self;
  [self.bannerView setRootViewController:self];
  [self.view addSubview:self.bannerView];
  [self.bannerView loadRequest:[self createRequest]];
  
  // Interstitial Ads
  self.interstitial = [self createAndLoadInterstitial];
  
  [self decorateAllButtonsAndLabel];
  [self checkQuizResult];
  
  [self.quizScoreStaticLabel setHidden:YES];
  self.quizResultText = nil;
  self.needSubmitScore = NO;
  
  NSInteger currentPlayCount = [self getPlayCount];
  currentPlayCount++;
  [self savePlayCount:currentPlayCount];
  
  self.allowShowRateAppAlert = YES;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  NumLaiAppDelegate *delegate = (NumLaiAppDelegate *)[[UIApplication sharedApplication] delegate];
  if (delegate.refererAppLink) {
    self.backLinkInfo = delegate.refererAppLink;
    [self _showBackLink];
  }
  delegate.refererAppLink = nil;
  
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [[QuizManager sharedInstance] sendQuizResultLogToServerWithQuizMode:self.quizMode
                                                            quizScore:self.quizScore];
  if (!self.quizResultText) {
    self.quizResultText = [[QuizManager sharedInstance] quizResultStringForScore:self.quizScore];
  }
  self.quizResultLevel = [[QuizManager sharedInstance] quizResultLevelForScore:self.quizScore];
  [self.quizResultLabel setText:self.quizResultText];
  self.quizScoreLabel.text = [NSString stringWithFormat:@"%d", self.quizScore];
  [self.quizScoreStaticLabel setHidden:NO];
  
  self.quizRankButtonTimer = [NSTimer scheduledTimerWithTimeInterval:0.03
                                                               target:self
                                                             selector:@selector(refreshQuizRankButton)
                                                             userInfo:nil
                                                              repeats:YES];
  self.quizRankButtonGreenValue = 214.0f;
  
  NSInteger currentPlayCount = [self getPlayCount];
  if (currentPlayCount % PlayCountForAlert == 0 && ![self getRateAppisVisited] && self.allowShowRateAppAlert) {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"สวัสดีจ้ะ"
                                                    message:@"ขอโทษที่ขัดจังหวะนะจ๊ะ แต่ว่ารบกวนเธอช่วยเข้าไปให้คะแนนแอพน้ำเน่าบน AppStore หน่อยได้มั้ยอ่า แบบว่าเค้าอยากได้ 5 ดาวอ่ะ >_<'  ขอบคุณมากเลยนะจ๊ะ "
                                                   delegate:self
                                          cancelButtonTitle:@"ไม่ล่ะฮะ"
                                          otherButtonTitles:@"ตกลงจ้ะ",nil];
    alert.tag = 2;
    self.allowShowRateAppAlert = NO;
    [alert show];
  }
}

- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
  
  [self.quizRankButtonTimer invalidate];
  self.quizRankButtonTimer = nil;
}

- (void)refreshQuizRankButton {
  float currentGreenValue = self.quizRankButtonGreenValue;
  float minGreenValue = 10.0f;
  float maxGreenValue = 227.0f;
  float newGreenValue;
  float GreenValueGap = 10.0f;
  if (self.quizRankAnimationGoForward) {
    newGreenValue = currentGreenValue + GreenValueGap;
  } else {
    newGreenValue = currentGreenValue - GreenValueGap;
  }
  if (newGreenValue >= maxGreenValue) {
    self.quizRankAnimationGoForward = NO;
  }
  if (newGreenValue <= minGreenValue) {
    self.quizRankAnimationGoForward = YES;
  }
  self.quizRankButtonGreenValue = newGreenValue;
  [self.submitScoreButton setBackgroundColor:[UIColor colorWithRed:227.0f / 255.0f green:newGreenValue / 255.0f blue:97.0f / 255.0f alpha:1.0f]];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
  if (alertView.tag == 2) {
    if (buttonIndex == 1) {
      [self saveRateAppisVisited:YES];
      [[UIApplication sharedApplication] openURL:[NSURL URLWithString:URLNumNaoAppStore]];
    }
  } else if (alertView.tag == 3) {
    NSString *nameText = [[alertView textFieldAtIndex:0] text];
    if (nameText.length > PlayerNameMaxLength) {
      nameText = [nameText substringToIndex:PlayerNameMaxLength];
    }
    self.playerName = nameText;
    self.needSubmitScore = YES;
    [self performSegueWithIdentifier:@"QuizResultToQuizRankSegue" sender:self];
  } else if (alertView.tag == 4) {
    if ([self.interstitial isReady]) {
      [self.interstitial presentFromRootViewController:self];
    }
  }
}

- (void)setUpAudioPlayer {
  NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"bold_valor" ofType:@"mp3"]];
  self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
  self.audioPlayer.volume = 1.0;
  self.audioPlayer.numberOfLoops = -1;
  [self.audioPlayer play];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([segue.identifier isEqualToString:@"QuizResultToQuizRankSegue"]) {
    QuizRankController *quizRankController = [segue destinationViewController];
    quizRankController.audioPlayer = self.audioPlayer;
    quizRankController.quizMode = self.quizMode;
    quizRankController.playerScore = self.quizScore;
    quizRankController.playerName = self.playerName;
    quizRankController.needSubmitScore = self.needSubmitScore;
    quizRankController.navigatedFromMainMenu = NO;
  } else {
    [self.audioPlayer stop];
  }
}

- (GADRequest *)createRequest {
  GADRequest *request = [GADRequest request];
  request.testDevices = [NSArray arrayWithObjects:GAD_SIMULATOR_ID, nil];
  return request;
}

- (void)adViewDidReceiveAd:(GADBannerView *)adView {
  __block float yPos = self.backToMenuButton.frame.origin.y + self.backToMenuButton.frame.size.height + 5;
  [UIView animateWithDuration:0 animations:^{
    adView.frame = CGRectMake(0.0, yPos, adView.frame.size.width, adView.frame.size.height);
  }];
}

- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error {
  NSLog(@"Failed to receive ad due to: %@", [error localizedFailureReason]);
}

- (GADInterstitial *)createAndLoadInterstitial {
  GADInterstitial *interstitial = [[GADInterstitial alloc] init];
  interstitial.adUnitID = MyAdUnitID_Interstitial;
  interstitial.delegate = self;
  [interstitial loadRequest:[GADRequest request]];
  return interstitial;
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)interstitial {
  [self playQuizAgain];
}

- (void)checkQuizResult {
  NSInteger quizScoreToUnlock = 30;
  NumLaiIAPHelper *IAPInstance = [NumLaiIAPHelper sharedInstance];
  
  if (self.quizScore >= quizScoreToUnlock) {
    switch (self.quizMode) {
      case NumLaiQuizMode1: {
        // Mode: On air
        if (!IAPInstance.quizMode2Purchased) {
          IAPInstance.quizMode2Purchased = YES;
          UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ยินดีด้วย !!"
                                                          message:@"เธอปลดล๊อดโหมดเพลงประกอบละคร ได้สำเร็จแล้ว !!"
                                                         delegate:nil
                                                cancelButtonTitle:@"ตกลงจ้ะ"
                                                otherButtonTitles:nil];
          [alert show];
        }
      } break;
      
      case NumLaiQuizMode2: {
        // Mode: Retro CH 3
        if (!IAPInstance.quizMode3Purchased) {
          IAPInstance.quizMode3Purchased = YES;
          UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ยินดีด้วย !!"
                                                          message:@"เธอปลดล๊อดโหมดเพลงยุคไนนตี้ 90s ได้สำเร็จแล้ว !!"
                                                         delegate:nil
                                                cancelButtonTitle:@"ตกลงจ้ะ"
                                                otherButtonTitles:nil];
          [alert show];
        }
      } break;
        
      case NumLaiQuizMode3: {
        // Mode: Retro CH 5
        if (!IAPInstance.quizMode4Purchased) {
          IAPInstance.quizMode4Purchased = YES;
          UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ยินดีด้วย !!"
                                                          message:@"เธอปลดล๊อดโหมดเพลงเพราะหน้า B ได้สำเร็จแล้ว !!"
                                                         delegate:nil
                                                cancelButtonTitle:@"ตกลงจ้ะ"
                                                otherButtonTitles:nil];
          [alert show];
        }
      } break;
        
      default:
        break;
    }
  }

}

- (void)decorateAllButtonsAndLabel {
  
  // Set the button Text Color
  [self.backToMenuButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
  [self.backToMenuButton setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];

  [self.playAgainButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
  [self.playAgainButton setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];

  [self.submitScoreButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
  [self.submitScoreButton setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
  
  // Round button corners
  CALayer *backToMenuBtnLayer = [self.backToMenuButton layer];
  [backToMenuBtnLayer setMasksToBounds:YES];
  [backToMenuBtnLayer setCornerRadius:5.0f];

  CALayer *playAgainBtnLayer = [self.playAgainButton layer];
  [playAgainBtnLayer setMasksToBounds:YES];
  [playAgainBtnLayer setCornerRadius:5.0f];

  CALayer *submitScoreBtnLayer = [self.submitScoreButton layer];
  [submitScoreBtnLayer setMasksToBounds:YES];
  [submitScoreBtnLayer setCornerRadius:5.0f];
  
  // Apply a 1 pixel, black border around Buy Button
  [backToMenuBtnLayer setBorderWidth:1.0f];
  [backToMenuBtnLayer setBorderColor:[[UIColor blackColor] CGColor]];

  [playAgainBtnLayer setBorderWidth:1.0f];
  [playAgainBtnLayer setBorderColor:[[UIColor blackColor] CGColor]];

  [submitScoreBtnLayer setBorderWidth:1.0f];
  [submitScoreBtnLayer setBorderColor:[[UIColor blackColor] CGColor]];
  
  [[self.shareFacebookButton layer] setCornerRadius:5.0];
  
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
  self.bannerView = nil;
}

- (IBAction)playAgain:(id)sender {
  
  NSInteger currentPlayCount = [self getPlayCount];
  NSLog(@"y=%d",currentPlayCount);
  if (currentPlayCount % PlayCountForInterstitial == 0 && [self.interstitial isReady]) {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"สวัสดีจ้ะ"
                                                    message:@"คือว่า เราขออนุญาตโชว์โฆษณานิดนึงนะจ๊ะ อย่าโกรธเราน้าาา >_<"
                                                   delegate:self
                                          cancelButtonTitle:@"ตกลงจ้ะ"
                                          otherButtonTitles:nil];
    alert.tag = 4;
    [alert show];
  } else {
    [self playQuizAgain];
  }
}

- (void)playQuizAgain {
  [self.audioPlayer stop];
  [QuizManager sharedInstance].xmlDataQuizRank = nil;
  [QuizManager sharedInstance].quizRankList = nil;
  [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)goToMainMenu:(id)sender {
  [self.audioPlayer stop];
  [QuizManager sharedInstance].xmlDataQuizRank = nil;
  [QuizManager sharedInstance].quizRankList = nil;
  [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)goToQuizRank:(id)sender {
  
  if (self.playerName) {
    self.needSubmitScore = NO;
    [self performSegueWithIdentifier:@"QuizResultToQuizRankSegue" sender:self];
  } else {
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"ช้าก่อน" message:@"รบกวนเธอช่วยพิมพ์ชื่อตัวเองด้วยนะจ๊ะ" delegate:self cancelButtonTitle:@"ตกลงจ้ะ" otherButtonTitles:nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField * alertTextField = [alert textFieldAtIndex:0];

    alertTextField.keyboardType = UIKeyboardTypeDefault;
    alertTextField.placeholder = @"กรอกชื่อเธอในนี้นะ";
    alert.tag = 3;
    [alert show];
  }
}

- (void)savePlayCount:(NSInteger)playCount {
  [[NSUserDefaults standardUserDefaults] setInteger:playCount forKey:PlayCountKey];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSInteger)getPlayCount {
  return [[NSUserDefaults standardUserDefaults] integerForKey:PlayCountKey];
}

- (void)saveRateAppisVisited:(BOOL)flag {
  [[NSUserDefaults standardUserDefaults] setBool:flag forKey:RateAppisVisitedKey];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)getRateAppisVisited {
  return [[NSUserDefaults standardUserDefaults] boolForKey:RateAppisVisitedKey];
}

- (IBAction)shareOnFacebook:(id)sender {
  [self shareLinkWithShareDialog];
}

- (void)postStatusUpdateWithShareDialog
{
  
  // Check if the Facebook app is installed and we can present the share dialog
  
  FBLinkShareParams *params = [[FBLinkShareParams alloc] init];
  params.link = [NSURL URLWithString:@"https://developers.facebook.com/docs/ios/share/"];
  
  // If the Facebook app is installed and we can present the share dialog
  if ([FBDialogs canPresentShareDialogWithParams:params]) {
    
    // Present share dialog
    [FBDialogs presentShareDialogWithLink:nil
                                  handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                    if(error) {
                                      // An error occurred, we need to handle the error
                                      // See: https://developers.facebook.com/docs/ios/errors
                                      NSLog(@"Error publishing story: %@", error.description);
                                    } else {
                                      // Success
                                      NSLog(@"result %@", results);
                                    }
                                  }];
    
    // If the Facebook app is NOT installed and we can't present the share dialog
  } else {
    // FALLBACK: publish just a link using the Feed dialog
    // Show the feed dialog
    NSMutableDictionary *optionDict = [[NSMutableDictionary alloc] init];
    [optionDict setObject:@"Test" forKey:@"description"];
    [optionDict setObject:@"Test" forKey:@"name"];
    
    
    [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                           parameters:optionDict
                                              handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                if (error) {
                                                  // An error occurred, we need to handle the error
                                                  // See: https://developers.facebook.com/docs/ios/errors
                                                  NSLog(@"Error publishing story: %@", error.description);
                                                } else {
                                                  if (result == FBWebDialogResultDialogNotCompleted) {
                                                    // User cancelled.
                                                    NSLog(@"User cancelled.");
                                                  } else {
                                                    // Handle the publish feed callback
                                                    NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                                                    
                                                    if (![urlParams valueForKey:@"post_id"]) {
                                                      // User cancelled.
                                                      NSLog(@"User cancelled.");
                                                      
                                                    } else {
                                                      // User clicked the Share button
                                                      NSString *result = [NSString stringWithFormat: @"Posted story, id: %@", [urlParams valueForKey:@"post_id"]];
                                                      NSLog(@"result %@", result);
                                                    }
                                                  }
                                                }
                                              }];
  }
}

// A function for parsing URL parameters returned by the Feed Dialog.
- (NSDictionary*)parseURLParams:(NSString *)query {
  NSArray *pairs = [query componentsSeparatedByString:@"&"];
  NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
  for (NSString *pair in pairs) {
    NSArray *kv = [pair componentsSeparatedByString:@"="];
    NSString *val =
    [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    params[kv[0]] = val;
  }
  return params;
}

- (IBAction)shareLinkWithShareDialog
{
 
  NSString *scoreStr = [NSString stringWithFormat:@"คุณได้ %d คะแนน (ความน้ำเน่าระดับ %d)", self.quizScore, self.quizResultLevel];
  NSString *pictureURL = [NSString stringWithFormat:@"http://quiz.thechappters.com/images/namnao/result_images/result_%d.jpg",self.quizResultLevel];
  NSString *link = URLNumNaoAppStore;
  
  // Check if the Facebook app is installed and we can present the share dialog
  FBLinkShareParams *params = [[FBLinkShareParams alloc] init];
  params.link = [NSURL URLWithString:link];
  params.description = self.quizResultText;
  params.caption = nil;
  params.name = scoreStr;
  params.picture = [NSURL URLWithString:pictureURL];
  
  // If the Facebook app is installed and we can present the share dialog
  if ([FBDialogs canPresentShareDialogWithParams:params] && NO) {
    
    [FBDialogs presentShareDialogWithParams:params
                              clientState:nil
                                  handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                    if(error) {
                                      NSLog(@"Error publishing story: %@", error.description);
                                    } else {
                                      NSLog(@"result %@", results);
                                    }
                                  }];
    
    
  } else {
    NSMutableDictionary *optionDict = [[NSMutableDictionary alloc] init];
    [optionDict setObject:scoreStr forKey:@"name"];
    [optionDict setObject:@"" forKey:@"caption"];
    [optionDict setObject:self.quizResultText forKey:@"description"];
    [optionDict setObject:link forKey:@"link"];
    [optionDict setObject:pictureURL forKey:@"picture"];
    
    // Show the feed dialog
    [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                           parameters:optionDict
                                              handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                if (error) {
                                                  NSLog(@"Error publishing story: %@", error.description);
                                                } else {
                                                  if (result == FBWebDialogResultDialogNotCompleted) {
                                                    NSLog(@"User cancelled.");
                                                  } else {
                                                    NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                                                    
                                                    if (![urlParams valueForKey:@"post_id"]) {
                                                      NSLog(@"User cancelled.");
                                                    } else {
                                                      NSString *result = [NSString stringWithFormat: @"Posted story, id: %@", [urlParams valueForKey:@"post_id"]];
                                                      NSLog(@"result %@", result);
                                                    }
                                                  }
                                                }
                                              }];
  }
}

- (IBAction)StatusUpdateWithAPICalls {
  // We will post on behalf of the user, these are the permissions we need:
  NSArray *permissionsNeeded = @[@"publish_actions"];
  
  // Request the permissions the user currently has
  [FBRequestConnection startWithGraphPath:@"/me/permissions"
                        completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                          if (!error){
                            NSDictionary *currentPermissions= [(NSArray *)[result data] objectAtIndex:0];
                            NSMutableArray *requestPermissions = [[NSMutableArray alloc] initWithArray:@[]];
                            
                            // Check if all the permissions we need are present in the user's current permissions
                            // If they are not present add them to the permissions to be requested
                            for (NSString *permission in permissionsNeeded){
                              if (![currentPermissions objectForKey:permission]){
                                [requestPermissions addObject:permission];
                              }
                            }
                            
                            // If we have permissions to request
                            if ([requestPermissions count] > 0){
                              // Ask for the missing permissions
                              [FBSession.activeSession requestNewPublishPermissions:requestPermissions
                                                                    defaultAudience:FBSessionDefaultAudienceFriends
                                                                  completionHandler:^(FBSession *session, NSError *error) {
                                                                    if (!error) {
                                                                      // Permission granted, we can request the user information
                                                                      [self makeRequestToUpdateStatus];
                                                                    } else {
                                                                      // An error occurred, handle the error
                                                                      // See our Handling Errors guide: https://developers.facebook.com/docs/ios/errors/
                                                                      NSLog(@"%@", error.description);
                                                                    }
                                                                  }];
                            } else {
                              // Permissions are present, we can request the user information
                              [self makeRequestToUpdateStatus];
                            }
                            
                          } else {
                            // There was an error requesting the permission information
                            // See our Handling Errors guide: https://developers.facebook.com/docs/ios/errors/
                            NSLog(@"%@", error.description);
                          }
                        }];
}

- (void)makeRequestToUpdateStatus {
  
  // NOTE: pre-filling fields associated with Facebook posts,
  // unless the user manually generated the content earlier in the workflow of your app,
  // can be against the Platform policies: https://developers.facebook.com/policy
  
  [FBRequestConnection startForPostStatusUpdate:@"User-generated status update."
                              completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                if (!error) {
                                  // Status update posted successfully to Facebook
                                  NSLog(@"result: %@", result);
                                } else {
                                  // An error occurred, we need to handle the error
                                  // See: https://developers.facebook.com/docs/ios/errors
                                  NSLog(@"%@", error.description);
                                }
                              }];
}

//------------------Login implementation starts here------------------

// Implement the loginViewShowingLoggedInUser: delegate method to modify your app's UI for a logged-in user experience
- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
  // If the user is logged in, they can post to Facebook using API calls, so we show the buttons
 // [_ShareLinkWithAPICallsButton setHidden:NO];
 // [_StatusUpdateWithAPICallsButton setHidden:NO];
}

// Implement the loginViewShowingLoggedOutUser: delegate method to modify your app's UI for a logged-out user experience
- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
  // If the user is NOT logged in, they can't post to Facebook using API calls, so we show the buttons
 // [_ShareLinkWithAPICallsButton setHidden:YES];
  //[_StatusUpdateWithAPICallsButton setHidden:YES];
}

// You need to override loginView:handleError in order to handle possible errors that can occur during login
- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
  NSString *alertMessage, *alertTitle;
  
  // If the user should perform an action outside of you app to recover,
  // the SDK will provide a message for the user, you just need to surface it.
  // This conveniently handles cases like Facebook password change or unverified Facebook accounts.
  if ([FBErrorUtility shouldNotifyUserForError:error]) {
    alertTitle = @"Facebook error";
    alertMessage = [FBErrorUtility userMessageForError:error];
    
    // This code will handle session closures since that happen outside of the app.
    // You can take a look at our error handling guide to know more about it
    // https://developers.facebook.com/docs/ios/errors
  } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {
    alertTitle = @"Session Error";
    alertMessage = @"Your current session is no longer valid. Please log in again.";
    
    // If the user has cancelled a login, we will do nothing.
    // You can also choose to show the user a message if cancelling login will result in
    // the user not being able to complete a task they had initiated in your app
    // (like accessing FB-stored information or posting to Facebook)
  } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
    NSLog(@"user cancelled login");
    
    // For simplicity, this sample handles other errors with a generic message
    // You can checkout our error handling guide for more detailed information
    // https://developers.facebook.com/docs/ios/errors
  } else {
    alertTitle  = @"Something went wrong";
    alertMessage = @"Please try again later.";
    NSLog(@"Unexpected error:%@", error);
  }
  
  if (alertMessage) {
    [[[UIAlertView alloc] initWithTitle:alertTitle
                                message:alertMessage
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
  }
}


//------------------Handling links back to app link launching app------------------

- (void) _showBackLink {
  if (nil == self.backLinkView) {
    // Set up the view
    UIView *backLinkView = [[UIView alloc] initWithFrame:
                            CGRectMake(0, 30, 320, 40)];
    backLinkView.backgroundColor = [UIColor darkGrayColor];
    UILabel *backLinkLabel = [[UILabel alloc] initWithFrame:
                              CGRectMake(2, 2, 316, 36)];
    backLinkLabel.textColor = [UIColor whiteColor];
    backLinkLabel.textAlignment = NSTextAlignmentCenter;
    backLinkLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0f];
    [backLinkView addSubview:backLinkLabel];
    self.backLinkLabel = backLinkLabel;
    [self.view addSubview:backLinkView];
    self.backLinkView = backLinkView;
  }
  // Show the view
  self.backLinkView.hidden = NO;
  // Set up the back link label display
  self.backLinkLabel.text = [NSString
                             stringWithFormat:@"Touch to return to %@", self.backLinkInfo[@"app_name"]];
  // Set up so the view can be clicked
  UITapGestureRecognizer *tapGestureRecognizer =
  [[UITapGestureRecognizer alloc] initWithTarget:self
                                          action:@selector(_returnToLaunchingApp:)];
  tapGestureRecognizer.numberOfTapsRequired = 1;
  [self.backLinkView addGestureRecognizer:tapGestureRecognizer];
  tapGestureRecognizer.delegate = self;
}

- (void)_returnToLaunchingApp:(id)sender {
  // Open the app corresponding to the back link
  NSURL *backLinkURL = [NSURL URLWithString:self.backLinkInfo[@"url"]];
  if ([[UIApplication sharedApplication] canOpenURL:backLinkURL]) {
    [[UIApplication sharedApplication] openURL:backLinkURL];
  }
  self.backLinkView.hidden = YES;
}

@end
