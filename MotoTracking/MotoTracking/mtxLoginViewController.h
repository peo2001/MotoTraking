//
//  mtxLoginViewController.h
//  MotoTracking
//
//  Created by Eugenio Pompei on 22/04/13.
//  Copyright (c) 2013 xTreme Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface mtxLoginViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *txtCodiceAttivazione;
@property (weak, nonatomic) IBOutlet UIButton *btnLogin;

@property (nonatomic, assign) NSString *codiceAttivazione;

@end
