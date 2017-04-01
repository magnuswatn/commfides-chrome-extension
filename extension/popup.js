// Kaller content-scriptet for å hente ut parameterne fra Commfides
chrome.tabs.query({active: true, currentWindow: true}, function(tabs) {
    chrome.tabs.sendMessage(tabs[0].id, {operation: "gimmeGimmeGimmeSomeParametersAfterMidnight"}, function(response) {
    // Sjekker om vi fikk noe svar, vis isåfall innloggingselementene på siden
        if (response != null){
            parameters = response.parameters;
            document.getElementById("text").innerHTML="Skriv inn pin-kode for &aring logge inn:";
            document.getElementById("form").style.display = "";
        }
  });
});

function Sign(pin) {
    // Kaller Python-appen for å signere parameterne
    var msg = { "operation": "sign", "params": {"pin": pin, "hash": parameters.hash} };
    chrome.runtime.sendNativeMessage('no.watn.magnus.smartcardsignapp', msg, function(response){
        if (response.status == "success"){
            SendParametersToCommfides(response.params.cert, response.params.signedHash, parameters.controlValue);
        } else {
            alert("Det skjedde en feil: " + response.message);
            window.close()
        }
    });
}

function SendParametersToCommfides(certificate, hash, controlValue) {
    chrome.tabs.query({active: true, currentWindow: true}, function(tabs) {
        chrome.tabs.sendMessage(tabs[0].id, {operation: "signInStranger", certificate: certificate, hash: hash, controlValue: controlValue}, function(response) {
            window.close();
        });
    });
}

document.addEventListener('DOMContentLoaded', function() {
    document.getElementById('form').addEventListener('submit', function(evt) {
        evt.preventDefault()
        document.getElementById('text').textContent='Logger inn...';
        document.getElementById('form').style.display="none";
        Sign(document.getElementById('pin').value);
    }, false);
}, false);
