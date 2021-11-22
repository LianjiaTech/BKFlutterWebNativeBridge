if(window.setupWebViewJavascriptBridge == null) {
    console.error('[LJWebBrowser] 未找到window.setupWebViewJavascriptBridge');
}

function lianjia_joint_log(bridge, level, message, [...values]) {
    var log = lianjia_sringify(message);
    for (value in values) {
        const _fragment = lianjia_sringify(message);
        log += _fragment;
    }
    
    bridge.callHandler('ljwebbrowser.log', `[LJWebBrowser][${level}] ${log}`);
}

/**
 * 通过替换console接口实现hook，原始输出转发至容器
 * 替换范围包括：
 * 1）group，groupCollapsed，groupEnd [function([name])]
 * 2）error，warn，info，log，debug [function(message, [...values])]
 */

const lianjia_origin_console_group = console.group;
const lianjia_origin_console_groupCollapsed = console.groupCollapsed;
const lianjia_origin_console_groupEnd = console.groupEnd;

window.setupWebViewJavascriptBridge((bridge) => {
    console.group = function([name]) {
        lianjia_origin_console_group(name);
        lianjia_joint_log(bridge, 'Group', `[LJWebBrowser] console.group: ${name}`);
    }

    console.groupCollapsed = function([name]) {
        lianjia_origin_console_groupCollapsed(name);
        lianjia_joint_log(bridge, 'Group', `[LJWebBrowser] console.group.collapsed: ${name}`);
    }

    console.groupEnd = function([name]) {
        lianjia_origin_console_groupEnd(name);
        lianjia_joint_log(bridge, 'Group', `[LJWebBrowser] console.group.end: ${name}`);
    }
});

const lianjia_origin_console_error = console.error;
const lianjia_origin_console_exception = console.exception;
const lianjia_origin_console_warn = console.warn;
const lianjia_origin_console_info = console.info;
const lianjia_origin_console_log = console.log;
const lianjia_origin_console_debug = console.debug;

window.setupWebViewJavascriptBridge((bridge) => {
    console.error = function(message, [...values]) {
        lianjia_origin_console_error(message, ...values);
        lianjia_joint_log(bridge, 'Error', message, ...values);
    }

    console.exception = function(message, [...values]) {
        lianjia_origin_console_exception(message, ...values);
        lianjia_joint_log(bridge, 'Exc', message, ...values);
    }

    console.warn = function(message, [...values]) {
        lianjia_origin_console_warn(message, ...values);
        lianjia_joint_log(bridge, 'Warn', message, ...values);
    }

    console.info = function(message, [...values]) {
        lianjia_origin_console_info(message, ...values);
        lianjia_joint_log(bridge, 'Info', message, ...values);
    }

    console.log = function(message, [...values]) {
        lianjia_origin_console_log(message, ...values);
        lianjia_joint_log(bridge, 'Log', message, ...values);
    }

    console.debug = function(message, [...values]) {
        lianjia_origin_console_debug(message, ...values);
        lianjia_joint_log(bridge, 'Debug', message, ...values);
    }
});
