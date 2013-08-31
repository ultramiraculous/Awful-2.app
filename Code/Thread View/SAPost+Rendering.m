//
//  SAPost+Rendering.m
//  Awful 2
//
//  Created by Nolan Waite on 2013-08-30.
//

#import "SAPost+Rendering.h"
#import <HTMLReader/HTMLParser.h>
#import "SAForumsClient.h"
#import "SAImageAttachment.h"
#import "SAPostTextView.h"

@interface HTMLNode (SAPostRendering)

- (NSAttributedString *)sa_innerAttributedString;

@end

@implementation SAPost (Rendering)

- (NSAttributedString *)stringContents
{
    NSMutableAttributedString *stringContents = [NSMutableAttributedString new];
    NSArray *nodes = [HTMLParser parserForString:self.HTMLContents context:nil].document.childNodes;
    for (HTMLNode *node in nodes) {
        [stringContents appendAttributedString:node.sa_innerAttributedString];
    }
    
    // Approximately process whitespace according to CSS 2.1 spec.
    // http://www.w3.org/TR/CSS2/text.html#white-space-model
    // NSRegularExpressionSearch is not documented to work for any of NSMutableString's methods.
    [stringContents.mutableString replaceOccurrencesOfString:@" +"
                                                  withString:@" "
                                                     options:NSRegularExpressionSearch
                                                       range:NSMakeRange(0, stringContents.length)];
    [stringContents.mutableString replaceOccurrencesOfString:@" ?\n ?"
                                                  withString:@"\n"
                                                     options:NSRegularExpressionSearch
                                                       range:NSMakeRange(0, stringContents.length)];
    CFStringTrimWhitespace((__bridge CFMutableStringRef)stringContents.mutableString);
    
    // Set the default body font anywhere the font attribute is missing.
    [stringContents enumerateAttribute:NSFontAttributeName
                               inRange:NSMakeRange(0, stringContents.length)
                               options:0
                            usingBlock:^(id value, NSRange range, BOOL *stop)
     {
         if (!value) {
             [stringContents addAttribute:NSFontAttributeName
                                    value:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]
                                    range:range];
         }
     }];
    return stringContents;
}

@end

@implementation HTMLNode (SAPostRendering)

- (NSAttributedString *)sa_innerAttributedString
{
    return nil;
}

@end

@implementation HTMLElementNode (SAPostRendering)

- (NSAttributedString *)sa_innerAttributedString
{
    NSMutableAttributedString *string = [NSMutableAttributedString new];
    for (HTMLNode *child in self.childNodes) {
        NSAttributedString *childStringContents = child.sa_innerAttributedString;
        if (childStringContents) {
            [string appendAttributedString:childStringContents];
        }
    }
    
    if ([self.tagName isEqualToString:@"a"]) {
        NSURL *url = [NSURL URLWithString:self[@"href"] relativeToURL:[SAForumsClient client].baseURL];
        [string addAttribute:NSLinkAttributeName value:url range:NSMakeRange(0, string.length)];
    }
    else if ([self.tagName isEqualToString:@"b"]) {
        [string addAttribute:NSFontAttributeName
                       value:BodyFontWithSymbolicTraits(UIFontDescriptorTraitBold)
                       range:NSMakeRange(0, string.length)];
    }
    else if ([self.tagName isEqualToString:@"br"]) {
        [string.mutableString appendString:@"\n"];
    }
    else if ([self.tagName isEqualToString:@"div"]) {
        NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        if ([[self[@"class"] componentsSeparatedByCharactersInSet:whitespace] containsObject:@"bbc-block"]) {
            NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
            style.firstLineHeadIndent = 20;
            style.headIndent = 20;
            [string addAttributes:@{ NSParagraphStyleAttributeName: style,
                                     SALeftBarColorAttributeName: [UIColor blackColor] }
                            range:NSMakeRange(0, string.length)];
        }
    }
    else if ([self.tagName isEqualToString:@"h4"]) {
        [string addAttribute:NSFontAttributeName
                       value:BodyFontWithSymbolicTraits(UIFontDescriptorTraitBold)
                       range:NSMakeRange(0, string.length)];
        [string.mutableString appendString:@"\n"];
    }
    else if ([self.tagName isEqualToString:@"i"]) {
        [string addAttribute:NSFontAttributeName
                       value:BodyFontWithSymbolicTraits(UIFontDescriptorTraitItalic)
                       range:NSMakeRange(0, string.length)];
    }
    else if ([self.tagName isEqualToString:@"img"]) {
        NSURL *url = [NSURL URLWithString:self[@"src"] relativeToURL:[SAForumsClient client].baseURL];
        NSRange range = NSMakeRange(string.length, 1);
        [string.mutableString appendFormat:@"%C", (unichar)NSAttachmentCharacter];
        [string addAttribute:SAImageAttachmentAttributeName
                       value:[[SAImageAttachment alloc] initWithURL:url]
                       range:range];
    }
    else if ([self.tagName isEqualToString:@"li"]) {
        [string.mutableString insertString:@"•\t" atIndex:0];
        NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
        CGSize bulletSpaceSize = [@"•N" sizeWithAttributes:@{ NSFontAttributeName: BodyFontWithSymbolicTraits(0) }];
        CGFloat indent = ceilf(bulletSpaceSize.width);
        
        // No idea why this tab stop won't line up with the headIndent. For now, a trial-and-errored `- 5`.
        style.tabStops = @[ [[NSTextTab alloc] initWithTextAlignment:NSTextAlignmentNatural
                                                            location:indent - 5
                                                             options:nil] ];
        style.headIndent = indent;
        [string addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, string.length)];
    }
    
    return string;
}

static UIFont * BodyFontWithSymbolicTraits(UIFontDescriptorSymbolicTraits traits)
{
    UIFontDescriptor *body = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleBody];
    UIFontDescriptorSymbolicTraits newTraits = body.symbolicTraits | traits;
    UIFontDescriptor *bodyWithTraits = [body fontDescriptorWithSymbolicTraits:newTraits];
    return [UIFont fontWithDescriptor:bodyWithTraits size:0];
}

@end

@implementation HTMLTextNode (SAPostRendering)

- (NSAttributedString *)sa_innerAttributedString
{
    // Replace each newline or here with a space so that element nodes (like <br>) can insert newlines or tabs with impunity.
    NSString *data = [self.data stringByReplacingOccurrencesOfString:@"[\n\t]"
                                                          withString:@" "
                                                             options:NSRegularExpressionSearch
                                                               range:NSMakeRange(0, self.data.length)];
    return [[NSAttributedString alloc] initWithString:data];
}

@end
