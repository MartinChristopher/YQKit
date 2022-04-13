//
//  YQAppPurchase.m
//  YQAppPurchase
//
//  Created by Apple on 2021/7/2.
//
#ifdef DEBUG
#define checkURL @"https://sandbox.itunes.apple.com/verifyReceipt"
#else
#define checkURL @"https://buy.itunes.apple.com/verifyReceipt"
#endif

#import "YQAppPurchase.h"

@interface YQAppPurchase () <SKPaymentTransactionObserver, SKProductsRequestDelegate>

/**
 *  商品字典
 */
@property (nonatomic, strong) NSMutableDictionary *productDic;

@end

@implementation YQAppPurchase

//单例
static YQAppPurchase *storeTool;

//单例
+ (YQAppPurchase *)defaultTool {
    if(!storeTool){
        storeTool = [YQAppPurchase new];
        [storeTool setup];
    }
    return storeTool;
}

#pragma mark  初始化
/**
 *  初始化
 */
- (void)setup {
    self.CheckAfterPay = YES;
    
    // 设置购买队列的监听器
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
}

#pragma mark 询问苹果的服务器能够销售哪些商品
/**
 *  询问苹果的服务器能够销售哪些商品
 */
- (void)requestProductsWithProductArray:(NSArray *)products {
    NSLog(@"开始请求可销售商品");
    // 能够销售的商品
    NSSet *set = [[NSSet alloc] initWithArray:products];
    // "异步"询问苹果能否销售
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:set];
    request.delegate = self;
    // 启动请求
    [request start];
}

#pragma mark 获取询问结果，成功采取操作把商品加入可售商品字典里
/**
 *  获取询问结果，成功采取操作把商品加入可售商品字典里
 *
 *  @param request  请求内容
 *  @param response 返回的结果
 */
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    if (self.productDic == nil) {
        self.productDic = [NSMutableDictionary dictionaryWithCapacity:response.products.count];
    }
    
    NSMutableArray *productArray = [NSMutableArray array];
    
    for (SKProduct *product in response.products) {
        // 填充商品字典
        [self.productDic setObject:product forKey:product.productIdentifier];
        
        [productArray addObject:product];
    }
    //通知代理
    [self.delegate GotProducts:productArray];
}

#pragma mark - 用户决定购买商品
/**
 *  用户决定购买商品
 *
 *  @param productID 商品ID
 */
- (void)buyProduct:(NSString *)productID {
    SKProduct *product = self.productDic[productID];
    
    // 要购买产品(店员给用户开了个小票)
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    
    // 去收银台排队，准备购买(异步网络)
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

#pragma mark - SKPaymentTransaction Observer
#pragma mark 购买队列状态变化,,判断购买状态是否成功
/**
 *  监测购买队列的变化
 *
 *  @param queue        队列
 *  @param transactions 交易
 */
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    // 处理结果
    for (SKPaymentTransaction *transaction in transactions) {
        NSLog(@"队列状态变化 %@", transaction.error);
        // 如果小票状态是购买完成
        if (SKPaymentTransactionStatePurchased == transaction.transactionState) {
            NSLog(@"购买完成 %@", transaction.payment.productIdentifier);
            
            if (self.CheckAfterPay) {
                //需要向苹果服务器验证
                //通知代理
                [self.delegate BeginCheckingdWithProductID:transaction.payment.productIdentifier];
                // 验证购买凭据
                [self verifyPruchaseWithID:transaction.payment.productIdentifier];
            }
            else {
                //不需要向苹果服务器验证
                // 验证凭据，获取到苹果返回的交易凭据
                   NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
                   // 从沙盒中获取到购买凭据
                   NSData *receiptData = [NSData dataWithContentsOfURL:receiptURL];
                   
                   // 在网络中传输数据，大多情况下是传输的字符串而不是二进制数据
                   // 传输的是BASE64编码的字符串
                   /**
                    BASE64 常用的编码方案，通常用于数据传输，以及加密算法的基础算法，传输过程中能够保证数据传输的稳定性
                    BASE64是可以编码和解码的
                    */
                   NSString *encodeStr = [receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
                //通知代理
                [self.delegate BoughtProductSuccessedWithProductID:transaction.payment.productIdentifier
                                                                  andInfo:@{@"receipt":encodeStr}];
            }
            // 将交易从交易队列中删除
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            
        }
        else if (SKPaymentTransactionStateRestored == transaction.transactionState) {
            NSLog(@"恢复成功 :%@", transaction.payment.productIdentifier);
            
            // 通知代理
            [self.delegate RestoredProductID:transaction.payment.productIdentifier];
            
            // 将交易从交易队列中删除
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
        }
        else if (SKPaymentTransactionStateFailed == transaction.transactionState){
            NSLog(@"交易失败");
            // 将交易从交易队列中删除
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            
            [self.delegate CanceldWithProductID:transaction.payment.productIdentifier];
        }
        else if (SKPaymentTransactionStatePurchasing == transaction.transactionState){
            NSLog(@"正在购买");
        }
        else {
            NSLog(@"state:%ld", (long)transaction.transactionState);
            NSLog(@"已经购买");
            // 将交易从交易队列中删除
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
        }
    }
}

#pragma mark - 恢复商品
/**
 *  恢复商品
 */
- (void)restorePurchase {
    // 恢复已经完成的所有交易.（仅限永久有效商品）
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

#pragma mark 验证购买凭据
/**
 *  验证购买凭据
 *
 *  @param ProductID 商品ID
 */
- (void)verifyPruchaseWithID:(NSString *)ProductID {
    // 验证凭据，获取到苹果返回的交易凭据
    NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
    // 从沙盒中获取到购买凭据
    NSData *receiptData = [NSData dataWithContentsOfURL:receiptURL];
    
    // 发送网络POST请求，对购买凭据进行验证
    NSURL *url = [NSURL URLWithString:checkURL];
    
    NSLog(@"checkURL:%@",checkURL);
    
    // 国内访问苹果服务器比较慢，timeoutInterval需要长一点
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20.0f];
    
    request.HTTPMethod = @"POST";
    
    // 在网络中传输数据，大多情况下是传输的字符串而不是二进制数据
    // 传输的是BASE64编码的字符串
    /**
     BASE64 常用的编码方案，通常用于数据传输，以及加密算法的基础算法，传输过程中能够保证数据传输的稳定性
     BASE64是可以编码和解码的
     */
    NSString *encodeStr = [receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    
    NSString *payload = [NSString stringWithFormat:@"{\"receipt-data\" : \"%@\"}", encodeStr];
    NSData *payloadData = [payload dataUsingEncoding:NSUTF8StringEncoding];
    
    request.HTTPBody = payloadData;
    
    // 提交验证请求，并获得官方的验证JSON结果
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        // 官方验证结果为空
        if (data == nil) {
            //验证失败,通知代理
            [self.delegate CheckFailedWithProductID:ProductID
                                                     andInfo:data];
        }
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data
                                                             options:NSJSONReadingAllowFragments error:nil];
        
        if (dict != nil) {
            // 验证成功,通知代理
            [self.delegate BoughtProductSuccessedWithProductID:ProductID
                                                                andInfo:dict];
        }
        else{
            //验证失败,通知代理
            [self.delegate CheckFailedWithProductID:ProductID
                                                     andInfo:data];
        }
    }];
    [task resume];
}

@end
