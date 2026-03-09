/// 统一管理面向用户的界面文案和提示信息。
class AppCopy {
  /// 通用“加载中”文案。
  static const String loading = '加载中...';

  /// 通用取消按钮文案。
  static const String cancel = '取消';

  /// 通用确认按钮文案。
  static const String confirm = '确认';

  /// 通用保存按钮文案。
  static const String save = '保存';

  /// 通用刷新按钮文案。
  static const String refresh = '刷新';

  /// 通用重试按钮文案。
  static const String retry = '重试';

  /// 通用重新加载按钮文案。
  static const String reload = '重新加载';

  /// 通用关于页入口文案。
  static const String viewAboutProject = '查看关于项目';

  /// 首页模块标题。
  static const String homeCrossPlatformDemo = '跨平台培育管理控制台';

  /// 首页主说明。
  static const String homeOverview =
      '当前 Flutter 前端已经按工作区 Spring Boot 后端收口，主链路围绕登录注册、设备状态轮询、异常码展示、LED 控制与健康检查展开；识别相关页面保留为独立服务扩展位。';

  /// 首页入口“开始识别”标题。
  static const String homeDetectTitle = '单图识别';

  /// 首页入口“开始识别”副标题。
  static const String homeDetectSubtitle = '前端结构和结果页仍保留，待独立识别服务并入工作区后继续联调。';

  /// 首页入口“实时监测”标题。
  static const String homeRealtimeTitle = '监控主控台';

  /// 首页入口“实时监测”副标题。
  static const String homeRealtimeSubtitle =
      '持续轮询 /api/status，展示设备环境、异常等级和 LED 控制入口。';

  /// 首页入口“历史记录”标题。
  static const String homeHistoryTitle = '识别历史';

  /// 首页入口“历史记录”副标题。
  static const String homeHistorySubtitle = '查看本地保存的识别结果与详情。';

  /// 首页入口“设置”标题。
  static const String homeSettingsTitle = '运维设置';

  /// 首页入口“设置”副标题。
  static const String homeSettingsSubtitle = '管理服务地址、健康检查、登录会话和本地数据。';

  /// 首页能力标签：Material 3。
  static const String homeMaterialPill = 'Material 3';

  /// 首页能力标签：Riverpod。
  static const String homeRiverpodPill = 'Flutter Riverpod';

  /// 首页能力标签：本地历史记录。
  static const String homeHistoryPill = '本地历史记录';

  /// 返回首页版本标签。
  static String homeVersionPill(String version) => '版本 $version';

  /// 登录页主说明。
  static const String authLoginOverview =
      '登录或注册后可进入设备监控主控台，查看 /api/status、执行 /api/ops/led，并在设置页排查 /api/health。';

  /// 登录页能力标签：自动恢复。
  static const String authRestoreChip = '登录态自动恢复';

  /// 登录页能力标签：401 回退。
  static const String authUnauthorizedChip = '401 自动退回登录';

  /// 登录页能力标签：自动附带 Token。
  static const String authTokenChip = 'Cookie 会话自动续用';

  /// 登录页能力标签：真实接口注册。
  static const String authRegisterChip = '真实接口注册';

  /// 演示登录模式标题。
  static const String authMockModeTitle = '当前为演示登录模式';

  /// 演示账号说明。
  static const String authMockAccountHint = '演示账号：demo\n演示密码：demo123456';

  /// 演示账号显示名。
  static const String authMockDisplayName = '演示账号';

  /// 填充演示账号按钮文案。
  static const String authFillDemoAccount = '填充演示账号';

  /// 真实模式注册面板标题。
  static const String authRegisterPanelTitle = '真实后端模式支持注册';

  /// 真实模式注册面板说明。
  static const String authRegisterPanelDescription =
      '当前已对接 /api/register，可在同一张登录卡片内切换到注册模式完成账号创建。';

  /// 登录卡片标题。
  static const String authLoginCardTitle = '平台登录';

  /// 登录页模式切换：登录。
  static const String authLoginTab = '登录';

  /// 登录页模式切换：注册。
  static const String authRegisterTab = '注册';

  /// 账号输入框标签。
  static const String authAccountLabel = '账号';

  /// 账号输入框占位。
  static const String authAccountHint = '请输入账号';

  /// 密码输入框标签。
  static const String authPasswordLabel = '密码';

  /// 真实接口模式密码占位。
  static const String authPasswordHint = '请输入密码';

