module.exports = {
    PORT: parseInt(process.env.PORT || '3000'),
    NATS: {
        CLUSTER_ID: process.env.NATS_CLUSTER_ID || 'home-lab',
        CLIENT_ID: process.env.NATS_CLIENT_ID || 'http-producer',
        URL: process.env.NATS_URL
    }
}
