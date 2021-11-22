(method, args, resolve, reject) => {
    window.WebViewJavascriptBridge.callHandler(method, args, (response) => {
        console.log('[LJWebBrowser|Channel|Method] response: ', response)
        resolve(response);
    });
};
