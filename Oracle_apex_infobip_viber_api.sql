Oracle apex send viber messages with infobip api

To send Viber messages with Infobip API from Oracle Apex, you can use the APEX_WEB_SERVICE package to make an HTTP POST request to the Infobip REST API. Here is an example PL/SQL code snippet that sends a Viber message using the Infobip API:

sql
Copy code
DECLARE
  l_response CLOB;
  l_url VARCHAR2(4000) := 'https://api.infobip.com/viber/1/send';
  l_headers apex_web_service.t_param_list;
  l_body VARCHAR2(4000) := '{"messages":[{"content":{"text":"Hello, this is a Viber message!"},"destination":{"to":"{phone_number}","country":"{country_code}"}}]}';
BEGIN
  l_headers := apex_web_service.g_request_headers;
  apex_web_service.set_header(l_headers, 'Authorization', 'App {api_key}');
  apex_web_service.set_header(l_headers, 'Content-Type', 'application/json');
  l_response := apex_web_service.make_rest_request(
    p_url => l_url,
    p_http_method => 'POST',
    p_parm_name => apex_util.string_to_table('p_body'),
    p_parm_value => apex_util.string_to_table(l_body),
    p_header => l_headers
  );
END;
Replace the {phone_number} and {country_code} placeholders in the l_body variable with the phone number and country code of the recipient of the Viber message, respectively. Replace the {api_key} placeholder in the Authorization header with your Infobip API key.

Note that you need to have the APEX_WEB_SERVICE package installed and enabled in your Oracle Apex environment to use this code. You also need to have an Infobip account and an API key to authenticate your requests.



