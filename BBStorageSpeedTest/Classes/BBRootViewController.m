//
//  Created by Bruno de Carvalho -- @biasedbit / http://biasedbit.com
//  Copyright (c) 2012 BiasedBit. All rights reserved.
//

#import "BBRootViewController.h"



#pragma mark -

@interface BBRootViewController ()

@end



#pragma mark -

@implementation BBRootViewController
{
    UITextView* _textView;
}


#pragma mark UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.title = @"Storage speed";

    _textView = [[UITextView alloc] initWithFrame:self.view.bounds];
    _textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _textView.font = [UIFont systemFontOfSize:15];
    _textView.editable = NO;
    _textView.alwaysBounceVertical = YES;

    [self.view addSubview:_textView];
}

- (void)viewDidAppear:(BOOL)animated
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^() {
        [self runTests];
    });
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark Private helpers

- (void)appendText:(NSString*)text
{
    dispatch_async(dispatch_get_main_queue(), ^() {
        _textView.text = [NSString stringWithFormat:@"%@%@\n", _textView.text, text];

        NSRange lastChar = NSMakeRange([_textView.text length] - 1, 1);
        [_textView scrollRangeToVisible:lastChar];
    });

    BBLogInfo(@"%@", text);
}

- (NSString*)humanReadableTime:(uint64_t)nanoseconds
{
    if (nanoseconds < 10000) {
        return [NSString stringWithFormat:@"%lluns", nanoseconds];
    } else {
        return [NSString stringWithFormat:@"%.2fms", (nanoseconds / 1000000.0)];
    }
}

- (void)runTests
{
    [self appendText:@"This is a text"];
    [self appendText:@"This is some more text"];
}

@end
