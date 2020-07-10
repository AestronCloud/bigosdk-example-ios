# cstore-example-ios

## 编译运行说明
1. 在控制台https://console.bigocloud.net 中新建项目，复制appId和cer到CSDataStore.m文件的指定位置中
2. 根据需求选中不同的target，在签名配置中修改bundle id和team，自动签名成功。然后点击run运行即可
> 不同的target可以编出不同的demo
> 1. video-live：多人直播
> 2.  audio-live：多人语音
> 3. video-call-1v1：1v1视频通话
> 4. audio-call-1v1：1v1语音通话

## 工程结构说明
1. common目录：在多个demo间复用的代码与资源
2. common/Utils：工具类集合
3. common/Thirdparty：第三方库
4. common/Beauty：美颜模块
5. video-live、audio-live、video-call-1v1、audio-call-1v1目录：各demo独有的代码与资源
