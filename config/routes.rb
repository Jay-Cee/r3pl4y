Replay::Application.routes.draw do
  match '/suggestions/rss' => 'suggestions#rss'
  resources :suggestions do
      member do
        get 'preview'
        get 'accept'
        get 'deny'
      end
  end

  devise_for :users, :controllers => { :omniauth_callbacks => 'omniauth_callbacks' } do
		get 'sign_in', :to => 'users/sessions#new', :as => :new_user_session
		get 'sign_out', :to => 'users/sessions#destroy', :as => :destroy_user_session		
	end

	resources :users, :only =>  [:index, :show] do
		resources :reviews do
			collection do
				get 'your'
			end
		end
	end

	match '/reviews/new/:game_id' => 'reviews#new'

	match '/users/:name/followers' => 'users#followers'
	match '/users/:name/following' => 'users#following'
	match '/users/:name/following_template' => 'users#following_template'
	match '/users/:name/followers_template' => 'users#followers_template'
	match '/users/:name/statistics' => 'users#stats'
	match '/users/:name/lists/:rating' => 'users#lists'
	match '/users/:name/invite/:invite_phrase' => 'users#invite'


	match '/sign_up' => 'sign_up#index'
	match '/sign_up/new' => 'sign_up#new'

  match '/stats/new-users' => 'stats#new_users'
  match '/stats/new-reviews' => 'stats#new_reviews'

  resources :tags


  resources :games
    match '/games/:slug/new-review' => 'games#new_review'
	match '/games/import'
	match '/games_oldest' => 'games#oldest'
	match '/games/:slug/reviews' => 'games#reviews'
	match '/games/:slug/duplicates' => 'games#duplicates'
	match '/games/:slug/merge/:with' => 'games#merge'

	resources :invites
	
	match '/profile' => 'profile#index'
	match '/profile/start' => 'profile#start'
	match '/profile/timeline' => 'profile#timeline'
	match '/profile/follow/:name' => 'profile#follow'
	match '/profile/unfollow/:name' => 'profile#unfollow'

	match '/search' => 'search#index'

  match '/import' => 'import#index'
  match '/import/perform' => 'import#perform'

	match '/site' => 'site#index'
	match '/site/tumblr' => 'site#tumblr'

  get "home/index"

	match '/donate' => 'donate#index'

  root :to => "home#index"

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
