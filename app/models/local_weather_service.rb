class LocalWeatherService
  include HttpGetter

  def cloud_cover_percentage(user)
    Rails.cache.fetch("cloud_cover_percentage:user_#{user.id}", :expires_in => 1.hour) do
      data = http_get(request_url(user.user_location))
      doc = Nokogiri::XML(data)
      element = doc.xpath('//cloud-amount/value').first
      element ? element.text.to_i : nil
    end
  end

  private

  def request_url(user_location)
    url =  "http://graphical.weather.gov/xml/sample_products/browser_interface/ndfdXMLclient.php?"
    url << "lat=#{user_location.latitude}"
    url << "&lon=#{user_location.longitude}"
    url << "&product=time-series"
    url << "&Unit=e"
    url << "&sky=sky"
    url
  end

end
