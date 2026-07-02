Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      root to: ->(env) { [200, { 'Content-Type' => 'application/json' }, [{ message: "Angelswing REST API v1 is online" }.to_json]] }

      post 'users/signup', to: 'users#signup'
      post 'auth/signin', to: 'auth#signin'

      # Singular 'content' route to match Postman collection GET /api/v1/content
      get 'content', to: 'contents#index'

      # Standard contents resource
      resources :contents, only: [:index, :create, :update, :destroy]
    end
  end

  root to: ->(env) { [200, { 'Content-Type' => 'application/json' }, [{ message: "Angelswing REST API is online" }.to_json]] }
end
