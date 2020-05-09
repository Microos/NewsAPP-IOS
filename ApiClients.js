let config = require('./config.json');

const googleTrends = require('google-trends-api');
const axios = require('axios');

/*
* Response json from Client:
*   status: 'ok' | type of error;
*   err_msg: null | 'detailed error message';
*   content: response body | null;
* */

class ApiClient {
    constructor(key) {
        this.apiKey = key;
        this.tabs = [];

    }

    getErrorResponse(errType, errMsg) {
        return {status: errType, err_msg: errMsg, content: null};
    }

    validateTab(tab) {
        if (!this.tabs.includes(tab)) {
            return [false, this.getErrorResponse('ApiParamError', `tab:[${tab}] is not valid.`)];
        }
        return [true, null];
    }
}

class GoogleTrendsClient extends ApiClient {
    constructor() {
        super(null);
        this.defaultStartTime = new Date("2019-06-01")
    }

    async getInterestOverTime(q) {
        let params = {
            keyword: q,
            startTime: this.defaultStartTime,
            endTime: new Date()
        }

        try {
            var content = []
            let results = await googleTrends.interestOverTime(params)
            let jObj = JSON.parse(results)

            for (let data of jObj.default.timelineData) {
                if (data.value) {
                    content.push(data.value[0])
                }
            }
            return {status: "ok", err_msg: null, content: content}
        } catch (e) {
            return {status: "Error API.getInterestOverTime", err_msg: e, content: null}
        }
    }
}

const TABs  = ['world', 'politics', 'business', 'technology', 'sports', 'science']; //valid tabnames from the view of outside
class GuardianClient extends ApiClient {
    constructor(key = config.grdKey) {
        super(key);
        this.name = 'Guardian Client';
        this.tabUrl = 'https://content.guardianapis.com';

    }


    async getHome() {
        let url = `https://content.guardianapis.com/search?orderby=newest&show-fields=starRating,headline,thumbnail,short-url&api-key=${this.apiKey}`
        let resp = await axios.get(url)
        try {
            return {status: 'ok', err_msg: null, content: resp.data.response.results};
        } catch (err) {
            let retFallback = this.getErrorResponse(err.name, err);
            let resp = err.response;
            if (!resp) return retFallback;

            if (resp.data) {
                let data = resp.data;
                return this.getErrorResponse('GRDApiError:tab', `[${resp.status}:${resp.statusText}] ${data.message}.`);
            }

            return retFallback;
        }


    }

    async getArticle(id) {
        const url = `https://content.guardianapis.com/${id}?api-key=${this.apiKey}&show-blocks=all`;
        try {
            console.log('api GET: ' + url);
            const resp = await axios.get(url);
            return {status: 'ok', err_msg: null, content: resp.data.response.content};

        } catch (e) {
            return {status: 'GRDApiError:article', err_msg: e.message, content: null};
        }
    }


    async getSearch(q) {
        const url = `https://content.guardianapis.com/search?q=${q}&api-key=${this.apiKey}&show-blocks=all`;
        try {
            console.log('api GET: ' + url);
            const resp = await axios.get(url);
            return {status: 'ok', err_msg: null, content: resp.data.response.results};
        } catch (e) {
            return {status: 'GRDApiError:search', err_msg: e.message, content: null};
        }
    }


    async getTab(tab) {
        if (tab == "sports") tab = "sport"
        try {
            let resp = await axios.get(`${this.tabUrl}/${tab}`, {
                params: {
                    'show-blocks': 'all',
                    'api-key': this.apiKey
                }
            })
            return {status: 'ok', err_msg: null, content: resp.data.response.results};
        } catch (e) {
            return {status: `GRDApiError:tab-${tab}`, err_msg: e.message, content: null}
        }

    }

}

module.exports = {
    GRDSections: TABs,
    GRDClient: GuardianClient,
    GoogleTrendsClient: GoogleTrendsClient
};


//
// pms = pms.then((resp) => {
//
// }).catch((err) => {
//     let retFallback = this.getErrorResponse(err.name, err);
//     let resp = err.response;
//     if (!resp) return retFallback;
//
//
//     if (resp.data) {
//         let data = resp.data;
//         return this.getErrorResponse('GRDApiError:tab', `[${resp.status}:${resp.statusText}] ${data.message}.`);
//     }
//
//     return retFallback;
//
// });
//
// return pms;