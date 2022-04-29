//
//  YQNetWorking.h
//
//  Created by Apple on 16/3/31.
//

#define AppNetworkChangedNotification @"AppNetworkChangedNotification"

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#if __has_include(<AFNetworking/AFNetworkActivityIndicatorManager.h>)
#import <AFNetworking/AFNetworkActivityIndicatorManager.h>
#else
#import "AFNetworkActivityIndicatorManager.h"
#endif

#if __has_include(<AFNetworking/AFNetworking.h>)
#import <AFNetworking/AFNetworking.h>
#else
#import "AFNetworking.h"
#endif

#import "YQUploadModel.h"
#import "NSString+MD5.h"

NS_ASSUME_NONNULL_BEGIN

UIKIT_EXTERN NSString *const YQNetworkStatus;

/**
 *  网络请求方式
 */
typedef NS_ENUM(NSInteger,YQNetRequestMethod) {
    /** Get */
    YQNetRequestMethodGet = 1,
    /** Post */
    YQNetRequestMethodPost = 2,
    /** Delete */
    YQNetRequestMethodDelete = 3,
    /** Put */
    YQNetRequestMethodPut = 4,
};

// 请勿直接使用NSURLSessionDataTask,以减少对第三方的依赖
// 所有接口返回的类型都是基类NSURLSessionTask，若要接收返回值且处理，请转换成对应的子类类型
typedef NSURLSessionTask YQURLSessionTask;
typedef void(^SuccessBlock)(id response);
typedef void(^FailureBlock)(NSError *error);

typedef NS_ENUM(NSUInteger, YQRequestType) {
    YQRequestTypeJSON = 1,        // 默认
    YQRequestTypePlainText  = 2,  // 普通text/html
};
typedef NS_ENUM(NSUInteger, YQResponseType) {
    YQResponseTypeJSON = 1, // 默认
    YQResponseTypeXML  = 2, // XML
    // 特殊情况下，一转换服务器就无法识别的，默认会尝试转换成JSON，若失败则需要自己去转换
    YQResponseTypeData = 3
};

/**
 *  下载进度
 *
 *  @param bytesRead      已下载的大小
 *  @param totalBytesRead 文件总大小
 */
typedef void(^YQDownloadProgress)(int64_t bytesRead,
                                   int64_t totalBytesRead);
typedef YQDownloadProgress YQGetProgress;
typedef YQDownloadProgress YQPostProgress;
/**
 *  上传进度
 *
 *  @param bytesWritten              已上传的大小
 *  @param totalBytesWritten         总上传大小
 */
typedef void (^YQUploadProgress)(int64_t bytesWritten,
                                  int64_t totalBytesWritten);

/**
 *  请求状态变化回调
 *  @param status  网络状态枚举
 */
typedef void(^NetStatus)(AFNetworkReachabilityStatus status);


@interface YQNetWorking : NSObject
/**
 *  GET请求接口，若不指定baseurl，可传完整的url
 *
 *  @param url     接口路径，如/path/getArticleList
 *  @param refreshCache 是否刷新缓存。由于请求成功也可能没有数据，对于业务失败，只能通过人为手动判断
 *  @param success 接口成功请求到数据的回调
 *  @param fail    接口请求数据失败的回调
 *
 *  @return 返回的对象中有可取消请求的API
 */
+ (YQURLSessionTask *)getWithUrl:(NSString *)url
                     refreshCache:(BOOL)refreshCache
                          success:(SuccessBlock)success
                             fail:(FailureBlock)fail;
// 多一个params参数，如@{"categoryid" : @(12)}
+ (YQURLSessionTask *)getWithUrl:(NSString *)url
                     refreshCache:(BOOL)refreshCache
                           params:(NSDictionary *)params
                          success:(SuccessBlock)success
                             fail:(FailureBlock)fail;
// 多一个带进度回调
+ (YQURLSessionTask *)getWithUrl:(NSString *)url
                     refreshCache:(BOOL)refreshCache
                           params:(NSDictionary *)params
                         progress:(YQGetProgress)progress
                          success:(SuccessBlock)success
                             fail:(FailureBlock)fail;


