// Legger inn en fin liten hyggelig beskjed i Commfides-boksen
document.getElementById('identification').innerHTML = '<p>Logg inn ved å trykke på C-knappen i adresselinjen</p>'

// Injiserer et script inn i siden, for å hente ut parameterene (hash, controlValue++) fra Commfides
// https://stackoverflow.com/questions/9602022/chrome-extension-retrieving-gmails-original-message
var getParamsScript = document.createElement('script');
getParamsScript.src = chrome.extension.getURL('getParameters.js');
(document.head||document.documentElement).appendChild(getParamsScript);
getParamsScript.onload = function() {
    getParamsScript.parentNode.removeChild(getParamsScript);
};

// Henter ut responsen fra scriptet som ble injisert i siden
document.addEventListener('RW759_connectExtension', function(e) {
	parameters = e.detail;
});

function sendParametersToCommfides(certificate, hash, controlValue) {
	// Blåkopi av scriptet som kommer fra Commfides
	// Populerer et skjult skjema, og sender det inn

	var form = document.getElementById("frmResult");
	
	var hiddenUserCertificate = document.createElement("input");
	hiddenUserCertificate.setAttribute("type", "hidden");
	hiddenUserCertificate.setAttribute("name", "userCertificate");
	hiddenUserCertificate.setAttribute("value", certificate);
	
	var hiddenSignedHash = document.createElement("input");
	hiddenSignedHash.setAttribute("type", "hidden");
	hiddenSignedHash.setAttribute("name", "signedHash");
	hiddenSignedHash.setAttribute("value", hash);
	
	var hiddenControlValueOut = document.createElement("input");
	hiddenControlValueOut.setAttribute("type", "hidden");
	hiddenControlValueOut.setAttribute("name", "controlValueOut");
	hiddenControlValueOut.setAttribute("value", controlValue);
	
	form.appendChild(hiddenUserCertificate);
	form.appendChild(hiddenSignedHash);
	form.appendChild(hiddenControlValueOut);

	document.body.appendChild(form);

	form.submit();
}

// Lytter etter forespørsler fra popup-en, og svarer med parameterne fra Commfides
chrome.runtime.onMessage.addListener(
  function(request, sender, sendResponse) {
       if (request.operation == "gimmeGimmeGimmeSomeParametersAfterMidnight") {
		sendResponse({parameters: parameters});
	} else if (request.operation == "signInStranger") {
		sendParametersToCommfides(request.certificate, request.hash, request.controlValue)
	} else {
		console.log('what')
	}
  });
