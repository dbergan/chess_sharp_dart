// Capture console.log in case the engine uses it directly instead of options.print
var oldLog = console.log;
console.log = function (msg) {
    self.postMessage("CONSOLE: " + msg + "\n");
    if (oldLog) oldLog.apply(console, arguments);
};

importScripts('chess_sharp.js');
var moduleInstance;
var commandBuffer = [];

var options = {
    // Point to the correct script for Pthread workers to avoid recursive spawning of stockfish_worker.js
    mainScriptUrlOrBlob: 'chess_sharp.js',
    print: function (line) {
        self.postMessage(line + '\n');
    },
    printErr: function (line) {
        console.error(line);
        self.postMessage("ERROR: " + line + "\n");
    }
};

var result = Stockfish(options);

function init(Module) {
    moduleInstance = Module;
    // Some Stockfish builds need a bit of time to initialize even after the promise resolves
    setTimeout(function () {
        for (var i = 0; i < commandBuffer.length; i++) {
            if (moduleInstance.postMessage) {
                moduleInstance.postMessage(commandBuffer[i]);
            } else {
                self.postMessage("ERROR: postMessage missing on module\n");
            }
        }
        commandBuffer = [];
    }, 100);
}

if (result && typeof result.then === 'function') {
    result.then(init);
} else {
    init(result);
}

self.onmessage = function (e) {
    var data = e.data;
    if (moduleInstance) {
        if (moduleInstance.postMessage) {
            moduleInstance.postMessage(data);
        }
    } else {
        commandBuffer.push(data);
    }
};
