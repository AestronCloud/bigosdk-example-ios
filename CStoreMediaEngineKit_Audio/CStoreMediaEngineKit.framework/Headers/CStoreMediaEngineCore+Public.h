//
//  CStoreMediaEngineCore+Public.h
//  CStoreEngineKit
//
//  Created by Caimu Yang on 2019/8/20.
//  Copyright © 2019 BIGO Inc. All rights reserved.
//

#ifndef CStoreMediaEngineCore_Public_h
#define CStoreMediaEngineCore_Public_h

#import "CStoreMediaEngineCoreEnums.h"
#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

@class CSMVideoRenderer;
@class CSMUserInfo;

NS_ASSUME_NONNULL_BEGIN

/**
 提供所有可供 App 调用的方法
 
 CStoreMediaEngineCore 是 Bigo SDK 的入口类。它为 App 提供了快速搭建音视频通信的 API。
 */
@interface CStoreMediaEngineCore (Public)

/**
 创建 CStoreMediaEngineCore 实例
 @param appId 开放平台授权申请的appId
 
 @warning *Important:* 请确保在调用其他 API 前先调用该方法创建并初始化 CStoreMediaEngineCore
 
 */
+ (void)launchWithAppId:(NSString *)appId;

/**
 返回全局唯一的CStoreMediaEngineCore对象
 @return CStoreMediaEngineCore对象，在调用 launchWithAppId: 之前调用该方法会返回nil
 */
+ (instancetype)sharedSingleton;

/**
 销毁CStoreMediaEngineCore对象
 
 调用destrop后再调用sharedSingleton会返回nil，需要重新调用 launchWithAppId: 初始化SDK
 */
+ (void)destroy;

/**
 通知SDK应用变成活跃状态
 
 在实现UIApplicationDelegate的applicationDidBecomeActive:接口时调用
 */
- (void)onApplicationDidBecomeActive;
/**
 通知SDK应用即将变成非活跃状态
 
 在实现UIApplicationDelegate的applicationWillResignActive:接口时调用
 */
- (void)onApplicationWillResignActive;
/**
 通知SDK应用回到后台
 
 在实现UIApplicationDelegate的applicationDidEnterBackground:接口时调用
 */
- (void)onApplicationDidEnterBackground;

/**
 用户有两种角色，分别是观众和主播，本接口用来设置用户角色
 
 由观众切换到主播或者由主播切换到观众可以设置此接口
 
 @param role 用户角色，详见：CSMClientRole
 
 @see CSMClientRole
 */
- (void)setClientRole:(CSMClientRole)role;

/**
 设置使用场景
 
 @param channelProfile 频道使用场景。详见 CSMChannelProfile
 */
- (void)setChannelProfile:(CSMChannelProfile)channelProfile;

/**
 获取SDK版本号
 
 @return 示例:0.0.1.218
 */
+ (NSString *)getSdkVersion;

#pragma mark - Channel

/**
 提前建立连接，连接会在40s后自动超时断开，在 joinChannelWithUserAccount:token:channelName:completion: 之前提前调用此方法
 
 预先建立好连接,可以节省一次rtt
 */
- (void)preConnect;


/** 
 加入频道
 
 该方法让用户加入频道，在同一个频道内的用户可以互相通话，多个用户加入同一个频道，可以群聊。
 
 1. 如果已在频道中，用户必须调用 leaveChannel 退出当前频道，才能进入下一个频道。
 2. 成功调用该方法加入频道后，会回调 completion block
 
 @param optionalUid 为0时，服务器将自动分配一个，不为0时，需要业务方自己保证唯一
 @param token 在 App 服务器端生成的用于鉴权的 Token
 @param channelName 频道号
 @param completion 成功加入频道回调
 */
- (void)joinChannelWithUid:(uint64_t)optionalUid
                     token:(NSString *)token
               channelName:(NSString *)channelName
                completion:(void(^)(BOOL success,
                                    CSMErrorCode resCode,
                                    NSString *channel,
                                    uint64_t uid,
                                    NSInteger useTime))completion;

/**
 使用 User Account 加入频道
 
 @param userAccount 不可为空，业务需要保证唯一性
 @param token 在 App 服务器端生成的用于鉴权的 Token
 @param channelName 频道号
 @param completion 成功加入频道回调
 */
- (void)joinChannelWithUserAccount:(NSString *)userAccount
                             token:(NSString *)token
                       channelName:(NSString *)channelName
                        completion:(void(^)(BOOL success,
                                            CSMErrorCode resCode,
                                            NSString *channel,
                                            uint64_t uid,
                                            NSInteger useTime))completion;

/**
 离开频道
 
 通信模式下的用户和直播模式下的主播离开频道后，远端会触发 [CStoreMediaEngineCoreDelegate mediaEngine:userOffline:reason:] 回调。
 */
- (void)leaveChannel;

/**
 更新 Token
 
 该方法用于更新 Token。如果启用了 Token 机制，过一段时间后使用的 Token 会失效。发生 [CStoreMediaEngineCoreDelegate mediaEngine:tokenPrivilegeWillExpire:] 回调时 App 应重新获取 Token，然后调用该 API 更新 Token，否则 SDK 无法和服务器建立连接
 
 @param token  @param token 在 App 服务器端生成的新Token
 */
