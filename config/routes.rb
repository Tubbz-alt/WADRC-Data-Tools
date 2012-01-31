WADRCDataTools::Application.routes.draw do
  
  resources :radiology_comments

  resources :protocol_roles
  resources :protocols
   match '/users/sign_up', :controller => 'users', :action => 'add_user', :as => :add_user
   # want to use adminrole limited add user form instead of devise
  devise_for :users

  resources :physiology_text_files
  resources :neuropsych_assessments
  resources :neuropsych_sessions
  
  match '/visits/found(.:format)', :to => 'visits#found', :as => :found_visits
  match '/visits/find', :to => 'visits#find', :as => :find_visits
  match '/visits/complete', :to => 'visits#index_by_scope', :scope => 'complete', :as => :complete_visits
  match '/visits/incomplete', :to => 'visits#index_by_scope', :scope => 'incomplete', :as => :incomplete_visits
  match '/visits/recently_imported', :to => 'visits#index_by_scope', :scope => 'recently_imported', :as => :recently_imported_visits
  match '/visits/assigned_to/:user_login', :controller => 'visits', :action => 'index_by_user_id', :as => :assigned_to
  match '/visits/in_scan_procedure/:scan_procedure_id', :controller => 'visits', :action => 'index_by_scan_procedure', :as => :in_scan_procedure
  match '/visits/visit_search' , :controller => 'visits', :action => 'visit_search', :as =>:visit_search
  
  match '/users/update_role', :controller => 'users', :action => 'update_role', :as => :update_role
  match '/users/control', :controller => 'users', :action => 'control', :as => :control
  match '/users/add_user', :controller => 'users', :action => 'add_user', :as => :add_user
  match '/users/edit_user', :controller => 'users', :action => 'edit_user', :as => :edit_user
  # moved up to get precidance over devise sign_upmatch '/users/sign_up', :controller => 'users', :action => 'add_user', :as => :add_user
  
    
  resources :studies
  resources :recruitment_groups
  resources :withdrawls
  resources :enrollments
  resources :series_descriptions
  resources :participants
  resources :analysis_memberships
  resources :users
#  resource :session
  resources :image_datasets, :shallow => true do # |image_dataset|
    resources :image_comments,:image_dataset_quality_checks
  end
  
  resources :visits
  resources :roles
  resources :raw_image_files
  resources :analyses
  resources :image_searches
  # resources :image_datasets, :shallow => true do |image_dataset|
  #   image_dataset.resources :image_comments
  #   image_dataset.resources :image_dataset_quality_checks
  # end
  resources :image_dataset_quality_checks, :only => [:index]
  resources :image_comments, :only => [:index]
  resources :scan_procedures
  resources :log_files
  resources :raw_data_imports
  
  

####  match '/signup', :controller => 'users', :action => 'new', :as => :signup
####  match '/login', :controller => 'sessions', :action => 'new', :as => :username
####  match '/logout', :controller => 'sessions', :action => 'destroy', :as => :logout

  root :to => "visits#index"

  match ':controller(/:action(/:id(.:format)))'

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
