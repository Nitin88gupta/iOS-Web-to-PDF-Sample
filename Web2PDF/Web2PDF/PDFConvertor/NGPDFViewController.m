//
//  NGViewController.m
//  Web2PDF
//
//  Created by Nitin Gupta on 03/05/14.
//  Copyright (c) 2014 Nitin Gupta. All rights reserved.
//

#import "NGPDFViewController.h"

@interface NGPDFViewController ()

@property (nonatomic, strong) NSURL *URL;
@property (nonatomic, strong) NSString *HTML;
@property (nonatomic, strong) NSString *PDFpath;
@property (nonatomic, strong) NSData *PDFdata;
@property (nonatomic, assign) CGSize pageSize;
@property (nonatomic, assign) UIEdgeInsets pageMargins;

@end

@interface UIPrintPageRenderer (PDF)

- (NSData*) printToPDF;

@end

@implementation NGPDFViewController

@synthesize URL=_URL,webview = _webview,delegate=_delegate,PDFpath=_PDFpath,pageSize=_pageSize,pageMargins=_pageMargins;

// Create PDF by passing in the URL to a webpage
+ (id)createPDFWithURL:(NSURL*)URL pathForPDF:(NSString*)PDFpath delegate:(id <NGPDFDelegate>)delegate pageSize:(CGSize)pageSize margins:(UIEdgeInsets)pageMargins
{
    NGPDFViewController *creator = [[NGPDFViewController alloc] initWithURL:URL delegate:delegate pathForPDF:PDFpath pageSize:pageSize margins:pageMargins];
    
    return creator;
}

// Create PDF by passing in the HTML as a String
+ (id)createPDFWithHTML:(NSString*)HTML pathForPDF:(NSString*)PDFpath delegate:(id <NGPDFDelegate>)delegate
               pageSize:(CGSize)pageSize margins:(UIEdgeInsets)pageMargins
{
    NGPDFViewController *creator = [[NGPDFViewController alloc] initWithHTML:HTML baseURL:nil delegate:delegate pathForPDF:PDFpath pageSize:pageSize margins:pageMargins];
    
    return creator;
}

// Create PDF by passing in the HTML as a String, with a base URL
+ (id)createPDFWithHTML:(NSString*)HTML baseURL:(NSURL*)baseURL pathForPDF:(NSString*)PDFpath delegate:(id <NGPDFDelegate>)delegate
               pageSize:(CGSize)pageSize margins:(UIEdgeInsets)pageMargins
{
    NGPDFViewController *creator = [[NGPDFViewController alloc] initWithHTML:HTML baseURL:baseURL delegate:delegate pathForPDF:PDFpath pageSize:pageSize margins:pageMargins];
    
    return creator;
}
+ (id)createPDFWithURL:(NSURL*)URL pathForPDF:(NSString*)PDFpath pageSize:(CGSize)pageSize margins:(UIEdgeInsets)pageMargins successBlock:(NGPDFCompletionBlock)successBlock errorBlock:(NGPDFCompletionBlock)errorBlock
{
    NGPDFViewController *creator = [[NGPDFViewController alloc] initWithURL:URL delegate:nil pathForPDF:PDFpath pageSize:pageSize margins:pageMargins];
    creator.successBlock = successBlock;
    creator.errorBlock = errorBlock;
    
    return creator;
}

+ (id)createPDFWithHTML:(NSString*)HTML pathForPDF:(NSString*)PDFpath pageSize:(CGSize)pageSize margins:(UIEdgeInsets)pageMargins successBlock:(NGPDFCompletionBlock)successBlock errorBlock:(NGPDFCompletionBlock)errorBlock
{
    NGPDFViewController *creator = [[NGPDFViewController alloc] initWithHTML:HTML baseURL:nil delegate:nil pathForPDF:PDFpath pageSize:pageSize margins:pageMargins];
    creator.successBlock = successBlock;
    creator.errorBlock = errorBlock;
    
    return creator;
}

+ (id)createPDFWithHTML:(NSString*)HTML baseURL:(NSURL*)baseURL pathForPDF:(NSString*)PDFpath pageSize:(CGSize)pageSize margins:(UIEdgeInsets)pageMargins successBlock:(NGPDFCompletionBlock)successBlock errorBlock:(NGPDFCompletionBlock)errorBlock
{
    NGPDFViewController *creator = [[NGPDFViewController alloc] initWithHTML:HTML baseURL:baseURL delegate:nil pathForPDF:PDFpath pageSize:pageSize margins:pageMargins];
    creator.successBlock = successBlock;
    creator.errorBlock = errorBlock;
    
    return creator;
}