- (CSMErrorCode)renewToken:(NSString *)token;

/**
 将房间切换为私密房间，切换为私密房间后，只有加入白名单用户才能够进入此房间
 
 @param accessTokenVer token版本
 @param accessToken token
 @param whiteUids 白名单uid列表，会覆盖以前的白名单设置
 @param completion 切私密房结果回调
 */
- (void)switchToPrivacyRoom:(uint32_t)accessTokenVer
                accessToken:(NSString *)accessToken
               whiteUidList:(nullable NSArray<NSNumber *> *)whiteUids
                 completion:(void (^)(BOOL success, CSMErrorCode resCode))completion;

/**
 房间在私密模式下更新白名单
 
 @param accessTokenVer token版本
 @param accessToken token
 @param appendList 要追加的白名单
 @param removeList 要移除的白名单
 @param completion 更新成功后的回调
 */
- (void)updateWhiteUidList:(uint32_t)accessTokenVer
               accessToken:(NSString *)accessToken
                appendList:(nullable NSArray <NSNumber *>*)appendList
                removeList:(nullable NSArray <NSNumber *>*)removeList
                completion:(void (^)(BOOL success, CSMErrorCode resCode))completion;

/**
 切换房间为公开房，黑名单内的用户无法进房
 
 @param blockUidList block用户的uid
 @param blockTime block时间，单位秒
 @param appendBlackUidList 追加的黑名单uid列表
 @param completion 切房结果回调
 */
- (void)switchToPublicRoom:(nullable NSArray<NSNumber *> *)blockUidList
                 blockTime:(uint32_t)blockTime
        appendBlackUidList:(nullable NSArray<NSNumber *> *)appendBlackUidList
                completion:(void (^)(BOOL success, CSMErrorCode resCode))completion;

/**
 房间在公开房模式下更新黑名单
 
 @param accessTokenVer token版本
 @param accessToken token
 @param appendList 要追加的黑名单
 @param removeList 要移除的黑名单
 @param completion 更新成功后的回调
 */
- (void)updateBlackUidList:(uint32_t)accessTokenVer
               accessToken:(NSString *)accessToken
                appendList:(nullable NSArray <NSNumber *>*)appendList
                removeList:(nullable NSArray <NSNumber *>*)removeList
                completion:(void (^)(BOOL success, CSMErrorCode resCode))completion;

/**
 主播踢出房间内指定用户
 
 被踢出的用户在 blockTime 指定的时间内进房会失败
 
 @param accessTokenVer token版本
 @param accessToken token
 @param kickUidList 被踢出的uid列表
 @param blockTime 被踢出的时长，单位秒
 @param completion 踢出的结果回调
 */
- (void)kickUser:(uint32_t)accessTokenVer
     accessToken:(NSString *)accessToken
     kickUidList:(nullable NSArray <NSNumber *>*)kickUidList
       blockTime:(uint32_t)blockTime
      completion:(void (^)(BOOL success, CSMErrorCode resCode))completion;

/**
 踢出房间内的所有用户
 
 被踢出的用户在 blockTime 指定的时间内进房会失败
 
 @param accessTokenVer token版本
 @param accessToken token
 @param blockTime 被踢出的时长，单位秒
 @param completion 踢出的结果回调
 */
- (void)kickAll:(uint32_t)accessTokenVer
    accessToken:(NSString *)accessToken
      blockTime:(uint32_t)blockTime
     completion:(void (^)(BOOL success, CSMErrorCode resCode))completion;

#pragma mark - Users

/**
 获取当前频道内的用户uid列表
 
 @param pageIdx 页面索引
 @param completion 回调用户uid列表
 */
- (void)queryChannelUsersWithPageIdx:(int32_t)pageIdx completion:(void (^)(int32_t resCode, int32_t pageIdx, int32_t totalPage, int64_t sid, NSArray<NSNumber *> *users))completion;

#pragma mark - User Account

/**
 注册本地用户 User Account
 
 该方法为本地用户注册一个 User Account。注册成功后，该 User Account 即可标识该本地用户的身份，用户可以使用它加入频道
 
 @param userAccount 第三方用户账号名，不可为空，业务方需要保证唯一
 @param completion 注册结果回调
 */
- (void)registerLocalUserAccount:(NSString *)userAccount
                      completion:(void (^)(BOOL success, CSMErrorCode resCode, CSMUserInfo *userInfo))completion;

/**
 通过 User Account 获取用户信息
 
 @param userAccount 第三方用户账号名，不可为空，业务方需要保证唯一
 @param completion 获取用户信息结果回调
 */
- (void)getUserInfoByUserAccount:(NSString *)userAccount
                      completion:(void (^)(BOOL success, CSMErrorCode resCode, CSMUserInfo *userInfo))completion;

/**
 通过 UID 获取用户信息
 
 @param uid 用户uid
 @param completion 获取用户信息结果回调
 */
