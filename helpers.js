function date2Str(d) {
    let year = d.getFullYear();
    let month = d.getMonth() + 1;
    let day = d.getDate();

    let h = d.getHours();
    let m = d.getMinutes();
    let s = d.getSeconds();

    return `${year}/${month}/${day} ${h}:${m}:${s}`;
}

function logRequest(req, res) {
    let oldEnd = res.end;

    res.end = (...args) => {
        console.error(`${req.connection.remoteAddress} -- [${date2Str(new Date())}] "${req.method}: ${req.url}" [${res.statusCode}]`);
        oldEnd.apply(res, args);
    };
}


const base64 = {
    encode: s => Buffer.from(s, 'utf8').toString('base64'),
    decode: s => Buffer.from(s, 'base64').toString('utf8')
};

function tabParamCheck(req, res) {
    if (!req.query.tab || !['nyt', 'grd'].includes(req.query.src)) {
        const errObj = {
            status: 'RequestParamError',
            err_msg: `tab=>[${req.query.tab}]; src=>[${req.query.src}]`,
            content: null
        };
        res.status(400); // 400: Bad Request
        res.send(errObj);
        return false;
    }
    return true;
}


function articleParamCheck(req, res) {
    if (!req.query.artId || !['nyt', 'grd'].includes(req.query.src)) {
        const errObj = {
            status: 'RequestParamError',
            err_msg: `artId=>[${req.query.artId}]; src=>[${req.query.src}]`,
            content: null
        };
        res.status(400);// 400: Bad Request
        res.send(errObj);
        return false;
    }
    return true;
}


function formatArticleDate(s, woyear=false){ //without year
    const d = new Date(s)
    const year = new Intl.DateTimeFormat('en', { year: 'numeric' }).format(d)
    const month = new Intl.DateTimeFormat('en', { month: 'short' }).format(d)
    const day = new Intl.DateTimeFormat('en', { day: '2-digit' }).format(d)

    if(woyear){
        return `${day} ${month}`
    }
    return `${day} ${month} ${year}`

}
module.exports = {
    formatArticleDate: formatArticleDate,
    logRequest: logRequest,
    base64: base64,
    tabParamCheck: tabParamCheck,
    articleParamCheck: articleParamCheck
};