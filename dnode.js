var dnode = require('dnode');

dnode.connect(3000, function (remote) {
    remote.zing(66, function (n) {
        console.log('n = ' + n);
    });
});