//
//  QuizManager.m
//  NumNao
//
//  Created by PRINYA on 4/12/2557 BE.
//  Copyright (c) 2557 PRINYA. All rights reserved.
//

#import "QuizManager.h"
#import "QuizObject.h"
#import "QuizResultObject.h"
#import "QuizRankObject.h"
#import "TBXML.h"

NSString * const QuizManagerDidLoadQuizSuccess = @"QuizManagerDidLoadQuizSuccess";
NSString * const QuizManagerDidLoadQuizFail = @"QuizManagerDidLoadQuizFail";
NSString * const QuizManagerDidLoadQuizRankSuccess = @"QuizManagerDidLoadQuizRankSuccess";
NSString * const QuizManagerDidLoadQuizRankFail = @"QuizManagerDidLoadQuizRankFail";
NSString * const VersionKeyOnAir = @"VersionKeyOnAir";
NSString * const VersionKeyRetroCh3 = @"VersionKeyRetroCh3";
NSString * const VersionKeyRetroCh5 = @"VersionKeyRetroCh5";
NSString * const VersionKeyRetroCh7 = @"VersionKeyRetroCh7";
NSString * const DeviceTokenSentKey = @"DeviceTokenSent";
NSString * const QuizDefaultVersion = @"QuizDefaultVersion";
NSString * const PlaynerDummyName = @"NumNaoPlayerDummyName";
NSString * const URLNumNaoAppStore = @"https://itunes.apple.com/th/app/id903714798?mt=8";
NSString * const URLNumNaoFacebookPage = @"https://m.facebook.com/thechappters";
//NSString * const URLNumNaoAppStore = @"http://bit.ly/numnao";
//NSString * const URLNumNaoFacebookPage = @"http://bit.ly/thechappters";


@implementation QuizManager

+ (QuizManager *)sharedInstance {
  static dispatch_once_t once;
  static QuizManager *sharedInstance;
  dispatch_once(&once, ^{
    sharedInstance = [[self alloc] init];
  });
  return sharedInstance;
}

- (NSInteger)quizResultLevelForScore:(NSInteger)quizScore {
  if (quizScore == 0) {
    return 0;
  }
  
  NSArray *sortedQuizResultList = [self.quizResultList sortedArrayUsingDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"scoreFrom" ascending:YES], nil]];
  
  NSInteger quizResultLevel = 1;
  QuizResultObject *prevQuizResultObject = nil;
  for (QuizResultObject *quizResultObject in sortedQuizResultList) {
    if (prevQuizResultObject) {
     if (quizResultObject.scoreFrom > prevQuizResultObject.scoreFrom &&
         quizResultObject.scoreTo > prevQuizResultObject.scoreTo) {
       quizResultLevel++;
     }
    }
    
    if ([quizResultObject matchForScore:quizScore]) {
      return quizResultLevel;
    }
    
    prevQuizResultObject = quizResultObject;
  }
  
  return quizResultLevel;
}

- (NSString *)quizResultStringForScore:(NSInteger)quizScore {
  NSString *resultString = nil;
  NSMutableArray *quizResults = [[NSMutableArray alloc] init];
  for (QuizResultObject *quizResultObject in self.quizResultList) {
    if ([quizResultObject matchForScore:quizScore]) {
      [quizResults addObject:quizResultObject];
    }
  }
  
  if (quizResults.count) {
    NSInteger randomIndex = arc4random() % [quizResults count];
    QuizResultObject *quizResultObject = (QuizResultObject *)quizResults[randomIndex];
    resultString = quizResultObject.resultText;
  }

  if (!resultString) {
    if (quizScore <= 7) {
      resultString = @"เอิ่ม ได้น้อยไปหน่อยนะ เธอต้องหมั่นดูละครหลังข่าวให้หนักหน่วงกว่านี้แล้วล่ะ";
    } else if (quizScore <= 14) {
      resultString = @"อ๊ะ ใช้ได้ๆ เธอดูละครหลังข่าวมาเยอะพอตัวเลยนะเนี่ย";
    } else {
      resultString = @"สุดยอดอ่ะ เธอดูละครหลังข่าวมาอย่างโชกโชนเลยสินะ";
    }
  }
  
  return resultString;
}