- (id)init
{
    if (self = [super init])
    {
        self.PDFdata = nil;
    }
    return self;
}

- (id)initWithURL:(NSURL*)URL delegate:(id <NGPDFDelegate>)delegate pathForPDF:(NSString*)PDFpath pageSize:(CGSize)pageSize margins:(UIEdgeInsets)pageMargins
{
    if (self = [super init])
    {
        self.URL = URL;
        self.delegate = delegate;
        self.PDFpath = PDFpath;
        
        self.pageMargins = pageMargins;
        self.pageSize = pageSize;
        
        [self forceLoadView];
    }
    return self;
}

- (id)initWithHTML:(NSString*)HTML baseURL:(NSURL*)baseURL delegate:(id <NGPDFDelegate>)delegate
        pathForPDF:(NSString*)PDFpath pageSize:(CGSize)pageSize margins:(UIEdgeInsets)pageMargins
{
    if (self = [super init])
    {
        self.HTML = HTML;
        self.URL = baseURL;
        self.delegate = delegate;
        self.PDFpath = PDFpath;
        
        self.pageMargins = pageMargins;
        self.pageSize = pageSize;
        
        [self forceLoadView];
    }
    return self;
}

- (void)forceLoadView
{
    [[UIApplication sharedApplication].delegate.window addSubview:self.view];
    
    self.view.frame = CGRectMake(0, 0, 1, 1);
    self.view.alpha = 0.0;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _webview = [[UIWebView alloc] initWithFrame:self.view.frame];
    _webview.delegate = self;
    
    [self.view addSubview:_webview];

    if (self.HTML == nil) {
        [_webview loadRequest:[NSURLRequest requestWithURL:self.URL]];
    }else{
        [_webview loadHTMLString:self.HTML baseURL:self.URL];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (webView.isLoading) return;
    
    UIPrintPageRenderer *render = [[UIPrintPageRenderer alloc] init];
    
    [render addPrintFormatter:webView.viewPrintFormatter startingAtPageAtIndex:0];
    
    CGRect printableRect = CGRectMake(self.pageMargins.left,
                                      self.pageMargins.top,
                                      self.pageSize.width - self.pageMargins.left - self.pageMargins.right,
                                      self.pageSize.height - self.pageMargins.top - self.pageMargins.bottom);
    
    CGRect paperRect = CGRectMake(0, 0, self.pageSize.width, self.pageSize.height);
    
    [render setValue:[NSValue valueWithCGRect:paperRect] forKey:@"paperRect"];
    [render setValue:[NSValue valueWithCGRect:printableRect] forKey:@"printableRect"];
    
    self.PDFdata = [render printToPDF];
    
    if (self.PDFpath) {
        [self.PDFdata writeToFile: self.PDFpath  atomically: YES];
    }
    
    [self terminateWebTask];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(webHTMLtoPDFDidSucceed:)])
        [self.delegate webHTMLtoPDFDidSucceed:self];
    
    if(self.successBlock) {
        self.successBlock(self);
    }
    
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if (webView.isLoading) return;
    
    [self terminateWebTask];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(webHTMLtoPDFDidFail:)])
        [self.delegate webHTMLtoPDFDidFail:self];
    
    if(self.errorBlock) {
        self.errorBlock(self);
    }
    
}

- (void)terminateWebTask
{
    [self.webview stopLoading];
    self.webview.delegate = nil;
    [self.view removeFromSuperview];
}

@end

@implementation UIPrintPageRenderer (PDF)

- (NSData*) printToPDF
{
    NSMutableData *pdfData = [NSMutableData data];
    
    UIGraphicsBeginPDFContextToData( pdfData, self.paperRect, nil );
    
    [self prepareForDrawingPages: NSMakeRange(0, self.numberOfPages)];
    
    CGRect bounds = UIGraphicsGetPDFContextBounds();
    
    for ( int i = 0 ; i < self.numberOfPages ; i++ )
    {
        UIGraphicsBeginPDFPage();
        
        [self drawPageAtIndex: i inRect: bounds];
    }
    
    UIGraphicsEndPDFContext();
    
    return pdfData;
}

@end
