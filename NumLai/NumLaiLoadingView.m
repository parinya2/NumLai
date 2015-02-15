//
//  NumLaiLoadingView.m
//  NumNao
//
//  Created by PRINYA on 8/11/2557 BE.
//  Copyright (c) 2557 PRINYA. All rights reserved.
//

#import "NumLaiLoadingView.h"

@interface NumLaiLoadingView ()

@end

@implementation NumLaiLoadingView

- (id)init
{
  UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
  self = [self initWithFrame:window.bounds];
  return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
      self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
      
      UIActivityIndicatorView *spinnerView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
      spinnerView.frame = CGRectMake(70, 10, spinnerView.bounds.size.width, spinnerView.bounds.size.height);
      spinnerView.hidesWhenStopped = YES;
      [spinnerView startAnimating];
      
      UILabel *loadingCaption = [[UILabel alloc] initWithFrame:CGRectMake(20, 45, 130, 22)];
      loadingCaption.backgroundColor = [UIColor clearColor];
      loadingCaption.textColor = [UIColor whiteColor];
      loadingCaption.adjustsFontSizeToFitWidth = YES;
      loadingCaption.textAlignment = NSTextAlignmentCenter;
      loadingCaption.text = @"รอแป๊บนึงนะจ๊ะ...";
      
      UIView *centerSquare = [[UIView alloc] initWithFrame:CGRectMake(75, 200, 170, 90)];
      centerSquare.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
      centerSquare.layer.cornerRadius = 10.0;
      centerSquare.clipsToBounds = YES;
      
      [centerSquare addSubview:spinnerView];
      [centerSquare addSubview:loadingCaption];
      
      [self addSubview:centerSquare];
    }
    return self;
}


@end