- (void)loadQuizRankFromServer:(NSInteger)quizMode quizScore:(NSInteger)quizScore {
  
  BOOL cacheAvailable = NO;
  if (self.xmlDataQuizRank) {
    cacheAvailable = YES;
  }
  
  NSString *urlString = [self urlStringQuizRankFromQuizMode:quizMode quizScore:quizScore];
  NSURL *url = [NSURL URLWithString:urlString];
  NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
  NSOperationQueue *queue = [[NSOperationQueue alloc] init];
  
  if (cacheAvailable) {
    NSMutableArray *quizRankList = [self extractQuizRankFromXMLdata:self.xmlDataQuizRank];
    self.quizRankList = [quizRankList copy];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:QuizManagerDidLoadQuizRankSuccess object:nil userInfo:nil];
  } else {
    NSLog(@"Start Connecting Async: Quiz Rank");
    [NSURLConnection
     sendAsynchronousRequest:urlRequest
     queue:queue
     completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
       if (error) {
         NSLog(@"Error SendAsyncRequest Quiz Rank %@",error.localizedDescription);
         [[NSNotificationCenter defaultCenter] postNotificationName:QuizManagerDidLoadQuizRankFail object:nil userInfo:nil];
       } else {
         NSLog(@"End Connecting Async: Quiz Rank");
         
         NSMutableArray *quizRankList = [self extractQuizRankFromXMLdata:data];
         self.quizRankList = [quizRankList copy];
         self.xmlDataQuizRank = [data copy];
         
         [[NSNotificationCenter defaultCenter] postNotificationName:QuizManagerDidLoadQuizRankSuccess object:nil userInfo:nil];
       }
     }];
  }
}

- (void)loadQuizResultListFromServer {
  BOOL cacheAvailable = NO;
  if (self.xmlDataQuizResult) {
    cacheAvailable = YES;
  }
  
  NSString *urlString = @"http://quiz.thechappters.com/webservice.php?app_id=1&method=getResultText";
  NSURL *url = [NSURL URLWithString:urlString];
  NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
  NSOperationQueue *queue = [[NSOperationQueue alloc] init];
  
  if (cacheAvailable) {
    NSMutableArray *quizResultList = [self extractQuizResultFromXMLdata:self.xmlDataQuizResult];
    self.quizResultList = [quizResultList copy];
    
    [NSURLConnection
     sendAsynchronousRequest:urlRequest
     queue:queue
     completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
       if (!error) {
         self.xmlDataQuizResult = [data copy];
       }
     }];
  } else {
    NSLog(@"Start Connecting Async: Quiz Result");
    [NSURLConnection
     sendAsynchronousRequest:urlRequest
     queue:queue
     completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
       if (error) {
         NSLog(@"Error SendAsyncRequest Quiz Result %@",error.localizedDescription);
       } else {
         NSLog(@"End Connecting Async: Quiz Result");
         
         NSMutableArray *quizResultList = [self extractQuizResultFromXMLdata:data];
         self.quizResultList = [quizResultList copy];
         self.xmlDataQuizResult = [data copy];
       }
     }];
  }
}

