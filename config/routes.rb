Rails.application.routes.draw do
  get "participations/create"
  get "participations/destroy"
  get "/terms", to: "static_pages#terms", as: :terms
  get "/privacy", to: "static_pages#privacy", as: :privacy
  get "contact", to: "static_pages#contact"
<<<<<<< HEAD
  get 'auth/:provider/callback', to: 'sessions#create'
  get 'auth/failure', to: redirect('/')
  delete 'logout', to: 'sessions#destroy', as: 'logout'
=======
  get "how_to_use", to: "static_pages#how_to_use", as: :how_to_use

>>>>>>> 46dc497a9368836cbd3ea1e9dbf1c42aeabd5d09
  devise_for :users, controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations",
    passwords: "users/passwords",
    confirmations: "users/confirmations",
    omniauth_callbacks: "users/omniauth_callbacks"
  }

  # 未ログイン時の root（ログイン画面）
  devise_scope :user do
    unauthenticated :user do
      root to: "static_pages#top", as: :unauthenticated_root
    end
  end

  # ログイン後の root（ダッシュボード）
  authenticated :user do
    root to: "dashboard#index", as: :authenticated_root
    get "dashboard", to: "dashboard#index", as: :dashboard
  end

  resources :challenges, except: [ :edit, :update ] do
    resources :participations, only: [ :create, :destroy ]
    resource :wake_up_logs, only: [ :create ]
  end

  resource :mypage, only: [ :show, :edit, :update ] do
    get :calendar, on: :collection
    get :graph, on: :collection
  end

  # devise_for :users
  get "posts/index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
end
