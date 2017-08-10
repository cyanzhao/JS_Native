
/**
 
 review web_injectJS
 blog
 prepare for javascriptcore
 
 */

#import "CyanWebViewController.h"
#import "InterfaceProvider.h"
#import "CyanUIwebViewController.h"
#import "CyanWkwebViewController.h"
#import "WebType.h"
#import "JSCoreViewController.h"
#import "JSCoreWKViewController.h"
#import "InterObject.h"

@interface CyanWebViewController ()<InterfaceProvider>{
    
    CyanBaseWebViewController *_webviewController;
}


@end

@implementation CyanWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    self.view.backgroundColor = [UIColor whiteColor];

    switch (_type) {
        case 2:{
            _webviewController = [[CyanUIwebViewController alloc]init];
            ((CyanUIwebViewController *)_webviewController).interfaceProvider = self;
            _webviewController.view.frame = self.view.bounds;
            [self.view addSubview:_webviewController.view];
            [self addChildViewController:_webviewController];
        }
            
            break;
        case 3:{
            _webviewController = [[CyanWkwebViewController alloc]init];
            ((CyanWkwebViewController *)_webviewController).interfaceProvider = self;
            _webviewController.view.frame = self.view.bounds;
            [self.view addSubview:_webviewController.view];
            [self addChildViewController:_webviewController];
        }
            break;
        case 0:{
            
            _webviewController = [[JSCoreViewController alloc]init];
            [self.view addSubview:_webviewController.view];
            [self addChildViewController:_webviewController];
        }
            break;
        case 1:{
            _webviewController = [[JSCoreWKViewController alloc]init];
            [self.view addSubview:_webviewController.view];
            
            [self addChildViewController:_webviewController];
        }
            break;
        default:
            break;
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"n_click" style:(UIBarButtonItemStylePlain) target:self action:@selector(natveClicked:)];
}

- (void)natveClicked:(id)sender{
    
    if (_type == Inject_UI || _type == Inject_WK) {
        [_webviewController evaluateJavaScript:@"callNative('-native call js method-');" completeBlock:nil];

    }else{
        
        //注册对象
        InterObject *interO = [[InterObject alloc] init];
        _webviewController.webContext[@"inter_object"] = interO;
        
        _webviewController.webContext[@"log"] = (NSString *)^(NSString *msg){
            
            return [NSString stringWithFormat:@"-C-%@",msg];
        };
        //注册函数
        JSValue *jsFunction = [_webviewController.webContext evaluateScript:@"(function(input){return  inter_object.callMethod(log(input + '-D-') + '-E-') + '-B-';})"];
        
        JSValue *resultsValue = [jsFunction callWithArguments:@[@"-A-"]];
 
        NSLog(@"result value：%@",[resultsValue toString]);
    }
}

- (void)callNativeZero{
    
    NSLog(@"callNativeZero");
}

- (NSString *)callNative:(id)sender{
    
    if ([sender isKindOfClass: [NSString class]]) {
        
        NSString *input = [(NSString *)sender stringByRemovingPercentEncoding];
        return [NSString stringWithFormat:@"-motify contents by native-%@",input];
    }
    return nil;
}

- (NSString *)callNativeTwo:(id)sender1 with:(id)sender2{
    
    return nil;
}

#pragma mark -- InterfaceProvider

- (NSDictionary<NSString *,NSValue *> *)javascriptInterfaces{
    
    return @{
             @"callNativeZero":[NSValue valueWithPointer:@selector(callNativeZero)],
             @"callNative":[NSValue valueWithPointer:@selector(callNative:)]};
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
