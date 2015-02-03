//
//  theCheckInternet.m
//  iMRT Taipei
//
//  Created by LarryStanley on 13/6/5.
//
//

#import "theCheckInternet.h"
#import "SystemConfiguration/SystemConfiguration.h"

@implementation theCheckInternet
- (BOOL) isConnectionAvailable
{
	SCNetworkReachabilityFlags flags;
    BOOL receivedFlags;
    
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(CFAllocatorGetDefault(), [@"dipinkrishna.com" UTF8String]);
    receivedFlags = SCNetworkReachabilityGetFlags(reachability, &flags);
    CFRelease(reachability);
    
    if (!receivedFlags || (flags == 0) )
    {
        return FALSE;
    } else {
		return TRUE;
	}
}
@end
