if(window.setupWebViewJavascriptBridge == null) {
    console.error('[LJWebBrowser] 未找到window.setupWebViewJavascriptBridge');
}

/**
 * 调用AjaxHook
 */
ah.proxy({
    onRequest: (config, handler) => {
        var _func = 'AjaxProxy.onRequest';

        //判断是否本地
        if(config.url.indexOf("http") == -1
           && config.url.indexOf("https") == -1) {
            console.warn(`[${_func}] 非桥接请求:${config.url}`);
            handler.next(config);
            return;
        }

        //interface XhrRequestConfig {
        //    method: string,
        //    url: string,
        //    headers: any,
        //    body: any,
        //    async: boolean,
        //    user: string,
        //    password: string,
        //    withCredentials: boolean
        //    xhr: OriginXMLHttpRequest,
        //}

        //输出参数
        console.groupCollapsed(`[${_func}] 请求:${config.url} ...`);
        console.log(`config.method: ${config.method}`);
        console.log(`config.url: ${config.url}`);
        console.log(`config.headers: ${config.headers}`);
        console.log(`config.body: ${config.body}`);
        console.log(`config.xhr: ${config.xhr}`);
        console.groupEnd();

        //直接传递config报错
        //TypeError: JSON.stringify cannot serialize cyclic structures.
        _config = config;
        _config['xhr'] = {
            'responseType': config.xhr.responseType,
            'timeout': config.xhr.timeout
        };

        window.setupWebViewJavascriptBridge((bridge) => {
            bridge.callHandler('ljwebbrowser.ajax', _config, (response) => {
                //容器约定
                //interface BridgeResponse {
                //   url: string,
                //   headers: any,
                //   MIMEType: string,
                //   textEncoding: string,
                //   statusCode: number,
                //   statusText: string,
                //   base64: string,
                //   json: any,
                //   text: string,
                //   error: string
                //}

                //输出响应
                console.groupCollapsed(`[${_func}] 响应信息...`);
                console.log(`response.url: ${response.url}`);
                console.log(`response.headers: ${response.headers}`);
                console.log(`response.MIMEType: ${response.MIMEType}`);
                console.log(`response.textEncoding: ${response.textEncoding}`);
                console.log(`response.statusCode: ${response.statusCode}`);
                console.log(`response.statusText: ${response.statusText}`);
                console.groupEnd();

                if(response.error) {
                    //type XhrErrorType = 'error' | 'timeout' | 'abort'
                    //
                    //interface XhrError {
                    //    config: XhrRequestConfig,
                    //    type: XhrErrorType
                    //}

                    console.warn(`[${_func}] response.error: ${response.error}`);
                    handler.resolve({
                        config: config,
                        type: 'error'
                    });
                    return;
                }

                // https://developer.mozilla.org/zh-CN/docs/Web/API/XMLHttpRequest/responseType
                // XMLHttpRequest.responseType = 'arraybuffer' | 'blob' | 'document' | 'json' | 'text'

                var data = null;
                var text = null;
                if(config.xhr.responseType == 'arraybuffer') {
                    console.groupCollapsed(`[${_func}] 响应内容...`);
                    console.debug(`response.base64: ${response.base64}`);
                    console.groupEnd();

                    data = new Blob([atob(response.base64)], {type:response.MIMEType});
                } else if(config.xhr.responseType == 'blob') {
                    console.groupCollapsed(`[${_func}] 响应内容...`);
                    console.debug(`response.base64: ${response.base64}`);
                    console.groupEnd();

                    data = new Blob([atob(response.base64)], {type:response.MIMEType});
                } else if(config.xhr.responseType == 'document') {
                    //TODO:
                } else if(config.xhr.responseType == 'json') {
                    console.groupCollapsed(`[${_func}] 响应内容...`);
                    console.debug(`response.json: ${response.json}`);
                    console.debug(`response.text: ${response.text}`);
                    console.groupEnd();

                    data = response.json;
                    text = response.text;
                } else if(config.xhr.responseType == 'text') {
                    console.groupCollapsed(`[${_func}] 响应内容...`);
                    console.debug(`response.text: ${response.text}`);
                    console.groupEnd();

                    data = response.text;
                    text = response.text;
                }

                //此处扩展Ajax-hook实现
                //interface XhrResponse {
                //    config: XhrRequestConfig,
                //    headers: any,
                //    response: any,
                //    responseText?: string,//扩展
                //    responseURL: string,//扩展
                //    status: number,
                //    statusText?: string,
                //}

                handler.resolve({
                    config: config,
                    headers: response.headers,
                    response: data,
                    responseText: text,
                    responseURL: response.url,
                    status: response.statusCode,
                    statusText: response.statusText,
                });
            });
        });
    },
    onResponse: (response, handler) => {
        handler.next(response);
    },
    onError: (err, handler) => {
        handler.next(err);
    }
});
