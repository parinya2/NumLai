//
//  QuizManager.h
//  NumNao
//
//  Created by PRINYA on 4/12/2557 BE.
//  Copyright (c) 2557 PRINYA. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const QuizManagerDidLoadQuizSuccess;
extern NSString * const QuizManagerDidLoadQuizFail;
extern NSString * const QuizManagerDidLoadQuizRankSuccess;
extern NSString * const QuizManagerDidLoadQuizRankFail;
extern NSString * const URLNumNaoAppStore;
extern NSString * const URLNumNaoFacebookPage;
extern NSString * const PlayerDummyName;

typedef NS_ENUM(NSInteger, NumNaoQuizMode) {
  NumNaoQuizModeOnAir = 0,
  NumNaoQuizModeRetroCh3 = 1,
  NumNaoQuizModeRetroCh5 = 2,
  NumNaoQuizModeRetroCh7 = 3,
};

@interface QuizManager : NSObject

@property (strong, nonatomic) NSArray *quizListOnAir;
@property (strong, nonatomic) NSArray *quizListRetroCh3;
@property (strong, nonatomic) NSArray *quizListRetroCh5;
@property (strong, nonatomic) NSArray *quizListRetroCh7;
@property (strong, nonatomic) NSArray *quizResultList;
@property (strong, nonatomic) NSArray *quizRankList;

@property (strong, nonatomic) NSData *xmlDataOnAir;
@property (strong, nonatomic) NSData *xmlDataRetroCh3;
@property (strong, nonatomic) NSData *xmlDataRetroCh5;
@property (strong, nonatomic) NSData *xmlDataRetroCh7;
@property (strong, nonatomic) NSData *xmlDataQuizResult;
@property (strong, nonatomic) NSData *xmlDataQuizRank;

@property (assign, nonatomic, getter = isTheNewOnAirAvailable) BOOL theNewOnAirAvailable;
@property (assign, nonatomic, getter = isTheNewRetroCh3Available) BOOL theNewRetroCh3Available;
@property (assign, nonatomic, getter = isTheNewRetroCh5Available) BOOL theNewRetroCh5Available;
@property (assign, nonatomic, getter = isTheNewRetroCh7Available) BOOL theNewRetroCh7Available;

@property (strong, nonatomic) NSString *serverVersionOnAir;
@property (strong, nonatomic) NSString *serverVersionRetroCh3;
@property (strong, nonatomic) NSString *serverVersionRetroCh5;
@property (strong, nonatomic) NSString *serverVersionRetroCh7;

- (NSArray *)mockQuizList;
- (NSString *)quizResultStringForScore:(NSInteger)quizScore;
- (NSInteger)quizResultLevelForScore:(NSInteger)quizScore;
- (void)loadQuizListFromServer:(NSInteger)quizMode;
- (void)loadQuizRankFromServer:(NSInteger)quizMode quizScore:(NSInteger)quizScore;
- (void)loadQuizResultListFromServer;
- (void)sendQuizResultLogToServerWithQuizMode:(NSInteger)quizMode
                                    quizScore:(NSInteger)quizScore;
- (void)sendQuizRankToServerWithQuizMode:(NSInteger)quizMode
                               quizScore:(NSInteger)quizScore
                              playerName:(NSString *)playerName;
- (void)sendDeviceTokenToServerWithToken:(NSString *)deviceToken;
- (void)checkQuizUpdateWithServer;
- (void)updateVersionNumberForQuizMode:(NSInteger)quizMode ;

+ (QuizManager *)sharedInstance;

@end
