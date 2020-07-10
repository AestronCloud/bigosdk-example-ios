//
//  CStoreMediaEngineCoreEnums.h
//  CStoreEngineKit
//
//  Created by Caimu Yang on 2019/8/20.
//  Copyright © 2019 BIGO Inc. All rights reserved.
//

#ifndef CStoreMediaEngineCoreEnums_h
#define CStoreMediaEngineCoreEnums_h

/**
 镜像模式
 */
typedef NS_ENUM(int, CSMVideoMirrorMode) {
    /**
     自动
     */
    CSMVideoMirrorModeAuto      = 0,
    /**
     打开
     */
    CSMVideoMirrorModeEnable    = 1,
    /**
     关闭
     */
    CSMVideoMirrorModeDisable   = 2
};

/**
 媒体连接状态
 */
typedef NS_ENUM(int, CSMConnectionStateType) {
    /**
     已断开
     */
    CSMConnectionStateTypeDisconnected  = 1,
    /**
     连接中
     */
    CSMConnectionStateTypeConnecting    = 2,
    /**
     已连接
     */
    CSMConnectionStateTypeConnected     = 3,
    /**
     重连中
     */
    CSMConnectionStateTypeReconnecting  = 4,
    /**
     连接失败
     */
    CSMConnectionStateTypeFailed        = 5,
};

/**
 网络类型
 */
typedef NS_ENUM(int, CSMNetworkType) {
    /**
     未知
     */
    CSMNetworkTypeUnknown     = 0,
    /**
     网络不可用
     */
    CSMNetworkTypeUnavailable = 1,
    /**
     WiFi
     */
    CSMNetworkTypeWIFI        = 2,
    /**
     2G网络
     */
    CSMNetworkType2G          = 3,
    /**
     3G网络
     */
    CSMNetworkType3G          = 4,
    /**
     4G网络
     */
    CSMNetworkType4G          = 5,
};

/**
 用户角色
 */
typedef NS_ENUM(int, CSMClientRole) {
    /**
     主播
     */
    CSMClientRoleBroadcaster = 1,
    /**
     观众
     */
    CSMClientRoleAudience    = 2,
};

/**
 错误码
 */
typedef NS_ENUM(int, CSMErrorCode) {
    /**
     未知
     */
    CSMErrorNone                = 0,
    /**
     超时
     */
    CSMErrorTimeout             = -1,
    /**
     协议失败
     */
    CSMErrorProtoFaile          = -2,
    /**
     无效的房间，可能没开播
     */
    CSMErrorRoomInvalid         = -3,
    /**
     无效的房间操作
     */
    CSMErrorRoomOperate         = -4,
    /**
     在黑名单中
     */
    CSMErrorInBlacklist         = -5,
    /**
     私密房不在白名单
     */
    CSMErrorNotInWhitelist      = -6,
    /**
     主播block了该用户（过了blocktime可以重新进入）
     */
    CSMErrorBlockedByHost       = -7,
    /**
     切私人房没有带白名单列表
     */
    CSMErrorNoWhitelist         = -8,
    /**
     房主将自己从白名单内移除
     */
    CSMErrorRemoveSelf          = -9,
    /**
     已经在频道中
     */
    CSMErrorAlreadyInChannel    = -10,
    /**
     频道状态无效
     */
    CSMErrorChannelStateInvalid = -11,
    /**
     Token无效
     */
    CSMErrorTokenInvalid        = -12,
    /**
     更新token时传入的token跟原来的token一样
     */
    CSMErrorSameToken           = -13,
    /**
     regetMS超时
     */
    CSMErrorNoMsGroup           = -15,
};

/**
 踢出原因
 */
typedef NS_ENUM(int, CSMKickReason) {
    /**
     被主播踢出
     */
    CSMKickReasonBroadcast        = -1,
    /**
     因房间变为私密房被踢出
     */
    CSMKickReasonRoomPrivated     = -2,
    /**
     因被加入黑名单被踢出
     */
    CSMKickReasonBlackList        = -3,
    /**
     主播踢出频道所有人
     */
    CSMKickReasonBroadcastKickAll = -4,
};

/**
 统计类型
 */
typedef NS_ENUM(int, CSMStatReportType) {
    /**
     lbs相关统计
     */
    CSMStatReportTypeLbs                = 1,
    /**
     频道相关统计
     */
    CSMStatReportTypeChannel            = 2,
    /**
     协议质量相关统计
     */
    CSMStatReportTypeLbsProtoQuality    = 3,
};

/**
 频道使用场景
 */
typedef NS_ENUM(int, CSMChannelProfile) {
    /**
     直播场景(默认)
     */
    CSMChannelProfileBroadcasting,
    /**
     通话场景
     */
    CSMChannelProfile1v1Call,
};

#endif /* CStoreMediaEngineCoreEnums_h */
