/**
 * 对象转换为字符串
 * https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Operators/typeof
 * @param  {[type]} object 对象
 * @return {[type]}        字符串
 */
function lianjia_stringify(object) {
    var _func = 'lianjia_stringify';

    const type = typeof(object);
    console.debug(`[${_func}] object type: ${type}`);

    if(type == 'object') {
        return JSON.stringify(object);
    } else if(type == 'function') {
        return 'function ' + object.name + '()';symbol
    } else if(type == 'symbol') {
        return object.toString();
    } else if(type == 'number') {
        return object.toString();
    } else if(type == 'bigint') {
        return object.toString();
    } else if(type == 'boolean') {
        return object.toString();
    } else if(type == 'string') {
        return object;
    } else {//undefined
        return type;
    }
}
