# Lockout IP addresses that are hammering your login page.
# After 20 requests in 1 minute, block all requests from that IP for 1 hour.
Rack::Attack.blocklist('allow2ban login scrapers') do |req|
  # `filter` returns false value if request is to your login page (but still
  # increments the count) so request below the limit are not blocked until
  # they hit the limit.  At that point, filter will return true and block.
  Rack::Attack::Allow2Ban.filter(req.env['HTTP_CF_CONNECTING_IP'], maxretry: 20, findtime: 1.day, bantime: 1.day) do
    # The count for the IP is incremented if the return value is truthy.
    req.path == '/api/v1/accounts' and req.post?
  end
end