- (void)loadQuizListFromServer:(NSInteger)quizMode {
  
  BOOL cacheAvailable = NO;
  switch (quizMode) {
    case NumNaoQuizModeOnAir: {
      if (self.xmlDataOnAir) {
        cacheAvailable = YES;
      }
    } break;
      
    case NumNaoQuizModeRetroCh3: {
      if (self.xmlDataRetroCh3) {
        cacheAvailable = YES;
      }
    } break;
      
    case NumNaoQuizModeRetroCh5: {
      if (self.xmlDataRetroCh5) {
        cacheAvailable = YES;
      }
    } break;
      
    case NumNaoQuizModeRetroCh7: {
      if (self.xmlDataRetroCh7) {
        cacheAvailable = YES;
      }
    } break;
      
    default:
      break;
  }
  
  NSString *urlString = [self urlStringFromQuizMode:quizMode];
  NSURL *url = [NSURL URLWithString:urlString];
  NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
  NSOperationQueue *queue = [[NSOperationQueue alloc] init];
  
  if (cacheAvailable) {
    NSLog(@"QuizManager Use Cache");
    
    switch (quizMode) {
      case NumNaoQuizModeOnAir: {
        NSMutableArray *quizList = [self extractQuizFromXMLdata:self.xmlDataOnAir];
        self.quizListOnAir = [quizList copy];
      } break;
        
      case NumNaoQuizModeRetroCh3: {
        NSMutableArray *quizList = [self extractQuizFromXMLdata:self.xmlDataRetroCh3];
        self.quizListRetroCh3 = [quizList copy];
      } break;
        
      case NumNaoQuizModeRetroCh5: {
        NSMutableArray *quizList = [self extractQuizFromXMLdata:self.xmlDataRetroCh5];
        self.quizListRetroCh5 = [quizList copy];
      } break;
        
      case NumNaoQuizModeRetroCh7: {
        NSMutableArray *quizList = [self extractQuizFromXMLdata:self.xmlDataRetroCh7];
        self.quizListRetroCh7 = [quizList copy];
      } break;
        
      default:
        break;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:QuizManagerDidLoadQuizSuccess object:nil userInfo:nil];
    
    [NSURLConnection
     sendAsynchronousRequest:urlRequest
     queue:queue
     completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
       if (!error) {
         switch (quizMode) {
           case NumNaoQuizModeOnAir: {
             self.xmlDataOnAir = [data copy];
           } break;
             
           case NumNaoQuizModeRetroCh3: {
             self.xmlDataRetroCh3 = [data copy];
           } break;
             
           case NumNaoQuizModeRetroCh5: {
             self.xmlDataRetroCh5 = [data copy];
           } break;
             
           case NumNaoQuizModeRetroCh7: {
             self.xmlDataRetroCh7 = [data copy];
           } break;
             
           default:
             break;
         }
       }
     }];
  } else {
    NSLog(@"Start Connecting Async");
    [NSURLConnection
     sendAsynchronousRequest:urlRequest
     queue:queue
     completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
       if (error) {
         NSLog(@"Error SendAsyncRequest %@",error.localizedDescription);
         [[NSNotificationCenter defaultCenter] postNotificationName:QuizManagerDidLoadQuizFail object:nil userInfo:nil];
       } else {
         NSLog(@"End Connecting Async");
         
         NSMutableArray *quizList = [self extractQuizFromXMLdata:data];
         
         switch (quizMode) {
           case NumNaoQuizModeOnAir: {
             self.xmlDataOnAir = [data copy];
             self.quizListOnAir = [quizList copy];
           } break;
             
           case NumNaoQuizModeRetroCh3: {
             self.xmlDataRetroCh3 = [data copy];
             self.quizListRetroCh3 = [quizList copy];
           } break;
             
           case NumNaoQuizModeRetroCh5: {
             self.xmlDataRetroCh5 = [data copy];
             self.quizListRetroCh5 = [quizList copy];
           } break;
             
           case NumNaoQuizModeRetroCh7: {
             self.xmlDataRetroCh7 = [data copy];
             self.quizListRetroCh7 = [quizList copy];
           } break;
             
           default:
             break;
         }
         
         [[NSNotificationCenter defaultCenter] postNotificationName:QuizManagerDidLoadQuizSuccess object:nil userInfo:nil];
       }
     }];
  }
}

