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
#import <CoreVideo/CoreVideo.h>

@class CSMVideoRenderer;
@class CSMUserInfo;
@class CSMLiveTranscoding;
@class CSMVideoCanvas;
@class CSAppConfigure;

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
 返回native层的SDK engin的handler

这个接口用来获取native C++层 SDK engine的handler，用来registering 音频和视频帧的回调
*/
- (void * _Nullable)getNativeHandle;

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
 设置媒体次要信息发送开关及相关类型
 
 @param start 开启/关闭媒体次要信息传输，YES 表示开启媒体次要信息传输，NO 表示关闭媒体次要信息传输。start 为 YES 时，onlyAudioPublish 参数开关才有效。
 @param onlyAudioPublish 是否为纯音频直播，YES 表示纯音频直播，sei为单帧发送，长度限制为(16,800)字节；false 表示音视频直播，sei为随帧发送，长度限制为(16,4096)字节；默认为 NO。
 @param seiSendType sei发送类型(预留参数，暂无作用)
*/
- (void)setMediaSideFlags:(BOOL)start onlyAudioPublish:(BOOL)onlyAudioPublish seiSendType:(int)seiSendType;

/**
发送媒体次要信息传输
 
@param info 需要传输的音视频次要信息数据，外部输入；注意：用户需要把 uuid(长度为 16 字节) + content 当作 info 输入；
*/
- (void)sendMediaSideInfo:(NSData *)info;

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
 @param extraInfo 进房所携带的额外数据，额外信息长度最长不能超过800字节，超过800字节会被截断为800字节。会在 [CStoreMediaEngineCoreDelegate mediaEngine:userJoined:elapsed:] 回调中携带
 @param completion 成功加入频道回调
 */
- (void)joinChannelWithUid:(uint64_t)optionalUid
                     token:(NSString *)token
               channelName:(NSString *)channelName
                 extraInfo:(NSString *)extraInfo
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
 @param extraInfo 进房所携带的额外数据，额外信息长度最长不能超过800字节，超过800字节会被截断为800字节。会在 [CStoreMediaEngineCoreDelegate mediaEngine:userJoined:elapsed:] 回调中携带
 @param completion 成功加入频道回调
 */
- (void)joinChannelWithUserAccount:(NSString *)userAccount
                             token:(NSString *)token
                       channelName:(NSString *)channelName
                         extraInfo:(NSString *)extraInfo
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
 
 该方法用于更新 Token。如果启用了 Token 机制，过一段时间后使用的 Token 会失效。发生 [CStoreMediaEngineCoreDelegate mediaEngine:tokenPrivilegeWillExpire:] 回调时 App 应重新获取 Token，然后调用该 API 更新 Token，否则 SDK 无法和服务器建立连接。更新token发生错误会通过 [CStoreMediaEngineCoreDelegate mediaEngine:didOccurError:]回调，收到CSMErrorCheckTokenFailed时可尝试重试
 
 @param token  在 App 服务器端生成的新Token
 */
- (void)renewToken:(NSString *)token;

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

/**
 设置音频参数和场景
 @param profile  设置采样率，码率，编码模式和声道数，详见 BigoAudioProfile。
 @param scenario 设置音频应用场景，详细定义见 BigoAudioScenario。不同的音频场景下，设备的系统音量(媒体音量/通话音量)是不同的
 @return 调用成功
 
    - 0：设置成功
    - < 0：设置失败
*/
- (int)setAudioProfile:(BigoAudioProfile)profile scenario:(BigoAudioScenario)scenario;

/**
 注册语音观测器对象
 @param observer 为 IAudioFrameObserver实例，需要外部实现；如果传入 NULL，则表示取消注册， 建议在leaveChannel 后调用，来释放语音观测器对象
 @return 调用成功
 
    - 0：设置成功
    - < 0：设置失败
*/
- (int) registerAudioFrameObserver:(long) observer;

#pragma mark - InEarMonitoring耳返
/**
是否启用耳返功能
@param enable 是否启用耳返
 
 - YES：启用耳返
 - NO：关闭耳返
*/
- (void) enableInEarMonitoring:(BOOL)enable;

