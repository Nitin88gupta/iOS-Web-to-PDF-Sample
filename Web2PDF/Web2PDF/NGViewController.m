//
//  NGViewController.m
//  Web2PDF
//
//  Created by Nitin Gupta on 03/05/14.
//  Copyright (c) 2014 Nitin Gupta. All rights reserved.
//

#import "NGViewController.h"

@interface NGViewController ()

@end

@implementation NGViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.resultStatusLabel setHidden:YES];
    _urlStr = @"https://github.com/Nitin88gupta/IOS";
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    _PDFCreator = nil;
}

- (BOOL) validateURL {
    return (_urlStr && [_urlStr length]);
}

- (void) popUrlInvalidError {
    UIAlertView *_alert = [[UIAlertView alloc] initWithTitle:@"Ooops!!" message:@"URL is invalid" delegate:Nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [_alert show];
    _alert = nil;
}

#pragma mark Button Actions
- (IBAction)loadGeneratorPDFUsingDelegate:(id)sender {
    if ([self validateURL]) {
        
        self.resultStatusLabel.text = @"loading...";
        [self.resultStatusLabel setHidden:NO];
        
        self.PDFCreator = [NGPDFViewController createPDFWithURL:[NSURL URLWithString:_urlStr]
                                                     pathForPDF:[@"~/Documents/NGPDF_delegateDemo.pdf" stringByExpandingTildeInPath]
                                                       delegate:self
                                                       pageSize:kPaperSizeA4
                                                        margins:UIEdgeInsetsMake(10, 5, 10, 5)];
    } else {
        [self popUrlInvalidError];
    }
}

- (IBAction)loadGeneratorPDFUsingBlocks:(id)sender {
    if ([self validateURL]) {
        
        self.resultStatusLabel.text = @"loading...";
        [self.resultStatusLabel setHidden:NO];
        self.PDFCreator = [NGPDFViewController createPDFWithURL:[NSURL URLWithString:_urlStr] pathForPDF:[@"~/Documents/NGPDF_blocksDemo.pdf" stringByExpandingTildeInPath] pageSize:kPaperSizeA4 margins:UIEdgeInsetsMake(10, 5, 10, 5) successBlock:^(NGPDFViewController *webHTMLtoPDF) {
            NSString *result = [NSString stringWithFormat:@"webHTMLtoPDF did succeed (%@ / %@)", webHTMLtoPDF, webHTMLtoPDF.PDFpath];
            NSLog(@"%@",result);
            self.resultStatusLabel.text = result;

        } errorBlock:^(NGPDFViewController *webHTMLtoPDF) {
            NSString *result = [NSString stringWithFormat:@"webHTMLtoPDF did fail (%@)", webHTMLtoPDF];
            NSLog(@"%@",result);
            self.resultStatusLabel.text = result;

        }];
    } else {
        [self popUrlInvalidError];
    }
}

#pragma mark NDwebHTMLtoPDFDelegate

- (void)webHTMLtoPDFDidSucceed:(NGPDFViewController*)webHTMLtoPDF
{
    NSString *result = [NSString stringWithFormat:@"webHTMLtoPDF did succeed (%@ / %@)", webHTMLtoPDF, webHTMLtoPDF.PDFpath];
    NSLog(@"%@",result);
    self.resultStatusLabel.text = result;
    [self.resultStatusLabel setHidden:NO];
    if (_PDFCreator) {
        _PDFCreator = nil;
    }
}

- (void)webHTMLtoPDFDidFail:(NGPDFViewController*)webHTMLtoPDF
{
    NSString *result = [NSString stringWithFormat:@"webHTMLtoPDF did fail (%@)", webHTMLtoPDF];
    NSLog(@"%@",result);
    self.resultStatusLabel.text = result;
    [self.resultStatusLabel setHidden:NO];
    if (_PDFCreator) {
        _PDFCreator = nil;
    }
}


@end
