
#import <UIKit/UIKit.h>

@interface TorchUtil : NSObject

+ (TorchUtil *) share;

- (bool) SaveLatent: (NSString *)path;

- (UIImage *) BuildImage : (NSString *) path latent:(NSInteger) latent value: (float) value;

@end
