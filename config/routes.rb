WADRCDataTools::Application.routes.draw do
  
  resources :scheduleruns

  resources :schedules

  resources :cg_query_tn_cns

  resources :cg_query_tns

  resources :cg_queries

  resources :cg_tn_cns

  resources :cg_tns

  resources :questionnaires

  resources :blooddraws

  resources :scan_procedures_vgroups

  resources :neuropsyches

  resources :vitals

  resources :petscans

  resources :lumbarpuncture_results

  resources :lookup_lumbarpunctures

  resources :lumbarpunctures

  resources :appointments

  resources :q_data

  resources :q_data_forms

  resources :question_scan_procedures

  resources :questionform_scan_procedures

  resources :question_scan_protocols

  resources :questionform_questions

  resources :questions

  resources :questionform_scan_protocols

  resources :questionforms

  resources :medicationdetails

  resources :employees

  resources :lookup_refs

  resources :lookup_switchboards

  resources :lookup_visitfrequencies

  resources :lookup_truthtables

  resources :lookup_statuses

  resources :lookup_sources

  resources :lookup_sets

  resources :lookup_scantasks

  resources :lookup_imagingplanes

  resources :lookup_relationships

  resources :lookup_recruitsources

  resources :lookup_pettracers

  resources :lookup_rads

  resources :lookup_pettraces

  resources :lookup_letterlabels

  resources :lookup_hardwares

  resources :lookup_genders

  resources :lookup_famhxes

  resources :lookup_ethnicities

  resources :lookup_eligibilityoutcomes

  resources :lookup_eligibility_ineligibilities

  resources :lookup_drugunits

  resources :lookup_drugfreqs

  resources :lookup_drugcodes

  resources :lookup_drugclasses

  resources :lookup_demographicmaritalstatuses

  resources :lookup_diagnoses

  resources :lookup_demographicrelativerelationships

  resources :lookup_demographicmaritialstatuses

  resources :lookup_demographicincomes

  resources :lookup_demographichandednesses

  resources :lookup_consentforms

  resources :lookup_consentcohorts

  resources :lookup_cohorts

  resources :lookup_cogstatuses

  resources :lookup_bvmtpercentiles

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
  match '/visit_search' , :controller => 'visits', :action => 'visit_search', :as =>:visit_search
  match '/mri_search' , :controller => 'visits', :action => 'mri_search', :as =>:mri_search
  match '/visits/mri_search' , :controller => 'visits', :action => 'mri_search', :as =>:mri_search
  match '/visits/change_directory_path', :controller => 'visits', :action => 'change_directory_path', :as =>:change_directory_path
  match '/visits/series_desc_cnt', :controller => 'visits', :action => 'series_desc_cnt', :as =>:series_desc_cnt
  
    match '/petscan_search' , :controller => 'petscans', :action => 'petscan_search', :as =>:petscan_search
    match '/pet_search' , :controller => 'petscans', :action => 'pet_search', :as =>:pet_search
    # match '/petscans/pet_search' , :controller => 'petscans', :action => 'pet_search', :as =>:pet_search
    match '/lumbarpuncture_search' , :controller => 'lumbarpunctures', :action => 'lumbarpuncture_search', :as =>:lumbarpuncture_search
    match '/lp_search' , :controller => 'lumbarpunctures', :action => 'lp_search', :as =>:lp_search
    # match '/lumbarpunctures/lp_search' , :controller => 'lumbarpunctures', :action => 'lp_search', :as =>:lp_search
    match '/blooddraw_search' , :controller => 'blooddraws', :action => 'blooddraw_search', :as =>:blooddraw_search
    match '/lh_search' , :controller => 'blooddraws', :action => 'lh_search', :as =>:lh_search
    match '/neuropsych_search' , :controller => 'neuropsyches', :action => 'neuropsych_search', :as =>:neuropsych_search
    match '/np_search' , :controller => 'neuropsyches', :action => 'np_search', :as =>:np_search
    match '/questionnaire_search' , :controller => 'questionnaires', :action => 'questionnaire_search', :as =>:questionnaire_search
    match '/q_search' , :controller => 'questionnaires', :action => 'q_search', :as =>:q_search
  
    match '/participant_search' , :controller => 'participants', :action => 'participant_search', :as =>:participant_search
  match '/cg_search' , :controller => 'data_searches', :action => 'cg_search', :as =>:cg_search
  match '/cg_tables' , :controller => 'data_searches', :action => 'cg_tables', :as =>:cg_tables
  match '/cg_edit_table/:id' , :controller => 'data_searches', :action => 'cg_edit_table', :as =>:cg_edit_table
    match '/cg_table_create_db' , :controller => 'data_searches', :action => 'cg_create_table_db', :as =>:cg_create_table_db
      match '/cg_table_edit_db' , :controller => 'data_searches', :action => 'cg_edit_table_db', :as =>:cg_edit_table_db
  match '/schedulerun_search' , :controller => 'scheduleruns', :action => 'schedulerun_search', :as =>:schedulerun_search
  match '/shared_file_upload' , :controller => 'shared', :action => 'file_upload', :as =>:file_upload
  
  match '/run_schedule/:id' ,:controller =>'schedules', :action => 'run_schedule', :as => :run_schedule
  
  match '/users/update_role', :controller => 'users', :action => 'update_role', :as => :update_role
  match '/users/control', :controller => 'users', :action => 'control', :as => :control
  match '/users/questionformbase', :controller => 'users', :action => 'questionformbase', :as => :questionformbase
  match '/users/cgbase', :controller => 'users', :action => 'cgbase', :as => :cgbase
  match '/users/add_user', :controller => 'users', :action => 'add_user', :as => :add_user
  match '/users/edit_user', :controller => 'users', :action => 'edit_user', :as => :edit_user
  match '/questionform/displayform/:id', :controller=>'questionforms',:action=>'displayform', :as => :displayform
  match '/questionform/editform/:id', :controller=>'questionforms',:action=>'editform', :as => :editform
    match '/questionform/question_enter', :controller=>'questionforms',:action=>'question_enter', :as => :question_enter
  # moved up to get precidance over devise sign_upmatch '/users/sign_up', :controller => 'users', :action => 'add_user', :as => :add_user
  
   match '/question/clone/:id', :controller=>'questions',:action=>'clone', :as => :clone
   
   #match '/vgroups/home', :controller => 'vgroups', :action => 'home', :as => :home
    match '/vgroups/home', :controller => 'vgroups', :action => 'vgroups_search', :as => :home
   match '/vgroups/vgroups_search', :controller => 'vgroups', :action => 'vgroups_search', :as => :vgroups_search
   match '/vgroups/complete', :to => 'vgroups#index_by_scope', :scope => 'complete', :as => :complete_vgroups
   match '/vgroups/incomplete', :to => 'vgroups#index_by_scope', :scope => 'incomplete', :as => :incomplete_vgroups
   match '/vgroups/recently_imported', :to => 'vgroups#index_by_scope', :scope => 'recently_imported', :as => :recently_imported_vgroups
   match '/vgroups/assigned_to/:user_login', :controller => 'vgroups', :action => 'index_by_user_id', :as => :assigned_to_vgroup
   match '/vgroups/in_scan_procedure/:scan_procedure_id', :controller => 'vgroups', :action => 'index_by_scan_procedure', :as => :in_scan_procedure_vgroup
   match '/vgroups/in_enumber/:enumber', :controller => 'vgroups', :action => 'index_by_enumber', :as => :in_enumber_vgroup
   #match '/vgroups/in_scan_procedure', :controller => 'vgroups', :action => 'home', :as => :home
   #match '/vgroups/in_enumber', :controller => 'vgroups', :action => 'home', :as => :home
   match '/vgroups/nii_file_cnt', :controller => 'vgroups', :action => 'nii_file_cnt', :as =>:nii_file_cnt
      
   match '/vgroups/vgroup_search' , :controller => 'vgroups', :action => 'vgroup_search', :as =>:vgroup_search
    match '/vgroups/change_qc_vgroup', :controller => 'vgroups', :action => 'change_qc_vgroup', :as =>:change_qc_vgroup
   match '/vgroups/change_appointment_vgroup', :controller => 'vgroups', :action => 'change_appointment_vgroup', :as =>:change_appointment_vgroup
   match '/vgroups/change_transfer_mri_vgroup', :controller => 'vgroups', :action => 'change_transfer_mri_vgroup', :as =>:change_transfer_mri_vgroup
   match '/vgroups/change_transfer_pet_vgroup', :controller => 'vgroups', :action => 'change_transfer_pet_vgroup', :as =>:change_transfer_pet_vgroup
   match '/vgroups/change_completedlumbarpuncture_vgroup', :controller => 'vgroups', :action => 'change_completedlumbarpuncture_vgroup', :as =>:change_completedlumbarpuncture_vgroup
   match '/vgroups/change_completedblooddraw_vgroup', :controller => 'vgroups', :action => 'change_completedblooddraw_vgroup', :as =>:change_completedblooddraw_vgroup
   match '/vgroups/change_completedneuropsych_vgroup', :controller => 'vgroups', :action => 'change_completedneuropsych_vgroup', :as =>:change_completedneuropsych_vgroup
   match '/vgroups/change_completedquestionnaire_vgroup', :controller => 'vgroups', :action => 'change_completedquestionnaire_vgroup', :as =>:change_completedquestionnaire_vgroup

  
   resources :vgroups
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
  resources :radiology_comments
  
  resources :visits, :shallow => true do
    resources :mriscantasks, :shallow => true do
      resources :mriperformances
    end
  end
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
  
  #CHANGED HERE!!!!!
#  resources :vgroups, :shallow => true do
#    resources :appointments
#  end
  
  resources :appointments, :shallow => true do
    resources :petscans
    resources :lumbarpunctures
    resources :visits
  end
  
  resources :lumbarpunctures, :shallow => true do
    resources :lumbarpuncture_results
  end

####  match '/signup', :controller => 'users', :action => 'new', :as => :signup
####  match '/login', :controller => 'sessions', :action => 'new', :as => :username
####  match '/logout', :controller => 'sessions', :action => 'destroy', :as => :logout

  root :to => "vgroups#vgroups_search" #"vgroups#home" #"visits#index"

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
