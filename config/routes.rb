Aurora::Application.routes.draw do
  match '/new_user' => 'site#new_user', :via => :post, :as => :new_user

  match '/incoming_sms_messages' => 'incoming_sms_messages#index', :via => :post, :as => :incoming_sms_messages

  match '/cron/alert_users_of_solar_event' => 'cron#alert_users_of_solar_event', :via => :post, :as => :cron_alert_users_of_solar_event
  match '/cron/alert_users_of_aurora' => 'cron#alert_users_of_aurora', :via => :post, :as => :cron_alert_users_of_aurora
  match '/cron/cleanup' => 'cron#cleanup', :via => :post, :as => :cron_cleanup

  root :to => 'site#index'
end
