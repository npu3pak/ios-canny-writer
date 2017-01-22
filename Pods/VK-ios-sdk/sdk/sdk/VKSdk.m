//
//  sdk.m
//
//  Copyright (c) 2014 VK.com
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"), to deal in
//  the Software without restriction, including without limitation the rights to
//  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//  the Software, and to permit persons to whom the Software is furnished to do so,
//  subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//  FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "VKSdk.h"
#import "VKAuthorizeController.h"

typedef enum : NSUInteger {
    VKAuthorizationNone        = 0,
    VKAuthorizationInitialized = 1,
    VKAuthorizationVkApp       = 1 << 1,
    VKAuthorizationWebview     = 1 << 2,
    VKAuthorizationSafari      = 1 << 3
} VKAuthorizationState;

@interface VKSdk ()

@property (nonatomic, assign) VKAuthorizationState authState;
@property (nonatomic, strong) NSString * currentAppId;
@property (nonatomic, strong) VKAccessToken *accessToken;

@end

@implementation VKSdk
static VKSdk *vkSdkInstance = nil;
static NSString * VK_ACCESS_TOKEN_DEFAULTS_KEY = @"VK_ACCESS_TOKEN_DEFAULTS_KEY_DONT_TOUCH_THIS_PLEASE";
#pragma mark Initialization
+ (void)initialize {
	NSAssert([VKSdk class] == self, @"Subclassing is not welcome");
	
}

+ (instancetype)instance {
	if (!vkSdkInstance) {
		[NSException raise:@"VKSdk should be initialized" format:@"Use [VKSdk initialize:delegate] method"];
	}
	return vkSdkInstance;
}

+ (void)initializeWithDelegate:(id <VKSdkDelegate> )delegate andAppId:(NSString *)appId {
	[self initializeWithDelegate:delegate andAppId:appId andCustomToken:vkSdkInstance.accessToken];
}

+ (void)initializeWithDelegate:(id <VKSdkDelegate> )delegate andAppId:(NSString *)appId andCustomToken:(VKAccessToken *)token
{
    if (!vkSdkInstance) {
        vkSdkInstance           = [[super alloc] initUniqueInstance];
    }
    vkSdkInstance.delegate      = delegate;
    vkSdkInstance.currentAppId  = appId;
    
	if (token && token != vkSdkInstance.accessToken) {
		vkSdkInstance.accessToken = token;
		if ([delegate respondsToSelector:@selector(vkSdkAcceptedUserToken:)]) {
			[delegate vkSdkAcceptedUserToken:token];
		}
	}
}

- (instancetype)initUniqueInstance {
    self = [super init];
    self.authState = VKAuthorizationInitialized;
	return self;
}

#pragma mark Authorization
+ (void)authorize:(NSArray *)permissions {
	[self authorize:permissions revokeAccess:NO];
}

+ (void)authorize:(NSArray *)permissions revokeAccess:(BOOL)revokeAccess {
	[self authorize:permissions revokeAccess:revokeAccess forceOAuth:NO];
}

+ (void)authorize:(NSArray *)permissions revokeAccess:(BOOL)revokeAccess forceOAuth:(BOOL)forceOAuth {
    if ([VKSdk instance].authState == VKAuthorizationInitialized &&
        [vkSdkInstance.delegate respondsToSelector:@selector(vkSdkIsBasicAuthorization)]) {
        [VKSdk instance].authState = [vkSdkInstance.delegate vkSdkIsBasicAuthorization] ? VKAuthorizationInitialized : VKAuthorizationVkApp;
    }
    //pull #87
	if ([[VKSdk instance].delegate respondsToSelector:@selector(vkSdkAuthorizationAllowFallbackToSafari)]) {
		if (![[VKSdk instance].delegate vkSdkAuthorizationAllowFallbackToSafari])
			[VKSdk instance].authState = VKAuthorizationInitialized;
	}
    //Если не VK app, то необходимо открыть сначала web view
    if (![self vkAppMayExists] &&
        [VKSdk instance].authState == VKAuthorizationInitialized) {
        [self authorize:permissions revokeAccess:revokeAccess forceOAuth:forceOAuth inApp:YES];
    } else {
        [self authorize:permissions revokeAccess:revokeAccess forceOAuth:forceOAuth inApp:NO];
    }
}
+ (void)authorize:(NSArray *)permissions revokeAccess:(BOOL)revokeAccess forceOAuth:(BOOL)forceOAuth inApp:(BOOL) inApp;
{
	[self authorize:permissions revokeAccess:revokeAccess forceOAuth:forceOAuth inApp:inApp display:VK_DISPLAY_MOBILE];
}
+ (void)authorize:(NSArray *)permissions revokeAccess:(BOOL)revokeAccess forceOAuth:(BOOL)forceOAuth inApp:(BOOL) inApp display:(VKDisplayType) displayType {
    if (![permissions containsObject:VK_PER_OFFLINE]) {
        permissions = [permissions mutableCopy];
        [(NSMutableArray*)permissions addObject:VK_PER_OFFLINE];
    }
    
    NSString *clientId = vkSdkInstance.currentAppId;
    
    if (!inApp) {
        NSURL *urlToOpen = [NSURL URLWithString:
                            [NSString stringWithFormat:@"vkauth://authorize?client_id=%@&scope=%@&revoke=%d",
                             clientId,
                             [permissions componentsJoinedByString:@","], revokeAccess ? 1:0]];
        if (!forceOAuth && [[UIApplication sharedApplication] canOpenURL:urlToOpen]) {
            [VKSdk instance].authState = VKAuthorizationVkApp;
        }
        else {
            
            urlToOpen = [NSURL URLWithString:[VKAuthorizeController buildAuthorizationUrl:[NSString stringWithFormat:@"vk%@://authorize", clientId]
                                                                                 clientId:clientId
                                                                                    scope:[permissions componentsJoinedByString:@","]
                                                                                   revoke:revokeAccess
                                                                                  display:@"mobile"]];
            [VKSdk instance].authState = VKAuthorizationSafari;
        }
        [[UIApplication sharedApplication] openURL:urlToOpen];
    } else {
        //Authorization through popup webview
        [VKAuthorizeController presentForAuthorizeWithAppId:clientId
                                             andPermissions:permissions
                                               revokeAccess:revokeAccess
                                                displayType:displayType];
        [VKSdk instance].authState = VKAuthorizationWebview;
    }
}
+(BOOL) vkAppMayExists {
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"vkauth://authorize"]];
}

