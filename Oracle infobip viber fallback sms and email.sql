DECLARE
  l_response CLOB;
BEGIN
  -- call Infobip API
  l_response := apex_web_service.make_rest_request(
    p_url         => 'https://api.infobip.com/sms/2/text/single',
    p_http_method => 'POST',
    p_parm_name   => apex_util.string_to_table('from,to,text'),
    p_parm_value  => apex_util.string_to_table('Sender,Recipient,Message'),
    p_header      => apex_util.string_to_table('Content-Type:application/json;charset=UTF-8,Authorization:Basic YOUR_API_KEY')
  );

  -- check if Infobip API call was successful
  IF l_response IS NOT NULL AND l_response like '%"status":"0"%' THEN
    apex_debug.info('Message sent using Infobip API');
  ELSE
    -- call SMS API provider as fallback
    l_response := apex_web_service.make_rest_request(
      p_url         => 'https://api.smsprovider.com/sms/send',
      p_http_method => 'POST',
      p_parm_name   => apex_util.string_to_table('from,to,text'),
      p_parm_value  => apex_util.string_to_table('Sender,Recipient,Message'),
      p_header      => apex_util.string_to_table('Content-Type:application/json;charset=UTF-8,Authorization:Bearer YOUR_API_KEY')
    );

    -- check if SMS API call was successful
    IF l_response IS NOT NULL AND l_response like '%"status":"success"%' THEN
      apex_debug.info('Message sent using SMS API provider');
    ELSE
      -- send email as last fallback option
      apex_mail.send(
        p_to       => 'recipient@email.com',
        p_from     => 'sender@email.com',
        p_subject  => 'Message fallback notification',
        p_body     => 'The message could not be delivered via Infobip or SMS API, so it was sent via email.'
      );
      apex_debug.info('Message sent using email');
    END IF;
  END IF;
END;
