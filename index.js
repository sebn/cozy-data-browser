const node = document.querySelector("[role=application]");
const data = node.dataset;

cozy.bar.init({
    appEditor: data.cozyAppEditor,
    appName: data.cozyAppName,
    iconPath: data.cozyIconPath,
    lang: data.cozyLocale
});

const app = Elm.Main.init({
    node: node,
    flags: {
        locationHash: location.hash,
        cozy: {
            domain: data.cozyDomain,
            token: data.cozyToken
        }
    }
});

window.addEventListener('hashchange', function () {
    app.ports.onLocationHashChange.send(location.hash);
});

app.ports.setLocationHash.subscribe(function (locationHash) {
    location.hash = locationHash;
});