  /// 演示接口模式密码占位。
  static const String authMockPasswordHint = '演示密码或自定义 6 位以上密码';

  /// 确认密码输入框标签。
  static const String authConfirmPasswordLabel = '确认密码';

  /// 确认密码输入框占位。
  static const String authConfirmPasswordHint = '请再次输入密码';

  /// 登录按钮文案。
  static const String authLogin = '登录';

  /// 登录进行中文案。
  static const String authLoggingIn = '登录中...';

  /// 注册按钮文案。
  static const String authRegister = '注册';

  /// 注册进行中文案。
  static const String authRegistering = '注册中...';

  /// 本地登录态已失效提示。
  static const String authSessionExpired = '本地登录态已过期，请重新登录。';

  /// 登录状态失效提示。
  static const String authUnauthorized = '登录状态已失效，请重新登录。';

  /// 请输入账号密码提示。
  static const String authInputRequired = '请输入账号和密码。';

  /// 请输入注册所需字段提示。
  static const String authRegisterInputRequired = '请输入账号、密码和确认密码。';

  /// 注册时两次密码不一致提示。
  static const String authRegisterPasswordMismatch = '两次输入的密码不一致，请重新输入。';

  /// 注册账号格式不符合后端约束提示。
  static const String authRegisterAccountInvalid =
      '用户名格式不正确，只能包含字母、数字和下划线，长度需在 3 到 32 位之间。';

  /// 注册密码长度不符合后端约束提示。
  static const String authRegisterPasswordLengthInvalid =
      '密码长度需在 6 到 32 位之间，请检查后重试。';

  /// 返回当前登录模式文案。
  static String authCurrentMode(String loginModeLabel) =>
      '当前模式：$loginModeLabel';

  /// 通用登录失败提示。
  static String authLoginFailed(Object error) => '登录失败：$error';

  /// 通用注册失败提示。
  static String authRegisterFailed(Object error) => '注册失败：$error';

  /// 登录失败，请稍后重试。
  static const String authLoginFailedRetry = '登录失败，请稍后重试。';

  /// 注册失败，请稍后重试。
  static const String authRegisterFailedRetry = '注册失败，请稍后重试。';

  /// 登录接口缺少数据体。
  static const String authLoginMissingData = '登录接口返回成功，但缺少 data 数据体。';

  /// 注册成功缺省提示。
  static const String authRegisterSuccessDefault = '注册成功，请使用新账号登录。';

  /// 登录态恢复失败提示。
  static String authRestoreFailed(Object error) => '恢复登录态失败：$error';

  /// 登录续期失败提示。
  static String authRefreshFailed(Object error) => '登录续期失败：$error';

  /// 登录续期缺少刷新令牌。
  static const String authRefreshTokenMissing = '当前会话缺少 refreshToken，无法自动续期。';

  /// 登录续期失败，请重新登录。
  static const String authRefreshRetry = '登录续期失败，请重新登录。';

  /// 登录续期接口缺少数据体。
  static const String authRefreshMissingData = '登录续期返回成功，但缺少 data 数据体。';

  /// 退出登录失败提示。
  static const String authLogoutFailed = '退出登录失败。';

  /// 账号或密码不正确提示。
  static const String authCredentialInvalid = '账号或密码不正确，请检查后重试。';

  /// 演示模式下不开放注册提示。
  static const String authRegisterUnavailableInMock =
      '当前为演示登录模式，注册入口仅在真实后端模式开放。';

  /// 注册规则说明。
  static const String authRegisterRules = '用户名需为 3-32 位字母、数字或下划线，密码需为 6-32 位。';

  /// 返回管理员显示名。
  static String authAdminDisplayName(String account) => '$account 管理员';

  /// 单图识别页标题。
  static const String detectPageTitle = '单图识别';

  /// 单图识别说明标题。
  static const String detectGuideTitle = '识别说明';

  /// 单图识别说明副标题。
  static const String detectGuideSubtitle =
      '当前仓库的 web 分支后端暂未提供 /api/v1/detect/image，页面保留为独立识别服务扩展位。';

  /// 单图识别模式标签：受控 mock。
  static const String detectMockModeChip = '受控 mock 链路';

  /// 单图识别模式标签：真实接口。
  static const String detectRealModeChip = '真实接口链路';

  /// 单图识别 mock 模式说明。
  static const String detectMockModeNotice =
      '当前默认使用受控 mock 打通选图、结果页和本地历史记录。后续独立识别服务并入后，再切回真实接口联调。';