- (void)getUserInfoByUid:(int64_t)uid
              completion:(void (^)(BOOL success, CSMErrorCode resCode, CSMUserInfo *userInfo))completion;


/**
 批量获取用户信息
 
 @param uid 用户自己的uid
 @param uids 要查询的用户uid列表
 @param completion 获取结果返回
 */
- (void)getUserInfoListByUid:(int64_t)uid
                        uids:(NSArray<NSNumber *> *)uids
                  completion:(void (^)(BOOL success, CSMErrorCode resCode, NSArray<CSMUserInfo *> *userInfos))completion;

#pragma mark - Core Audio

/**
 调节录音音量
 
 @param volume 录音信号音量，可在 0~400 范围内进行调节
 
 - 0：静音
 - 100：原始音量
 - 400：最大可为原始音量的 4 倍（自带溢出保护）
 */
- (void)adjustRecordingSignalVolume:(int)volume;

/**
 调节播放音量
 
 @param volume 播放信号音量，可在 0~400 范围内进行调节：
 
 - 0：静音
 - 100：原始音量
 - 400：最大可为原始音量的 4 倍（自带溢出保护）
 */
- (void)adjustPlaybackSignalVolume:(int)volume;

/**
 开/关本地音频采集
 
 当 App 加入频道时，它的语音功能默认是开启的。该方法可以关闭或重新开启本地语音功能，即停止或重新开始本地音频采集。
 
 该方法不影响接收或播放远端音频流，enableLocalAudio:NO 适用于只听不发的用户场景。
 
 语音功能关闭或重新开启后，会收到回调 [CStoreMediaEngineCoreDelegate mediaEngine:didMicrophoneEnabled:] 。
 
 该方法与 muteLocalAudioStream 的区别在于：
 
 - enableLocalAudio：开启或关闭本地语音采集及处理
 - muteLocalAudioStream：停止或继续发送本地音频流
 
 @param enabled 是否开启
 
 - YES：重新开启本地语音功能，即开启本地语音采集（默认）
 - NO：关闭本地语音功能，即停止本地语音采集
 */
- (void)enableLocalAudio:(BOOL)enabled;

/**
 停止/恢复发送本地音频流。
 
 静音/取消静音。该方法用于允许/禁止往网络发送本地音频流。
 
 成功调用该方法后，远端会触发  [CStoreMediaEngineCoreDelegate mediaEngine:didAudioMuted:byUid:]  回调。
 
 该方法不影响录音状态，并没有禁用麦克风
 
 @param mute 是否停止发送音视频
 
 - YES：停止发送本地音频流
 - NO：继续发送本地音频流（默认）
 */
- (void)muteLocalAudioStream:(BOOL)mute;

/**
 停止/恢复接收指定音频流。
 
 如果之前有调用过 muteAllRemoteAudioStreams: 停止接收所有远端音频流，在调用本 API 之前请确保你已调用 muteAllRemoteAudioStreams:NO
 
 muteAllRemoteAudioStreams: 是全局控制， muteRemoteAudioStream:mute: 是精细控制
 
 @param uid   指定的用户 ID
 @param mute 是否停止接收
 
 - YES：停止接收指定用户的音频流
 - NO：继续接收指定用户的音频流（默认）
 */
- (void)muteRemoteAudioStream:(uint64_t)uid mute:(BOOL)mute;

/**
 停止/恢复接收所有音频流。
 
 @param mute 是否停止接收
 
 - YES：停止接收所有远端音频流
 - NO：继续接收所有远端音频流（默认）
 */
- (void)muteAllRemoteAudioStreams:(BOOL)mute;

/**
 设置是否默认接收音频流。 该方法在加入频道前后都可调用
 
 如果在加入频道后调用，会接收不到后面加入频道的用户的音频流
 
 @param mute 是否默认不接收所有远端音频
 
 - YES：默认不接收所有远端音频流
 - NO：默认接收所有远端音频流（默认）
 */
- (void)setDefaultMuteAllRemoteAudioStreams:(BOOL)mute;

- (void)setIsTelephoneReceiverMode:(BOOL)isTelephoneReceiverMode; // Set YES to switch to the telephone receiver.

/**
 设置是否将语音路由设到扬声器（外放）。
 
 @param enabled 是否将音频路由到外放
 
 - YES：切换到外放
 - NO：切换到听筒。如果设备连接了耳机，则语音路由走耳机
 */
- (void)setEnableSpeakerphone:(BOOL)enabled;

/**
 检查扬声器是否已开启。
 
 @return 是否开启
 */
- (BOOL)isSpeakerphoneEnabled;

/**
 获取当前网络连接状态
 
 @return 返回连接状态 CSMConnectionStateType
 */
- (CSMConnectionStateType)getConnectionState;


- (void)playSoundWithFilePath:(NSString *)filePath isLoop:(BOOL)isLoop;
- (void)stopPlaySound;
- (NSString *)mssdkDebugInfo;

@end

NS_ASSUME_NONNULL_END

#endif /* CStoreMediaEngineCore_Public_h */