/**
设置耳返音量大小
@param volume 音量大小0-100,不设置默认是100
*/
- (void) setInEarMonitoringVolume:(int)volume;
/**
设置耳返音量的范围，最大值和最小值，默认是最小值0，最大值100
@param minVolume 音量最小值
@param maxVolume 音量最大值
@return 调用成功
 
    - 0：设置成功
    - < 0：设置失败
*/
- (void) setInEarMonitoringVolumeRange:(int)minVolume maxVolume:(int)maxVolume;
#pragma mark - Audio Effect Player
/**
获取音效文件的播放音量
@return volume 音量大小0-100.0
*/
- (double) getEffectsVolume;
/**
设置音效播放器的音量
@param volume 音量大小0-100.0
@return 调用成功
 
   - 0：设置成功
   - < 0：设置失败
*/
- (int) setEffectsVolume:(double)volume;
/**
设置soundId的音效文件的音量
@param soundId 音效文件的ID
@param volume 要设置的音量值
@return 调用成功
 
   - 0：设置成功
   - < 0：设置失败
*/
- (int) setVolumeOfEffect:(int)soundId withVolume:(double)volume;
/**
播放音效文件soundId
@param soundId 音效文件的ID
@param filePath 音效文件的绝对路径
@param loopCount 设置播放循环的次数；-1为无限循环；0为播放1次；1为播放2次；...；n为播放n+1次
@param pitch 需要改变的音高比例，范围[0.5,-2]，默认为1.0表示不改变； 目前尚不支持(设置为1.0)
@param pan 设定音效的空间位置。默认0.0，取值范围为 [-1.0, 1.0]， -1.0：音效出现在左边，0:音效出现在正前方，1.0：音效出现在右边；目前尚不支持(设置为0)
@param gain 设定音效的音量。默认100.0，取值范围为 [0, 100.0]
@param publish 是否将音效发给其他用户
@param progress 是否需要回调文件的播放进度
@return 调用成功
 
   - 0：设置成功
   - < 0：设置失败
*/
- (int) playEffect:(int)soundId filePath:(NSString *_Nullable)filePath loopCount:(int)loopCount pitch:(double)pitch pan:(double)pan gain:(double)gain publish:(BOOL)publish progress:(BOOL)progress;
/**
停止播放soundId的音效文件
@param soundId 音效文件的ID
@return 调用成功
 
   - 0：设置成功
   - < 0：设置失败
*/
- (int) stopEffect:(int)soundId;
/**
停止播放所有的音效文件
@return 调用成功
 
   - 0：设置成功
   - < 0：设置失败
*/
- (int) stopAllEffects;
/**
预加载的soundId的音效文件
@param soundId 音效文件的ID
@param filePath 音效文件的绝对路径
@return 调用成功
 
   - 0：设置成功
   - < 0：设置失败
*/
- (int) preloadEffect:(int)soundId filePath:(NSString *_Nullable)filePath;
/**
释放预加载的soundId的音效文件
@param soundId 音效文件的ID
@return 调用成功
 
   - 0：设置成功
   - < 0：设置失败
*/
- (int) unloadEffect:(int)soundId;
/**
暂停播放soundId的音效文件
@param soundId 音效文件的ID
@return 调用成功
 
   - 0：设置成功
   - < 0：设置失败
*/
- (int) pauseEffect:(int)soundId;
/**
暂停播放所有的音效文件
@return 调用成功
 
   - 0：设置成功
   - < 0：设置失败
*/
- (int) pauseAllEffects;
/**
恢复播放soundId的音效文件
@param soundId 音效文件的ID
@return 调用成功
 
   - 0：设置成功
   - < 0：设置失败
*/
- (int) resumeEffect:(int)soundId;
/**
恢复播放所有的音效文件
@return 调用成功
 
   - 0：设置成功
   - < 0：设置失败
*/
- (int) resumeAllEffects;
/**
获取当前音效文件的播放位置
@param soundId 音效文件的ID
@return 播放位置
*/
- (int) getEffectFileDuration:(int)soundId;
/**
获取当前音效文件的播放位置
@param soundId 音效文件的ID
@return 播放位置
*/
- (int) getCurrentEffectFilePlayPosition:(int)soundId;
/**
设置音效文件的播放位置
@param soundId 音效文件的ID
@param position 设置播放的位置
@return 调用成功
 
- 0：设置成功
- < 0：设置失败
*/
- (int) setCurrentEffectFilePlayPosition:(int)soundId currentPositon:(int) position;
//*************** 音效播放器 ***************//

