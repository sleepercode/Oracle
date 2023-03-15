
Infobip Viber API Integration.


To use Infobip API to send Viber messages in Oracle Apex, you will need to follow the steps below:

Sign up for an Infobip account and create a Viber messaging service.
Obtain an API key from Infobip. This will be used to authenticate your requests.
In Oracle Apex, create a web service reference to the Infobip API. To do this, navigate to the "Shared Components" section of your application, select "Web Service References", and click "Create". Enter the URL for the Infobip API endpoint (e.g. https://api.infobip.com/viber/1/message), select "REST" as the type, and enter your API key in the appropriate field.
Create a PL/SQL function that uses the web service reference to send Viber messages. This function should take in parameters such as the recipient's phone number, the message text, and any additional options (such as message type or image URL). Here is an example function:
sql
Copy code
function send_viber_message(p_phone_number in varchar2, p_message_text in varchar2, p_message_type in varchar2 default 'text', p_image_url in varchar2 default null) return varchar2 is
  l_url varchar2(4000);
  l_request utl_http.req;
  l_response utl_http.resp;
  l_body varchar2(32767);
  l_result varchar2(4000);
begin
  -- Construct the API request URL
  l_url := 'https://api.infobip.com/viber/1/message';
  
  -- Set up the HTTP request
  l_request := utl_http.begin_request(l_url, 'POST', 'HTTP/1.1');
  utl_http.set_header(l_request, 'Content-Type', 'application/json');
  utl_http.set_header(l_request, 'Authorization', 'App '||'{your_api_key}');
  
  -- Construct the JSON payload
  l_body := '{"destinations":[{"to":"'||p_phone_number||'"}],"text":"'||p_message_text||'","type":"'||p_message_type||'"}';
  if p_message_type = 'picture' and p_image_url is not null then
    l_body := l_body||',"image":"'||p_image_url||'"';
  end if;
  
  -- Send the request and get the response
  utl_http.set_body_charset(l_request, 'UTF-8');
  utl_http.set_body_length(l_request, length(l_body));
  utl_http.write_text(l_request, l_body);
  l_response := utl_http.get_response(l_request);
  l_result := utl_http.get_response_text(l_response);
  
  -- Clean up and return the result
  utl_http.end_response(l_response);
  return l_result;
exception
  when others then
    return sqlerrm;
end;
You can then call the send_viber_message function from within your Oracle Apex application whenever you want to send a Viber message. For example:
ruby
Copy code
begin
  send_viber_message('1234567890', 'Hello, world!', 'text');
end;
Note that this is just an example function and you may need to modify it to fit your specific use case. Also, be sure to replace {your_api_key} with your actual Infobip API key.
