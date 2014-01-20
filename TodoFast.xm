#import <libactivator/libactivator.h>
#import <UIKit/UIKit.h>

@interface TodoFast : NSObject <LAListener, UIAlertViewDelegate>{
@private
	UIAlertView *taskView;
}
@end

@implementation TodoFast

-(BOOL)dismiss{
	if (taskView){
		[taskView dismissWithClickedButtonIndex:[taskView cancelButtonIndex] animated:YES];
		[taskView release];
		taskView = nil;
		return YES;
	}

	return NO;
}

-(void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex{
	[taskView release];
	taskView = nil;

	if([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Create"]){
		//AppigoTask *task = [[AppigoTask alloc] initWithName:[alertView textFieldAtIndex:0].text];
 		//[AppigoPasteboard openTodoWithTask:task];
		//[task release];

		NSString *stringURL = [NSString stringWithFormat:@"appigotodo://com.insanj.todofast/import?name=%@", [alertView textFieldAtIndex:0].text];
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[stringURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
	}//end if
}//end method

-(void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event{
	if (![self dismiss]){
		if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"appigotodo:"]]){
			taskView = [[UIAlertView alloc] initWithTitle:@"TodoFast" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Create", nil];
			[taskView setAlertViewStyle:UIAlertViewStylePlainTextInput];
			[[taskView textFieldAtIndex:0] setPlaceholder:@"New Appigo Todo Task"];
		}

		else
			taskView = [[UIAlertView alloc] initWithTitle:@"Appigo Todo Required" message:@"Please install Appigo Todo for iOS from the App Store to use TodoFast!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];

		[taskView show];
		[event setHandled:YES];
	}//end if
}

-(void)activator:(LAActivator *)activator abortEvent:(LAEvent *)event{
	[self dismiss];
}

-(void)activator:(LAActivator *)activator otherListenerDidHandleEvent:(LAEvent *)event{
	[self dismiss];
}

-(void)activator:(LAActivator *)activator receiveDeactivateEvent:(LAEvent *)event{
	if ([self dismiss])
		[event setHandled:YES];
}

-(void)dealloc{
	[super dealloc];
}

+(void)load{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[[LAActivator sharedInstance] registerListener:[self new] forName:@"libactivator.todofast"];
	[pool release];
}

@end 