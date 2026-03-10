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

  /// 通用系统总览入口文案。
  static const String viewAboutProject = '查看系统总览';

  /// 首页模块标题。
  static const String homeCrossPlatformDemo = '培育运营中枢';

  /// 首页主说明。
  static const String homeOverview =
      '当前版本围绕账号认证、视频流接入、环境监测、风险预警、远程执行和运维自检构建统一工作闭环，所有主入口都对准当前版本可直接使用的业务能力。';

  /// 首页入口“系统总览”标题。
  static const String homePreviewTitle = '系统总览';

  /// 首页入口“系统总览”副标题。
  static const String homePreviewSubtitle = '查看平台定位、设备架构、栽培背景和调控目标。';

  /// 首页入口“开始识别”标题。
  static const String homeDetectTitle = '单图识别';

  /// 首页入口“开始识别”副标题。
  static const String homeDetectSubtitle =
      '当前后端未提供 `/api/v1/detect/image`，该入口先收口为独立识别服务扩展位。';

  /// 首页入口“实时监测”标题。
  static const String homeRealtimeTitle = '监控主控台';

  /// 首页入口“实时监测”副标题。
  static const String homeRealtimeSubtitle =
      '持续同步设备环境、异常等级和补光控制状态，作为值守与处置的核心入口。';

  /// 首页入口“视频中心”标题。
  static const String homeVideoTitle = '视频中心';

  /// 首页入口“视频中心”副标题。
  static const String homeVideoSubtitle = '查看视频流清单、单路详情、播放地址与 AI 转发状态。';

  /// 首页入口“历史记录”标题。
  static const String homeHistoryTitle = '识别历史';

  /// 首页入口“历史记录”副标题。
  static const String homeHistorySubtitle = '识别服务接入后，这里将承接本地保存的结果记录与详情浏览。';

  /// 首页入口“设置”标题。
  static const String homeSettingsTitle = '运维设置';

  /// 首页入口“设置”副标题。
  static const String homeSettingsSubtitle = '管理服务地址、健康检查、登录会话和本机数据。';

  /// 首页扩展位区标题。
  static const String homeExtensionTitle = '后续扩展能力';

  /// 首页扩展位区说明。
  static const String homeExtensionSubtitle =
      '以下入口保留给独立识别服务并入后的能力扩展，当前不会作为主工作台能力开放。';

  /// 首页扩展位状态标签。
  static const String homeExtensionBadge = '待独立识别服务接入';

  /// 首页能力标签：统一工作台。
  static const String homeMaterialPill = '统一工作台';

  /// 首页能力标签：Riverpod。
  static const String homeRiverpodPill = '状态分层';

  /// 首页能力标签：本地历史记录。
  static const String homeHistoryPill = '本地数据沉淀';

  /// 返回首页版本标签。
  static String homeVersionPill(String version) => '版本 $version';

  /// 登录页主说明。
  static const String authLoginOverview =
      '登录或注册后可进入设备监控主控台，查看设备状态、提交补光指令，并在运维设置中完成健康检查与环境排查。';

  /// 登录页能力标签：自动恢复。
  static const String authRestoreChip = '会话自动恢复';

  /// 登录页能力标签：401 回退。
  static const String authUnauthorizedChip = '状态失效自动回退';

  /// 登录页能力标签：自动附带 Token。
  static const String authTokenChip = '会话自动续用';

  /// 登录页能力标签：真实接口注册。
  static const String authRegisterChip = '账号在线开通';

  /// 联调登录模式标题。
  static const String authMockModeTitle = '当前为联调登录模式';

  /// 联调账号说明。
  static const String authMockAccountHint = '联调账号：demo\n联调密码：demo123456';

  /// 联调账号显示名。
  static const String authMockDisplayName = '联调账号';

  /// 填充联调账号按钮文案。
  static const String authFillDemoAccount = '填充联调账号';

  /// 在线服务注册面板标题。
  static const String authRegisterPanelTitle = '在线账号开通';

  /// 在线服务注册面板说明。
  static const String authRegisterPanelDescription =
      '当前账号可直接在线开通，开通完成后回到登录表单即可继续进入系统。';

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

  /// 联调接口模式密码占位。
  static const String authMockPasswordHint = '联调密码或 6 位以上自定义密码';

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

  /// 联调模式下不开放注册提示。
  static const String authRegisterUnavailableInMock =
      '当前为联调登录模式，账号开通仅在在线服务模式开放。';

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

  /// 单图识别未接入标题。
  static const String detectUnavailableTitle = '识别服务暂未并入当前后端';

  /// 单图识别未接入说明。
  static const String detectUnavailableMessage =
      '当前工作区后端只覆盖登录、设备状态、LED 控制和健康检查；`/api/v1/detect/image` 对应的独立识别服务尚未并入，因此客户端默认不开放单图识别主链路。';

  /// 单图识别未接入补充说明。
  static const String detectUnavailableFootnote =
      '后续识别服务并入后，可直接复用现有结果页、历史记录模型和仓储分层继续联调。';

  /// 单图识别未接入返回总览按钮。
  static const String detectBackToOverview = '返回平台总览';

  /// 单图识别未接入前往主控台按钮。
  static const String detectGoRealtime = '前往监控主控台';

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

  /// 历史记录空态说明，当前后端未接入识别服务。
  static const String historyEmptyWithoutDetect =
      '当前后端未接入识别服务，本地暂无结果记录。后续独立识别服务并入后，这里会展示已保存的识别结果。';

  /// 实时主控台前往总览按钮。
  static const String realtimeOpenOverview = '平台总览';

  /// 实时主控台前往设置按钮。
  static const String realtimeOpenSettings = '运维设置';

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
  static const String splashBootstrapping = '正在初始化环境配置、本地状态和账号信息...';

  /// 启动失败重试按钮。
  static const String splashRetry = '重试初始化';

  /// 启动失败提示。
  static String splashInitFailed(Object error) => '初始化失败：$error';

  /// 系统总览页标题。
  static const String aboutPageTitle = '系统总览';

  /// 系统总览页平台定位标题。
  static const String aboutProjectTitle = '平台定位';

  /// 系统总览页平台定位内容。
  static const String aboutProjectDescription =
      '是一个面向石斛幼苗培育场景的统一管理软件，用于承接登录认证、设备监控、状态展示、远程控制、识别扩展入口和运行环境配置。';

  /// 系统总览页系统基线标题。
  static const String aboutTechTitle = '系统基线';

  /// 系统总览页系统基线内容。
  static const String aboutTechDescription =
      '跨平台客户端工程、OpenHarmony 工程接入、统一路由、状态管理、网络封装、本地持久化，以及与设备服务的 HttpSession + Cookie 会话集成。';

  /// 系统总览页建设策略标题。
  static const String aboutStrategyTitle = '建设策略';

  /// 系统总览页建设策略内容。
  static const String aboutStrategyDescription =
      '当前优先保证登录、设备状态轮询、LED 控制和健康检查链路稳定，再继续并入独立识别服务，不再沿用过时文档中的假设接口。';

  /// 视频中心页标题。
  static const String videoPageTitle = '视频中心';

  /// 视频中心页副标题。
  static const String videoPageSubtitle =
      '统一查看视频流清单、单路详情与播放入口，客户端只消费元数据，不代理媒体流。';

  /// 视频中心主视觉标签。
  static const String videoHeroBadge = '视频直连工作台';

  /// 视频中心主视觉说明。
  static const String videoHeroDescription =
      '视频流由 Java 服务统一编排，客户端只消费元数据并调起外部播放入口，媒体链路仍保持直连网关。';

  /// 视频中心加载中提示。
  static const String videoLoading = '正在同步视频流清单...';

  /// 视频中心空态标题。
  static const String videoEmptyTitle = '当前没有可展示的视频流';

  /// 视频中心空态说明。
  static const String videoEmptyMessage =
      '视频服务已返回成功，但数据列表为空。请检查 Java 服务是否已经登记视频流信息。';

  /// 视频服务异常标题。
  static const String videoServiceErrorTitle = '视频服务暂未就绪';

  /// 视频服务异常副标题。
  static const String videoServiceErrorSubtitle =
      '客户端已接入视频模块，但需要 Java 视频服务稳定返回流清单后才能展示。';

  /// 视频服务异常说明。
  static String videoServiceErrorMessage(Object error) => '视频服务返回失败：$error';

  /// 视频流筛选区标题。
  static const String videoFilterTitle = '快速定位';

  /// 视频流检索占位提示。
  static const String videoSearchHint = '按流标识、设备标识或名称检索';

  /// 视频流筛选标签：全部。
  static const String videoFilterAll = '全部流';

  /// 视频流筛选标签：仅在线。
  static const String videoFilterAvailable = '仅在线';

  /// 视频流筛选标签：已转发 AI。
  static const String videoFilterAiForwarded = '已转发 AI';

  /// 当前筛选结果计数。
  static String videoVisibleCount(int visibleCount, int totalCount) =>
      '当前展示 $visibleCount / $totalCount';

  /// 视频流经过筛选后为空的标题。
  static const String videoFilteredEmptyTitle = '没有符合当前筛选条件的视频流';

  /// 视频流经过筛选后为空的说明。
  static const String videoFilteredEmptyMessage =
      '可以尝试清空检索词或切回全部流，查看当前服务返回的完整视频流清单。';

  /// 复制接口地址按钮。
  static const String videoCopyServiceUrl = '复制接口地址';

  /// 视频流详情页标题。
  static const String videoDetailPageTitle = '流详情';

  /// 视频流详情加载提示。
  static const String videoDetailLoading = '正在同步视频流详情...';

  /// 返回视频中心按钮。
  static const String videoBackToHub = '返回视频中心';

  /// 打开播放入口按钮。
  static const String videoOpenPlayer = '打开播放页';

  /// 复制播放入口按钮。
  static const String videoCopyPlayer = '复制播放页';

  /// 打开网关入口按钮。
  static const String videoOpenGateway = '打开网关页';

  /// 复制网关入口按钮。
  static const String videoCopyGateway = '复制网关页';

  /// 打开视频流详情按钮。
  static const String videoOpenDetail = '查看详情';

  /// 外部浏览器打开成功提示。
  static const String videoOpenedExternal = '已拉起外部浏览器。';

  /// 服务地址复制成功提示。
  static const String videoServiceUrlCopied = '已复制视频服务接口地址。';

  /// 链接复制成功提示。
  static String videoCopied(String copiedLabel) => '已复制$copiedLabel链接。';

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
  static const String settingsLocalDataTitle = '本机数据';

  /// 登录会话标题。
  static const String settingsSessionTitle = '登录会话';

  /// 项目说明标题。
  static const String settingsProjectTitle = '系统总览';

  /// 退出登录标题。
  static const String settingsLogoutTitle = '退出登录';

  /// 退出登录确认提示。
  static const String settingsLogoutMessage = '退出后需要重新登录才能继续访问设备监控和运维功能，是否继续？';

  /// 确认退出登录按钮。
  static const String settingsLogoutConfirm = '确认退出';

  /// 清理识别历史标题。
  static const String settingsClearHistoryTitle = '清理识别历史';

  /// 清理识别历史确认提示。
  static const String settingsClearHistoryMessage =
      '该操作会删除本机已保存的历史识别记录，且不可恢复，是否继续？';

  /// 识别历史已清理提示。
  static const String settingsHistoryCleared = '识别历史已清理。';

  /// 清理识别历史按钮。
  static const String settingsClearHistory = '清理识别历史';

  /// 恢复默认设置按钮。
  static const String settingsResetDefaults = '恢复默认设置';

  /// 修改服务地址标题。
  static const String settingsEditBaseUrlTitle = '修改服务地址';

  /// 修改按钮。
  static const String settingsEdit = '修改';

  /// 服务地址字段标题。
  static const String settingsBaseUrl = '服务地址';

  /// 连接超时字段标题。
  static const String settingsConnectTimeout = '连接超时';

  /// 接收超时字段标题。
  static const String settingsReceiveTimeout = '接收超时';

  /// 服务地址示例提示。
  static const String settingsBaseUrlHint = '例如：http://101.35.79.76:8082';

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
  static const String settingsLocalDataSubtitle =
      '用于管理当前设备上的账号回填与本地配置，危险操作都需要显式确认。';

  /// 运行环境说明。
  static const String settingsOverviewSubtitle = '优先确认当前环境、平台和版本，再进行巡检和排障。';

  /// 健康检查说明。
  static const String settingsHealthSubtitle = '用于运行巡检与排障，可手动刷新当前服务状态。';

  /// 服务名称字段标题。
  static const String settingsServiceName = '服务名称';

  /// 服务版本字段标题。
  static const String settingsServiceVersion = '服务版本';

  /// 服务时间字段标题。
  static const String settingsServiceTime = '服务时间';

  /// 记住账号字段标题。
  static const String settingsRememberedAccount = '记住的账号';

  /// 未保存记住账号。
  static const String settingsRememberedAccountMissing = '当前未保存';

  /// 清除记住账号标题。
  static const String settingsClearRememberedAccountTitle = '清除记住的账号';

  /// 清除记住账号确认提示。
  static const String settingsClearRememberedAccountMessage =
      '清除后，登录页将不再自动回填账号，是否继续？';

  /// 已清除记住账号提示。
  static const String settingsRememberedAccountCleared = '已清除记住的账号。';

  /// 清除记住账号按钮。
  static const String settingsClearRememberedAccount = '清除记住账号';
}
