//
//  SAPostTextView.m
//  Awful 2
//
//  Created by Nolan Waite on 2013-08-30.
//

#import "SAPostTextView.h"

@interface SAPostLayoutManager : NSLayoutManager

@end


@implementation SAPostTextView
{
    // Our superclass has a readonly textStorage property, so directly use an ivar to store our own.
    NSTextStorage *_textStorage;
}

- (id)initWithFrame:(CGRect)frame
{
    // The layout manager must be added to the text storage before calling our superclass's designated initializer or we'll crash (as of iOS 7 beta 5).
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:CGSizeMake(0, CGFLOAT_MAX)];
    textContainer.widthTracksTextView = YES;
    SAPostLayoutManager *layoutManager = [SAPostLayoutManager new];
    [layoutManager addTextContainer:textContainer];
    NSTextStorage *textStorage = [NSTextStorage new];
    [textStorage addLayoutManager:layoutManager];
    
    self = [super initWithFrame:frame textContainer:textContainer];
    if (self) {
        _textStorage = textStorage;
        self.editable = NO;
        self.scrollEnabled = NO;
        self.textContainerInset = UIEdgeInsetsZero;
    }
    return self;
}

@end

@implementation SAPostLayoutManager

- (void)drawBackgroundForGlyphRange:(NSRange)glyphsToShow atPoint:(CGPoint)origin
{
    [super drawBackgroundForGlyphRange:glyphsToShow atPoint:origin];
    NSRange characterRange = [self characterRangeForGlyphRange:glyphsToShow actualGlyphRange:nil];
    [self.textStorage enumerateAttribute:SALeftBarColorAttributeName
                                 inRange:characterRange
                                 options:0
                              usingBlock:^(UIColor *color, NSRange range, BOOL *stop)
     {
         if (!color) {
             return;
         }
         NSRange glyphRange = [self glyphRangeForCharacterRange:range actualCharacterRange:nil];
         CGRect firstLineRect = [self lineFragmentUsedRectForGlyphAtIndex:glyphRange.location effectiveRange:nil];
         CGRect lastLineRect = [self lineFragmentUsedRectForGlyphAtIndex:NSMaxRange(glyphRange) - 1
                                                          effectiveRange:nil];
         CGRect leftBarRect = CGRectMake(CGRectGetMinX(firstLineRect), CGRectGetMinY(firstLineRect),
                                         1, CGRectGetMaxY(lastLineRect) - CGRectGetMinY(firstLineRect));
         const CGFloat leftBarPadding = 10;
         leftBarRect = CGRectOffset(leftBarRect, origin.x - leftBarPadding, origin.y);
         [color setFill];
         [[UIBezierPath bezierPathWithRect:leftBarRect] fill];
     }];
}

@end

NSString * const SALeftBarColorAttributeName = @"SALeftBarColor";

NSString * const SAImageAttachmentAttributeName = @"SAImageAttachment";
