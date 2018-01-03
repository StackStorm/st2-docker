#
# nginx configuration to expose st2 webui, redirect HTTP->HTTPS,
# provide SSL termination, and reverse-proxy st2api and st2auth API endpoint.
# To enable:
#    cp ${LOCATION}/st2.conf /etc/nginx/sites-available
#    ln -l /etc/nginx/sites-available/st2.conf /etc/nginx/sites-enabled/st2.conf
# see https://docs.stackstorm.com/install.html for details

server {
  listen *:80 default_server;

  add_header Front-End-Https on;
  add_header X-Content-Type-Options nosniff;

  if ($ssl_protocol = "") {
       return 301 https://$host$request_uri;
  }

  index  index.html;

  access_log /var/log/nginx/st2webui.access.log combined;
  error_log /var/log/nginx/st2webui.error.log;
}

server {
  listen       *:443 ssl;

  ssl on;

  ssl_certificate           /etc/ssl/st2/st2.crt;
  ssl_certificate_key       /etc/ssl/st2/st2.key;
  ssl_session_cache         shared:SSL:10m;
  ssl_session_timeout       5m;
  ssl_protocols             TLSv1 TLSv1.1 TLSv1.2;
  ssl_ciphers               EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH:ECDHE-RSA-AES128-GCM-SHA384:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA128:DHE-RSA-AES128-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES128-GCM-SHA128:ECDHE-RSA-AES128-SHA384:ECDHE-RSA-AES128-SHA128:ECDHE-RSA-AES128-SHA:ECDHE-RSA-AES128-SHA:DHE-RSA-AES128-SHA128:DHE-RSA-AES128-SHA128:DHE-RSA-AES128-SHA:DHE-RSA-AES128-SHA:AES128-GCM-SHA384:AES128-GCM-SHA128:AES128-SHA128:AES128-SHA128:AES128-SHA:AES128-SHA:HIGH:!aNULL:!eNULL:!EXPORT:!DES:!MD5:!PSK:!RC4;
  ssl_prefer_server_ciphers on;

  index  index.html;

  access_log            /var/log/nginx/ssl-st2webui.access.log combined;
  error_log             /var/log/nginx/ssl-st2webui.error.log;

  add_header              Front-End-Https on;
  add_header              X-Content-Type-Options nosniff;

  resolver {{ env['ST2WEB_DNS_RESOLVER'] | default('127.0.0.1') }} valid=10s ipv6=off;

  location @apiError {
    add_header Content-Type application/json always;
    return 503 '{ "faultstring": "Nginx is unable to reach st2api. Make sure service is running." }';
  }

  location /api/ {
    error_page 502 = @apiError;

    set $st2_api_url {{ env['ST2_API_URL'] | striptrailingslash }};

    rewrite ^/api/(.*)  /$1 break;

    proxy_pass            $st2_api_url$uri$is_args$args;
    proxy_read_timeout    90;
    proxy_connect_timeout 90;
    proxy_redirect        off;

    proxy_set_header      Host $host;
    proxy_set_header      X-Real-IP $remote_addr;
    proxy_set_header      X-Forwarded-For $proxy_add_x_forwarded_for;

    proxy_set_header Connection '';
    chunked_transfer_encoding off;
    proxy_buffering off;
    proxy_cache off;
    proxy_set_header Host $host;
  }

  location @streamError {
    add_header Content-Type text/event-stream;
    return 200 "retry: 1000\n\n";
  }

  # For backward compatibility reasons, rewrite requests from "/api/stream"
  # to "/stream/v1/stream" and "/api/v1/stream" to "/stream/v1/stream"
  location /api/stream {
    rewrite ^/api/stream/?(.*)$ /stream/v1/stream/$1 last;
  }
  location /api/v1/stream {
    rewrite ^/api/v1/stream/?(.*)$ /stream/v1/stream/$1 last;
  }
  location /stream/ {
    error_page 502 = @streamError;

    set $st2_stream_url {{ env['ST2_STREAM_URL'] | striptrailingslash }};

    rewrite ^/stream/(.*)  /$1 break;

    proxy_pass  $st2_stream_url$uri$is_args$args;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;

    # Disable buffering and chunked encoding.
    # In the stream case we want to receive the whole payload at once, we don't
    # want multiple chunks.
    proxy_set_header Connection '';
    chunked_transfer_encoding off;
    proxy_buffering off;
    proxy_cache off;
  }

  location @authError {
    add_header Content-Type application/json always;
    return 503 '{ "faultstring": "Nginx is unable to reach st2auth. Make sure service is running." }';
  }

  location /auth/ {
    error_page 502 = @authError;

    set $st2_auth_url {{ env['ST2_AUTH_URL'] | striptrailingslash }};

    rewrite ^/auth/(.*)  /$1 break;

    proxy_pass            $st2_auth_url$uri$is_args$args;
    proxy_read_timeout    90;
    proxy_connect_timeout 90;
    proxy_redirect        off;

    proxy_set_header      Host $host;
    proxy_set_header      X-Real-IP $remote_addr;
    proxy_set_header      X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_pass_header     Authorization;

    proxy_set_header Connection '';
    chunked_transfer_encoding off;
    proxy_buffering off;
    proxy_cache off;
    proxy_set_header Host $host;
  }

  location / {
    root      /opt/stackstorm/static/webui/;
    index     index.html;

    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
  }
}
