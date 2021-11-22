if(window.setupWebViewJavascriptBridge == null) {
    console.error('[LJWebBrowser] 未找到window.setupWebViewJavascriptBridge');
}

/**
 * 创建通道
 * @param  {[type]} name 通道名称
 */
function lianjia_method_channel_register(channel_name) {
    var _func = 'lianjia_method_channel_register';

    console.groupCollapsed(`[${_func}] 注册通道:${channel_name} ...`);
    if(window[channel_name]) {
        console.log(`找到通道`);
    } else {
        console.log(`未找到通道，创建通道`);
        var channel = new Object();
        window[channel_name] = channel;
    }
    console.groupEnd();
}

//[容器<->Flutter]约定
//使用JS类型作为数据类型
//interface BridgeData {
//   method: string,
//   args: any,
//   type: string
//}

function _lianjia_convert_flutter_data(method_name, args, type) {
    //Flutter对象[Map|Array|...]在JS中无法转换为Object
    //所以只能依赖字符串传递对象
    var _args = args;
    if(type == 'object') {
        _args = JSON.parse(JSON.stringify(args));
    }

    const data = {
        'method' : method_name,
        'args' : _args,
        'type' : type
    }

    return data;
}

function _lianjia_convert_flutter_data_with_name(channel_name, method_name, args, type) {
    //Flutter对象[Map|Array|...]在JS中无法转换为Object
    //所以只能依赖字符串传递对象
    var _args = args;
    if(type == 'object') {
        _args = JSON.parse(JSON.stringify(args));
    }

    const data = {
        'channel_name' : channel_name,
        'method' : method_name,
        'args' : _args,
        'type' : type
    }

    return data;
}

