//
//  NGViewController.h
//  Web2PDF
//
//  Created by Nitin Gupta on 03/05/14.
//  Copyright (c) 2014 Nitin Gupta. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kPaperSizeA4 CGSizeMake(595.2,841.8)
#define kPaperSizeLetter CGSizeMake(612,792)

@class NGPDFViewController;

typedef void (^NGPDFCompletionBlock)(NGPDFViewController* webHTMLtoPDF);

@protocol NGPDFDelegate <NSObject>

@optional
- (void)webHTMLtoPDFDidSucceed:(NGPDFViewController*)webHTMLtoPDF;
- (void)webHTMLtoPDFDidFail:(NGPDFViewController*)webHTMLtoPDF;
@end

@interface NGPDFViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, copy) NGPDFCompletionBlock successBlock;
@property (nonatomic, copy) NGPDFCompletionBlock errorBlock;
@property (nonatomic, strong) UIWebView *webview;

@property (nonatomic, weak) id <NGPDFDelegate> delegate;

@property (nonatomic, strong, readonly) NSString *PDFpath;
@property (nonatomic, strong, readonly) NSData *PDFdata;

+ (id)createPDFWithURL:(NSURL*)URL pathForPDF:(NSString*)PDFpath delegate:(id <NGPDFDelegate>)delegate pageSize:(CGSize)pageSize margins:(UIEdgeInsets)pageMargins;
+ (id)createPDFWithHTML:(NSString*)HTML pathForPDF:(NSString*)PDFpath delegate:(id <NGPDFDelegate>)delegate pageSize:(CGSize)pageSize margins:(UIEdgeInsets)pageMargins;
+ (id)createPDFWithHTML:(NSString*)HTML baseURL:(NSURL*)baseURL pathForPDF:(NSString*)PDFpath delegate:(id <NGPDFDelegate>)delegate pageSize:(CGSize)pageSize margins:(UIEdgeInsets)pageMargins;

+ (id)createPDFWithURL:(NSURL*)URL pathForPDF:(NSString*)PDFpath pageSize:(CGSize)pageSize margins:(UIEdgeInsets)pageMargins successBlock:(NGPDFCompletionBlock)successBlock errorBlock:(NGPDFCompletionBlock)errorBlock;
+ (id)createPDFWithHTML:(NSString*)HTML pathForPDF:(NSString*)PDFpath pageSize:(CGSize)pageSize margins:(UIEdgeInsets)pageMargins successBlock:(NGPDFCompletionBlock)successBlock errorBlock:(NGPDFCompletionBlock)errorBlock;
+ (id)createPDFWithHTML:(NSString*)HTML baseURL:(NSURL*)baseURL pathForPDF:(NSString*)PDFpath pageSize:(CGSize)pageSize margins:(UIEdgeInsets)pageMargins successBlock:(NGPDFCompletionBlock)successBlock errorBlock:(NGPDFCompletionBlock)errorBlock;

@end
