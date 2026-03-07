
// 用于声明构建行为的脚本，当前由构建插件托管。
import { hapTasks } from '@ohos/hvigor-ohos-plugin';
export default {
    system: hapTasks,  /* Hvigor 内置插件，不允许修改。 */
    plugins: []        /* 用于扩展 Hvigor 能力的自定义插件。 */
}
