var cache = [{}];


function fetch(assetName) {
    return new Promise(function(resolve, reject) {
        for (var entry in cache) {
            if (entry.key == assetName) {
                resolve(entry.value);
                return;
            }
        }

        load(assetName).then(resolve, reject);
    });
}


function load(assetName) {
    return new Promise(function(resolve, reject) {
        var request = new XMLHttpRequest();
        request.open("GET", assetName);

        request.onreadystatechange = function () {
            if (request.readyState === XMLHttpRequest.DONE) {
                var json = JSON.parse(request.responseText);

                cache.push({
                    "key": assetName,
                    "value": json
                });

                resolve(json);
                return;
            }
        }

        request.send();
    });
}

