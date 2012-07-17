module HttpGetter

  def http_get(url)
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port) 
    http.open_timeout = 3
    http.read_timeout = 3
    response = http.request(Net::HTTP::Get.new(uri.request_uri))
    response.body
  end

end
