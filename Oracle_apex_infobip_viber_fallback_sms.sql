DECLARE
  l_response CLOB;
  l_url VARCHAR2(4000);
  l_headers apex_web_service.t_param_list;
  l_body VARCHAR2(4000) := '{"messages":[{"content":{"text":"Hello, this is a Viber message!"},"destination":{"to":"{phone_number}","country":"{country_code}"}}]}';
  l_max_attempts NUMBER := 3;
  l_attempt NUMBER := 1;
  l_success BOOLEAN := FALSE;
  l_fallback_api VARCHAR2(4000) := 'SMS'; -- Change to 'EMAIL' to fallback to email API
BEGIN
  l_headers := apex_web_service.g_request_headers;
  apex_web_service.set_header(l_headers, 'Authorization', 'App {api_key}');
  apex_web_service.set_header(l_headers, 'Content-Type', 'application/json');
  
  -- Try sending Viber message
  WHILE NOT l_success AND l_attempt <= l_max_attempts LOOP
    l_response := apex_web_service.make_rest_request(
      p_url => 'https://api.infobip.com/viber/1/send',
      p_http_method => 'POST',
      p_parm_name => apex_util.string_to_table('p_body'),
      p_parm_value => apex_util.string_to_table(l_body),
      p_header => l_headers
    );
    
    IF apex_web_service.get_status_code >= 200 AND apex_web_service.get_status_code < 300 THEN
      -- Viber message was sent successfully
      l_success := TRUE;
    ELSE
      -- Viber message failed to send, retry or fallback to SMS or email
      l_attempt := l_attempt + 1;
      
      IF l_attempt <= l_max_attempts THEN
        -- Wait for a few seconds before retrying
        DBMS_LOCK.SLEEP(5);
      ELSE
        -- Fallback to secondary SMS or email API
        IF l_fallback_api = 'SMS' THEN
          l_url := 'https://api.example.com/sms/send';
          l_body := '{"message":"Hello, this is an SMS fallback message!","phone_number":"{phone_number}"}';
        ELSIF l_fallback_api = 'EMAIL' THEN
          l_url := 'https://api.example.com/email/send';
          l_body := '{"subject":"Viber message failed","body":"Hello, this is an email fallback message!","email_address":"{email_address}"}';
        END IF;
        
        l_response := apex_web_service.make_rest_request(
          p_url => l_url,
          p_http_method => 'POST',
          p_parm_name => apex_util.string_to_table('p_body'),
          p_parm_value => apex_util.string_to_table(l_body)
        );
        
        IF apex_web_service.get_status_code >= 200 AND apex_web_service.get_status_code < 300 THEN
          -- SMS or email message was sent successfully
          l_success := TRUE;
        ELSE
          -- SMS or email message failed to send after max attempts
          DBMS_OUTPUT.PUT_LINE(l_fallback_api || ' message failed to send after ' || l_max_attempts || ' attempts');
        END IF;
      END IF;
    END IF;
  END LOOP;
  
  IF NOT l_success THEN
    -- Viber message and SMS message both failed to send after max attempts
    DBMS_OUTPUT.PUT_LINE('Sending Viber message and fallback SMS message both failed after ' || l_max_attempts || ' attempts');
  END IF;
END;