#pragma mark - AudioMixing
//************* 伴奏播放器 ***************//
/**
开始播放音乐文件
@param filePath 需要播放的文件路径
@param loopback YES: 只有本地可以听到混音或替换后的音频流//NO: 本地和对方都可以听到混音或替换后的音频流
@param replace  YES: 只推送设置的本地音频文件或者线上音频文件，不传输麦克风收录的音频。// NO: 音频文件内容将会和麦克风采集的音频流进行混音
@param cycle    指定音频文件循环播放的次数:-1：无限循环
@return 调用成功
 
   - 0：设置成功
   - < 0：设置失败
*/
- (int) startAudioMixing:(NSString *_Nonnull)filePath loopback:(BOOL)loopback replace:(BOOL)replace cycle:(NSInteger)cycle;
/**
停止播放音乐文件
@return 调用成功
 
   - 0：设置成功
   - < 0：设置失败
*/
- (int) stopAudioMixing;
/**
暂停播放音乐文件
 @return 调用成功
 
   - 0：设置成功
   - < 0：设置失败
*/
- (int) pauseAudioMixing;
/**
恢复播放音乐文件
@return 调用成功
 
   - 0：设置成功
   - < 0：设置失败
*/
- (int) resumeAudioMixing;
/**
调节音乐文件的播放音量
@param volume  音乐文件播放音量范围为 0~100。默认 100 为原始文件音量
@return 调用成功
 
   - 0：设置成功
   - < 0：设置失败
*/
- (int) adjustAudioMixingVolume:(NSInteger)volume;
/**
调节音乐文件在本地播放的音量
@param volume  音乐文件播放音量范围为 0~100。默认 100 为原始文件音量
@return 调用成功
 
   - 0：设置成功
   - < 0：设置失败
*/
- (int) adjustAudioMixingPlayoutVolume:(NSInteger)volume;
/**
调节音乐文件在远端播放的音量
@param volume  音乐文件播放音量范围为 0~100。默认 100 为原始文件音量
@return 调用成功
 
  - 0：设置成功
  - < 0：设置失败
*/
- (int) adjustAudioMixingPublishVolume:(NSInteger)volume;
/**
获取音乐文件的本地播放音量
@return 返回音量值，范围为 [0,100]
*/
- (int) getAudioMixingPlayoutVolume;
/**
获取音乐文件的远端播放音量
@return 返回音量值，范围为 [0,100]
*/
- (int) getAudioMixingPublishVolume;
/**
获取音乐文件时长
@return 获取音乐文件时长，单位为毫秒
*/
- (int) getAudioMixingDuration;
/**
获取音乐文件当前播放位置，单位为毫秒。
*/
- (int) getAudioMixingCurrentPosition;
/**
设置音频文件的播放位置
@param pos 整数。进度条位置，单位为毫秒
@return 是否设置成功
 
 - 0：设置成功
 - < 0：设置失败
*/
- (int) setAudioMixingPosition:(NSInteger)pos;
//************* 伴奏播放器 ***************//
#pragma mark - audio volume
/**
 启用说话者音量提示
@param interval  指定音量提示的时间间隔. 启用该方法后，会在 reportAudioVolumeIndicationOfSpeakers 回调中按设置的时间间隔返回音量提示
 - <= 0： 禁用音量提示功能
 - > 0：提示间隔，单位为毫秒。建议设置到大于 200 毫秒。最小不得少于 20 毫秒。
@param smooth 指定音量提示的灵敏度。取值范围为 [0,10]，建议值为 3，数字越大，波动越灵敏；数字越小，波动越平滑。
@param report_vad 是否开启本地人声检测功能。。：。除引擎自动进行本地人声检测的场景外， reportAudioVolumeIndicationOfSpeakers 回调的 vad 参数不会报告是否在本地检测到人声。
 - NO： （默认）关闭本地人声检测功能
 - YES：开启后， reportAudioVolumeIndicationOfSpeakers 回调的 vad 参数会报告是否在本地检测到人声。
*/
- (void) enableAudioVolumeIndication:(NSInteger)interval smooth:(NSInteger)smooth report_vad:(BOOL)report_vad;

