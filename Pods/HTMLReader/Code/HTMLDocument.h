//
//  HTMLDocument.h
//  HTMLReader
//
//  Created by Nolan Waite on 2013-06-26.
//

#import <Foundation/Foundation.h>
#import "HTMLNode.h"

/**
 * HTMLDocumentQuirksMode can change parts of the parsing algorithm.
 */
typedef NS_ENUM(NSInteger, HTMLDocumentQuirksMode)
{
    /**
     * The default quirks mode.
     */
    HTMLNoQuirksMode,
    
    /**
     * A quirks mode for old versions of HTML.
     */
    HTMLQuirksMode,
    
    /**
     * A quirks mode for (XHTML 1.0 or HTML 4.01) (Frameset or Transitional).
     */
    HTMLLimitedQuirksMode,
};

/**
 * An HTMLDocument is the root of a tree of nodes representing parsed HTML.
 */
@interface HTMLDocument : HTMLNode

/**
 * Parses a string of HTML.
 *
 * @param string Some HTML.
 *
 * @return An initialized HTMLDocument.
 */
+ (instancetype)documentWithString:(NSString *)string;

/**
 * The document type node.
 */
@property (nonatomic) HTMLDocumentTypeNode *doctype;

/**
 * The document's quirks mode.
 */
@property (nonatomic) HTMLDocumentQuirksMode quirksMode;

/**
 * The root node (usually the <html> element node), ignoring the document type node and any root-level comment nodes.
 */
@property (readonly, strong, nonatomic) HTMLElementNode *rootNode;

@end
