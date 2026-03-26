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
  static const String viewAboutProject = '打开使用帮助';

  /// 首页模块标题。
  static const String homeCrossPlatformDemo = '监测值守中枢';

  /// 首页主说明。
  static const String homeOverview =
      '当前版本围绕账号认证、设备监控、LED 控制和运维自检构建统一工作闭环，所有主入口都对准后端当前真实可用的业务能力。';

  /// 首页入口“视频中心”标题。
  static const String homePreviewTitle = '视频中心';

  /// 首页入口“视频中心”副标题。
  static const String homePreviewSubtitle = '查看实时画面并直接打开观看。';

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

  /// 当前平台不支持持久化登录态提示。
  static const String authSessionPersistenceNotice =
      '当前平台暂不支持安全保存登录状态，关闭应用或系统回收进程后需要重新登录。';

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

  /// 登录页界面预览入口标题。
  static const String authPreviewEntryTitle = '界面预览入口';

  /// 登录页界面预览入口说明。
  static const String authPreviewEntryDescription =
      '后端暂时不可用时，也能先查看总览、值守、视频和我的的完整界面编排。';

  /// 登录页进入界面预览按钮。
  static const String authPreviewEnter = '直接预览界面';

  /// 使用帮助页界面预览按钮。
  static const String aboutPreviewEnter = '打开界面预览';

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
  static const String splashBootstrapping = '正在准备页面、本机设置和当前账号信息。';

  /// 启动失败重试按钮。
  static const String splashRetry = '重试初始化';

  /// 启动失败提示。
  static String splashInitFailed(Object error) => '初始化失败：$error';

  /// 系统帮助页标题。
  static const String aboutPageTitle = '使用帮助';

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

  /// 当前使用概览标题。
  static const String settingsOverviewTitle = '当前使用';

  /// 设置加载失败提示。
  static String settingsLoadFailed(Object error) => '设置加载失败：$error';

  /// 设置页账号与本机卡标题。
  static const String settingsProfileTitle = '账号与本机';

  /// 设置页账号与本机卡说明。
  static const String settingsProfileSubtitle = '把当前账号、记住账号和常用操作收在同一处处理。';

  /// 设置页常用操作标题。
  static const String settingsActionsTitle = '常用操作';

  /// 设置页常用操作说明。
  static const String settingsActionsHint = '常用操作收在这里，避免页面里再拆出多张独立功能卡。';

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

  /// 当前未登录。
  static const String settingsUnauthenticated = '当前未登录。';

  /// 当前账号字段标题。
  static const String settingsCurrentAccount = '当前账号';

  /// 当前账号说明。
  static const String settingsProfileAccountHint = '当前保持登录状态，需要更换账号时再从这里退出。';

  /// 账号操作处理中提示。
  static const String settingsProfileStatusSubmitting = '正在处理账号操作。';

  /// 登录态可继续使用提示。
  static const String settingsProfileStatusReady = '当前已登录，可以直接继续使用。';

  /// 本机支持长期保持时的说明。
  static const String settingsProfilePersistenceSupportedHint =
      '本机支持长期保存登录态和回填信息。';

  /// 本机安全存储能力受限时的说明。
  static const String settingsProfilePersistenceLimitedHint =
      '本机安全存储能力受限，需要关注登录态保留方式。';

  /// 退出中。
  static const String settingsLoggingOut = '退出中...';

  /// 退出登录。
  static const String settingsLogout = '退出登录';

  /// 当前平台登录态不会持久化提示标题。
  static const String settingsSessionPersistenceWarningTitle = '本机不会长期保留登录状态';

  /// 当前平台登录态不会持久化提示内容。
  static const String settingsSessionPersistenceWarningMessage =
      '当前平台暂不支持安全保存登录状态。关闭应用、清理后台或系统回收进程后，需要重新登录。';

  /// 设置页界面预览提示。
  static const String settingsPreviewModeNotice =
      '当前为界面预览，设备状态、视频和服务结果使用本地样例数据，不依赖在线接口。';

  /// 记住账号字段标题。
  static const String settingsRememberedAccount = '记住的账号';

  /// 未保存记住账号。
  static const String settingsRememberedAccountMissing = '当前未保存';

  /// 已保存记住账号时的说明。
  static const String settingsRememberedAccountSavedHint =
      '当前设备会在下次登录时自动回填这个账号。';

  /// 未保存记住账号时的说明。
  static const String settingsRememberedAccountEmptyHint =
      '当前没有保存登录账号，需要时可以重新勾选记住账号。';

  /// 清除记住账号标题。
  static const String settingsClearRememberedAccountTitle = '清除记住的账号';

  /// 清除记住账号确认提示。
  static const String settingsClearRememberedAccountMessage =
      '清除后，登录页将不再自动回填账号，是否继续？';

  /// 已清除记住账号提示。
  static const String settingsRememberedAccountCleared = '已清除记住的账号。';

  /// 清除记住账号按钮。
  static const String settingsClearRememberedAccount = '清除记住账号';

  /// 软件内视频播放页标题。
  static const String videoPlaybackInlineTitle = '软件内实时画面';

  /// 软件内视频播放页副标题。
  static const String videoPlaybackInlineSubtitle =
      '当前已切换到软件内播放页，画面和备用入口都在应用内打开。';

  /// 视频播放页加载中提示。
  static const String videoPlaybackLoading = '正在载入画面...';

  /// 视频播放页加载失败标题。
  static const String videoPlaybackLoadFailed = '画面载入失败';

  /// 视频播放页地址无效提示。
  static const String videoPlaybackAddressInvalid = '画面地址无效';

  /// 视频播放页地址无效补充说明。
  static const String videoPlaybackAddressHint = '当前接口没有返回可用的播放地址，请稍后刷新后重试。';

  /// 当前平台不支持软件内播放标题。
  static const String videoPlaybackUnsupportedTitle = '当前平台暂不支持软件内查看';

  /// 当前平台不支持软件内播放说明。
  static const String videoPlaybackUnsupportedMessage =
      '当前平台还没有接入软件内视频能力。请优先在 Android、iOS、macOS、Windows、Linux 或 Web 端使用视频中心。';
}