//************* 变声功能 ***************//
#pragma mark - voice changer
/**
 设置本地语音音调，开发中，待上线
@param pitch  语音频率。可以在 [0.5,2.0] 范围内设置。取值越小，则音调越低。默认值为 1.0，表示不需要修改音调。
@return 是否设置成功
 - 0：设置成功
 - < 0：设置失败
*/
- (int)setLocalVoicePitch:(double) pitch;
/**
 设置本地语音音效均衡，开发中，待上线
@param bandFrequency  频谱子带索引，取值范围是 [0,9]，分别代表 10 个 频带，对应的中心频率是 [31，62，125，250，500，1k，2k，4k，8k，16k] Hz，详见 AestronAudioEqualizationBandFrequency。
@param gain  每个 band 的增益，单位是 dB，每一个值的范围是 [-15,15]，默认值为 0。
@return 是否设置成功
 - 0：设置成功
 - < 0：设置失败
*/
- (int)setLocalVoiceEqualizationOfBandFrequency:(AestronAudioEqualizationBandFrequency)bandFrequency withGain:(NSInteger)gain;

/**
 设置本地音效混响，开发中，待上线
@param reverbType  混响音效类型。参考AestronAudioReverbParamsType。
@param value 设置混响音效的效果数值。各混响音效对应的取值范围请参考AestronAudioReverbParamsType
@return 是否设置成功
 - 0：设置成功
 - < 0：设置失败
*/
- (int)setLocalVoiceReverbOfType:(AestronAudioReverbParamsType)reverbType withValue:(NSInteger)value;

/**
 设置本地语音变声
@param voiceChanger 本地语音的变声，默认原声。
@return 是否设置成功
 - 0：设置成功
 - < 0：设置失败
*/
- (int)setLocalVoiceChanger:(AestronAudioVoiceChanger)voiceChanger;

/**
 预设置本地语音混响
@param preset 本地语音混响选项，默认原声。详见AestronAudioReverbPreset
@return 是否设置成功
 - 0：设置成功
 - < 0：设置失败
*/
- (int)setLocalVoiceReverbPreset:(AestronAudioReverbPreset)preset;

/**
 预设置本地语音均衡器，开发中，后续上线
@param preset 本地语音均衡器选项，默认原声。详见AestronAudioEqualizationPreset
@return 是否设置成功
 - 0：设置成功
 - < 0：设置失败
*/
- (int)setLocalVoiceEqualizerPreset:(AestronAudioEqualizationPreset)preset;


#pragma mark - Core Video

/**
 承载播放的主view
 
 然后再通过 [CStoreMediaEngineCore setVideoRenderers:] 划分成不同的矩形，显示不同的主播
 @param rendererView 承载播放的主view
 */
- (void)attachRendererView:(GLKView *)rendererView;

/**
 打开多View绘制模式
 
 多View绘制模式使用[CStoreMediaEngineCore setupLocalVideo:]和[CStoreMediaEngineCore setupRemoteVideo:]进行视频绘制，打开该模式后，请不要再调用[CStoreMediaEngineCore attachRendererView:]和[CStoreMediaEngineCore setVideoRenderers:]接口
 
 @param enable 是否打开多View绘制模式
 
 - YES 打开
 - NO 关闭
 */
- (void)enableMultiViewRender:(BOOL)enable;

/**
 初始化本地视图
 
 该方法初始化本地视图并设置本地用户视频显示信息，只影响本地用户看到的视频画面，不影响本地发布视频。调用该方法绑定本地视频流的显示视窗(view)。

 注意：如果需要在进频道前进行视频预览，需要先把 [CSMVideoCanvas uid] 指定为0，进频道成功后再把uid改为真正的本地用户uid。
 
 @param local 设置本地视图属性，详见 CSMVideoCanvas
 */
- (void)setupLocalVideo:(CSMVideoCanvas *_Nullable)local;

/**
 初始化远端用户视图
 
 该方法绑定远端用户和显示视图，只影响本地用户看到的视频画面。调用该接口时需要指定远端用户的 uid，一般在 [CStoreMediaEngineCoreDelegate mediaEngine:userJoined:elapsed:] 拿到远端uid后调用
 
 @param remote 设置远端视图属性，详见 CSMVideoCanvas
 */
- (void)setupRemoteVideo:(CSMVideoCanvas *_Nonnull)remote;

/**
 清除承载播放的主view
 */
- (void)clearRendererView;

