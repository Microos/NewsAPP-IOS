const path = require('path');
const express = require('express');

const config = require('./config.json');
const helper = require('./helpers');
const serverFacade = require('./ServerFacade');
const apiClients = require('./ApiClients')//skip facade

let app = express();
let facade = new serverFacade.ServerFacade();
let GTClient = new apiClients.GoogleTrendsClient() //skip facade

// logging
app.use(function (req, res, next) {
    helper.logRequest(req, res);
    next()
});
app.disable("etag")

/**
 * Routes
 */


app.get('/api/home', async (req, res) => {
    const obj = await facade.getHome()
    if (obj.status != 'ok') {
        console.log(obj);
        res.status(500);
    }
    res.send(obj)
});

app.get('/api/article', async (req, res) => {
    const obj = await facade.getArticle(req.query.id)
    if (obj.status != 'ok') {
        console.log(obj);
        res.status(500);
    }
    res.send(obj)
});


//TODO: param check
app.get('/api/search', async (req, res) => {
    const obj = await facade.getSearch(req.query.q);
    if (obj.status != 'ok') {
        console.log(obj);
        res.status(500);
    }
    res.send(obj);
});


app.get('/api/trends', async (req, res) => {
    const obj = await GTClient.getInterestOverTime(req.query.q || "Coronavirus")
    if (obj.status != 'ok') {
        console.log(obj);
        res.status(500);
    }
    res.send(obj)
});


app.get('/api/headlines', async (req, res) => {
        const sec = req.query.section.toLowerCase();
        if (!apiClients.GRDSections.includes(sec) && sec != "sport") {
            res.status(400)
            res.send({
                status: "Bad Request Parameters",
                err_msg: `tab param = ${sec}, is not one of the valid tabs.`,
                content: null
            })
            return
        }
        const obj = await facade.getTab(sec)
        if (obj.status != 'ok') {
            console.log(obj);
            res.status(500);
        }
        res.send(obj)
    }
);


// // OLD for hw8 -----
//
// app.get('/_api/tab', async (req, res) => {
//     if (!helper.tabParamCheck(req, res))
//         return;
//     const tab = req.query.tab.toLowerCase();
//     const src = req.query.src.toLowerCase();
//     const obj = await facade.getTab(tab, src);
//     if (obj.status != 'ok') {
//         console.log(obj);
//         res.status(500);
//     }
//     res.send(obj)
// });
//
//
// app.get('/_api/article', async (req, res) => {
//     if (!helper.articleParamCheck(req, res))
//         return;
//
//
//     const b64id = req.query.artId;
//     const id = helper.base64.decode(b64id);
//     const src = req.query.src.toLowerCase();
//
//
//     const obj = await facade.getArticle(id, src);
//     if (obj.status != 'ok') {
//         console.log(obj);
//         res.status(500);
//     }
//     res.send(obj);
//
// });


// main
app.listen(process.env.PORT || config.port, '0.0.0.0', () => {
    console.log("Start listening on port -> " + config.port);
});