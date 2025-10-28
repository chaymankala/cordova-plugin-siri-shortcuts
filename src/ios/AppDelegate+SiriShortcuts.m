#import "AppDelegate+SiriShortcuts.h"
#import <objc/runtime.h>

static void * UserActivityPropertyKey = &UserActivityPropertyKey;

@implementation AppDelegate (siriShortcuts)

- (NSUserActivity *)userActivity {
    return objc_getAssociatedObject(self, UserActivityPropertyKey);
}

- (void)setUserActivity:(NSUserActivity *)activity {
    objc_setAssociatedObject(self, UserActivityPropertyKey, activity, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)application:(UIApplication *)application
continueUserActivity:(NSUserActivity *)userActivity
 restorationHandler:(void (^)(NSArray *))restorationHandler {
    
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    if ([userActivity.activityType isEqualToString:[NSString stringWithFormat:@"%@.shortcut", bundleIdentifier]])
    {
        NSLog(@"Setting userActivity on appDelegate");
        self.userActivity = userActivity;
        return YES;
    }
    
    NSLog(@"Activity type didn't match - checking if Truecaller can handle it");
    
    // Forward to Truecaller SDK if it exists
    Class tcClass = NSClassFromString(@"TCTrueSDK");
    if (tcClass && [tcClass respondsToSelector:@selector(sharedManager)]) {
        id tcManager = [tcClass performSelector:@selector(sharedManager)];
        if ([tcManager respondsToSelector:@selector(application:continueUserActivity:restorationHandler:)]) {
            NSLog(@"Forwarding to Truecaller SDK");
            return [tcManager application:application
                      continueUserActivity:userActivity
                        restorationHandler:restorationHandler];
        }
    }
    
    return NO;
}

@end