/**
 划分视频渲染区域
 
 @param videoRenderers 表示渲染区域的数组，详见 CSMVideoRenderer
 */
- (void)setVideoRenderers:(NSArray<CSMVideoRenderer *> *)videoRenderers;

/**
 设置视频背景
 
 @param image 背景图
 */
- (void)setVideoBackgroundImage:(UIImage *)image;

- (void)setLocalRenderMode:(int)mode;

/**
 设置镜像模式
 
 @param mode 镜像模式
 
 - 0：内部选择
 - 1：打开镜像
 - 2：关闭镜像
 */
- (void)setLocalVideoMirrorMode:(CSMVideoMirrorMode)mode;

/**
 打开预览,该方法内部会执行打开摄像头操作。
 */
- (void)startPreview;

/**
 关闭预览,该方法内部会执行关闭摄像头操作。
 */
- (void)stopPreview;

/**
 开/关本地视频采集。
 
 该方法禁用/启用本地视频功能。enableLocalVideo:NO 适用于只看不发的视频场景。
  
 @param enabled 是否启用本地视频
 
 - YES：开启本地视频采集和渲染（默认）
 - NO：关闭使用本地摄像头设备。关闭后，远端用户会接收不到本地用户的视频流；但本地用户依然可以接收远端用户的视频流。设置为 NO 时，该方法不需要本地有摄像头。
 */
- (void)enableLocalVideo:(BOOL)enabled;

/**
 停止/恢复发送本地视频流。
 
 成功调用该方法后，远端会触发 [CStoreMediaEngineCoreDelegate mediaEngine:didVideoMuted:byUid:] 回调
 
 调用该方法时，SDK 不再发送本地视频流，但摄像头仍然处于工作状态。相比于 enableLocalVideo:NO 用于控制本地视频流发送的方法，该方法响应速度更快。
 
 该方法不影响本地视频流获取，没有禁用摄像头。
 
 @param mute 发送本地视频流
 
 - YES：不发送本地视频流
 - NO：发送本地视频流（默认）
 */
- (void)muteLocalVideoStream:(BOOL)mute;

/**
 停止/恢复接收指定视频流。
 
 如果之前有调用过 muteAllRemoteVideoStreams:YES 停止接收所有远端视频流，在调用本 API 之前请确保你已调用 muteAllRemoteVideoStreams:NO 。
 muteAllRemoteVideoStreams 是全局控制，muteRemoteVideoStream:mute 是精细控制。
 
 @param uid   指定的用户 ID
 @param mute 是否停止
 
 - YES：停止接收指定用户的视频流
 - NO：继续接收指定用户的视频流（默认）
 */
- (void)muteRemoteVideoStream:(uint64_t)uid mute:(BOOL)mute;

/**
 停止/恢复接收所有视频流。
 
 @param mute 是否停止
 
 - YES：停止接收所有远端视频流
 - NO：继续接收所有远端视频流（默认）
 */
- (void)muteAllRemoteVideoStreams:(BOOL)mute;

/**
 设置是否默认接收视频流。 该方法在加入频道前后都可调用
 
 如果在加入频道后调用，会接收不到后面加入频道的用户的视频流
 
 @param mute 是否默认不接收所有远端视频
 
 - YES：默认不接收所有远端视频流
 - NO：默认接收所有远端视频流（默认）
 */
- (void)setDefaultMuteAllRemoteVideoStreams:(BOOL)mute;

/**
 切换前置/后置摄像头。
 */
- (void)switchCamera;

/**
 检测设备是否支持闪光灯常开。
 
 一般情况下，App 默认开启前置摄像头，因此如果你的前置摄像头不支持闪光灯常开，直接使用该方法会返回 false。
 
 如果需要检查后置摄像头是否支持闪光灯常开，需要先使用 switchCamera 切换摄像头，再使用该方法。
 
 @return 是否支持闪光灯常开
 
 - YES: 设备支持闪光灯常开
 - NO：设备不支持闪光灯常开
 */
- (BOOL)isCameraTorchSupported;

/**
 设置是否打开闪光灯。
 @param isOn 是否打开闪光灯
 
 - YES：打开
 - NO：关闭
 */
- (void)setCameraTorchOn:(BOOL)isOn;