- (NSMutableArray *)extractQuizRankFromXMLdata:(NSData *)xmlData {
  NSMutableArray *result = [[NSMutableArray alloc] init];
  NSError *error;
  
  NSString *xmlString = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
  
  TBXML *tbxml = [TBXML newTBXMLWithXMLString:xmlString error:&error];
  
  TBXMLElement *rootXMLElement = tbxml.rootXMLElement;
  
  if (!rootXMLElement) {
    return nil;
  }
  
  QuizRankObject *playerRankObject = [[QuizRankObject alloc] init];
  NSString *playerRankNoStr = [TBXML valueOfAttributeNamed:@"rank_number_of_score" forElement:rootXMLElement];
  if (playerRankNoStr) {
    NSString *scoreStr = [TBXML valueOfAttributeNamed:@"score" forElement:rootXMLElement];
    playerRankObject.rankNo = [playerRankNoStr integerValue];
    playerRankObject.score = [scoreStr integerValue];
    playerRankObject.playerName = PlaynerDummyName;
    playerRankObject.deviceOS = @"ios";
    playerRankObject.isActivePlayer = YES;
  }

  
  TBXMLElement *childXMLElement = [TBXML childElementNamed:@"rank" parentElement:rootXMLElement];
  while (childXMLElement) {
    
    QuizRankObject *quizRankObject = [[QuizRankObject alloc] init];
    
    quizRankObject.playerName = [TBXML valueOfAttributeNamed:@"player_name" forElement:childXMLElement];
    quizRankObject.deviceOS = [TBXML valueOfAttributeNamed:@"device_os" forElement:childXMLElement];
    
    NSString *scoreStr = [TBXML valueOfAttributeNamed:@"score" forElement:childXMLElement];
    NSString *quizModeStr = [TBXML valueOfAttributeNamed:@"category_id" forElement:childXMLElement];
    NSString *rankNoStr = [TBXML valueOfAttributeNamed:@"no" forElement:childXMLElement];
    quizRankObject.score = [scoreStr integerValue];
    quizRankObject.quizMode = [quizModeStr integerValue];
    quizRankObject.rankNo = [rankNoStr integerValue];
    quizRankObject.isActivePlayer = NO;
    
    if (playerRankNoStr) {
      playerRankObject.quizMode = [quizModeStr integerValue];
    }

    [result addObject:quizRankObject];
    childXMLElement = childXMLElement->nextSibling;
  }
  
  if (playerRankNoStr) {
    [result addObject:playerRankObject];
  }

  
  return result;

}

- (NSMutableArray *)extractQuizResultFromXMLdata:(NSData *)xmlData {
  NSMutableArray *result = [[NSMutableArray alloc] init];
  NSError *error;
  
  NSString *xmlString = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
  
  TBXML *tbxml = [TBXML newTBXMLWithXMLString:xmlString error:&error];
  
  TBXMLElement *rootXMLElement = tbxml.rootXMLElement;
  
  if (!rootXMLElement) {
    return nil;
  }
  
  TBXMLElement *childXMLElement = [TBXML childElementNamed:@"result_text" parentElement:rootXMLElement];
  while (childXMLElement) {
    
    QuizResultObject *quizResultObject = [[QuizResultObject alloc] init];
    
    quizResultObject.resultText = [TBXML valueOfAttributeNamed:@"result_text_text" forElement:childXMLElement];
    
    NSString *scoreFromStr = [TBXML valueOfAttributeNamed:@"from_score" forElement:childXMLElement];
    NSString *scoreToStr = [TBXML valueOfAttributeNamed:@"to_score" forElement:childXMLElement];
    quizResultObject.scoreFrom = [scoreFromStr integerValue];
    quizResultObject.scoreTo = [scoreToStr integerValue];
    
    [result addObject:quizResultObject];
    childXMLElement = childXMLElement->nextSibling;
  }
  
  return result;
}

