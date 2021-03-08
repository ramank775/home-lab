const express = require('express');
const { PORT, NATS: { CLUSTER_ID, CLIENT_ID, URL } } = require('./config');
const nats = require('node-nats-streaming');

const sc = nats.connect(CLUSTER_ID, CLIENT_ID, {
    url: URL,
    reconnect: true,
    reconnectTimeWait: 500
})

const app = express();

app.get('/health', (req, res) => {
    return res.status(200).send();
});

function parser(req, res, next) {
    if (req.method == 'POST') {
        req.on('data', data => {
            req.body = data.toString();
            next();
        })
    } else
        next();

}

app.post('/publish/:subject', parser, (req, res) => {
    const subject = req.params.subject;
    const content = req.body;
    sc.publish(subject, content, (err, guid) => {
        if (err) {
            console.error(`Error while publishing to subject ${subject}, Content: ${content}.`, 'Error: ', err);
            return;
        }
        console.log(`Message published successfully to subject ${subject}, guid: ${guid}`);
    })
    return res.status(202).send();
})

app.listen(PORT, () => {
    console.log(`http nat producer started at port:${PORT}`);
});
