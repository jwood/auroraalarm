Aurora::Application.routes.draw do
  match '/new_user' => 'site#new_user', :via => :post, :as => :new_user

  root :to => 'site#index'
end
