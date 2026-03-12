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
  static const String viewAboutProject = '查看使用说明';

  /// 首页模块标题。
  static const String homeCrossPlatformDemo = '监测值守中枢';

  /// 首页主说明。
  static const String homeOverview =
      '当前版本围绕账号认证、设备监控、LED 控制和运维自检构建统一工作闭环，所有主入口都对准后端当前真实可用的业务能力。';

  /// 首页入口“系统总览”标题。
  static const String homePreviewTitle = '使用说明';

  /// 首页入口“系统总览”副标题。
  static const String homePreviewSubtitle = '快速了解页面怎么用。';

  /// 首页入口“实时监测”标题。
  static const String homeRealtimeTitle = '值守台';

  /// 首页入口“实时监测”副标题。
  static const String homeRealtimeSubtitle = '查看实时状态，必要时处理补光。';

  /// 首页入口“设置”标题。
  static const String homeSettingsTitle = '我的';

  /// 首页入口“设置”副标题。
  static const String homeSettingsSubtitle = '管理账号、设备和本机偏好。';

  /// 首页能力标签：统一工作台。
  static const String homeMaterialPill = '统一工作台';

  /// 返回首页版本标签。
  static String homeVersionPill(String version) => '版本 $version';

  /// 登录页主说明。
  static const String authLoginOverview =
      '使用账号和密码登录后即可进入石斛监测后台，系统会自动保持当前会话，减少值守期间的重复登录。';

  /// 登录页能力标签：自动恢复。
  static const String authRestoreChip = '会话自动恢复';

  /// 登录页能力标签：401 回退。
  static const String authUnauthorizedChip = '失效自动返回登录';

  /// 登录页能力标签：会话 Cookie。
  static const String authSessionChip = '自动保持登录';

  /// 登录页能力标签：真实接口注册。
  static const String authRegisterChip = '账号在线开通';

  /// 联调登录模式标题。
  static const String authMockModeTitle = '演示环境';

  /// 联调账号说明。
  static const String authMockAccountHint =
      '演示账号：demo\n演示密码：demo123456\n用于体验登录流程，不会影响在线设备。';

  /// 联调账号显示名。
  static const String authMockDisplayName = '演示账号';

  /// 填充联调账号按钮文案。
  static const String authFillDemoAccount = '填入演示账号';

  /// 在线服务注册面板标题。
  static const String authRegisterPanelTitle = '账号开通';

  /// 在线服务注册面板说明。
  static const String authRegisterPanelDescription =
      '当前账号支持在线开通，开通完成后即可回到登录表单继续进入监测后台。';

  /// 登录页服务信息标题。
  static const String authServicePanelTitle = '服务接入';

  /// 登录页设备服务字段标题。
  static const String authDeviceServiceLabel = '服务地址';

  /// 登录页服务地址恢复按钮。
  static const String authResetServiceConfig = '恢复默认服务地址';

  /// 登录页服务地址恢复成功提示。
  static const String authResetServiceConfigSuccess = '已恢复默认服务地址，请重新尝试登录。';

  /// 登录页自定义服务地址提示。
  static const String authCustomServiceConfigHint =
      '当前检测到自定义服务地址。如果这不是你主动切换的后端，请先恢复默认地址再重试。';

  /// 登录页默认服务地址提示。
  static const String authDefaultServiceConfigHint =
      '当前已使用默认服务地址。若登录仍失败，优先检查网络连通性和后端服务状态。';

  /// 登录卡片标题。
  static const String authLoginCardTitle = '平台登录';

  /// 登录页模式切换：登录。
  static const String authLoginTab = '登录';

  /// 登录页模式切换：注册。
  static const String authRegisterTab = '注册';

  /// 用户名输入框标签。
  static const String authUsernameLabel = '账号';

  /// 用户名输入框占位。
  static const String authUsernameHint = '例如：root';

  /// 密码输入框标签。
  static const String authPasswordLabel = '密码';

  /// 真实接口模式密码占位。
  static const String authPasswordHint = '请输入密码';

  /// 联调接口模式密码占位。
  static const String authMockPasswordHint = '演示密码或 6 位以上自定义密码';

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

  /// 请输入用户名密码提示。
  static const String authInputRequired = '请输入账号和密码。';

  /// 请输入注册所需字段提示。
  static const String authRegisterInputRequired = '请输入账号、密码和确认密码。';

  /// 注册时两次密码不一致提示。
  static const String authRegisterPasswordMismatch = '两次输入的密码不一致，请重新输入。';

  /// 注册用户名格式不符合后端约束提示。
  static const String authRegisterAccountInvalid =
      '账号格式不正确，只能包含字母、数字和下划线，长度需在 3 到 32 位之间。';

  /// 注册密码长度不符合后端约束提示。
  static const String authRegisterPasswordLengthInvalid =
      '密码长度需在 6 到 32 位之间，请检查后重试。';

  /// 返回当前登录模式文案。
  static String authCurrentMode(String loginModeLabel) =>
      '当前模式：$loginModeLabel';

  /// 通用登录失败提示。
  static String authLoginFailed([Object? error]) => authLoginFailedRetry;

  /// 通用注册失败提示。
  static String authRegisterFailed([Object? error]) => authRegisterFailedRetry;

  /// 登录失败，请稍后重试。
  static const String authLoginFailedRetry = '登录失败，请稍后重试。';

  /// 注册失败，请稍后重试。
  static const String authRegisterFailedRetry = '注册失败，请稍后重试。';

  /// 登录接口缺少数据体。
  static const String authLoginMissingData = '登录接口返回成功，但缺少 data 数据体。';

  /// 注册成功缺省提示。
  static const String authRegisterSuccessDefault = '注册成功，请使用新账号登录。';

  /// 登录态恢复失败提示。
  static String authRestoreFailed([Object? error]) => '恢复登录状态失败，请刷新页面后重试。';

  /// 登录续期失败提示。
  static String authRefreshFailed([Object? error]) => '登录状态校验失败，请重新登录。';

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
  static const String authRegisterUnavailableInMock = '当前为演示环境，账号开通仅在在线服务模式开放。';

  /// 注册规则说明。
  static const String authRegisterRules = '账号需为 3-32 位字母、数字或下划线；密码需为 6-32 位。';

  /// 返回管理员显示名。
  static String authAdminDisplayName(String account) => '$account 管理员';

  /// 实时主控台前往总览按钮。
  static const String realtimeOpenOverview = '总览';

  /// 实时主控台前往设置按钮。
  static const String realtimeOpenSettings = '我的';

  /// 启动初始化说明。
  static const String splashBootstrapping = '正在初始化环境配置、本地状态和账号信息...';

  /// 启动失败重试按钮。
  static const String splashRetry = '重试初始化';

  /// 启动失败提示。
  static String splashInitFailed(Object error) => '初始化失败：$error';

  /// 系统总览页标题。
  static const String aboutPageTitle = '使用说明';

  /// 系统总览页平台定位标题。
  static const String aboutProjectTitle = '平台定位';

  /// 系统总览页平台定位内容。
  static const String aboutProjectDescription =
      '是一个面向石斛幼苗培育场景的统一管理软件，用于承接登录认证、设备监控、状态展示、远程控制和运行环境配置。';

  /// 系统总览页系统基线标题。
  static const String aboutTechTitle = '系统基线';

  /// 系统总览页系统基线内容。
  static const String aboutTechDescription =
      '账号认证、设备状态查看、补光控制、服务巡检和本地配置围绕同一套后台协同工作，避免值守时在多个工具之间来回切换。';

  /// 系统总览页建设策略标题。
  static const String aboutStrategyTitle = '建设策略';

  /// 系统总览页建设策略内容。
  static const String aboutStrategyDescription =
      '当前优先保证登录、设备状态轮询、补光控制和健康检查链路稳定，让进入页面后的主要动作都能直接落到真实设备服务。';

  /// 设置页标题。
  static const String settingsPageTitle = '我的';

  /// 设置页加载中提示。
  static const String settingsLoading = '正在加载设置...';

  /// 运行环境标题。
  static const String settingsOverviewTitle = '当前设备';

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
  static const String settingsLocalDataTitle = '本地偏好';

  /// 登录会话标题。
  static const String settingsSessionTitle = '当前账号';

  /// 项目说明标题。
  static const String settingsProjectTitle = '系统概览';

  /// 退出登录标题。
  static const String settingsLogoutTitle = '退出登录';

  /// 退出登录确认提示。
  static const String settingsLogoutMessage = '退出后需要重新登录才能继续使用，是否继续？';

  /// 确认退出登录按钮。
  static const String settingsLogoutConfirm = '确认退出';

  /// 恢复默认设置按钮。
  static const String settingsResetDefaults = '恢复默认';

  /// 恢复默认设置确认标题。
  static const String settingsResetDefaultsTitle = '恢复默认';

  /// 恢复默认设置确认说明。
  static const String settingsResetDefaultsMessage =
      '恢复后会清空当前设备上的本机偏好并回到默认状态，是否继续？';

  /// 恢复默认设置完成提示。
  static const String settingsResetDefaultsDone = '已恢复默认。';

  /// 修改设备服务地址标题。
  static const String settingsEditBaseUrlTitle = '修改设备服务地址';

  /// 修改按钮。
  static const String settingsEdit = '修改';

  /// 设备服务地址字段标题。
  static const String settingsDeviceBaseUrl = '设备服务地址';

  /// 连接超时字段标题。
  static const String settingsConnectTimeout = '连接超时';

  /// 接收超时字段标题。
  static const String settingsReceiveTimeout = '接收超时';

  /// 设备服务地址示例提示。
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

  /// 健康检查原始响应字段标题。
  static const String settingsHealthResponse = '接口响应';

  /// 健康检查完成时间字段标题。
  static const String settingsHealthCheckedAt = '检查时间';

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
  static const String settingsSessionSubtitle = '查看当前登录账号，并在需要时退出。';

  /// 服务配置：开发/测试环境提示。
  static const String settingsServiceConfigEditable =
      '当前构建允许调整设备服务地址，修改后会立即影响登录、巡检和设备控制链路。';

  /// 服务配置：正式环境提示。
  static const String settingsServiceConfigReadonly = '正式环境默认隐藏高风险配置项。';

  /// 本地数据说明。
  static const String settingsLocalDataSubtitle = '这里只保留账号回填和恢复默认这两个本机操作。';

  /// 运行环境说明。
  static const String settingsOverviewSubtitle = '这里只保留当前设备状态和最近同步。';

  /// 健康检查说明。
  static const String settingsHealthSubtitle =
      '当前后端只返回 `/api/health` 的原始结果，页面仅展示真实响应和检查时间。';

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
