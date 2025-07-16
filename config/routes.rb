Rails.application.routes.draw do  
  mount Ckeditor::Engine => '/ckeditor'
  devise_for :tocs, controllers: {
        sessions: 'tocs/sessions',
        registrations: 'tocs/registrations',
        passwords: 'tocs/passwords',
        confirmations: 'tocs/confirmations',
        invitations: 'tocs/invitations',
        displayqrs: 'devise/displayqrs',
        checkgas: 'devise/checkgas'  
    } 
  mount RailsAdmin::Engine => '/toc', as: 'rails_admin'
  require 'sidekiq/web'
  authenticate :toc, lambda { |u| u.role.role.eql?"superadmin" } do
    mount Sidekiq::Web => '/sidekiq'
  end
  # root to: "tocs/sessions#new"
  devise_scope :toc do
    root to: 'tocs/sessions#new'
  end
  resources :cities, only: :index
  resources :states, only: :index
  resources :countries
  match "/get_job_applications", :controller=> "countries", :action=> "get_job_applications", :via=> :post
end
