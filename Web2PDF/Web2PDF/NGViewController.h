//
//  NGViewController.h
//  Web2PDF
//
//  Created by Nitin Gupta on 03/05/14.
//  Copyright (c) 2014 Nitin Gupta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NGPDFViewController.h"

@interface NGViewController : UIViewController <NGPDFDelegate> {
    NSString *_urlStr;
}

@property (nonatomic, strong) NGPDFViewController *PDFCreator;
@property (nonatomic, weak) IBOutlet UILabel *resultStatusLabel;

@end