  /// 单图识别真实模式说明。
  static const String detectRealModeNotice =
      '当前已切到真实识别模式；如果服务仍指向 web 分支后端，会因为缺少 /api/v1/detect/image 而失败。';

  /// 单图识别能力标签：本地选图。
  static const String detectGalleryChip = '支持本地选图';

  /// 单图识别能力标签：相机入口。
  static const String detectCameraChip = '支持相机入口';

  /// 单图识别能力标签：保存历史。
  static const String detectHistoryChip = '识别结果可保存为历史记录';

  /// 图片预览标题。
  static const String detectPreviewTitle = '图片预览';

  /// 图片预览副标题。
  static const String detectPreviewSubtitle =
      '桌面端拖拽入口已预留，这一轮先保证各平台都能通过文件选择进入识别。';

  /// 操作区标题。
  static const String detectActionsTitle = '操作区';

  /// 从相册选择。
  static const String detectPickFromGallery = '从相册选择';

  /// 使用相机。
  static const String detectPickFromCamera = '使用相机';

  /// 清空选择。
  static const String detectClearSelection = '清空选择';

  /// 开始识别。
  static const String detectStart = '开始识别';

  /// 识别中。
  static const String detectRunning = '识别中...';

  /// 识别未完成标题。
  static const String detectFailedTitle = '本次识别未完成';

  /// 重新识别。
  static const String detectRetry = '重新识别';

  /// 去选图片。
  static const String detectRepick = '去选图片';

  /// 重新选图。
  static const String detectRechoose = '重新选图';

  /// 预览空状态。
  static const String detectEmptyPreview = '请选择石斛图片后开始识别';

  /// 图片预览失败说明。
  static const String detectPreviewUnavailable = '当前平台无法预览该图片，但仍可继续发起识别。';

  /// 未选择图片提示。
  static const String detectSelectImageFirst = '请先选择一张石斛图片。';

  /// 当前文件信息。
  static String detectCurrentFile(String fileName) => '当前文件：$fileName';

  /// 识别失败提示。
  static String detectFailed(Object error) => '识别失败：$error';

  /// 读取图片失败提示。
  static String detectReadImageFailed(Object error) => '读取图片失败：$error';

  /// 启动初始化说明。
  static const String splashBootstrapping = '正在初始化环境配置、本地状态和演示信息...';

  /// 启动失败重试按钮。
  static const String splashRetry = '重试初始化';

  /// 启动失败提示。
  static String splashInitFailed(Object error) => '初始化失败：$error';

  /// 关于页标题。
  static const String aboutPageTitle = '关于项目';

  /// 关于页项目定位标题。
  static const String aboutProjectTitle = '项目定位';

  /// 关于页项目定位内容。
  static const String aboutProjectDescription =
      '是一个面向石斛幼苗培育场景的跨平台 Flutter 前端，用于承接登录、设备监控、状态展示、远程控制、识别扩展入口和运行环境配置。';

  /// 关于页技术基线标题。
  static const String aboutTechTitle = '当前技术基线';

  /// 关于页技术基线内容。
  static const String aboutTechDescription =
      'Flutter 全平台工程、OpenHarmony Flutter 3.35.7 模板、Material 3、GoRouter、Riverpod、Dio、SharedPreferences、FlutterSecureStorage，以及与 Spring Boot 后端的 HttpSession + Cookie 会话集成。';

  /// 关于页开发策略标题。
  static const String aboutStrategyTitle = '开发策略';

  /// 关于页开发策略内容。
  static const String aboutStrategyDescription =
      '当前优先保证登录、设备状态轮询、LED 控制和健康检查链路稳定，再继续并入独立识别服务，不再沿用过时文档中的假设接口。';

  /// 设置页标题。
  static const String settingsPageTitle = '运维设置';

  /// 设置页加载中提示。
  static const String settingsLoading = '正在加载设置...';

  /// 运行环境标题。
  static const String settingsOverviewTitle = '运行环境';

  /// 设置加载失败提示。
  static String settingsLoadFailed(Object error) => '设置加载失败：$error';

  /// 环境类型。
  static const String settingsEnvironmentType = '环境类型';

  /// 当前平台。
  static const String settingsCurrentPlatform = '当前平台';

  /// 应用版本。
  static const String settingsAppVersion = '应用版本';

  /// 服务配置标题。
  static const String settingsServiceConfigTitle = '服务配置';

  /// 服务健康检查标题。
  static const String settingsHealthTitle = '服务健康检查';

