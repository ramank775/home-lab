module.exports = {
    NATS: {
        CLUSTER_ID: process.env.NATS_CLUSTER_ID || 'home-lab',
        CLIENT_ID: process.env.NATS_CLIENT_ID || 'slack-notifier',
        URL: process.env.NATS_URL
    }
}