#pragma mark Access token
+ (void)setAccessToken:(VKAccessToken *)token {
    [token saveTokenToDefaults:VK_ACCESS_TOKEN_DEFAULTS_KEY];
    id oldToken = vkSdkInstance->_accessToken;
	vkSdkInstance->_accessToken = token;
    BOOL respondsToRenew = [vkSdkInstance->_delegate respondsToSelector:@selector(vkSdkRenewedToken:)],
         respondsToReceive = [vkSdkInstance->_delegate respondsToSelector:@selector(vkSdkReceivedNewToken:)];
    
    if (oldToken && respondsToRenew)
        [vkSdkInstance->_delegate vkSdkRenewedToken:token];
	if ((!oldToken || (oldToken && !respondsToRenew)) && respondsToReceive)
		[vkSdkInstance->_delegate vkSdkReceivedNewToken:token];
}

+ (void)setAccessTokenError:(VKError *)error {
	[vkSdkInstance->_delegate vkSdkUserDeniedAccess:error];
}

+ (VKAccessToken *)getAccessToken {
	return vkSdkInstance->_accessToken;
}

+ (BOOL)processOpenURL:(NSURL *)passedUrl {
	NSString *urlString = [passedUrl absoluteString];
    NSRange rangeOfHash = [urlString rangeOfString:@"#"];
    if (rangeOfHash.location == NSNotFound) {
        return NO;
    }
    
	NSString *parametersString = [urlString substringFromIndex:rangeOfHash.location + 1];
	if (parametersString.length == 0) {
		return NO;
	}
	NSDictionary *parametersDict = [VKUtil explodeQueryString:parametersString];
    BOOL inAppCheck = [urlString hasPrefix:@"https://oauth.vk.com"];
    if ( (!inAppCheck && parametersDict[@"error"]) ||
              (inAppCheck && (parametersDict[@"cancel"] || parametersDict[@"error"] || parametersDict[@"fail"] ) ) ) {
		VKError *error     = [VKError errorWithQuery:parametersDict];
		[VKSdk setAccessTokenError:error];
		return NO;
	}
	else if (inAppCheck && parametersDict[@"success"]) {
		VKAccessToken *token = [VKSdk getAccessToken];
        token.accessToken   = parametersDict[@"access_token"] ? : token.accessToken;
		token.secret        = parametersDict[@"secret"]       ? : token.secret;
        token.userId        = parametersDict[@"user_id"]      ? : token.userId;
        [token saveTokenToDefaults:VK_ACCESS_TOKEN_DEFAULTS_KEY];
	}
	else {
		VKAccessToken *token = [VKAccessToken tokenFromUrlString:parametersString];
        if (!token.accessToken) {
            return NO;
        }
		[VKSdk setAccessToken:token];
	}
	return YES;
}

+ (BOOL)processOpenURL:(NSURL *)passedUrl fromApplication:(NSString *)sourceApplication {
	if ([sourceApplication isEqualToString:@"com.vk.odnoletkov.client"] ||
         [sourceApplication isEqualToString:@"com.vk.client"] ||
         (
          ([sourceApplication isEqualToString:@"com.apple.mobilesafari"] || !sourceApplication) &&
           [passedUrl.scheme  isEqualToString:[NSString stringWithFormat:@"vk%@", vkSdkInstance.currentAppId]]
         )
        )
		return [self processOpenURL:passedUrl];
	return NO;
}

+(void)forceLogout {
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    
    for (NSHTTPCookie *cookie in cookies)
        if (NSNotFound != [cookie.domain rangeOfString:@"vk.com"].location)
        {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage]
             deleteCookie:cookie];
        }
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:VK_ACCESS_TOKEN_DEFAULTS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    vkSdkInstance->_accessToken = nil;
}
+(BOOL)isLoggedIn {
    if (vkSdkInstance->_accessToken && ![vkSdkInstance->_accessToken isExpired]) return true;
    return false;
}
+(BOOL)wakeUpSession {
    VKAccessToken * token = [VKAccessToken tokenFromDefaults:VK_ACCESS_TOKEN_DEFAULTS_KEY];
    if (!token || token.isExpired)
        return NO;
    vkSdkInstance->_accessToken = token;
    return YES;
}

-(NSString *)currentAppId {
    return _currentAppId;
}

@end
