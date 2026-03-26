/// 认证入口表单模式。
enum AuthFormMode {
  /// 登录模式。
  login,

  /// 注册模式。
  register,
}

/// 为认证表单模式提供派生判断。
extension AuthFormModeX on AuthFormMode {
  /// 当前是否为注册模式。
  bool get isRegister => this == AuthFormMode.register;
}