/**
 设置所有视频合流后的最大分辨率和帧率
 
 分辨率会随着开播人数的增加而变小，码率会随着分辨率及帧率变化，但合流后的分辨率趋近于设置的最大分辨率
 
 @param maxResolutionType 最大分辨率，详见 CSMResolutionType
 @param maxFrameRate 最大帧率，详见 CSMFrameRate
 */
- (void)setAllVideoMaxEncodeParamsWithMaxResolution:(CSMResolutionType)maxResolutionType maxFrameRate:(CSMFrameRate)maxFrameRate;

#pragma mark - Basic Beauty
/**
 设置滤镜类型以及强度
 
 @param filterPath 滤镜素材路径，传入nil则关闭滤镜
 @param level 滤镜级别，范围[0,100]，0关闭，100强度最大
 */
- (void)setBeautifyFilterWithPath:(NSString * _Nullable)filterPath level:(int)level;

/**
 设置美白强度
 
 @param whiteResourcePath 美白素材路径，传入nil则取消美白
 @param level 美白强度，范围[0,100]，0关闭，100强度最大
 */
- (void)setBeautifyWhiteSkinWithPath:(NSString * _Nullable)whiteResourcePath level:(int)level;

/**
 设置磨皮强度
 
 @param level    磨皮强度[0,100]， 0关闭，100为最高磨皮强度
 */
- (void)setBeautifySmoothSkinWithLevel:(int)level;

#pragma mark - Advanced Beauty
/**
 初始化人脸识别引擎，大眼瘦脸和贴纸功能需要识别人脸，在使用这些功能前，请先初始化人脸识别引擎
 
 内部会在当前线程进行引擎初始化，第一次初始化较耗时，调用方需要考虑在工作线程中调用
 
 @param modelPath 模型文件目录
 */
- (void)enableVenusEngineWithModelPath:(NSString *)modelPath;

/**
 设置大眼等级
 
 调整大眼效果之前，务必先调用 enableVenusEngineWithModelPath: 初始化人脸识别引擎，否则调整无效
 
 @param level 大眼级别，范围[0,100]，0关闭，100强度最大
 */
- (void)setBeautifyBigEyeWithLevel:(int)level;

/**
 设置瘦脸等级
 
 调整瘦脸效果之前，务必先调用 enableVenusEngineWithModelPath: 初始化人脸识别引擎，否则调整无效
 
 @param level 瘦脸级别，范围[0,100]，0关闭，100强度最大
 */
- (void)setBeautifyThinFaceWithLevel:(int)level;

/**
 设置贴纸
 
 设置贴纸之前，务必先调用 enableVenusEngineWithModelPath: 初始化人脸识别引擎，否则调整无效
 
 @param path 贴纸素材路径，传入nil则取消贴纸，传入无效的素材路径，也会取消已有的贴纸效果
 */
- (void)setStickerWithPath:(NSString * _Nullable)path;

#pragma mark CDN Live Streaming
/**
 增加旁路推流地址，仅触发旁路推流，不会触发转码合流，触发转码合流请调用 [CStoreMediaEngineCore setLiveTranscoding:]
 
 该方法用于添加旁路推流地址，调用该方法后，SDK 会在本地触发  [CStoreMediaEngineCoreDelegate mediaEngine:rtmpStreamingChangedToState:state:errorCode:]  回调，报告增加旁路推流地址的状态。

 - 该方法仅适用于直播场景。
 - 请确保在成功加入频道后再调用该接口。
 - 该方法每次只能增加一路旁路推流地址。若需推送多路流，则需多次调用该方法。
 
 @param url CDN 推流地址，格式为 RTMP，不支持中文等特殊字符。
 
 @return 接口调用结果
 
 - 0：调用成功
 - < 0：调用失败
  - -1：在非直播场景调用
  - -2：url长度为0或者为nil
  - -3：在成功加入频道前调用
  - -4：未知错误
 */
- (int)addPublishStreamUrl:(NSString *_Nonnull)url;
/**
 删除旁路推流地址
 
 该方法用于删除旁路推流过程中已经设置的 RTMP 推流地址。调用该方法后，SDK 会在本地触发 [CStoreMediaEngineCoreDelegate mediaEngine:rtmpStreamingChangedToState:state:errorCode:] 回调，报告删除旁路推流地址的状态。
 
 - 该方法仅适用于直播场景。
 - 请确保在成功加入频道后再调用该接口。
 - 该方法每次只能删除一路旁路推流地址。若需删除多路流，则需多次调用该方法。
 
 @param url CDN 推流地址，格式为 RTMP，不支持中文等特殊字符。
 
 @return 接口调用结果
 
 - 0：调用成功
 - < 0：调用失败
    - -1：在非直播场景调用
    - -2：url长度为0或者为nil
    - -3：在成功加入频道前调用
    - -4：未知错误
 */