- (NSMutableArray *)extractQuizFromXMLdata:(NSData *)xmlData {
  NSMutableArray *result = [[NSMutableArray alloc] init];
  NSError *error;
  
  NSString *xmlString = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
  
  TBXML *tbxml = [TBXML newTBXMLWithXMLString:xmlString error:&error];
  
  TBXMLElement *rootXMLElement = tbxml.rootXMLElement;
  
  if (!rootXMLElement) {
    return nil;
  }
  
  TBXMLElement *childXMLElement = [TBXML childElementNamed:@"quiz" parentElement:rootXMLElement];
  while (childXMLElement) {
    
    QuizObject *quizObject = [[QuizObject alloc] init];
    
    quizObject.quizText = [TBXML valueOfAttributeNamed:@"quiz_text" forElement:childXMLElement];
    
    NSString *quizLevelStr = [TBXML valueOfAttributeNamed:@"quiz_level" forElement:childXMLElement];
    quizObject.quizLevel = [quizLevelStr integerValue];
    
    TBXMLElement *choicesListElement = [TBXML childElementNamed:@"choices" parentElement:childXMLElement];
    
    TBXMLElement *choiceElement = [TBXML childElementNamed:@"choice" parentElement:choicesListElement];
    
    while (choiceElement) {
      
      TBXMLAttribute *attribute = choiceElement->firstAttribute;
      NSString *choiceNo;
      NSString *choiceText;
      BOOL isCorrectChoice = NO;
      while (attribute) {
        NSString *attName = [TBXML attributeName:attribute];
        NSString *attValue = [TBXML attributeValue:attribute];
        
        if ([attName isEqualToString:@"choice_no"]) {
          choiceNo = attValue;
        } else if ([attName isEqualToString:@"choice_text"]) {
          choiceText = attValue;
        } else if ([attName isEqualToString:@"correct"]) {
          isCorrectChoice = [attValue isEqualToString:@"1"] ? YES : NO;
        }
        
        attribute = attribute->next;
      }
      
      if ([choiceNo isEqualToString:@"1"]) {
        quizObject.ansChoice1 = choiceText;
        if (isCorrectChoice) {
          quizObject.answerIndex = 1;
        }
      } else if ([choiceNo isEqualToString:@"2"]) {
        quizObject.ansChoice2 = choiceText;
        if (isCorrectChoice) {
          quizObject.answerIndex = 2;
        }
      } else if ([choiceNo isEqualToString:@"3"]) {
        quizObject.ansChoice3 = choiceText;
        if (isCorrectChoice) {
          quizObject.answerIndex = 3;
        }
      } else if ([choiceNo isEqualToString:@"4"]) {
        quizObject.ansChoice4 = choiceText;
        if (isCorrectChoice) {
          quizObject.answerIndex = 4;
        }
      }
      
      choiceElement = choiceElement->nextSibling;
    }
    
    [result addObject:quizObject];
    childXMLElement = childXMLElement->nextSibling;
  }
  
  return result;
}

- (void)extractQuizVersionFromXMLdata:(NSData *)xmlData {

  NSError *error;
  NSString *xmlString = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];

  TBXML *tbxml = [TBXML newTBXMLWithXMLString:xmlString error:&error];
  TBXMLElement *rootXMLElement = tbxml.rootXMLElement;

  self.serverVersionOnAir = QuizDefaultVersion;
  self.serverVersionRetroCh3 = QuizDefaultVersion;
  self.serverVersionRetroCh5 = QuizDefaultVersion;
  self.serverVersionRetroCh7 = QuizDefaultVersion;
  
  if (rootXMLElement) {
    TBXMLElement *childXMLElement = [TBXML childElementNamed:@"version" parentElement:rootXMLElement];
    while (childXMLElement) {
      NSString *quizGroupId = [TBXML valueOfAttributeNamed:@"quiz_group_id" forElement:childXMLElement];
      NSString *quizVersion = [TBXML valueOfAttributeNamed:@"no" forElement:childXMLElement];
      if ([quizGroupId isEqualToString:@"1"]) {
        self.serverVersionOnAir = quizVersion;
      } else if ([quizGroupId isEqualToString:@"2"]) {
        self.serverVersionRetroCh3 = quizVersion;
      } else if ([quizGroupId isEqualToString:@"3"]) {
        self.serverVersionRetroCh5 = quizVersion;
      } else if ([quizGroupId isEqualToString:@"4"]) {
        self.serverVersionRetroCh7 = quizVersion;
      }
      childXMLElement = childXMLElement->nextSibling;
    }
  }
}

