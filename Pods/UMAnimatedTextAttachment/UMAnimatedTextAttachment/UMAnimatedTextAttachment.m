//
//  UMAnimatedTextAttachment.m
//  AnimatedTextAttachment
//
//  Created by Chris Williams on 9/1/13.
//

#import "UMAnimatedTextAttachment.h"


//NSTextAttachmentCell, the good parts
@protocol UMTextAttachmentCell <NSObject>

- (void)drawWithFrame:(CGRect)cellFrame inView:(UIView *)controlView characterIndex:(NSUInteger)charIndex layoutManager:(NSLayoutManager *)layoutManager;

- (CGRect)cellFrameForTextContainer:(NSTextContainer *)textContainer proposedLineFragment:(CGRect)lineFrag glyphPosition:(CGPoint)position characterIndex:(NSUInteger)charIndex;
@end

@interface UMAnimatableAttachmentView : UIView  <UMTextAttachmentCell>
{
	UMDrawInRectBlock _drawBlock;
	NSUInteger _charIndex;
	__weak NSLayoutManager *_manager;
}


@property (nonatomic, weak) NSTextAttachment *attachment;

@end


@implementation UMAnimatableAttachmentView

+ (instancetype)viewForAttachment:(NSTextAttachment*)attachment{
	
	id inst = [[self alloc] init];
	
	[inst setAttachment:attachment];
	
	return inst;
}


- (CGRect)cellFrameForTextContainer:(NSTextContainer *)textContainer proposedLineFragment:(CGRect)lineFrag
					  glyphPosition:(CGPoint)position characterIndex:(NSUInteger)charIndex{
	
	//Cache the character index and manager for future invalidation
	_charIndex = charIndex;
	_manager = textContainer.layoutManager;
	
	return [self.attachment attachmentBoundsForTextContainer:textContainer
										proposedLineFragment:lineFrag glyphPosition:position characterIndex:charIndex];
}

- (void)setDrawingBlock:(UMDrawInRectBlock)drawingBlock {
	
	_drawBlock = drawingBlock;
	
	[_manager invalidateDisplayForCharacterRange:NSMakeRange(_charIndex, 1)];
}

- (void)drawWithFrame:(CGRect)cellFrame inView:(UIView *)controlView
	   characterIndex:(NSUInteger)charIndex layoutManager:(NSLayoutManager *)layoutManager {
	
	if (_drawBlock) {
		_drawBlock(cellFrame);
	}
}

@end

@interface UMAnimatedTextAttachment ()
{
	UMAnimatableAttachmentView *_cell;
	
	NSTimer *_gifTimer;
	int _gifFrame;
}

@end

@implementation UMAnimatedTextAttachment

- (instancetype)initWithImage:(UIImage*)image{
	
	if (!(self = [super init])) return nil;
	
	self.image = image;
	
	return self;
}

- (instancetype)initWithBounds:(CGRect)bounds{
	
	if (!(self = [super init])) return nil;
	
	self.bounds = bounds;
	
	return self;
}

- (UMAnimatableAttachmentView*)attachmentCell{
	
	_cell = _cell ?: [UMAnimatableAttachmentView viewForAttachment:self];
	return _cell;
	
}


- (void)setImage:(UIImage *)image{
	
	[_gifTimer invalidate];
	
	[super setImage:image];
	
	if ([image.images count] == 0){
		[self drawImage:image];
	}
	else{
		_gifFrame = 0;
		NSTimeInterval interval = image.duration/image.images.count;
		_gifTimer = [NSTimer timerWithTimeInterval:interval target:self selector:@selector(nextFrame) userInfo:nil repeats:YES];
		[[NSRunLoop mainRunLoop] addTimer:_gifTimer forMode:NSRunLoopCommonModes]; //Common modes allows for animation to occur while scrolling
		[self drawImage:image.images.firstObject];
	}
}

- (void)drawBlock:(UMDrawInRectBlock)drawblock{
	
	[[self attachmentCell] setDrawingBlock:drawblock];
	
}

- (void)drawImage:(UIImage*)toDraw{
	
	[[self attachmentCell] setDrawingBlock:^(CGRect rect) {

		[toDraw drawInRect:rect];
		
	}];
}

- (void)nextFrame{
	
	UIImage *lastFrame = self.image.images[_gifFrame];
	
	_gifFrame = (_gifFrame + 1) % self.image.images.count;
	
	UIImage *nextFrame = self.image.images[_gifFrame];
	
	//in the case of a repeated frame (ie if there's a repeated frame to help with timing)
	//don't force a potentially redundant redraw
	if (lastFrame != nextFrame) {
		[self drawImage:nextFrame];
	}
}

- (void)dealloc{
	[_gifTimer invalidate];
}

@end
