//
//  SAPostTextView.m
//  Awful 2
//
//  Created by Nolan Waite on 2013-08-30.
//

#import "SAPostTextView.h"
#import "SAImageAttachment.h"

@interface SAPostLayoutManager : NSLayoutManager

@end

@interface SAPostTextView () <NSLayoutManagerDelegate>

@property (strong, nonatomic) NSMutableArray *imageViews;
@property (strong, nonatomic) NSMutableArray *imageAttachments;
@property (strong, nonatomic) NSMutableArray *imageCharacterRanges;

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
    layoutManager.delegate = self;
    [layoutManager addTextContainer:textContainer];
    NSTextStorage *textStorage = [NSTextStorage new];
    [textStorage addLayoutManager:layoutManager];
    
    self = [super initWithFrame:frame textContainer:textContainer];
    if (self) {
        _textStorage = textStorage;
        _imageViews = [NSMutableArray new];
        _imageAttachments = [NSMutableArray new];
        _imageCharacterRanges = [NSMutableArray new];
        self.editable = NO;
        self.scrollEnabled = NO;
        self.textContainerInset = UIEdgeInsetsZero;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame textContainer:(NSTextContainer *)textContainer
{
    return [self initWithFrame:frame];
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    [super setAttributedText:attributedText];
    
    // For whatever reason, Xcode 5 DP6 with iOS 7 beta 5 complains about "creating selector for nonexistent method".
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wselector"
    [self.imageViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    #pragma clang diagnostic pop
    
    [self.imageViews removeAllObjects];
    [self.imageAttachments removeAllObjects];
    [self.imageCharacterRanges removeAllObjects];
    self.textContainer.exclusionPaths = nil;
    [attributedText enumerateAttribute:SAImageAttachmentAttributeName
                               inRange:NSMakeRange(0, attributedText.length)
                               options:0
                            usingBlock:^(SAImageAttachment *attachment, NSRange range, BOOL *stop)
    {
        if (attachment) {
            UIImageView *imageView = [UIImageView new];
            [self.imageViews addObject:imageView];
            [self.imageAttachments addObject:attachment];
            [self.imageCharacterRanges addObject:[NSValue valueWithRange:range]];
        }
    }];
}

- (NSArray *)missingImageAttachmentURLs
{
    NSMutableArray *URLs = [NSMutableArray new];
    for (NSUInteger i = 0; i < self.imageViews.count; i++) {
        UIImageView *imageView = self.imageViews[i];
        if (!imageView.image) {
            SAImageAttachment *attachment = self.imageAttachments[i];
            [URLs addObject:attachment.URL];
        }
    }
    return URLs;
}

- (void)setImage:(UIImage *)image forImageAttachmentWithURL:(NSURL *)attachmentURL
{
    for (NSUInteger i = 0; i < self.imageAttachments.count; i++) {
        SAImageAttachment *attachment = self.imageAttachments[i];
        if (![attachment.URL isEqual:attachmentURL]) {
            continue;
        }
        attachment.image = image;
        NSRange characterRange = [self.imageCharacterRanges[i] rangeValue];
        [self.textStorage edited:NSTextStorageEditedCharacters range:characterRange changeInLength:0];
        NSRange glyphRange = [self.layoutManager glyphRangeForCharacterRange:characterRange
                                                        actualCharacterRange:nil];
        [self.layoutManager glyphRangeForTextContainer:self.textContainer];
        UIImageView *imageView = self.imageViews[i];
        imageView.image = image;
        CGRect frame = [self.layoutManager boundingRectForGlyphRange:glyphRange
                                                     inTextContainer:self.textContainer];
        imageView.frame = CGRectOffset(frame, self.textContainerInset.left, self.textContainerInset.top);
        [self addSubview:imageView];
    }
}

#pragma mark NSLayoutManagerDelegate

- (NSControlCharacterAction)layoutManager:(NSLayoutManager *)layoutManager
                          shouldUseAction:(NSControlCharacterAction)action
               forControlCharacterAtIndex:(NSUInteger)charIndex
{
    SAImageAttachment *attachment = [layoutManager.textStorage attribute:SAImageAttachmentAttributeName
                                                                 atIndex:charIndex
                                                          effectiveRange:nil];
    if (attachment.image) {
        return NSControlCharacterWhitespaceAction;
    } else {
        return action;
    }
}

- (CGRect)layoutManager:(NSLayoutManager *)layoutManager
boundingBoxForControlGlyphAtIndex:(NSUInteger)glyphIndex
       forTextContainer:(NSTextContainer *)textContainer
   proposedLineFragment:(CGRect)proposedRect
          glyphPosition:(CGPoint)glyphPosition
         characterIndex:(NSUInteger)charIndex
{
    SAImageAttachment *attachment = [layoutManager.textStorage attribute:SAImageAttachmentAttributeName
                                                                 atIndex:charIndex
                                                          effectiveRange:nil];
    CGSize imageSize = attachment.image.size;
    CGSize attachmentSize = imageSize;
    CGFloat maxWidth = textContainer.size.width - textContainer.lineFragmentPadding * 2;
    if (attachmentSize.width > maxWidth) {
        attachmentSize.height = floorf(imageSize.height * maxWidth / imageSize.width);
        attachmentSize.width = maxWidth;
    }
    return (CGRect){ .size = attachmentSize };
}

- (CGFloat)layoutManager:(NSLayoutManager *)layoutManager
lineSpacingAfterGlyphAtIndex:(NSUInteger)glyphIndex
withProposedLineFragmentRect:(CGRect)rect
{
    NSUInteger charIndex = [layoutManager characterIndexForGlyphAtIndex:glyphIndex];
    SAImageAttachment *attachment = [layoutManager.textStorage attribute:SAImageAttachmentAttributeName
                                                                 atIndex:charIndex
                                                          effectiveRange:nil];
    if (attachment.image) {
        CGSize imageSize = attachment.image.size;
        CGSize attachmentSize = imageSize;
        CGFloat maxWidth = CGRectGetWidth(rect);
        if (attachmentSize.width > maxWidth) {
            attachmentSize.height = floorf(imageSize.height * maxWidth / imageSize.width);
            attachmentSize.width = maxWidth;
        }
        if (attachmentSize.height > CGRectGetHeight(rect)) {
            return attachmentSize.height - CGRectGetHeight(rect);
        }
    }
    return 0;
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
