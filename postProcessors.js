const _ = require('lodash');
const helper = require('./helpers')
const strickKeysCheck = (ret, ks) => {
    ks.map(k => {
        if (!ret[k])
            throw new Error(`bad value for key-value: ${k}-[${ret[k]}]`);
    })
};

const fieldFilter = (arr, fields) => {
    let ret = []
    for(let a of arr){
        let allPass = true
        for(f of fields){
            if(!a[f] || a[f].length == 0){
                allPass = false
                break
            }
        }
        if(allPass){
            ret.push(a)
        }
    }
    return ret
}


const articlePostProcessor = (content) => {
    let ret = {};
    ret['title'] = content.webTitle;
    try {
        const assets = content.blocks.main.elements[0].assets;
        ret['image'] = assets[assets.length - 1].file;
    } catch (e) {
        console.error(`Error when try to get image: [${e}]; => use null for imageUrl`);
        ret['image'] = null;
    }
    //date : 2020-03-26T21:43:01Z


    try{
        ret['date'] = helper.formatArticleDate(content.webPublicationDate);
        ret['section'] = content['sectionName'];
        ret['extUrl'] = content['webUrl']

    }catch (e) {
        console.error(`Error when fetch fields: ${e};`);
    }

    ret['content'] = ''
    try{
        for(let b of content.blocks.body){
            ret['content'] += b.bodyHtml + "\n";
        }
        let reg = /<iframe .*>.*<\/iframe>/gmi
        ret['content'] = ret['content'].replace(reg, "")
    }catch (e) {
        console.error(`Error when fetch contents: ${e};`);
    }

    return ret;
};

const homePostProcessor = (contentArray) => {
    const keys = ["thumbnail", "title", "time","timeForBookmark", "section", "artId", "extUrl"]
    let processedContentArray = contentArray.map((content) => {
        let ret = {}

        ret['thumbnail'] = content['fields']['thumbnail']
        if (!ret['thumbnail']) ret['thumbnail'] = null

        ret['title'] = content['webTitle']
        ret['time'] = content['webPublicationDate']
        ret['timeForBookmark'] = helper.formatArticleDate(ret['time'], true)
        ret['section'] = content['sectionName']
        ret['artId'] = content['id']
        ret['extUrl'] = content['webUrl']

        return ret
    })

    let requiredFields = ["title", "extUrl", "artId"]
    return fieldFilter(processedContentArray, requiredFields)
}
const searchPostProcessor = (contentArray) => {
    let processedContentArray =  contentArray.map(o => {
        let ret = {};
        ret['title'] = o['webTitle'];
        ret['time'] = o['webPublicationDate']
        ret['timeForBookmark'] = helper.formatArticleDate(ret['time'], true)
        //section may missing: undefined/"";
        ret['section'] = o['sectionId'] || "";
        ret['artId'] = o['id'];
        ret['extUrl'] = o['webUrl'];


        // imageUrl i.g. thumbnail
        try {
            const assets = o.blocks.main.elements[0].assets;
            ret['thumbnail'] = assets[assets.length - 1].file;
        } catch (e) {
            ret['thumbnail'] = null;
        }

        return ret;
    });

    let requiredFields = ["title", "artId", "extUrl"]
    return fieldFilter(processedContentArray, requiredFields)
};

const tabPostProcessor = (contentArray) => {
    let processedArr = contentArray.map(o => {
        let ret = {};
        try {
            ret['title'] = o['webTitle'];
            ret['section'] = o['sectionName'];
            ret['artId'] = o['id'];
            ret['time'] = o['webPublicationDate']
            ret['timeForBookmark'] = helper.formatArticleDate(ret['time'], true)
            ret['extUrl'] = o['webUrl']
        } catch (e) {
            console.error(`tabPostProcessor: ${e} => item will not be included.`);
            return null;
        }

        //image allow null
        try {
            let assets = o.blocks.main.elements[0].assets;
            ret['thumbnail'] = assets[assets.length - 1].file;
        } catch (e) {
            console.error(`tabPostProcessor: ${e} => use null for image`);
            ret['thumbnail'] = null;
        }

        return ret;
    });

    return processedArr
}

//