/**
 *  POST请求接口，若不指定baseurl，可传完整的url
 *
 *  @param url     接口路径，如/path/getArticleList
 *  @param params  接口中所需的参数，如@{"categoryid" : @(12)}
 *  @param success 接口成功请求到数据的回调
 *  @param fail    接口请求数据失败的回调
 *
 *  @return 返回的对象中有可取消请求的API
 */
+ (YQURLSessionTask *)postWithUrl:(NSString *)url
                      refreshCache:(BOOL)refreshCache
                            params:(NSDictionary *)params
                           success:(SuccessBlock)success
                              fail:(FailureBlock)fail;
+ (YQURLSessionTask *)postWithUrl:(NSString *)url
                      refreshCache:(BOOL)refreshCache
                            params:(NSDictionary *)params
                          progress:(YQPostProgress)progress
                           success:(SuccessBlock)success
                              fail:(FailureBlock)fail;

+ (YQURLSessionTask *)deleteWithUrl:(NSString *)url
                       refreshCache:(BOOL)refreshCache
                             params:(NSDictionary *)params
                            success:(SuccessBlock)success
                               fail:(FailureBlock)fail;

+ (YQURLSessionTask *)putWithUrl:(NSString *)url
                       refreshCache:(BOOL)refreshCache
                             params:(NSDictionary *)params
                            success:(SuccessBlock)success
                               fail:(FailureBlock)fail;

/**
 *  图片上传接口，若不指定baseurl，可传完整的url
 *
 *  @param url      上传图片的接口路径，如/path/images/
 *  @param photos   图片数组
 *  @param params   参数
 *  @param progress 上传进度
 *  @param success  上传成功回调
 *  @param failure  上传失败回调
 *
 *  @return 返回的对象中有可取消请求的API
 */
+ (YQURLSessionTask *)uploadImageWithURL:(NSString *)url
                                   photos:(NSArray *)photos
                                   params:(NSDictionary *)params
                                 progress:(YQUploadProgress)progress
                                  success:(SuccessBlock)success
                                  failure:(FailureBlock)failure;
//上传单张图片
+ (YQURLSessionTask *)uploadImageWithURL:(NSString *)url
                                    image:(UIImage *)image
                                   params:(NSDictionary *)params
                                 progress:(YQUploadProgress)progress
                                  success:(SuccessBlock)success
                                  failure:(FailureBlock)failure;
//上传data数据
+ (YQURLSessionTask *)uploadDataWithURL:(NSString *)url
                                    data:(NSData *)data
                                  params:(NSDictionary *)params
                                    name:(NSString *)name
                                fileType:(YQUploadType)fileType
                                progress:(YQUploadProgress)progress
                                 success:(SuccessBlock)success
                                 failure:(FailureBlock)failure;

//提交form表单
+ (YQURLSessionTask *)submitFormWithURL:(NSString *)url
                                 params:(NSDictionary *)params
                            uploadFiles:(NSArray <YQUploadModel *>*)uploadFiles
                               progress:(YQUploadProgress)progress
                                success:(SuccessBlock)success
                                failure:(FailureBlock)failure;
/**
 *  上传文件
 *
 *  @param url              上传路径
 *  @param uploadingFile    待上传文件的路径
 *  @param progress         上传进度
 *  @param success          上传成功回调
 *  @param fail             上传失败回调
 *
 *  @return 返回的对象中有可取消请求的API
 */
+ (YQURLSessionTask *)uploadFileWithUrl:(NSString *)url
                           uploadingFile:(NSString *)uploadingFile
                                progress:(YQUploadProgress)progress
                                 success:(SuccessBlock)success
                                    fail:(FailureBlock)fail;
/**
 *  下载文件
 *
 *  @param url           下载URL
 *  @param progressBlock 下载进度
 *  @param success       下载成功后的回调
 *  @param failure       下载失败后的回调
 *  @return 返回NSURLSessionDownloadTask实例，可用于暂停继续，暂停调用suspend方法，重新开启下载调用resume方法
 */
+ (YQURLSessionTask *)downloadWithUrl:(NSString *)url
                              progress:(YQDownloadProgress)progressBlock
                               success:(void(^)(NSURL *fileUrl))success
                               failure:(FailureBlock)failure;

/**
 *  取消所有请求
 */
