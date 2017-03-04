#!PYTHON_PATH
"""
Native app for the commfides-chrome-extension

Reads a message from the Chrome extension,
signs the hash with the key from the smartcard
and returns hash + cert

Magnus Watn <magnus@watn.no>
"""
import sys
import json
import base64
import struct

import PyKCS11

PYKCS11LIB = PKCS11_LIB

KEY_NAME = 'Authentication key'
CERT_NAME = 'Authentication certificate'

class PluginError(Exception):
    """An error occured, see the error message"""
    pass

def send_message_to_plugin(message):
    """Sends a message back to the Chrome extension"""
    sys.stdout.write(struct.pack('I', len(message)))
    sys.stdout.write(message)
    sys.stdout.flush()

def read_message_from_plugin():
    """Reads a message from the Chrome extension"""
    text_length_bytes = sys.stdin.read(4)
    text_length = struct.unpack('i', text_length_bytes)[0]
    text = sys.stdin.read(text_length).decode('utf-8')
    return text

def sign_with_authkey(data, pin):
    """Signs the data with the key in the smartcard"""
    pkcs11 = PyKCS11.PyKCS11Lib()
    pkcs11.load(PYKCS11LIB)

    try:
        slot = pkcs11.getSlotList()[0]
    except IndexError:
        raise PluginError('Could not find a smartcard reader')

    session = pkcs11.openSession(slot, PyKCS11.CKF_SERIAL_SESSION | PyKCS11.CKF_RW_SESSION)

    session.login(pin)

    authkey = session.findObjects([(PyKCS11.CKA_LABEL, KEY_NAME)])[0]
    authcert = session.findObjects([(PyKCS11.CKA_LABEL, CERT_NAME)])[0]

    authcert_bytes = session.getAttributeValue(authcert, [PyKCS11.CKA_VALUE])[0]
    signature = session.sign(authkey, data, PyKCS11.Mechanism(PyKCS11.CKM_RSA_PKCS, None))

    session.logout()
    session.closeSession()

    return str(bytearray(signature)), str(bytearray(authcert_bytes))

def return_error_to_plugin(errormessage):
    """Returns an error message to the extension"""
    reply = json.dumps({'status': 'error', 'message': errormessage})
    send_message_to_plugin(reply)

def sign_and_return_results(params):
    """Signs the hash, and returns the answer to the extension"""
    try:
        hash_to_be_signed = base64.b64decode(params['hash'])
        pin = params['pin'].encode('ascii')
    except KeyError:
        raise PluginError('Malformed request')
    signature, cert = sign_with_authkey(hash_to_be_signed, pin)

    reply = json.dumps({'status': 'success', 'params' : {
        'signedHash':base64.b64encode(signature),
        'cert': base64.b64encode(cert)}})

    send_message_to_plugin(reply)

def main():
    """Reads the message from the extension and calls the correct function"""
    json_message = read_message_from_plugin()
    message = json.loads(json_message)
    if message['operation'] == 'sign':
        sign_and_return_results(message['params'])
    else:
        raise PluginError('Unknown operation')

if __name__ == '__main__':
    try:
        main()
    except Exception as error:
        return_error_to_plugin(str(error))
