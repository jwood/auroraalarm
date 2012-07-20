Aurora::Application.routes.draw do
  match '/new_user' => 'site#new_user', :via => :post, :as => :new_user

  match '/incoming_sms_messages' => 'incoming_sms_messages#index', :via => :post, :as => :incoming_sms_messages

  root :to => 'site#index'
end
