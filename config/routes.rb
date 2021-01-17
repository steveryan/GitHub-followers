Rails.application.routes.draw do
    resources :followers, only: [:new, :index]
    root 'followers#new'
end
