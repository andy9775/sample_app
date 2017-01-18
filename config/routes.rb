Rails.application.routes.draw do
  # calling context is: #<ActionDispatch::Routing::Mapper:0x007f8114f55b80>
  # a class instance
  # has methods of ActionDispatch::Routing::Mapper -> get, resources, ...

  root 'static_pages#home'

  get '/help', to: 'static_pages#help'

  # we can set the path helper using 'as'. In this case we would use
  # helf_url and helf_path.
  # this is useful if we have a long path and want to shorten its name
  #  get '/help', to: 'static_pages#help', as: 'helf'

  get '/about', to: 'static_pages#about'
  get '/contact', to: 'static_pages#contact'
  get '/signup', to: 'users#new'
  post '/signup', to: 'users#create'
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'
  resources :users, except: [:new] # disable /users/new route
end
