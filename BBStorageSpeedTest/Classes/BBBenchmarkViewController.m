//
//  Created by Bruno de Carvalho -- @biasedbit / http://biasedbit.com
//  Copyright (c) 2012 BiasedBit. All rights reserved.
//

#import "BBBenchmarkViewController.h"

#import "BBDictionaryItemRepository.h"
#import "BBCoderItemRepository.h"
#import "BBProfiler.h"



#pragma mark - Constants

NSUInteger const kBBBenchmarkViewControllerItemCount = 1000;



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

    [self testRepositoryCorrectness:dictionaryRepository];
    [self testRepositoryCorrectness:coderRepository];

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

    [self appendText:@"Testing NSDictionary & Binary Plist serialization...\n"];
    [self appendText:[self testSpeed:dictionaryRepository withDummyData:dummyData]];
    [self appendText:@"Finished testing NSDictionary & Binary Plist..."];

    sleep(1);

    [self appendText:@"Testing NSKeyedArchiver & NSCoder serialization...\n"];
    [self appendText:[self testSpeed:coderRepository withDummyData:dummyData]];
    [self appendText:@"Finished testing NSKeyedArchiver & NSCoder serialization..."];

    [self appendText:@"Done!"];
}

- (void)testRepositoryCorrectness:(BBItemRepository*)repository
{
    [repository reset];
    NSAssert([repository itemCount] == 0, @"Zero items after reset");

    [repository reload];
    NSAssert([repository itemCount] == 0, @"Zero items after reloading empty repository");

    NSDate* date = [NSDate date];
    
    BBItem* item = [[BBItem alloc] init];
    item.identifier = @"item zero";
    item.createdAt = date;
    item.hash = @"item zero hash";
    item.data = [@"item zero data" dataUsingEncoding:NSUTF8StringEncoding];
    item.views = 1;
    item.displayInRect = CGRectMake(1, 1, 1, 1);
    item.optionalString = @"optional!";

    [repository addItem:item];
    NSAssert([repository itemCount] == 1, @"One item in repository after adding one item");

    [repository removeItem:item];
    NSAssert([repository itemCount] == 0, @"Zero items after removing item");

    [repository addItem:item];
    NSAssert([repository itemCount] == 1, @"One item in repository after adding one item");

    [repository removeItemWithIdentifier:item.identifier];
    NSAssert([repository itemCount] == 0, @"Zero items after removing item by identifier");

    [repository addItem:item];
    NSAssert([repository itemCount] == 1, @"One item in repository after adding one item");

    BBItem* retrievedItem = [repository itemWithIdentifier:@"item zero"];
    NSAssert(retrievedItem != nil, @"Non-nil item when retrieving by key");
    NSAssert(retrievedItem == item, @"Same item when retrieving by key");

    NSAssert([repository flush], @"Flush repository to disk");

    [repository reload];
    NSAssert([repository itemCount] == 1, @"One item after reloading repository from disk");

    retrievedItem = [repository itemWithIdentifier:@"item zero"];
    NSAssert(retrievedItem != nil, @"Non-nil item when retrieving by key");
    NSAssert(retrievedItem != item, @"Not the same item after reloading from disk");

    NSAssert([retrievedItem.identifier isEqualToString:@"item zero"], @"Correct deserialization of 'identifier' field");
    NSAssert([retrievedItem.createdAt isEqualToDate:date], @"Correct deserialization of 'date' field");
    NSAssert([retrievedItem.hash isEqualToString:@"item zero hash"], @"Correct deserialization of 'hash' field");
    NSData* retrievedData = retrievedItem.data;
    NSString* stringFromRetrievedData = [[NSString alloc] initWithData:retrievedData encoding:NSUTF8StringEncoding];
    NSAssert([stringFromRetrievedData isEqualToString:@"item zero data"], @"Correct deserialization of 'data' field");
    NSAssert(retrievedItem.views == 1, @"Correct deserialization of 'views' field");
    NSAssert(CGRectEqualToRect(retrievedItem.displayInRect, item.displayInRect),
             @"Correct deserialization of 'displayInRect' field");

    [repository reset];
    NSAssert([repository itemCount] == 0, @"Zero items after final reset");

    BBLogInfo(@"Repository of class %@ passed correctness tests.", NSStringFromClass([repository class]));
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