  /// 本地数据标题。
  static const String settingsLocalDataTitle = '本地数据';

  /// 登录会话标题。
  static const String settingsSessionTitle = '登录会话';

  /// 项目说明标题。
  static const String settingsProjectTitle = '平台说明';

  /// 退出登录标题。
  static const String settingsLogoutTitle = '退出登录';

  /// 退出登录确认提示。
  static const String settingsLogoutMessage =
      '退出后需要重新登录才能继续访问设备监控、远程控制和识别扩展入口，是否继续？';

  /// 确认退出登录按钮。
  static const String settingsLogoutConfirm = '确认退出';

  /// 清空历史记录标题。
  static const String settingsClearHistoryTitle = '清空历史记录';

  /// 清空历史记录确认提示。
  static const String settingsClearHistoryMessage = '该操作不可恢复，是否继续？';

  /// 历史记录已清空提示。
  static const String settingsHistoryCleared = '历史记录已清空。';

  /// 清空历史记录按钮。
  static const String settingsClearHistory = '清空历史记录';

  /// 恢复默认设置按钮。
  static const String settingsResetDefaults = '恢复默认设置';

  /// 修改服务地址标题。
  static const String settingsEditBaseUrlTitle = '修改 Base URL';

  /// 修改按钮。
  static const String settingsEdit = '修改';

  /// Base URL 字段标题。
  static const String settingsBaseUrl = 'Base URL';

  /// 连接超时字段标题。
  static const String settingsConnectTimeout = '连接超时';

  /// 接收超时字段标题。
  static const String settingsReceiveTimeout = '接收超时';

  /// 服务地址示例提示。
  static const String settingsBaseUrlHint = '例如：http://127.0.0.1:8082';

  /// 服务状态检查中提示。
  static const String settingsCheckingHealth = '正在检查服务状态...';

  /// 服务状态检查失败提示。
  static String settingsHealthCheckFailed(Object error) => '服务健康检查失败：$error';

  /// 重新检查按钮。
  static const String settingsRecheck = '重新检查';

  /// 服务正常。
  static const String settingsServiceUp = '服务正常';

  /// 服务不可用。
  static const String settingsServiceDown = '服务不可用';

  /// 服务未知。
  static const String settingsServiceUnknown = '服务未知';

  /// 模型就绪。
  static const String settingsModelReady = '模型就绪';

  /// 模型加载中。
  static const String settingsModelLoading = '模型加载中';

  /// 模型异常。
  static const String settingsModelError = '模型异常';

  /// 模型未知。
  static const String settingsModelUnknown = '模型未知';

  /// 当前未登录。
  static const String settingsUnauthenticated = '当前未登录。';

  /// 当前账号字段标题。
  static const String settingsCurrentAccount = '当前账号';

  /// 显示名称字段标题。
  static const String settingsDisplayName = '显示名称';

  /// 登录模式字段标题。
  static const String settingsLoginMode = '登录模式';

  /// 角色字段标题。
  static const String settingsRole = '角色';

  /// 到期时间字段标题。
  static const String settingsExpiry = '到期时间';

  /// 未返回到期时间。
  static const String settingsExpiryMissing = '未返回';

  /// 退出中。
  static const String settingsLoggingOut = '退出中...';

  /// 退出登录。
  static const String settingsLogout = '退出登录';

  /// 当前没有可用登录态。
  static const String settingsNoSession = '当前没有可用登录态。';

  /// 当前会话说明。
  static const String settingsSessionSubtitle = '用于展示当前账号、登录模式和会话到期时间。';

  /// 服务配置：开发/测试环境提示。
  static const String settingsServiceConfigEditable = '开发和测试环境允许调整服务地址。';

  /// 服务配置：正式环境提示。
  static const String settingsServiceConfigReadonly = '正式环境默认隐藏高风险配置项。';

  /// 本地数据说明。
  static const String settingsLocalDataSubtitle = '危险操作都必须显式确认，避免误删本地识别记录。';

  /// 运行环境说明。
  static const String settingsOverviewSubtitle = '优先确认当前环境、平台和版本，再进行接口联调与回归。';

  /// 健康检查说明。
  static const String settingsHealthSubtitle = '用于联调和排障，可手动刷新当前服务状态。';

  /// 服务名称字段标题。
  static const String settingsServiceName = '服务名称';

  /// 服务版本字段标题。
  static const String settingsServiceVersion = '服务版本';

  /// 服务时间字段标题。
  static const String settingsServiceTime = '服务时间';
}
