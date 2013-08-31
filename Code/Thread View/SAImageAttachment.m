//
//  SAImageAttachment.m
//  Awful 2
//
//  Created by Nolan Waite on 2013-08-31.
//

#import "SAImageAttachment.h"

@implementation SAImageAttachment

- (id)initWithURL:(NSURL *)URL
{
    self = [super init];
    if (self) {
        _URL = URL;
    }
    return self;
}

@end
