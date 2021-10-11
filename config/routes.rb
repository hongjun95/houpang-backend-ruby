Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  begin
    ActiveAdmin.routes(self)
  rescue StandardError
    ActiveAdmin::DatabaseHitDuringLoad
  end

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  devise_scope :users do
    post "token" => "users/refresh#create"
  end

  devise_for :users,
             path: "",
             path_names: {
               sign_in: "login",
               sign_out: "logout",
               registration: "signup"
             },
             controllers: {
               sessions: "users/sessions",
               registrations: "users/registrations"
             }

  # category
  resources :categories
  get '/items/category/:id', to: 'items#get_items_by_category_id'

  # item
  get '/items/provider', to: 'items#get_items_from_provider'
  resources :items

  # like
  get '/likes', to: 'likes#show'
  put '/likes/items/:item_id/add', to: 'likes#like_item'
  put '/likes/items/:item_id/remove', to: 'likes#unlike_item'

  # orders
  get '/orders/consumer', to:'orders#get_orders_from_consumer'
  get '/orders/provider', to:'orders#get_orders_from_provider'
  get '/orders/:order_id', to:'orders#find_order_by_id'
  get '/orders/order_item/:order_item_id', to:'orders#find_order_item_by_id'
  post '/orders', to:'orders#create'
  put '/orders/order-item/:order_item_id', to:'orders#cancel_oder_item'
  put '/orders/order-item/:order_item_id/update', to:'orders#update_order_status'

  resources :images do
    post :dropzone, on: :collection
  end
end
