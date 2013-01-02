module Stubs
  class StubbedLocalWeatherService

    def initialize(cloud_cover)
      @cloud_cover = cloud_cover
    end

    def cloud_cover_percentage(user)
      @cloud_cover
    end

  end
end
