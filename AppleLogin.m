#import "AppleLogin.h"

@interface AppleLogin ()

@property (nonatomic, strong) NSWindow *window;
@property (nonatomic, strong) NSString *nonce;
@end

@implementation AppleLogin
 -(id)initWithWindow:(NSWindow *)window {
    if(self = [super init]) {
      self.window = window;
    }
    return self;
  }

  -(NSString*)getSha256:(NSString*)input {
    const char* str = [input UTF8String];
    unsigned char result[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(str, strlen(str), result);

    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH*2];
    for (int i = 0; i<CC_SHA256_DIGEST_LENGTH; i++) {
      [ret appendFormat:@"%02x",result[i]];
    }
    return ret;
  }

  - (void)initiateLoginProcess:(void (^)(NSDictionary<NSString *, NSString *> *result))completionHandler errorHandler:(void (^)(NSError *error))errorHandler {
    self.successBlock = completionHandler;
    self.errorBlock = errorHandler;

    ASAuthorizationAppleIDProvider *appleIDProvider = [[ASAuthorizationAppleIDProvider alloc]init];
    ASAuthorizationAppleIDRequest *request = [appleIDProvider createRequest];
    request.requestedScopes = @[ASAuthorizationScopeFullName, ASAuthorizationScopeEmail];
    
    NSUUID *uuid = [NSUUID UUID];
    self.nonce = [uuid UUIDString];
    request.nonce = [self getSha256:self.nonce];

    ASAuthorizationController *authorizationController = [[ASAuthorizationController alloc]initWithAuthorizationRequests:@[request]];
    authorizationController.delegate = self;
    authorizationController.presentationContextProvider = self;

    [authorizationController performRequests];
  }

  - (void)authorizationController:(ASAuthorizationController *)controller didCompleteWithAuthorization:(ASAuthorization *)authorization {
    ASAuthorizationAppleIDCredential *appleIDCredential = [authorization credential];

    if(appleIDCredential) {
      NSString *idToken = [[NSString alloc] initWithData:appleIDCredential.identityToken encoding:NSUTF8StringEncoding];
      NSString *code = [[NSString alloc] initWithData:appleIDCredential.authorizationCode encoding:NSUTF8StringEncoding];

      NSPersonNameComponents *fullName = appleIDCredential.fullName;
      NSDictionary *userDetails = @{
        @"firstName": fullName.givenName ?: @"",
        @"middleName": fullName.middleName ?: @"",
        @"lastName": fullName.familyName ?: @"",
        @"email" : appleIDCredential.email ?: @"",
        @"idToken" : idToken,
        @"code" : code,
        @"nonce": self.nonce
      };

      self.successBlock(userDetails);
    }
  }

  - (void)authorizationController:(ASAuthorizationController *)controller didCompleteWithError:(NSError *)error {
    self.errorBlock(error);
  }

  -(ASPresentationAnchor)presentationAnchorForAuthorizationController:(ASAuthorizationController *)controller {
    return self.window;
  }
@end