- (NSString *)urlStringFromQuizMode:(NSInteger)quizMode {
  NSString *urlString = nil;
  
  switch (quizMode) {
    case NumNaoQuizModeOnAir: {
      urlString = @"http://quiz.thechappters.com/webservice.php?app_id=1&method=getQuiz&category_id=1";
    } break;
      
    case NumNaoQuizModeRetroCh3: {
      urlString = @"http://quiz.thechappters.com/webservice.php?app_id=1&method=getQuiz&category_id=2";
    } break;
      
    case NumNaoQuizModeRetroCh5: {
      urlString = @"http://quiz.thechappters.com/webservice.php?app_id=1&method=getQuiz&category_id=3";
    } break;
      
    case NumNaoQuizModeRetroCh7: {
      urlString = @"http://quiz.thechappters.com/webservice.php?app_id=1&method=getQuiz&category_id=4";
    } break;
      
    default: {
      NSLog(@"Unknown quizMode");
      return nil;
    } break;
  }
  
  return urlString;
}

- (NSString *)urlStringQuizRankFromQuizMode:(NSInteger)quizMode quizScore:(NSInteger) quizScore{
  NSString *urlString = nil;
  BOOL quizScoreAvailable = quizScore >= 0;
  
  switch (quizMode) {
    case NumNaoQuizModeOnAir: {
      if (quizScoreAvailable) {
        urlString = [NSString stringWithFormat:@"http://quiz.thechappters.com/webservice.php?app_id=1&method=getRank&category_id=1&score=%d", quizScore];
      } else {
        urlString = [NSString stringWithFormat:@"http://quiz.thechappters.com/webservice.php?app_id=1&method=getRank&category_id=1"];
      }
    } break;
      
    case NumNaoQuizModeRetroCh3: {
      if (quizScoreAvailable) {
        urlString = [NSString stringWithFormat:@"http://quiz.thechappters.com/webservice.php?app_id=1&method=getRank&category_id=2&score=%d", quizScore];
      } else {
        urlString = [NSString stringWithFormat:@"http://quiz.thechappters.com/webservice.php?app_id=1&method=getRank&category_id=2"];
      }
    } break;
      
    case NumNaoQuizModeRetroCh5: {
      if (quizScoreAvailable) {
        urlString = [NSString stringWithFormat:@"http://quiz.thechappters.com/webservice.php?app_id=1&method=getRank&category_id=3&score=%d", quizScore];
      } else {
        urlString = [NSString stringWithFormat:@"http://quiz.thechappters.com/webservice.php?app_id=1&method=getRank&category_id=3"];
      }
    } break;
      
    case NumNaoQuizModeRetroCh7: {
      if (quizScoreAvailable) {
        urlString = [NSString stringWithFormat:@"http://quiz.thechappters.com/webservice.php?app_id=1&method=getRank&category_id=4&score=%d", quizScore];
      } else {
        urlString = [NSString stringWithFormat:@"http://quiz.thechappters.com/webservice.php?app_id=1&method=getRank&category_id=4"];
      }
    } break;
      
    default: {
      NSLog(@"Unknown quizRank");
      return nil;
    } break;
  }
  
  return urlString;
}

- (NSArray *)mockQuizList {
  NSMutableArray *result = [[NSMutableArray alloc] init];
  
  for (int i = 0; i < 30; i++) {
    NSString *quizText = [NSString stringWithFormat:@"Level 1 Question %d", (i+1)];
    QuizObject *obj = [[QuizObject alloc] initWithQuizText:quizText
                                                ansChoice1:@"choice1"
                                                ansChoice2:@"choice2"
                                                ansChoice3:@"choice3"
                                                ansChoice4:@"choice4"
                                               answerIndex:1
                                                 quizLevel:1];
    [result addObject:obj];
  }
  
  for (int i = 30; i < 60; i++) {
    NSString *quizText = [NSString stringWithFormat:@"Level 2 Question %d", (i+1)];
    QuizObject *obj = [[QuizObject alloc] initWithQuizText:quizText
                                                ansChoice1:@"choice1"
                                                ansChoice2:@"choice2"
                                                ansChoice3:@"choice3"
                                                ansChoice4:@"choice4"
                                               answerIndex:1
                                                 quizLevel:2];
    [result addObject:obj];
  }
  
  for (int i = 60; i < 100; i++) {
    NSString *quizText = [NSString stringWithFormat:@"Level 3 Question %d", (i+1)];
    QuizObject *obj = [[QuizObject alloc] initWithQuizText:quizText
                                                ansChoice1:@"choice1"
                                                ansChoice2:@"choice2"
                                                ansChoice3:@"choice3"
                                                ansChoice4:@"choice4"
                                               answerIndex:1
                                                 quizLevel:3];
    [result addObject:obj];
  }
  
  return result;
}

