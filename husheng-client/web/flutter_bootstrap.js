{{flutter_js}}
{{flutter_build_config}}

(function bootstrapFlutterApp() {
  const renderStartupError = window.__renderStartupError;
  const hideBootShell = window.__hideBootShell;
  const setBootShellStatus = window.__setBootShellStatus;

  function reportFailure(title, error) {
    if (typeof renderStartupError === 'function') {
      const detail =
        error && typeof error === 'object' && 'stack' in error
          ? error.stack
          : String(error ?? 'Unknown startup error');
      renderStartupError(title, detail);
      return;
    }
    throw error;
  }

  async function unregisterServiceWorkers() {
    if (!('serviceWorker' in navigator)) {
      return;
    }

    try {
      const registrations = await navigator.serviceWorker.getRegistrations();
      await Promise.all(
        registrations.map((registration) => registration.unregister()),
      );
    } catch (error) {
      console.warn('Failed to clear service workers before boot.', error);
    }
  }

  setBootShellStatus?.('正在校验本地缓存并准备 Flutter 运行时。');

  unregisterServiceWorkers()
    .then(() => {
      setBootShellStatus?.('正在加载界面引擎与静态资源。');

      _flutter.loader.load({
        config: {
          canvasKitBaseUrl: 'canvaskit/',
        },
        onEntrypointLoaded: async function onEntrypointLoaded(
          engineInitializer,
        ) {
          try {
            setBootShellStatus?.('正在初始化应用界面。');
            const appRunner = await engineInitializer.initializeEngine();
            hideBootShell?.();
            await appRunner.runApp();
          } catch (error) {
            reportFailure('应用启动失败', error);
          }
        },
      });
    })
    .catch((error) => {
      reportFailure('应用启动失败', error);
    });
})();
