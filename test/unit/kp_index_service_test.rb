require 'test_helper'

class KpIndexServiceTest < ActiveSupport::TestCase

  def setup
    @service = KpIndexService.new
  end

  should "be able to fetch the most recent Kp forecast" do
    body = File.read(File.expand_path('../../data/wingkp_list.txt', __FILE__))
    FakeWeb.register_uri(:get, "http://www.swpc.noaa.gov/wingkp/wingkp_list.txt", :body => body)
    assert_equal [Time.utc(2012, 7, 17, 21, 50), 3.67], @service.current_forecast
  end

  should "not freak out if we could not fetch the data" do
    FakeWeb.register_uri(:get, "http://www.swpc.noaa.gov/wingkp/wingkp_list.txt", :body => "")
    assert_nil @service.current_forecast
  end

end
