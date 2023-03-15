CREATE OR REPLACE PACKAGE infobip_viber AS
  FUNCTION send_viber_message(p_phone_number IN VARCHAR2, p_message IN VARCHAR2)
    RETURN BOOLEAN;
END infobip_viber;
/

CREATE OR REPLACE PACKAGE BODY infobip_viber AS
  FUNCTION send_viber_message(p_phone_number IN VARCHAR2, p_message IN VARCHAR2)
    RETURN BOOLEAN
  IS
    l_api_key CONSTANT VARCHAR2(100) := 'YOUR_API_KEY_HERE';
    l_url CONSTANT VARCHAR2(200) := 'https://api.infobip.com/viber/2/send';
    l_json CLOB;
    l_request UTL_HTTP.REQ;
    l_response UTL_HTTP.RESP;
    l_response_text CLOB;
    l_success BOOLEAN := FALSE;
  BEGIN
    -- Send Viber message
    l_json :=
      '{
        "messages": [
          {
            "from": {
              "name": "Your Company Name"
            },
            "viber": {
              "text": "' || p_message || '"
            },
            "to": {
              "phone_number": "' || p_phone_number || '"
            }
          }
        ]
      }';

    l_request := UTL_HTTP.BEGIN_REQUEST(url => l_url, method => 'POST');
    UTL_HTTP.SET_HEADER(l_request, 'Content-Type', 'application/json');
    UTL_HTTP.SET_HEADER(l_request, 'Authorization', 'App ' || l_api_key);
    UTL_HTTP.SET_BODY(l_request, l_json);
    l_response := UTL_HTTP.GET_RESPONSE(l_request);
    l_response_text := UTL_HTTP.READ_TEXT(l_response);

    IF l_response.status_code = 200 THEN
      l_success := TRUE;
    ELSE
      -- Send SMS message as fallback
      infobip_sms.send_sms_message(p_phone_number, p_message);
    END IF;

    RETURN l_success;
  EXCEPTION
    WHEN OTHERS THEN
      -- Log error
      INSERT INTO error_log (error_message)
      VALUES (SQLERRM);

      -- Send SMS message as fallback
      infobip_sms.send_sms_message(p_phone_number, p_message);

      RETURN FALSE;
  END send_viber_message;
END infobip_viber;
/
