// Blokkerer deployJava-scriptet fra å kjøre.
// https://stackoverflow.com/questions/9698059/disable-single-javascript-file-with-addon-or-extension/9699373#9699373
chrome.webRequest.onBeforeRequest.addListener(
    function() { return {cancel: true}; },
    {
    urls: ["https://app01.commfides.com/cip/js/deployJava.js",
           "https://app05.commfides.com/cip/js/deployJava.js",
           "https://app02.test.commfides.com/cip/js/deployJava.js"],
    types: ["script"]
    },
    ["blocking"]
);
