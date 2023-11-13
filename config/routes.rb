Rails.application.routes.draw do
  get 'convertidor_csv/index'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  root 'xml#index'
  get 'xml', to: 'xml#index'
  post 'xml/upload', to: 'xml#upload'
  post 'convertidor_csv/upload', to: 'convertidor_csv#upload'
  #get 'convertidor_csv#index'
  # Defines the root path route ("/")
  # root "articles#index"
end