const _tabPostProcessor = (src) => {
    let name = src + ' tab postprocessor';

    // keys
    const looseKeys = ['imageUrl']; //allow null
    const striclKeys = ['title', 'section', 'date', 'description', 'url', 'artId'];

    if (src == 'grd') {
        return (arr) => {
            let processedArr = arr.map(o => {
                let ret = {};
                try {
                    ret['title'] = o['webTitle'];
                    ret['section'] = o['sectionId'];
                    ret['date'] = o['webPublicationDate'].slice(0, 10);

                    ret['description'] = o.blocks.body[0].bodyTextSummary;
                    ret['url'] = o['webUrl'];
                    ret['artId'] = o['id'];

                    //check if any bad results
                    strickKeysCheck(ret, striclKeys);
                } catch (e) {
                    console.error(`${name}: ${e} => item will not be included.`);
                    return null;
                }

                //image allow null
                try {
                    let assets = o.blocks.main.elements[0].assets;
                    ret['imageUrl'] = assets[assets.length - 1].file;
                } catch (e) {
                    console.error(`${name}: ${e} => use null for image`);
                    ret['imageUrl'] = null;
                }

                return ret;
            });


            return _.filter(processedArr, (o) => {
                return o != null;
            });
        }
    } else if (src == 'nyt') {
        return (arr) => {
            let processedArr = arr.map(o => {
                let ret = {};

                try {
                    ret['title'] = o['title'];
                    ret['section'] = o['section'];
                    ret['date'] = o['published_date'].slice(0, 10);
                    ret['description'] = o['abstract'];
                    ret['url'] = o['url'];
                    ret['artId'] = o['url'];
                    //check if any bad results
                    strickKeysCheck(ret, striclKeys);
                } catch (e) {
                    console.error(`${name}: ${e} => item will not be included.`);
                    return null;
                }

                // image allow null
                try {
                    let img = null;
                    for (let imgObj of (o.multimedia || [])) {
                        if (imgObj.type == 'image' && imgObj.url && imgObj.width >= 2000) {
                            img = imgObj.url;
                            break;
                        }
                    }
                    ret['imageUrl'] = img;

                } catch (e) {
                    console.error(`${name}: ${e} => use null for image`);
                    ret['imageUrl'] = null;
                }
                return ret;
            });

            return _.filter(processedArr, (o) => {
                return o;
            });

        }
    }

};
const _articlePostProcesarticlePostProcessorsor = (src) => {
    let name = src + ' article postprocessor';
    const strickKeys = ['title', 'imageUrl', 'date', 'description', 'section']; //section needed for bookmark


    const grd = (content) => {
        let ret = {};
        ret['title'] = content.webTitle;
        try {
            const assets = content.blocks.main.elements[0].assets;
            ret['imageUrl'] = assets[assets.length - 1].file;
        } catch (e) {
            console.error(`Error when try to get image: [${e}]; => use null for imageUrl`);
            ret['imageUrl'] = null;
        }
        //date : 2020-03-26T21:43:01Z
        date = content.webPublicationDate.slice(0, 10);
        date = new Date(date).toLocaleString('en-us',{month:'short', year:'numeric', day:'numeric'})
        ret['date'] = date
        ret['description'] = content.blocks.body[0].bodyTextSummary;
        ret['section'] = content['sectionName'];
        return ret;
    };

    const nyt = (content) => {
        let ret = {};
        ret['title'] = content.headline.main;
        // imageUrl: pick the first image with width >= 2000
        try {
            ret['imageUrl'] = null;
            const imgObjs = content.multimedia;
            for (let i = 0; i < imgObjs.length; i++) {
                const imgObj = imgObjs[i];
                if (imgObj.width >= 2000) {
                    ret['imageUrl'] = imgObj.url;
                    if (!ret['imageUrl'].startsWith('http')) {
                        ret['imageUrl'] = "https://nyt.com/" + ret['imageUrl'];
                    }
                    break;
                }
            }

            if (ret['imageUrl'] == null)
                throw "Did not find an image with width >= 2000"


        } catch (e) {
            console.error(`Error when try to get image: [${e}]; => use null for imageUrl`);
            ret['imageUrl'] = null;
        }
        //date: 2020-03-26T04:11:05+0000
        ret['date'] = content.pub_date.slice(0, 10);
        ret['description'] = content.abstract;
        ret['section'] = content['section_name'];
        return ret;


    };

    if (src == 'grd') return grd;
    else return nyt;

};


const _searchPostProcessor = (src) => {
    let name = src + ' search postprocessor';
    const strickKeys = ['title', 'imageUrl', 'date', 'section', 'url', 'artId']; //section needed for bookmark

    const grd = (content) => {
        return content.map(o => {
            let ret = {};
            ret['title'] = o['webTitle'];
            ret['date'] = o['webPublicationDate'].slice(0, 10);
            ret['artId'] = o['id'];

            //section may miss: undefined/"";
            ret['section'] = o['sectionId'] || null;
            ret['url'] = o['webUrl'];


            // imageUrl
            try {
                const assets = o.blocks.main.elements[0].assets;
                ret['imageUrl'] = assets[assets.length - 1].file;
            } catch (e) {
                ret['imageUrl'] = null;
            }

            return ret;
        });
    };

    const nyt = (content) => {
        return content.map(o => {
            let ret = {};

            ret['title'] = o.headline.main;

            //news deck can be "None"
            ret['section'] = o['news_desk'] || null;
            if (!ret['section'] || ret['section'].toLowerCase() == 'none')
                ret['section'] = null;


            ret['date'] = o['pub_date'].slice(0, 10);
            ret['artId'] = o['web_url']; //TODO: this inconsistent with 'url' in getTab()
            ret['url'] = o['web_url'];
            try {
                ret['imageUrl'] = null;
                const imgObjs = o['multimedia'];
                let maxW = -1;
                for (let imgObj of imgObjs) {
                    if (imgObj.type != 'image') continue;
                    maxW = Math.max(maxW, imgObj.width);
                    if (imgObj.width >= 2000) {
                        ret['imageUrl'] = imgObj.url;
                        if (!ret['imageUrl'].startsWith('http')) {
                            ret['imageUrl'] = "https://nyt.com/" + ret['imageUrl'];
                        }
                        break;
                    }
                }
                if (ret['imageUrl'] == null)
                    throw `Did not find an image with width >= 2000; Max width: ${maxW}`;

            } catch (e) {
                console.error(`Error when try to get image: [${e}]; => use null for imageUrl`);
                ret['imageUrl'] = null;
            }


            return ret;
        });
    };

    if (src == 'grd') return grd;
    else return nyt;

};

module.exports = {
    homePostProcessor: homePostProcessor,
    articlePostProcessor: articlePostProcessor,
    searchPostProcessor: searchPostProcessor,
    tabPostProcessor: tabPostProcessor,

};