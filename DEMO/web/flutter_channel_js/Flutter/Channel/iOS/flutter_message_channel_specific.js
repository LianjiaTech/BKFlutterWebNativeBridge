/**
 * flutter注册通道handler
 * @param  {[type]} channel_name 通道名称
 * @param  {[type]} handler_name 统一处理器
 */
function lianjia_message_channel_register_by_flutter(channel_name, handler_name) {
    var _func = 'lianjia_method_channel_register_by_flutter';

    console.groupCollapsed(`[${_func}] 通道:${channel_name} 注册handler...`);
    console.log(`handler_name: ${handler_name}`);

    //查找通道。未找到通道则结束
    var channel = window[channel_name];
    if(channel) {
        console.log(`找到通道`);
    } else {
        console.error(`未找到通道`);
        console.groupEnd();
        return;
    }

    //查找函数。未找到函数则结束
    var handler = channel[handler_name];
    if(handler) {
        console.log(`找到handler`);
    } else {
        console.error(`未找到handler`);
        console.groupEnd();
        return;
    }

    //注册桥接
    var bridge_handler_name = channel_name + '.' + handler_name;
    console.log(`桥接handler名称: ${bridge_handler_name}`);

    console.groupEnd();

    window.setupWebViewJavascriptBridge((bridge) => {
        bridge.registerHandler(bridge_handler_name, (request/*BridgeData*/, callback) => {
            var method_name = request.method;
            var args = request.args;
            var type = request.type;
            var callback_name = bridge_handler_name + '.' + method_name + '.callback';

            console.groupCollapsed(`[${_func}] 通道:${channel_name} 调用:${handler_name} ...`);
            console.log(`method: ${method_name}`);
            console.log(`args: ${args}`);
            console.log(`type: ${type}`);
            console.log(`通道handler回调: ${callback_name}`);
            console.log(`native...->flutter`);
            console.groupEnd();

            //在channel中绑定回调
            channel[callback_name] = (method_name, args, type) => {
                console.groupCollapsed(`[${_func}] 通道:${channel_name} 响应:${handler_name} ...`);
                console.log(`method: ${method_name}`);
                console.log(`args: ${args}`);
                console.log(`type: ${type}`);
                console.log(`flutter...->native`);
                console.groupEnd();

                const response = window._lianjia_pack_flutter_data(method_name, args, type);
                callback(response);
            };
            handler(method_name, args, type, callback_name);
        });
    });
}

/**
 * native注册通道handler
 * @param  {[type]} channel_name 通道名称
 * @param  {[type]} handler_name handler名称
 */
function lianjia_message_channel_register_by_native(channel_name, handler_name) {
    var _func = 'lianjia_method_channel_register_by_native';

    console.groupCollapsed(`[${_func}] 通道:${channel_name} 注册handler...`);
    console.log(`handler_name: ${handler_name}`);

    //查找通道。未找到通道则结束
    var channel = window[channel_name];
    if(channel) {
        console.log(`找到通道`);
    } else {
        console.error(`未找到通道`);
        console.groupEnd();
        return;
    }

    //查找handler
    if(channel[handler_name]) {
        console.log(`找到handler`);
    } else {
        console.log(`未找到handler`);
    }

    //注册函数
    channel[handler_name] = (method_name, args, type) => {
        const bridge_handler_name = channel_name + '.' + handler_name;

        console.groupCollapsed(`[${_func}] 通道:${channel_name} 调用:${handler_name} ...`);
        console.log(`method: ${method_name}`);
        console.log(`args: ${args}`);
        console.log(`type: ${type}`);
        console.log(`桥接handler名称: ${bridge_handler_name}`);
        console.log(`flutter...->native`);
        console.groupEnd();

        const request = window._lianjia_pack_flutter_data(method_name, args, type);
        return new Promise((resolve, reject) => {
            window.setupWebViewJavascriptBridge((bridge) => {
                bridge.callHandler(bridge_handler_name, request, (response/*BridgeData*/) => {
                    var method_name = response.method;
                    var args = response.args;
                    var type = response.type;

                    console.groupCollapsed(`[${_func}] 通道:${channel_name} 响应:${handler_name} ...`);
                    console.log(`method: ${method_name}`);
                    console.log(`args: ${args}`);
                    console.log(`type: ${type}`);
                    console.log(`native...->flutter`);
                    console.groupEnd();

                    resolve(response);
                });
            });
        });
    }

    console.log(`注册完成`);
    console.groupEnd();
}
