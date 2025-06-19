Rails.application.routes.draw do
  devise_for :users
  root 'home#index'
  
  # Quiz routes with new structure
  get 'quiz', to: 'quiz#index'
  get 'quiz/single/:level', to: 'quiz#single', as: 'quiz_single'
  get 'quiz/multiple/:level', to: 'quiz#multiple', as: 'quiz_multiple'
  post 'quiz/answer', to: 'quiz#answer'
  get 'quiz/result', to: 'quiz#result'
  
  # Exam routes
  get 'exam', to: 'exam#index'
  get 'exam/history', to: 'exam#history'
  post 'exam/start', to: 'exam#start'
  get 'exam/:id', to: 'exam#show', as: 'exam_show'
  post 'exam/:id/answer', to: 'exam#answer', as: 'exam_answer'
  get 'exam/:id/result', to: 'exam#result', as: 'exam_result'
  
  # Learn routes
  get 'learn', to: 'learn#index', as: 'learn'
  get 'learn/:type/:id', to: 'learn#show', as: 'learn_show'
  
  # Admin routes (only for superadmin)
  namespace :admin do
    resources :users
    resources :kanji_singles
    resources :kanji_multiples
    root 'dashboard#index'
  end
  
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
