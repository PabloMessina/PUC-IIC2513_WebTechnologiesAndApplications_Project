Rails.application.routes.draw do

  root 'home#index'

  namespace :admin do
    resources :users
    resources :groceries
    resources :products
  end

  resources :users, only: [:show, :new, :create, :edit, :update]
  resources :groceries do
    resources :products, controller: 'grocery_products'    
    resources :purchase_orders
    resources :reports
  end

  resources :reports, only:[] do
    resources :comments, only:[:index,:create], controller: 'report_comments'
  end

  resources :sessions, only: [:new, :create, :destroy]
  resources :products, only: [:index] do
    resources :reviews, only: [:show, :new, :create, :index, :edit, :update, :destroy]
  end


  match '/signup',    to: 'users#new',            via: 'get'
  match '/signin',    to: 'sessions#new',         via: 'get'
  match '/signout',   to: 'sessions#destroy',     via: 'delete'

  match '/groceries/:grocery_id/rate_product/:id', to: 'grocery_products#rate_product', via: 'post', as: 'rate_product'

  match '/groceries/:grocery_id/follow', to: 'groceries#follow', via: 'post', as: 'grocery_follow'
  match '/groceries/:grocery_id/unfollow', to: 'groceries#unfollow', via: 'post', as: 'grocery_unfollow'

  match '/reviews/:review_id/comments/new', to: 'review_comments#create', via: 'post', as: 'post_new_comment'
  match '/reviews/:review_id/comments', to: 'review_comments#index', via: 'get', as: 'review_comments'

  match '/groceries/:id/search_products', to: 'groceries#search_products', via: 'get', as: 'search_products'

  match '/search_groceries', to: 'search#groceries', via: 'get'
  match '/search_products',  to: 'search#products',  via: 'get'

  match '/users/:id/feed', to: 'users#news_feed', via: 'get', as:'user_news_feed'
  match '/users/:id/posted_news', to: 'users#posted_news', via: 'get', as: 'user_posted_news'
  match '/users/:id/following_groceries', to: 'users#following_groceries', via: 'get', as: 'user_following_groceries'
  match '/users/:id/associated_groceries', to: 'users#associated_groceries', via: 'get', as: 'user_associated_groceries'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