+ (void)cancelAllRequest;
/*
 *  取消单个请求。
 *  如果是要取消某个请求，最好是引用接口所返回来的YQURLSessionTask对象，
 *  然后调用对象的cancel方法。如果不想引用对象，这里额外提供了一种方法来实现取消某个请求
 *
 *  @param url  可以是绝对URL，也可以是path（也就是不包括baseurl）
 */
+ (void)cancelRequestWithURL:(NSString *)url;


/**
 *  缓存
 *
 *  默认只缓存GET请求的数据，对于POST请求是不缓存的。如果要缓存POST获取的数据，需要手动调用设置
 *  对JSON类型数据有效，对于PLIST、XML不确定！
 *
 *  @param isCacheGet           默认为YES
 *  @param shouldCachePost  默认为NO
 */
+ (void)cacheGetRequest:(BOOL)isCacheGet shoulCachePost:(BOOL)shouldCachePost;
/**
 *  清除缓存
 */
+ (void)clearCaches;
/**
 *  获取缓存总大小/bytes
 *
 *  @return 缓存大小
 */
+ (unsigned long long)totalCacheSize;


/**
 *  BaseURL
 *  用于指定网络请求接口的基础url，如：
 *  http://baidu.com或者http://192.168.7.15:8080
 *  通常在AppDelegate中启动时就设置一次就可以了。如果接口有来源
 *  于多个服务器，可以调用更新
 *
 *  @param baseUrl 网络接口的基础url
 */
+ (void)updateBaseUrl:(NSString *)baseUrl;
/**
 *  获取当前的baseUrl
 */
+ (NSString *)baseUrl;


/**
 *
 *  配置公共的请求头，只调用一次即可，通常放在应用启动的时候配置就可以了
 *
 *  @param httpHeaders 只需要将与服务器商定的固定参数设置即可
 */
+ (void)configCommonHttpHeaders:(NSDictionary *)httpHeaders;

/**
 *
 *  修改/添加请求头参数
 */
+ (void)setHttpHeaderValue:(id)value forKey:(NSString *)key;

/**
 *
 * 删除请求头参数
 */
+ (void)removeHttpHeaderforKey:(NSString *)key;

/**
 *  配置请求格式，默认为JSON。如果要求传XML或者PLIST，请在全局配置一下
 *
 *  @param requestType 请求格式，默认为JSON
 *  @param responseType 响应格式，默认为JSO，
 *  @param shouldAutoEncode 默认为NO，是否自动encode url
 *  @param shouldCallbackOnCancelRequest 当取消请求时，是否要回调，默认为YES
 */
+ (void)configRequestType:(YQRequestType)requestType
             responseType:(YQResponseType)responseType
      shouldAutoEncodeUrl:(BOOL)shouldAutoEncode
  callbackOnCancelRequest:(BOOL)shouldCallbackOnCancelRequest;



/**
 *  开启或关闭是否自动将URL使用UTF8编码，用于处理链接中有中文时无法请求的问题
 *
 *  @param shouldAutoEncode YES or NO,默认为NO
 */
+ (void)shouldAutoEncodeUrl:(BOOL)shouldAutoEncode;

/*
 *  格式化接口数据打印日志
 *
 *  开启或关闭接口打印信息
 *
 *  @param isDebug 开发期，最好打开，默认是NO
 */
+ (void)enableInterfaceDebug:(BOOL)isDebug;

//使用AFN框架来检测网络状态的改变
+ (void)startMonitoringNetStatus:(NetStatus)netStatus;

+ (void)stopMonitoring;

/**
 *
 *  配置请求超时重试次数(不支持上传下载接口)
 *
 *  @param number 默认重试次数为0
 */
+ (void)setNumberOfTimesToRetryOnTimeout:(NSInteger)number;

/// 设置网络请求超时时间
/// @param timeoutInterval 超时时间
+ (void)setTimeoutInterval:(NSTimeInterval)timeoutInterval;

//通过接口path，拼接baseurl 返回完整的url地址
+ (NSString *)absoluteUrlWithPath:(NSString *)path;

+ (BOOL)hasNetWithStatus:(AFNetworkReachabilityStatus)status;

+ (NSDictionary *)httpHeader;

+ (AFHTTPSessionManager *)manager;

+ (NSData *)compressImageToData:(UIImage *)img;

@end

NS_ASSUME_NONNULL_END
