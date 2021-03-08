const nats = require('node-nats-streaming');
const format = require('string-template');
const request = require('request');
const pref = require('./preference.json');

const { NATS: { CLIENT_ID, CLUSTER_ID, URL } } = require('./config');


function init_templates() {
    const templates = {};
    pref.forEach((item) => {
        templates[item.subject] = [...(templates[item.subject] || []), {
            name: item.name,
            endpoint: item.endpoint,
            template: item.template
        }]
    })
    return templates;
}

function subscribe(sc) {
    const opts = sc.subscriptionOptions("slack-notifier")
    const subjects = Object.keys(templates);
    subjects.forEach((key) => {
        const subscription = sc.subscribe(key, opts);
        subscription.on('message', (msg) => {
            try {
                console.log('Received a message [' + msg.getSequence() + '] ' + msg.getData());
                let parsedMessage = JSON.parse(msg.getData());
                const options = templates[key];
                if (options) {
                    options.forEach((val) => {
                        const slack_msg = {
                            'text': format(val.template, parsedMessage)
                        };
                        request.post({
                            uri: val.endpoint,
                            json: true,
                            body: slack_msg
                        }, (err) => {
                            if (err) {
                                console.error(`Error occur with endpoint: ${val.endpoint}, message: ${slack_msg}`, "error:", err);
                            }
                        });
                    });
                }
            } catch (error) {
                console.log('error occur while recieving message.', error);
            }
        });
    });
}

function nats_connect() {
    const sc = nats.connect(CLUSTER_ID, CLIENT_ID, {
        url: URL,
        reconnect: true,
        reconnectTimeWait: 500
    });

    sc.on('connect', () => {
        subscribe(sc);
    })
}

const templates = init_templates();
nats_connect();