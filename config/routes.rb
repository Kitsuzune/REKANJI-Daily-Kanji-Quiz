Rails.application.routes.draw do
  devise_for :users
  root 'home#index'
  
  get 'quiz', to: 'quiz#index'
  get 'quiz/practice/:level', to: 'quiz#practice', as: 'quiz_practice'
  get 'quiz/single/:level', to: 'quiz#single', as: 'quiz_single'
  get 'quiz/mixed', to: 'quiz#mixed'
  post 'quiz/answer', to: 'quiz#answer'
  get 'quiz/result', to: 'quiz#result'
  
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