- (int)removePublishStreamUrl:(NSString *_Nonnull)url;

/**
 设置直播转码，调用后会启动转码合流，如果已经启动转码合流，调用则会更新转码合流的相关参数
 
 该方法用于旁路推流的视图布局及音频设置等。调用该方法更新转码设置后本地会触发 [CStoreMediaEngineCoreDelegate mediaEngineTranscodingUpdated:] 回调。具体参数详见：CSMLiveTranscoding
 
 @param transcoding 一个 CSMLiveTranscoding 的对象，详细设置见 CSMLiveTranscoding。
 @return 接口调用结果
 
 - 0: 方法调用成功；
 - < 0: 方法调用失败。
    - -3：在成功加入频道前调用
    - -4：未知错误
    - -5：视频布局参数无效，请参照API文档检查[CSMLiveTranscoding size]，[CSMTranscodingUser rect]，[CSMTranscodingImage rect]几个参数是否有误
 */
- (int)setLiveTranscoding:(CSMLiveTranscoding *)transcoding;

/**
 停止转码合流
 
 @return 接口调用结果
 
 - 0: 方法调用成功；
 - < 0: 方法调用失败。
 */
- (int)stopLiveTranscoding;

/**
 加入频道PK
 
 如果您想和其他频道的主播跨房间PK，则调用该方法加入PK频道
  
 @param token 进房所携带的校验token
 @param channelName 要PK的频道名
 @param myUid 您的uid
 @param completion 加入后信息的回调通知
 */
- (void)joinPkChannelWithToken:(NSString *)token
                   channelName:(NSString *)channelName
                         myUid:(uint64_t)myUid
                    completion:(void(^)(BOOL success,
                                        CSMErrorCode resCode,
                                        NSString *channel,
                                        uint64_t uid,
                                        NSInteger useTime))completion;

/**
 退出PK频道
 */
- (void)leavePkChannel;

/**
是否启用通话模式

@param isUseCallMode 是否是通话模式
 
 - YES：启用通话模式(通话音量)
 - NO：不启用通话模式(媒体音量)
*/
- (void)setIsUseCallMode:(BOOL)isUseCallMode;

/**
 开始或停止自定义视频采集
 
 必须在引擎启动前设置，即在setClientRole、joinChannelWithUid等接口之前调用，建议尽可能作为第一条调用的接口。调用leaveChannel后下次进房，自定义视频采集默认会停止，所以如果要保持打开状态，在每次进频道前都需要设置
 
 当开发者开启自定义采集时，CStoreMediaEngineCoreDelegate中可接收到相关回调
 
 @param enable 是否打开自定义视频采集
 
 - YES 打开自定义视频采集
 - NO 停止自定义视频采集
 */
- (void)enableCustomVideoCapture:(BOOL)enable;

/**
 向 SDK 发送自定义采集的视频帧 CVPixelBuffer 数据，仅支持kCVPixelFormatType_420YpCbCr8BiPlanarFullRange格式
 
 该接口应该在 [onStart] 通知的之后 [CStoreMediaEngineCoreDelegate onStartCustomCaptureVideoWithMediaEngine:] 开始调用，在 [CStoreMediaEngineCoreDelegate onStopCustomCaptureVideoWithMediaEngine:] 通知之后结束调用。
 
 @param frameBuffer 要向 SDK 发送的视频帧数据
*/
- (void)sendCustomVideoCapturePixelBuffer:(CVPixelBufferRef)frameBuffer;

/**
 * 设置App配置信息
 * 该接口需要在joinChannel前调用
 * 用户通过此接口可以设置一些App配置信息，比如通过设置国家码，SDK能找到更优的节点去接入直播
 * @param appConfigs App配置信息
 */
- (void)setAppConfigure:(CSAppConfigure*)appConfigs;

@end

NS_ASSUME_NONNULL_END

#endif /* CStoreMediaEngineCore_Public_h */