- (void)sendQuizResultLogToServerWithQuizMode:(NSInteger)quizMode
                                    quizScore:(NSInteger)quizScore {
  NSString *UUID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
  NSString *urlString = [NSString stringWithFormat:@"http://quiz.thechappters.com/webservice.php?app_id=1&method=insertLog&device_id=%@&player_name=no_name&category_id=%d&score=%d&device_os=ios", UUID, (quizMode + 1),quizScore];
  NSURL *url = [NSURL URLWithString:urlString];
  NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
  NSOperationQueue *queue = [[NSOperationQueue alloc] init];
  
  [NSURLConnection
   sendAsynchronousRequest:urlRequest
   queue:queue
   completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
     if (error) {
       NSLog(@"SendResultLogToServer error %@",error.localizedDescription);
     } else {
       NSLog(@"SendResultLogToServer success");
     }
   }];
}

- (void)sendQuizRankToServerWithQuizMode:(NSInteger)quizMode
                                    quizScore:(NSInteger)quizScore
                              playerName:(NSString *)playerName {
  NSString *urlString = [NSString stringWithFormat:@"http://quiz.thechappters.com/webservice.php?app_id=1&method=insertRank&player_name=%@&category_id=%d&score=%d&device_os=ios", playerName, (quizMode + 1),quizScore];
  NSString *properUrlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
  NSURL *url = [NSURL URLWithString:properUrlString];
  NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
  NSOperationQueue *queue = [[NSOperationQueue alloc] init];
  
  [NSURLConnection
   sendAsynchronousRequest:urlRequest
   queue:queue
   completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
     if (error) {
       NSLog(@"SendQuizRankToServer error %@",error.localizedDescription);
     } else {
       NSLog(@"SendQuizRankToServer success");
     }
   }];
}

- (void)sendDeviceTokenToServerWithToken:(NSString *)deviceToken {
  if (![[NSUserDefaults standardUserDefaults] boolForKey:DeviceTokenSentKey]) {
    NSString *urlString = [NSString stringWithFormat:@"http://quiz.thechappters.com/webservice.php?app_id=1&method=insertDeviceToken&device_token=%@&device_os=ios", deviceToken];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection
     sendAsynchronousRequest:urlRequest
     queue:queue
     completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
       if (error) {
         NSLog(@"SendDeviceTokenToServer error %@",error.localizedDescription);
         [[NSUserDefaults standardUserDefaults] setBool:NO forKey:DeviceTokenSentKey];
         [[NSUserDefaults standardUserDefaults] synchronize];
       } else {
         NSLog(@"SendDeviceTokenToServer success");
         [[NSUserDefaults standardUserDefaults] setBool:YES forKey:DeviceTokenSentKey];
         [[NSUserDefaults standardUserDefaults] synchronize];
       }
     }];
  }
}

- (void)checkQuizUpdateWithServer {
  NSString *urlString = @"http://quiz.thechappters.com/webservice.php?app_id=1&method=getVersion";
  NSURL *url = [NSURL URLWithString:urlString];
  NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
  NSOperationQueue *queue = [[NSOperationQueue alloc] init];
  
  [NSURLConnection
   sendAsynchronousRequest:urlRequest
   queue:queue
   completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
     if (error) {
       NSLog(@"CheckQuizUpdateWithServer error %@",error.localizedDescription);
       
       self.serverVersionOnAir = QuizDefaultVersion;
       self.serverVersionRetroCh3 = QuizDefaultVersion;
       self.serverVersionRetroCh5 = QuizDefaultVersion;
       self.serverVersionRetroCh7 = QuizDefaultVersion;
     } else {
       [self extractQuizVersionFromXMLdata:data];
       NSLog(@"CheckQuizUpdateWithServer success");
     }
   }];
}

