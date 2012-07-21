class OutgoingSmsMessages
  class << self

    def signup_prompt
      "We have received a request to sign you up for SMS alerts when the northern lights are active in your area. Reply Y to confirm. Msg&data rates may apply."
    end

    def signup_confirmation
      "You are all set to be notified when the northern lights are active in your area! Text STOP to cancel. Text HELP for info. Msg&data rates may apply."
    end

    def zipcode_prompt
      "Thanks for signing up to be notified when the northern lights are active in your area. Please reply with your zip code to complete your signup."
    end

  end
end
