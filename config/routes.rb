Aurora::Application.routes.draw do
  post '/new_user' => 'site#new_user', :as => :new_user

  post '/incoming_sms_messages' => 'incoming_sms_messages#index', :as => :incoming_sms_messages

  post '/cron/alert_users_of_solar_event' => 'cron#alert_users_of_solar_event', :as => :cron_alert_users_of_solar_event
  post '/cron/alert_users_of_aurora' => 'cron#alert_users_of_aurora', :as => :cron_alert_users_of_aurora
  post '/cron/cleanup' => 'cron#cleanup', :as => :cron_cleanup

  get '/test' => 'test#index'
  post '/test/alert_users_of_solar_event' => 'test#alert_users_of_solar_event'
  post '/test/alert_users_of_aurora' => 'test#alert_users_of_aurora'
  post '/test/send_message' => 'test#send_message'
  get '/test/status' => 'test#status'

  root :to => 'site#index'
end
