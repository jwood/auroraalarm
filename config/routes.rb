Aurora::Application.routes.draw do
  match '/new_user' => 'site#new_user', :via => :post, :as => :new_user

  match '/incoming_sms_messages' => 'incoming_sms_messages#index', :via => :post, :as => :incoming_sms_messages

  match '/cron/alert_users_of_solar_event' => 'cron#alert_users_of_solar_event', :via => :post, :as => :cron_alert_users_of_solar_event

  root :to => 'site#index'
end
