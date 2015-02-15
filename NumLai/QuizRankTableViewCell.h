//
//  QuizRankTableViewCell.h
//  NumNao
//
//  Created by PRINYA on 11/30/2557 BE.
//  Copyright (c) 2557 PRINYA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QuizRankTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *rankNoLabel;
@property (strong, nonatomic) IBOutlet UILabel *playerNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *scoreLabel;
@property (strong, nonatomic) IBOutlet UIImageView *deviceOSImageView;
@property (strong, nonatomic) IBOutlet UIImageView *medalImageView;

@end
