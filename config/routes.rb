Rails.application.routes.draw do
  resources :colour_palettes, :only => [:index]

  post 'most_used_colours', to: 'most_used_colours#index'

  get '/colours', to: 'colours#show', constraints:  lambda {|req| req.params.key?(:rgb) }
  resources :colours, :only => [:index]

  resources :currencies, :only => [:index, :show]

  get '/fonts', to: 'fonts#show', constraints: lambda {|req| req.params.key?(:ids) }
  resources :fonts, only: [:index]

  get '/graphics', to: 'graphics#show', constraints: lambda {|req| req.params.key?(:ids) }
  get '/graphics', to: 'graphics#index_by_tags', constraints: lambda {|req| req.params.key?(:tags) }
  resources :graphics, :only => [:index, :show]

  resources :manufacturers, :only => [:index]
  resources :order_kits
  resources :product_lines, :only => [:index, :show]
  resources :prompted_features, :only => [:index]
  resources :linked_features, :only => [:index]
  resources :regions, :only => [:index, :show]
  resources :countries, :only => [:index, :show] do
      resource :address_format, :only => [:show]
  end

  resources :rule_sets, :only => [:index]
  resources :shipping_options, :only => [:index]
  resources :tags
  resources :target_categories, :only => [:index]
  resources :target_kits, :only => [:index, :show]
  resources :targets, :only => [:index, :show]
  resources :themes, :only => [:index]
  resources :use_categories, :only => [:index]
  resources :uses, :only => [:index]
end
