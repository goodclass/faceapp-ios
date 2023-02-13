#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wcomma"
#pragma clang diagnostic ignored "-Wdocumentation"
#pragma clang diagnostic ignored "-Wshorten-64-to-32"
#pragma clang diagnostic ignored "-Wrange-loop-analysis"
#pragma clang diagnostic ignored "-Wquoted-include-in-framework-header"
#include <torch/script.h>
#pragma clang diagnostic pop

#include <iostream>
#include <time.h>
#include "torchutil.h"


@implementation TorchUtil

static TorchUtil* instance = nil;

static torch::jit::script::Module stylegan2_module;
static torch::Tensor lastPressesLatent;

+ (TorchUtil *) share {
    if (instance == nil) {
        instance = [[TorchUtil alloc] init];
        
        auto path_syn = [[NSBundle mainBundle] URLForResource:@"stylegan/stylegan2" withExtension:@"pt"].path;
        stylegan2_module = torch::jit::load([path_syn UTF8String]);
        stylegan2_module.eval();
    }
    return instance;
}

- (bool) SaveLatent: (NSString *)path {
    if (!lastPressesLatent.defined()){ return false;}
    try{
        auto bytes = torch::jit::pickle_save(lastPressesLatent);
        std::ofstream fout([path UTF8String], std::ios::out | std::ios::binary);
        fout.write(bytes.data(), bytes.size());
        fout.close();
        return true;
    }catch (const c10::Error& e) {
        return false;
    }
}

- (UIImage *) BuildImage : (NSString *) path latent:(NSInteger) latent value: (float) value{
    std::ifstream codefile([path UTF8String], std::ios::binary);
    std::vector<char> data((std::istreambuf_iterator<char>(codefile)), std::istreambuf_iterator<char>());
    torch::Tensor codeTensor = torch::jit::pickle_load(data).toTensor();
    
    auto stylename = [NSArray arrayWithObjects:@"stylegan/style/age",@"stylegan/style/gender",
                      @"stylegan/style/smile",@"stylegan/style/beauty", nil];
    if (latent>=1 && latent <=4){
        auto stylepath = [[NSBundle mainBundle] pathForResource:stylename[latent-1] ofType:@"pt"];
        std::ifstream stylefile([stylepath UTF8String], std::ios::binary);
        std::vector<char> styledata((std::istreambuf_iterator<char>(stylefile)), std::istreambuf_iterator<char>());
        torch::Tensor styleTensor = torch::jit::pickle_load(styledata).toTensor();
        codeTensor.add_(styleTensor.mul_(value));
    }
    lastPressesLatent = codeTensor.clone();

    torch::autograd::AutoGradMode guard(false);

    auto _start = CFAbsoluteTimeGetCurrent();
    auto output = stylegan2_module.forward({codeTensor}).toTensor();
    std::cout<< value <<" time = "<< CFAbsoluteTimeGetCurrent()-_start<<std::endl;
    output = output.squeeze().permute({1, 2, 0}).mul(127.5).add(128).clamp(0, 255).to(torch::kU8).contiguous();
    int width = (int)output.size(0), height = (int)output.size(1);

    
    size_t bufferLength = width * height * 3;
    char* rgba = (char*)malloc(bufferLength);
    memcpy(rgba, output.data_ptr(), bufferLength);

    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, rgba, bufferLength, NULL);
    CGImageRef imageRef = CGImageCreate(width, height, 8, 24, 3 * width, colorSpaceRef, kCGBitmapByteOrderDefault,
                                        provider, NULL, YES, kCGRenderingIntentDefault);
    NSData *image_data = UIImagePNGRepresentation([UIImage imageWithCGImage:imageRef]);
    CGImageRelease(imageRef); CGColorSpaceRelease(colorSpaceRef); CGDataProviderRelease(provider); free(rgba);
    return [UIImage imageWithData:image_data];
}


@end
