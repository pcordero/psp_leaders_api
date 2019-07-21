Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  # concern :api_base do
  #   resources :leaders
  #   resources :states do
  #     resources :leaders do
  #       collection do
  #         get 'us_senate'
  #         get 'us_house'
  #         get 'state_senate'
  #         get 'state_house'
  #       end
  #     end
  #   end
  # end

  # namespace :v1 do
  #   concerns :api_base
  # end

  #get '/leaders/:id', to: 'leaders#show'

  # wget http://localhost:8080/v1/leaders/us-rep-ron-paul
  get '/v1/leaders/:id', to: 'leaders#show'

  # wget http://localhost:3010/states/fl
  # wget http://localhost:3010/states/IN/leaders/state_senate
  # wget http://localhost:3010/states/FL/leaders/state_senate

  #wget http://localhost:8080/v1/states/fl
  get '/v1/states/:id', to: 'leaders#states'

  #wget http://localhost:8080/v1/states/fl/us_senate
  get '/v1/states/:state_id/us_senate', to: 'leaders#us_senate'
  get '/v1/states/:state_id/leaders/us_senate', to: 'leaders#us_senate'

  #wget http://localhost:8080/v1/states/fl/us_house
  get '/v1/states/:state_id/us_house', to: 'leaders#us_house'
  get '/v1/states/:state_id/leaders/us_house', to: 'leaders#us_house'

  #wget http://localhost:8080/v1/states/fl/state_senate
  get '/v1/states/:state_id/state_senate', to: 'leaders#state_senate'
  get '/v1/states/:state_id/leaders/state_senate', to: 'leaders#state_senate'

  #/v1/states/ak/leaders/us_senate
  get '/v1/states/:state_id/us_senate', to: 'leaders#us_senate'
  get '/v1/states/:state_id/leaders/us_senate', to: 'leaders#us_senate'

  #wget http://localhost:8080/v1/states/fl/state_house
  # http://localhost:9292/v1/states/ak/leaders/state_house
  get '/v1/states/:state_id/state_house', to: 'leaders#state_house'
  get '/v1/states/:state_id/leaders/state_house', to: 'leaders#state_house'

  #wget http://localhost:8080/v1/states/va/leaders
  get '/v1/states/:state_id/leaders', to: 'leaders#leaders'

  # F, [2018-07-12T12:25:21.764888 #19004] FATAL -- : [a54266b8-063c-441d-bc04-1776a94aeb5c] ActionController::RoutingError (No route matches [GET] "/v1/states/oh/leaders/us_senate")

  #get '/v1/states', to: ''

  #/v1/states/fl/leaders
  ###get '/v1/states/:id/leaders', to: 'leaders#states'
  #namespace :v1 do
  #concerns :api_base do
  #resources :v1 do
  resources :leaders
  resources :states do
    #get 'show'
    resources :leaders do
      collection do
        get 'us_senate'
        get 'us_house'
        get 'state_senate'
        get 'state_house'
      end
    end
    #end
end

  # namespace :v1 do
  #   concerns :api_base
  # end
  #end
end
