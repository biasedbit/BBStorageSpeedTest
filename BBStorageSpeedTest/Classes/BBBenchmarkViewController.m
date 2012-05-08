//
//  Created by Bruno de Carvalho -- @biasedbit / http://biasedbit.com
//  Copyright (c) 2012 BiasedBit. All rights reserved.
//

#import "BBBenchmarkViewController.h"

#import "BBDictionaryItemRepository.h"
#import "BBCoderItemRepository.h"
#import "BBProfiler.h"



#pragma mark - Constants

NSUInteger const kBBBenchmarkViewControllerItemCount = 10000;



#pragma mark -

@interface BBBenchmarkViewController ()

@end



#pragma mark -

@implementation BBBenchmarkViewController
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
    BBItemRepository* dictionaryRepository = [BBDictionaryItemRepository sharedRepository];
    BBItemRepository* coderRepository = [BBCoderItemRepository sharedRepository];

    NSMutableArray* dummyData = [NSMutableArray arrayWithCapacity:kBBBenchmarkViewControllerItemCount];
    for (NSUInteger i = 0; i < kBBBenchmarkViewControllerItemCount; i++) {
        BBItem* dummyItem = [[BBItem alloc] init];
        dummyItem.identifier = [NSString stringWithFormat:@"item %u", i];
        dummyItem.createdAt = [NSDate date];
        dummyItem.hash = @"someHash120djas!hf0410AjsifhsFjsd";
        dummyItem.data = [@"some dummy data" dataUsingEncoding:NSUTF8StringEncoding];
        dummyItem.views = i;
        dummyItem.displayInRect = CGRectMake(i, i, i, i);
        if (i % 2 == 0) {
            dummyItem.optionalString = @"optional string!";
        }

        [dummyData addObject:dummyItem];
    }

    [self appendText:@"Testing property list of NSDictionary serialization...\n"];
    [self appendText:[self testSpeed:dictionaryRepository withDummyData:dummyData]];
    [self appendText:@"Finished testing coredata cache..."];

    sleep(1);

    [self appendText:@"Testing NSKeyedArchiver & NSCoder serialization...\n"];
    [self appendText:[self testSpeed:coderRepository withDummyData:dummyData]];
    [self appendText:@"Finished testing filesystem cache..."];

    [self appendText:@"Done!"];
}

- (NSString*)testSpeed:(BBItemRepository*)repository withDummyData:(NSArray*)items
{
    // Make sure we have no content
    [repository reset];

    for (BBItem* item in items) {
        [repository addItem:item];
    }

    // Time executions of flush (write to disk) and reload (read from disk)
    uint64_t flushNanoseconds = [BBProfiler profileBlock:^() {
        NSAssert([repository flush], @"Flush repository contents");
    }];

    uint64_t reloadNanoseconds = [BBProfiler profileBlock:^() {
        [repository reload];
    }];

    // Clean it up again
    [repository reset];

    return [NSString stringWithFormat:
            @"Execution times:\n"
            "Flush:\t\t%@\n"
            "Reload:\t\t%@\n"
            "Item count:\t%u\n",
            [self humanReadableTime:flushNanoseconds],
            [self humanReadableTime:reloadNanoseconds],
            [items count]];
}

@end
