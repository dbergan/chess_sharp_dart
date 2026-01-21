/*! coi-serviceworker v0.1.7 - Guido Zuidhof, licensed under MIT */
let coep = 'require-corp';
let coop = 'same-origin';

if (typeof window === 'undefined') {
    self.addEventListener("install", () => self.skipWaiting());
    self.addEventListener("activate", (event) => event.waitUntil(self.clients.claim()));

    self.addEventListener("fetch", function (event) {
        if (event.request.cache === "only-if-cached" && event.request.mode !== "same-origin") {
            return;
        }

        event.respondWith(
            fetch(event.request)
                .then((response) => {
                    if (response.status === 0) {
                        return response;
                    }

                    const newHeaders = new Headers(response.headers);
                    newHeaders.set("Cross-Origin-Embedder-Policy", coep);
                    newHeaders.set("Cross-Origin-Opener-Policy", coop);

                    return new Response(response.body, {
                        status: response.status,
                        statusText: response.statusText,
                        headers: newHeaders,
                    });
                })
                .catch((e) => console.error(e))
        );
    });
} else {
    (() => {
        // You can customize these values
        const re = new RegExp("coi-serviceworker\\.js$");
        // Check if the script is already running
        if (navigator.serviceWorker && navigator.serviceWorker.controller) {
            navigator.serviceWorker.controller.postMessage({
                type: "coep",
                value: coep
            });
            navigator.serviceWorker.controller.postMessage({
                type: "coop",
                value: coop
            });
        } else {
            navigator.serviceWorker.register(window.document.currentScript.src).then(
                (registration) => {
                    console.log("COI Service Worker registered: ", registration.scope);

                    registration.addEventListener("updatefound", () => {
                        console.log("COI Service Worker update found!");
                        const installingWorker = registration.installing;
                        installingWorker.addEventListener("statechange", () => {
                            if (installingWorker.state === "installed") {
                                console.log("COI Service Worker installed, reloading...");
                                window.location.reload();
                            }
                        });
                    });
                },
                (err) => {
                    console.error("COI Service Worker registration failed: ", err);
                }
            );
        }
    })();
}
