

//可定制promise实现
var %@ = (method, args) => {
    console.log('[LJWebBrowser|Promise] method: ', method)
    console.log('[LJWebBrowser|Promise] args: ', args)
    
    var jsonee = args;
    try {
        const json = JSON.stringify(args);
        if(args.length != null) {
            if(args.length > 0 && (json === '{}' || json == null)) {
                throw new Error('JSON.stringify为空');
            }
        }
    } catch (e) {
        jsonee = lianjia_jsonify(args)
    }
    
    //可定制处理逻辑
    var handler = %@
    
    var promise = new Promise((resolve, reject) => {
        console.log('[LJWebBrowser|Promise] resolve: ', resolve)
        console.log('[LJWebBrowser|Promise] reject: ', reject)
        
        handler(method, jsonee, resolve, reject);
    });
    
    console.log('[LJWebBrowser|Promise] promise: ', promise)
    return promise;
}
