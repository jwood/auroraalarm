class OutgoingSmsMessages
  class << self

    def signup_prompt
      "We have received a request to sign you up for SMS alerts when the northern lights are active in your area. Reply Y to confirm. Msg&data rates may apply."
    end

    def signup_confirmation
      "You are all set to be notified when the northern lights are active in your area! Text STOP to cancel. Text HELP for info. Msg&data rates may apply."
    end

  end
end
