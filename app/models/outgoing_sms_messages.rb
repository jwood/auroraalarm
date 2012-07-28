class OutgoingSmsMessages
  class << self

    def signup_prompt
      "We have received a request to sign you up for SMS alerts when the northern lights are active in your area. Reply Y to confirm. #{msg_and_data_rates}"
    end

    def signup_confirmation
      "You are all set to be notified when the northern lights are active in your area! #{stop_text} #{help} #{msg_and_data_rates}"
    end

    def location_prompt
      "To sign up to be notified when the northern lights are active in your area, please text AURORA followed by your zip code."
    end

    def bad_location_at_signup
      "Sorry, we didn't see a zip code in that message. Please text AURORA followed by your zip code."
    end

    def already_signed_up
      "You are already signed up to be notified when the northern lights are active in your area. #{stop_text} #{help} #{msg_and_data_rates}"
    end

    def stop
      "You will no longer be notified when the northern lights are active in your area. Sorry to see you go. #{help} #{msg_and_data_rates}"
    end

    def location_update(location)
      "You have successfully updated your location to #{location}. #{help} #{msg_and_data_rates}"
    end

    def international_location
      "Sorry, but only locations inside the US are supported at this time. #{help} #{msg_and_data_rates}"
    end

    def storm_prompt(geomagnetic_storm)
      "A #{geomagnetic_storm.description} (#{geomagnetic_storm.scale}) geomagnetic storm is expected over the next 72 hours. Would you like to be woken up if the northern lights are viewable in your area?"
    end

    def approved_alert_permission
      "Thanks. You will be notified if this storm produces northern lights in your area over the next 72 hours. #{help} #{msg_and_data_rates}"
    end

    def declined_alert_permission
      "Thanks. You will not be notified if this storm produces northern lights in your area. #{help} #{msg_and_data_rates}"
    end

    private

    def stop_text
      "Text STOP to cancel."
    end

    def msg_and_data_rates
      "Msg&data rates may apply."
    end

    def help
      "Text HELP for info."
    end

  end
end
