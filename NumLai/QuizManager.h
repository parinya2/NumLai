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

typedef NS_ENUM(NSInteger, NumLaiQuizMode) {
  NumLaiQuizMode1 = 1, //เพลงฮิตติดชาร์ท
  NumLaiQuizMode2 = 2, //เพลงประกอบละคร
  NumLaiQuizMode3 = 3, //เพลงยุคไนนตี้ 90s
  NumLaiQuizMode4 = 4, //เพลงเพราะหน้า B
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

@property (assign, nonatomic, getter = isTheNewMode1Available) BOOL theNewMode1Available;
@property (assign, nonatomic, getter = isTheNewMode2Available) BOOL theNewMode2Available;
@property (assign, nonatomic, getter = isTheNewMode3Available) BOOL theNewMode3Available;
@property (assign, nonatomic, getter = isTheNewMode4Available) BOOL theNewMode4Available;

@property (strong, nonatomic) NSString *serverVersionMode1;
@property (strong, nonatomic) NSString *serverVersionMode2;
@property (strong, nonatomic) NSString *serverVersionMode3;
@property (strong, nonatomic) NSString *serverVersionMode4;

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
