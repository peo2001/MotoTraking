//
//  mtxLoginViewController.m
//  MotoTracking
//
//  Created by Eugenio Pompei on 22/04/13.
//  Copyright (c) 2013 xTreme Software. All rights reserved.
//

#import "mtxLoginViewController.h"

@interface mtxLoginViewController ()

@end

@implementation mtxLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _txtCodiceAttivazione.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    _txtCodiceAttivazione.delegate = self;
    _txtCodiceAttivazione.text = _codiceAttivazione;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    return ([textField.text length] + [string length] - range.length <=6);

}


@end
