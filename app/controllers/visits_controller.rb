class VisitsController <  AuthorizedController #  ApplicationController
    load_resource
     load_and_authorize_resource  :only => [:show, :edit, :update]  #-- causes problems with the searches, but seems to be needed for the edit, show
    
    
    # to get the ussr scan_procedure array in
    # added in below by find
  
    before_filter :set_current_tab
    
  # GET /visits
  # GET /visits.xml  
  def index

    scan_procedure_array =current_user[:view_low_scan_procedure_array]
    # Remove default scope if sorting has been requested.
    if !params[:search].blank? && !params[:search][:meta_sort].blank?
      @search = Visit.unscoped.search(params[:search]) 
    else
      @search = Visit.search(params[:search]) 
    end
    @visits = @search.relation.where(" visits.id in (select visit_id from scan_procedures_visits where scan_procedure_id in (?))", scan_procedure_array).page(params[:page])
    @collection_title = 'All MRI appts'
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @visits }
    end
  end

  # GET /visits/:scope
  def index_by_scope

    scan_procedure_array =current_user[:view_low_scan_procedure_array]
    @search = Visit.send(params[:scope]).search(params[:search])
    @visits = @search.relation.where("visits.id in (select visit_id from scan_procedures_visits where scan_procedure_id in (?))", scan_procedure_array).page(params[:page])
    @collection_title = "All #{params[:scope].to_s.gsub('_',' ')} MRI appts"
    render :template => "visits/index"
  end
  
  def assigned_to_who
    redirect_to assigned_to_path( :user_login => params[:user][:username] )
  end
  
  # GET /visits/assigned_to/:user_login
  def index_by_user_id

    scan_procedure_array =current_user[:view_low_scan_procedure_array]
    
    @user = User.find(params[:user_login])
    @search = Visit.assigned_to(@user.id).search
    @visits = @search.relation.where("visits.id in (select visit_id from scan_procedures_visits where scan_procedure_id in (?))", scan_procedure_array).page(params[:page])
    
    @collection_title = "All MRI appts assigned " # to #{params[:user_login]}"
    @visits = nil
    render :template => "visits/index"
  end
  
  def in_scan_procedure
    redirect_to in_scan_procedure_path( :scan_procedure_id => params[:scan_procedure][:id] )
  end

  def index_by_scan_procedure  


    scan_procedure_array =current_user[:view_low_scan_procedure_array]
    # sp = ScanProcedure.find_by_id(params[:scan_procedure_id])
    if !params[:search].blank? && !params[:search][:meta_sort].blank?
      @search = Visit.unscoped.includes(:scan_procedures).where(:scan_procedures => {:id => params[:scan_procedure_id]}).search(params[:search])
    else
      @search = Visit.includes(:scan_procedures).where(:scan_procedures => {:id => params[:scan_procedure_id]}).search
    end
    @visits =  @search.relation.where("visits.id in (select visit_id from scan_procedures_visits where scan_procedure_id in (?))", scan_procedure_array).page(params[:page])   
    
    @collection_title = "All MRI appts enrolled in #{ScanProcedure.find_by_id(params[:scan_procedure_id]).codename}"
    
    
    render :template => "visits/index"

  end
  
  # GET /visits/by_month
  def by_month

    scan_procedure_array =current_user[:view_low_scan_procedure_array]
    @visits = Visit.relation.where("visits.id in (select visit_id from scan_procedures_visits where scan_procedure_id in (?))", scan_procedure_array).all
    @title = "Visits by month"
    @collection_title = "MRI appts by month"
    @total_count = @visits.size
    
    render :template => "visits/index_by_month"
  end
  
  # GET /visits/found
  def found

    scan_procedure_array =current_user[:view_low_scan_procedure_array]   
    @visits = Visit.find_by_search_params(params['visit_search']).where("visits.id in (select visit_id from scan_procedures_visits where scan_procedure_id in (?))", scan_procedure_array).page(params[:page])
    @collection_title = "Found MRI appts"
    @visit_search = params['visit_search']
    
    if @visits.size == 1
      @visit = @visits.first
      flash[:notice] = "Found 1 MRI appt matching that search."
      respond_to do |format|
        format.xml  { render :xml => @visit }
        format.html { redirect_to @visit }
      end
      
    else
      render :template => "visits/found"
    end
  end


   
  
  # GET /visits/find
  def find
    scan_procedure_array =current_user[:view_low_scan_procedure_array]
    @search = Visit.where("visits.id in (select visit_id from scan_procedures_visits where scan_procedure_id in (?))", scan_procedure_array).search(params[:search])
  end

  # GET /visits/1
  # GET /visits/1.xml
  def show
    scan_procedure_array =current_user[:view_low_scan_procedure_array]
  
    @visit = Visit.where("visits.id in (select visit_id from scan_procedures_visits where scan_procedure_id in (?))", scan_procedure_array).find_by_id(params[:id])
    # Grab the visits within 1 month +- visit date for "previous" and "back" hack.
    @visits = Visit.where(:date => @visit.date-1.month..@visit.date+1.month).all
    idx = @visits.index(@visit)
    @older_visit = idx + 1 >= @visits.size ? nil : @visits[idx + 1]
    @newer_visit = idx - 1 < 0 ? nil : @visits[idx - 1]
   
    @image_datasets = @visit.image_datasets.page(params[:page])
    @participant = @visit.try(:enrollments).first.try(:participant) 
    @enumbers = @visit.enrollments

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @visit }
    end
  end

  # GET /visits/new
  # GET /visits/new.xml
  def new
    @visit = Visit.new
    @visit.enrollments << Enrollment.new
    @visit.user = current_user
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @visit }
    end
  end

  # GET /visits/1/edit
  def edit
    scan_procedure_array =current_user[:edit_low_scan_procedure_array ]   
    @visit = Visit.where("visits.id in (select visit_id from scan_procedures_visits where scan_procedure_id in (?))", scan_procedure_array).find(params[:id])
    @visit.enrollments.build # if @visit.enrollments.blank?
    
    
  end

  # POST /visits
  # POST /visits.xml
  def create
    @visit = Visit.new(params[:visit])
    @visit.user = current_user
    if @visit.appointment_id.blank?
       @appointment = Appointment.create
       @appointment.appointment_type ='mri'
       @appointment.appointment_date = @visit.date
       @vgroup = Vgroup.create
       @vgroup.vgroup_date = @visit.date
       @vgroup.save
       @appointment.vgroup_id = @vgroup.id
       @appointment.save
       @visit.appointment_id = @appointment.id
    end
    respond_to do |format|
      if @visit.save
        flash[:notice] = 'MRI appt was successfully created.'
        format.html { redirect_to(@visit) }
        format.xml  { render :xml => @visit, :status => :created, :location => @visit }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @visit.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /visits/1
  # PUT /visits/1.xml
  def update
     scan_procedure_array =current_user[:edit_low_scan_procedure_array] 
    @visit = Visit.where("visits.id in (select visit_id from scan_procedures_visits where scan_procedure_id in (?))", scan_procedure_array).find(params[:id])

    # hiding the protocols in checkbox which user not have access to, if any add in to attributes before update
    @scan_procedures = ScanProcedure.where(" scan_procedures.id in (select scan_procedure_id from scan_procedures_visits where visit_id = "+params[:id]+" and scan_procedure_id not in (?))",  scan_procedure_array ).all
    if @scan_procedures.count > 0
       scan_procedure_array = []
       @scan_procedures.each do |p2|
         scan_procedure_array << p2.id
       end    
       params[:visit][:scan_procedure_ids] = params[:visit][:scan_procedure_ids] | scan_procedure_array   
    end
     # HTML Checkbox Hack to remove all if none were checked.
    attributes = {'scan_procedure_ids' => []}.merge(params[:visit] || {} )
    
    @enumbers = @visit.enrollments
    set_participant_in_enrollment(@visit.rmr, @enumbers)

    respond_to do |format|
      if @visit.update_attributes(attributes)

        4
        flash[:notice] = 'visit was successfully updated.'
        format.html { redirect_to(@visit) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @visit.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def set_participant_in_enrollment( rmr, enroll)
    # loop thru each enrollment, check for participant_id
    # if not populated, look for other participant_id based on
    # last 6 digits of rmr = RMRaic
    # other participant_id for the enumber
    
    participant_id =""
    enumber_array = []
    # make hash of enums
     blank_participant_id ="N"
    enroll.each do |e|
       enumber_array << e.enumber
       if !e.participant_id.blank?
           participant_id = e.participant_id
       else
           blank_participant_id ="Y"
       end
    end
    # what if there are two participant_id's -- multiple enrollments

    if participant_id.blank?
      # if rmr starts with RMRaic and last 6 chars are digits
      # look for a participant with this reggieID
      if rmr[0..5] == "RMRaic" && is_a_number?(rmr[6..11]) && rmr.length == 12
           reggieid = rmr[6..11]
           @participant = Participant.where(" reggieid in (?)",reggieid)
           participant_id = @participant[0].try(:id).to_s
      end
      if participant_id.blank?
            # look for participant_id associated with enumber
            @participant = Participant.where(" participants.id in (select enrollments.participant_id  from  enrollments where enumber  in (?))",enumber_array)
            participant_id = @participant[0].try(:id).to_s           
      end
      # if still blank, and good rmr format, insert new partipant
      if participant_id.blank? && rmr[0..5] == "RMRaic" && is_a_number?(rmr[6..11]) && rmr.length == 12
          # do insert , get participant_id
           
           @participant = Participant.new
           @participant.reggieid = rmr[6..11]
           @participant.save
          participant_id = @participant.id
      end
          # participant_id was blank, now, if not blank, update enrollments where participant_id is null
      if !participant_id.blank?
         sql = "UPDATE enrollments set enrollments.participant_id = "+participant_id.to_s+" WHERE enrollments.participant_id is NULL AND
                          enrollments.id 
                            IN (select  enrollment_visit_memberships.enrollment_id  FROM enrollment_visit_memberships
                                WHERE enrollment_visit_memberships.visit_id = "+params[:id]+ " )"

                           
          connection = ActiveRecord::Base.connection();
          results = connection.execute(sql)          
      end      
    end
    if  blank_participant_id == "Y"
      if !participant_id.blank?
         sql = "UPDATE enrollments set enrollments.participant_id = 2606 WHERE enrollments.participant_id is NULL AND
                          enrollments.id 
                            IN (select  enrollment_visit_memberships.enrollment_id  FROM enrollment_visit_memberships
                                WHERE enrollment_visit_memberships.visit_id = 832 )"

         # problems with multiple participants - even the same one for a visit                  
           connection = ActiveRecord::Base.connection();
           results = connection.execute(sql)          
      end      
    end 
    
    
  end

  def is_a_number?(s)

    s.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true
1
  end  
  

  # DELETE /visits/1
  # DELETE /visits/1.xml
  def destroy
     @user = current_user
  # not sure why :edit_low_scan_procedure_array is getting lost, could because permissions on user and ability
  # can also get edit_low_scan_procedure_array from user, but its got spaces 
   #  scan_procedure_array =@user[:edit_low_scan_procedure_array]
    scan_procedure_array =(@user.edit_low_scan_procedure_array).split(' ').map(&:to_i) 
    @visit = Visit.where("visits.id in (select visit_id from scan_procedures_visits where scan_procedure_id in (?))", scan_procedure_array).find(params[:id])
    @visit.destroy

    respond_to do |format|
      format.html { redirect_to(visits_url) }
      format.xml  { head :ok }
    end
  end
  
  # Send an Email About the Visit
  def send_confirmation
    @visit=Visit.find(params[:id])
    begin
      PandaMailer.visit_confirmation(@visit, params[:email]).deliver
      flash[:notice] = "Email was succesfully sent."
    rescue StandardError => error
      logger.info error
      flash[:error] = "Sorry, your email was not delivered: " + error.to_s
    end
    redirect_to @visit
  end
  
  def visit_search
    # possible params -- visits fields just get added as AND statements
    #   other table fields should be grouped into one lower level IN select 
    # scan_procedures_visits.scan_procedures_id
    # visits.rmr
    # visits.path
    # visits.date scan date before = latest_timestamp(1i)(2i)(3i)
    # visits.date scan date after  = earliest_timestamp(1i)(2i)(3i)
    
    #enrollment_visit_memberships.enrollment_id enrollments.enumber

    
   if params[:visit_search].nil?
        params[:visit_search] =Hash.new  
   end
    #scan_procedure_array =current_user[:view_low_scan_procedure_array]
    scan_procedure_array = (current_user.view_low_scan_procedure_array).split(' ').map(&:to_i)
    # Remove default scope if sorting has been requested.
    @search = Visit.search(params[:search]) 
      if !params[:visit_search][:scan_procedure_id].blank?
         @search =@search.where(" visits.id in (select scan_procedures_visits.visit_id from scan_procedures_visits where scan_procedures_visits.scan_procedure_id in (?))",params[:visit_search][:scan_procedure_id])
      end
      
      if !params[:visit_search][:series_description].blank?
         var = "%"+params[:visit_search][:series_description].downcase+"%"
         @search =@search.where(" visits.id in (select image_datasets.visit_id from image_datasets
          where lower(image_datasets.series_description) like ? )", var)
      end
      
      if !params[:visit_search][:enumber].blank?
         @search =@search.where(" visits.id in (select enrollment_visit_memberships.visit_id from enrollment_visit_memberships,enrollments
          where enrollment_visit_memberships.enrollment_id = enrollments.id and lower(enrollments.enumber) in (lower(?)))",params[:visit_search][:enumber])
      end      

      if !params[:visit_search][:rmr].blank? && params[:visit_search][:path].blank? && params[:visit_search][:latest_timestamp].blank? && params[:visit_search][:earliest_timestamp].blank?
          @search = @search.where(" lower(visits.rmr) in (lower(?))",params[:visit_search][:rmr])
      elsif params[:visit_search][:rmr].blank? && !params[:visit_search][:path].blank? && params[:visit_search][:latest_timestamp].blank? && params[:visit_search][:earliest_timestamp].blank?
              var ="%"+params[:visit_search][:path]+"%"
             @search = @search.where(" visits.path LIKE ? ",var)
      elsif !params[:visit_search][:rmr].blank? && !params[:visit_search][:path].blank? && params[:visit_search][:latest_timestamp].blank? && params[:visit_search][:earliest_timestamp].blank?
            var ="%"+params[:visit_search][:path]+"%"
            @search = @search.where(" visits.path LIKE ? and visits.rmr in (?) ",var,params[:visit_search][:rmr])
      end

       #  build expected date format --- between, >, < 
       v_date_latest =""
       #want all three date parts
      
       if !params[:visit_search]["#{'latest_timestamp'}(1i)"].blank? && !params[:visit_search]["#{'latest_timestamp'}(2i)"].blank? && !params[:visit_search]["#{'latest_timestamp'}(3i)"].blank?
            v_date_latest = params[:visit_search]["#{'latest_timestamp'}(1i)"] +"-"+params[:visit_search]["#{'latest_timestamp'}(2i)"].rjust(2,"0")+"-"+params[:visit_search]["#{'latest_timestamp'}(3i)"].rjust(2,"0")
       end

       v_date_earliest =""
       #want all three date parts
  
       if !params[:visit_search]["#{'earliest_timestamp'}(1i)"].blank? && !params[:visit_search]["#{'earliest_timestamp'}(2i)"].blank? && !params[:visit_search]["#{'earliest_timestamp'}(3i)"].blank?
             v_date_earliest = params[:visit_search]["#{'earliest_timestamp'}(1i)"] +"-"+params[:visit_search]["#{'earliest_timestamp'}(2i)"].rjust(2,"0")+"-"+params[:visit_search]["#{'earliest_timestamp'}(3i)"].rjust(2,"0")
        end

       if v_date_latest.length>0 && v_date_earliest.length >0
         @search = @search.where(" visits.date between ? and ? ",v_date_earliest,v_date_latest)
       elsif v_date_latest.length>0
         @search = @search.where(" visits.date < ?  ",v_date_latest)
       elsif  v_date_earliest.length >0
         @search = @search.where(" visits.date > ? ",v_date_earliest)
        end

        if !params[:visit_search][:gender].blank?
           @search =@search.where(" visits.id in (select enrollment_visit_memberships.visit_id from participants,  enrollment_visit_memberships, enrollments
            where enrollment_visit_memberships.enrollment_id = enrollments.id and enrollments.participant_id = participants.id 
                   and participants.gender is not NULL and participants.gender in (?) )", params[:visit_search][:gender])
        end   


        if !params[:visit_search][:min_age].blank? && params[:visit_search][:max_age].blank?
            @search = @search.where("  visits.id in (select enrollment_visit_memberships.visit_id from participants,  enrollment_visit_memberships, enrollments, scan_procedures_visits,visits
                               where enrollment_visit_memberships.enrollment_id = enrollments.id and enrollments.participant_id = participants.id
                            and  scan_procedures_visits.visit_id = enrollment_visit_memberships.visit_id 
                            and visits.id = enrollment_visit_memberships.visit_id
                            and floor(DATEDIFF(visits.date,participants.dob)/365.25) >= ?   )",params[:visit_search][:min_age])
        elsif params[:visit_search][:min_age].blank? && !params[:visit_search][:max_age].blank?
             @search = @search.where("  visits.id in (select enrollment_visit_memberships.visit_id from participants,  enrollment_visit_memberships, enrollments, scan_procedures_visits,visits
                             where enrollment_visit_memberships.enrollment_id = enrollments.id and enrollments.participant_id = participants.id
                         and  scan_procedures_visits.visit_id = enrollment_visit_memberships.visit_id 
                         and visits.id = enrollment_visit_memberships.visit_id
                         and floor(DATEDIFF(visits.date,participants.dob)/365.25) <= ?   )",params[:visit_search][:max_age])
        elsif !params[:visit_search][:min_age].blank? && !params[:visit_search][:max_age].blank?
           @search = @search.where("  visits.id in (select enrollment_visit_memberships.visit_id from participants,  enrollment_visit_memberships, enrollments, scan_procedures_visits,visits
                           where enrollment_visit_memberships.enrollment_id = enrollments.id and enrollments.participant_id = participants.id
                       and  scan_procedures_visits.visit_id = enrollment_visit_memberships.visit_id 
                       and visits.id = enrollment_visit_memberships.visit_id
                       and floor(DATEDIFF(visits.date,participants.dob)/365.25) between ? and ?   )",params[:visit_search][:min_age],params[:visit_search][:max_age])
        end

        
    @search =  @search.where(" visits.id in (select visit_id from scan_procedures_visits where scan_procedure_id in (?))", scan_procedure_array)
    @visits =  @search.page(params[:page])
    ### LOOK WHERE TITLE IS SHOWING UP
    @collection_title = 'All MRI appts'
 
   
#    light_include_options = :image_dataset_quality_checks
#    heavy_include_options = {
#      :image_dataset_quality_checks => {:except => [:id]},
#      :visit => {:methods => :age_at_visit, :only => [:scanner_source, :date], :include => {
#        :enrollments => {:only => [:enumber], :include => { 
#          :participant => { :methods => :genetic_status, :only => [:gender, :wrapnum, :ed_years] }
#        }}
#      }}
#    }
=begin
light_include_options = :image_dataset_quality_checks
merged_comment_html
label_not_null_comments
scan_procedure_name

radiology_comments_options = {
  :visit => {:methods => :age_at_visit, :only => [:id,:scanner_source, :rmr, :date,:note], :include => {
    :radiology_comment =>{:only => [:comment_html_1, :comment_html_2]},
    :image_dataset_quality_checks =>{ :only => [:id]},
    :image_dataset =>{:image_dataset_comment => { :only =>[:comment]}}
    :enrollments => {:only => [:enumber], :include => { 
      :participant => { :methods => :genetic_status, :only => [:gender, :wrapnum, :ed_years] }
    }}
  }}
}
=end
# use methods for radiology_comments, image_dataset comment and image dataset quailty check comments
radiology_comments_options = {
      :radiology_comments => { :methods => :combined_radiology_comments ,:only =>[:q1_flag ]    }
}
#      :image_datasets => { :only => [:series_description] }
# }

limit_visits =  [:user_id ,:initials,:transfer_mri,:transfer_pet,:conference,:dicom_dvd,:compile_folder,:id,
                  :created_at, :updated_at, :research_diagnosis, :consent_form_type, :created_by_id, :dicom_study_uid,:compiled_at]



### if Radiology - pass in params -- do same seach, but call differ respond_to
### add radiology_comments, image_dataset comment, and image_dataset_quality_check columns to visit?
### define what field go out
#     light_include_options = :visit
        export_record = visit_search_path(:visit_search => params[:visit_search], :format => :csv)
        export_record.gsub!('%28','(')
        export_record.gsub!('%29',')')

        
        #current_user.id.to_s 
        # add export_log
  @current_tab = "visit_search"
    respond_to do |format|
      format.html {render :template => "visits/visit_search"}
      if !params[:visit_search][:include_radiology_comment].try(:length).nil?
         if params[:visit_search][:include_radiology_comment] == "1"
           
            format.csv  {   render :csv => @visits.csv_download_limit(@search,radiology_comments_options,limit_visits) }
         else
            format.csv  { render :csv => @visits.csv_download(@search) }
         end
      else
        format.csv  { render :csv => @visits.csv_download(@search) }
      end  
    end
#    render :template => "visits/visit_search"
    
  end
  
  private
  
  def set_current_tab
    @current_tab = "visits"
  end
  
end
