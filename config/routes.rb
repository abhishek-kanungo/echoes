Rails.application.routes.draw do
  get '/auth/:provider/callback', to: 'api/v1/sessions#google_auth'
  get '/auth/failure', to: 'sessions#failure'
end