- (BOOL)isTheNewOnAirAvailable {
  BOOL flag = NO;
  NSString *currentVersion = [[NSUserDefaults standardUserDefaults]
                              stringForKey:VersionKeyOnAir];
  if ([self.serverVersionOnAir isEqualToString:QuizDefaultVersion]) {
    flag = NO;
  } else {
    flag = ![currentVersion isEqualToString:self.serverVersionOnAir];
  }

  self->_theNewOnAirAvailable = flag;
  return self->_theNewOnAirAvailable;
}

- (BOOL)isTheNewRetroCh3Available {
  BOOL flag = NO;
  NSString *currentVersion = [[NSUserDefaults standardUserDefaults]
                              stringForKey:VersionKeyRetroCh3];
  if ([self.serverVersionRetroCh3 isEqualToString:QuizDefaultVersion]) {
    flag = NO;
  } else {
    flag = ![currentVersion isEqualToString:self.serverVersionRetroCh3];
  }
  self->_theNewRetroCh3Available = flag;
  return self->_theNewRetroCh3Available;
}

- (BOOL)isTheNewRetroCh5Available {
  BOOL flag = NO;
  NSString *currentVersion = [[NSUserDefaults standardUserDefaults]
                              stringForKey:VersionKeyRetroCh5];
  if ([self.serverVersionRetroCh5 isEqualToString:QuizDefaultVersion]) {
    flag = NO;
  } else {
    flag = ![currentVersion isEqualToString:self.serverVersionRetroCh5];
  }
  
  self->_theNewRetroCh5Available = flag;
  return self->_theNewRetroCh5Available;
}

- (BOOL)isTheNewRetroCh7Available {
  BOOL flag = NO;
  NSString *currentVersion = [[NSUserDefaults standardUserDefaults]
                              stringForKey:VersionKeyRetroCh7];
  if ([self.serverVersionRetroCh7 isEqualToString:QuizDefaultVersion]) {
    flag = NO;
  } else {
    flag = ![currentVersion isEqualToString:self.serverVersionRetroCh7];
  }
  
  self->_theNewRetroCh7Available = flag;
  return self->_theNewRetroCh7Available;
}

- (void)updateVersionNumberForQuizMode:(NSInteger)quizMode {
  
  switch (quizMode) {
    case NumNaoQuizModeOnAir: {
      if (![self.serverVersionOnAir isEqualToString:QuizDefaultVersion]) {
        [[NSUserDefaults standardUserDefaults] setObject:self.serverVersionOnAir
                                                   forKey:VersionKeyOnAir];
        [[NSUserDefaults standardUserDefaults] synchronize];
      }
    } break;

    case NumNaoQuizModeRetroCh3: {
      if (![self.serverVersionRetroCh3 isEqualToString:QuizDefaultVersion]) {
        [[NSUserDefaults standardUserDefaults] setObject:self.serverVersionRetroCh3
                                                   forKey:VersionKeyRetroCh3];
        [[NSUserDefaults standardUserDefaults] synchronize];
      }
    } break;

    case NumNaoQuizModeRetroCh5: {
      if (![self.serverVersionRetroCh5 isEqualToString:QuizDefaultVersion]) {
        [[NSUserDefaults standardUserDefaults] setObject:self.serverVersionRetroCh5
                                                   forKey:VersionKeyRetroCh5];
        [[NSUserDefaults standardUserDefaults] synchronize];
      }
    } break;
      
    case NumNaoQuizModeRetroCh7: {
      if (![self.serverVersionRetroCh7 isEqualToString:QuizDefaultVersion]) {
        [[NSUserDefaults standardUserDefaults] setObject:self.serverVersionRetroCh7
                                                   forKey:VersionKeyRetroCh7];
        [[NSUserDefaults standardUserDefaults] synchronize];
      }
    } break;
      
    default:
      break;
  }
}

@end
