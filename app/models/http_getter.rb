module HttpGetter

  def http_get(url)
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port) 
    http.open_timeout = 10
    http.read_timeout = 10
    response = http.request(Net::HTTP::Get.new(uri.request_uri))
    response.body
  rescue Timeout::Error => e
    Rails.logger.error e.message_with_backtrace
    nil
  end

end
