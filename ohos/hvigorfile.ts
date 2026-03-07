
import path from 'path'
import { appTasks } from '@ohos/hvigor-ohos-plugin';
import { flutterHvigorPlugin } from 'flutter-hvigor-plugin';

export default {
    system: appTasks,  /* Hvigor 内置插件，不允许修改。 */
    plugins:[flutterHvigorPlugin(path.dirname(__dirname))]         /* 用于扩展 Hvigor 能力的自定义插件。 */
}
