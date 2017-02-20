// Sender parameterene (hash, controlValue++) opp til content scriptet
// https://stackoverflow.com/questions/9602022/chrome-extension-retrieving-gmails-original-message
document.dispatchEvent(new CustomEvent('RW759_connectExtension', {
    detail: parameters
}));
