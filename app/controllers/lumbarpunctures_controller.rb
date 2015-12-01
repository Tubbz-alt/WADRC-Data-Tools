# encoding: utf-8
class LumbarpuncturesController < ApplicationController
  # GET /lumbarpunctures
  # GET /lumbarpunctures.xml
  def index
    @lumbarpunctures = Lumbarpuncture.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @lumbarpunctures }
    end
  end

  # GET /lumbarpunctures/1
  # GET /lumbarpunctures/1.xml
  def show

    @current_tab = "lumbarpunctures"
    scan_procedure_array = []
    scan_procedure_array =  (current_user.view_low_scan_procedure_array).split(' ').map(&:to_i)
          hide_date_flag_array = []
      hide_date_flag_array =  (current_user.hide_date_flag_array).split(' ').map(&:to_i)
      @hide_page_flag = 'N'
      if hide_date_flag_array.count > 0
        @hide_page_flag = 'Y'
      end
     
    @lumbarpuncture = Lumbarpuncture.where("lumbarpunctures.appointment_id in (select appointments.id from appointments,scan_procedures_vgroups where 
                                      appointments.vgroup_id = scan_procedures_vgroups.vgroup_id 
                                      and scan_procedure_id in (?))", scan_procedure_array).find(params[:id])

    @appointment = Appointment.find(@lumbarpuncture.appointment_id)                            

    @lumbarpunctures = Lumbarpuncture.where("lumbarpunctures.appointment_id in (select appointments.id from appointments,scan_procedures_vgroups where 
                                appointments.vgroup_id = scan_procedures_vgroups.vgroup_id 
                               and appointments.appointment_date between ? and ?
                               and scan_procedure_id in (?))", @appointment.appointment_date-2.month,@appointment.appointment_date+2,scan_procedure_array).all

    idx = @lumbarpunctures.index(@lumbarpuncture)
    @older_lumbarpuncture = idx + 1 >= @lumbarpunctures.size ? nil : @lumbarpunctures[idx + 1]
    @newer_lumbarpuncture = idx - 1 < 0 ? nil : @lumbarpunctures[idx - 1]
    
    @vgroup = Vgroup.find(@appointment.vgroup_id)
    @participant = @vgroup.try(:participant)
    @enumbers = @vgroup.enrollments
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @lumbarpuncture }
    end
  end

  # GET /lumbarpunctures/new
  # GET /lumbarpunctures/new.xml
  def new
          hide_date_flag_array = []
      hide_date_flag_array =  (current_user.hide_date_flag_array).split(' ').map(&:to_i)
      @hide_page_flag = 'N'
      if hide_date_flag_array.count > 0
        @hide_page_flag = 'Y'
      end
       @current_tab = "lumbarpunctures"
    @lumbarpuncture = Lumbarpuncture.new
        vgroup_id = params[:id]
        @vgroup = Vgroup.find(vgroup_id)
        @enumbers = @vgroup.enrollments
        params[:new_appointment_vgroup_id] = vgroup_id
        @appointment = Appointment.new
        @appointment.vgroup_id = vgroup_id
        @appointment.appointment_date = (Vgroup.find(vgroup_id)).vgroup_date
        @appointment.appointment_type ='lumbar_puncture'
    #    @appointment.save  --- save in create step

        @lumbarpuncture.appointment_id = @appointment.id

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @lumbarpuncture }
    end
  end

  # GET /lumbarpunctures/1/edit
  def edit
    @current_tab = "lumbarpunctures"
    scan_procedure_array = []
    scan_procedure_array =  (current_user.edit_low_scan_procedure_array).split(' ').map(&:to_i)
          hide_date_flag_array = []
      hide_date_flag_array =  (current_user.hide_date_flag_array).split(' ').map(&:to_i)
      @hide_page_flag = 'N'
      if hide_date_flag_array.count > 0
        @hide_page_flag = 'Y'
      end
    @lumbarpuncture = Lumbarpuncture.where("lumbarpunctures.appointment_id in (select appointments.id from appointments,scan_procedures_vgroups where 
                                      appointments.vgroup_id = scan_procedures_vgroups.vgroup_id 
                                      and scan_procedure_id in (?))", scan_procedure_array).find(params[:id])
    @appointment = Appointment.find(@lumbarpuncture.appointment_id)
    @vgroup = Vgroup.find(@appointment.vgroup_id)
    @enumbers = @vgroup.enrollments   
  end

  # POST /lumbarpunctures
  # POST /lumbarpunctures.xml
  def create
            params[:date][:lpstartt][0]="1899"
             params[:date][:lpstartt][1]="12"
             params[:date][:lpstartt][2]="30"       
             lpstarttime = nil
            if !params[:date][:lpstartt][0].blank? && !params[:date][:lpstartt][1].blank? && !params[:date][:lpstartt][2].blank? && !params[:date][:lpstartt][3].blank? && !params[:date][:lpstartt][4].blank?
        lpstarttime =  params[:date][:lpstartt][0]+"-"+params[:date][:lpstartt][1]+"-"+params[:date][:lpstartt][2]+" "+params[:date][:lpstartt][3]+":"+params[:date][:lpstartt][4]
             params[:lumbarpuncture][:lpstarttime] = lpstarttime
             params[:lumbarpuncture][:lpstarttime_hour] = params[:date][:lpstartt][3]
             params[:lumbarpuncture][:lpstarttime_minute] =params[:date][:lpstartt][4]

            end

         params[:date][:lpendt][0]="1899"
         params[:date][:lpendt][1]="12"
         params[:date][:lpendt][2]="30"       
          lpendtime = nil
        if !params[:date][:lpendt][0].blank? && !params[:date][:lpendt][1].blank? && !params[:date][:lpendt][2].blank? && !params[:date][:lpendt][3].blank? && !params[:date][:lpendt][4].blank?
    lpendtime =  params[:date][:lpendt][0]+"-"+params[:date][:lpendt][1]+"-"+params[:date][:lpendt][2]+" "+params[:date][:lpendt][3]+":"+params[:date][:lpendt][4]
         params[:lumbarpuncture][:lpendtime] = lpendtime 
        params[:lumbarpuncture][:lpendtime_hour] = params[:date][:lpendt][3]
        params[:lumbarpuncture][:lpendtime_minute] =params[:date][:lpendt][4]
        end

     @current_tab = "lumbarpunctures"
     scan_procedure_array = []
     scan_procedure_array =  (current_user.edit_low_scan_procedure_array).split(' ').map(&:to_i)
           hide_date_flag_array = []
      hide_date_flag_array =  (current_user.hide_date_flag_array).split(' ').map(&:to_i)
      @hide_page_flag = 'N'
      if hide_date_flag_array.count > 0
        @hide_page_flag = 'Y'
      end
    @lumbarpuncture = Lumbarpuncture.new(params[:lumbarpuncture])
        
    appointment_date = nil
    if !params[:appointment]["#{'appointment_date'}(1i)"].blank? && !params[:appointment]["#{'appointment_date'}(2i)"].blank? && !params[:appointment]["#{'appointment_date'}(3i)"].blank?
         appointment_date = params[:appointment]["#{'appointment_date'}(1i)"] +"-"+params[:appointment]["#{'appointment_date'}(2i)"].rjust(2,"0")+"-"+params[:appointment]["#{'appointment_date'}(3i)"].rjust(2,"0")
    end
    
    vgroup_id =params[:new_appointment_vgroup_id]
    @vgroup = Vgroup.where("vgroups.id in (select vgroup_id from scan_procedures_vgroups where scan_procedure_id in (?))", scan_procedure_array).find(vgroup_id)
    @appointment = Appointment.new
    @appointment.vgroup_id = vgroup_id
    @appointment.appointment_type ='lumbar_puncture'
    @appointment.appointment_date =appointment_date
    @appointment.comment = params[:appointment][:comment]
    if !params[:appointment].nil? and !params[:appointment][:appointment_coordinator].nil?
                @appointment.appointment_coordinator = params[:appointment][:appointment_coordinator]
    end
    @appointment.user = current_user
    if !@vgroup.participant_id.blank?
      @participant = Participant.find(@vgroup.participant_id)
      if !@participant.dob.blank?
         @appointment.age_at_appointment = ((@appointment.appointment_date - @participant.dob)/365.25).round(2)
      end
    end
    @appointment.save
    @lumbarpuncture.appointment_id = @appointment.id

    respond_to do |format|
      if @lumbarpuncture.save
         @vgroup.completedlumbarpuncture = params[:vgroup][:completedlumbarpuncture]
          @vgroup.save
        
        # @appointment.save
        if !params[:vital_id].blank?
          @vital = Vital.find(params[:vital_id])
          @vital.pulse = params[:pulse]
          @vital.bp_systol = params[:bp_systol]
          @vital.bp_diastol = params[:bp_diastol]
          @vital.bloodglucose = params[:bloodglucose]
          @vital.save
        else
          @vital = Vital.new
          @vital.appointment_id = @lumbarpuncture.appointment_id
          @vital.pulse = params[:pulse]
          @vital.bp_systol = params[:bp_systol]
          @vital.bp_diastol = params[:bp_diastol]
          @vital.bloodglucose = params[:bloodglucose]
          @vital.save      
        end    
        
        if !params[:lookup_lumbarpuncture_id].blank?
          LookupLumbarpuncture.all.each do |lookup_lp|
              val = nil
              val = params[:lookup_lumbarpuncture_id][lookup_lp.id.to_s].to_s
              if val.blank?
                   val = "0"
              end
              sql = "INSERT INTO lumbarpuncture_results (lumbarpuncture_id,lookup_lumbarpuncture_id,value) VALUES ("+@lumbarpuncture.id.to_s+","+lookup_lp.id.to_s+",'"+val+"')
                    ON DUPLICATE KEY UPDATE value='"+val+"' "
              ActiveRecord::Base.connection.insert_sql sql
              # insert or update?
          end
        else
           # update to null or delete?
        end   

        format.html { redirect_to(@lumbarpuncture, :notice => 'Lumbarpuncture was successfully created.') }
        format.xml  { render :xml => @lumbarpuncture, :status => :created, :location => @lumbarpuncture }
      else
        @appointment.delete
        format.html { render :action => "new" }
        format.xml  { render :xml => @lumbarpuncture.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /lumbarpunctures/1
  # PUT /lumbarpunctures/1.xml
  def update

        scan_procedure_array = []
        scan_procedure_array =  (current_user.edit_low_scan_procedure_array).split(' ').map(&:to_i)
              hide_date_flag_array = []
      hide_date_flag_array =  (current_user.hide_date_flag_array).split(' ').map(&:to_i)
      @hide_page_flag = 'N'
      if hide_date_flag_array.count > 0
        @hide_page_flag = 'Y'
      end

        @lumbarpuncture = Lumbarpuncture.where("lumbarpunctures.appointment_id in (select appointments.id from appointments,scan_procedures_vgroups where 
                                          appointments.vgroup_id = scan_procedures_vgroups.vgroup_id 
                                          and scan_procedure_id in (?))", scan_procedure_array).find(params[:id])

        appointment_date = nil
        if !params[:appointment]["#{'appointment_date'}(1i)"].blank? && !params[:appointment]["#{'appointment_date'}(2i)"].blank? && !params[:appointment]["#{'appointment_date'}(3i)"].blank?
             appointment_date = params[:appointment]["#{'appointment_date'}(1i)"] +"-"+params[:appointment]["#{'appointment_date'}(2i)"].rjust(2,"0")+"-"+params[:appointment]["#{'appointment_date'}(3i)"].rjust(2,"0")
        end
              params[:date][:lpstartt][0]="1899"
             params[:date][:lpstartt][1]="12"
             params[:date][:lpstartt][2]="30"       
             lpstarttime = nil
            if !params[:date][:lpstartt][0].blank? && !params[:date][:lpstartt][1].blank? && !params[:date][:lpstartt][2].blank? && !params[:date][:lpstartt][3].blank? && !params[:date][:lpstartt][4].blank?
        lpstarttime =  params[:date][:lpstartt][0]+"-"+params[:date][:lpstartt][1]+"-"+params[:date][:lpstartt][2]+" "+params[:date][:lpstartt][3]+":"+params[:date][:lpstartt][4]
             params[:lumbarpuncture][:lpstarttime] = lpstarttime
             params[:lumbarpuncture][:lpstarttime_hour] = params[:date][:lpstartt][3]
             params[:lumbarpuncture][:lpstarttime_minute] =params[:date][:lpstartt][4]
            end

         params[:date][:lpendt][0]="1899"
         params[:date][:lpendt][1]="12"
         params[:date][:lpendt][2]="30"       
          lpendtime = nil
        if !params[:date][:lpendt][0].blank? && !params[:date][:lpendt][1].blank? && !params[:date][:lpendt][2].blank? && !params[:date][:lpendt][3].blank? && !params[:date][:lpendt][4].blank?
    lpendtime =  params[:date][:lpendt][0]+"-"+params[:date][:lpendt][1]+"-"+params[:date][:lpendt][2]+" "+params[:date][:lpendt][3]+":"+params[:date][:lpendt][4]
         params[:lumbarpuncture][:lpendtime] = lpendtime
        params[:lumbarpuncture][:lpendtime_hour] = params[:date][:lpendt][3]
        params[:lumbarpuncture][:lpendtime_minute] =params[:date][:lpendt][4]
        end
        
        # ok to update vitals even if other update fail
        if !params[:vital_id].blank?
          @vital = Vital.find(params[:vital_id])
          @vital.pulse = params[:pulse]
          @vital.bp_systol = params[:bp_systol]
          @vital.bp_diastol = params[:bp_diastol]
          @vital.bloodglucose = params[:bloodglucose]
          @vital.save
        else
          @vital = Vital.new
          @vital.appointment_id = @lumbarpuncture.appointment_id
          @vital.pulse = params[:pulse]
          @vital.bp_systol = params[:bp_systol]
          @vital.bp_diastol = params[:bp_diastol]
          @vital.bloodglucose = params[:bloodglucose]
          @vital.save      
        end
        
        if !params[:lookup_lumbarpuncture_id].blank?
          LookupLumbarpuncture.all.each do |lookup_lp|
              val = nil
              val = params[:lookup_lumbarpuncture_id][lookup_lp.id.to_s].to_s
              if val.blank?
                 val = "0"   # not sure why "" not going to 0
              end
              sql = "INSERT INTO lumbarpuncture_results (lumbarpuncture_id,lookup_lumbarpuncture_id,value) VALUES ("+@lumbarpuncture.id.to_s+","+lookup_lp.id.to_s+",'"+val+"')
                    ON DUPLICATE KEY UPDATE value='"+val+"' "
               ActiveRecord::Base.connection.insert_sql sql
             
              # insert or update?
          end
        else
           # update to null or delete?
        end

        respond_to do |format|
          if @lumbarpuncture.update_attributes(params[:lumbarpuncture])
            @appointment = Appointment.find(@lumbarpuncture.appointment_id)
            @vgroup = Vgroup.find(@appointment.vgroup_id)
            @appointment.comment = params[:appointment][:comment]
            if !params[:appointment].nil? and !params[:appointment][:appointment_coordinator].nil?
                @appointment.appointment_coordinator = params[:appointment][:appointment_coordinator]
            end
            @appointment.appointment_date =appointment_date
            if !@vgroup.participant_id.blank?
              @participant = Participant.find(@vgroup.participant_id)
              if !@participant.dob.blank?
                 @appointment.age_at_appointment = ((@appointment.appointment_date - @participant.dob)/365.25).round(2)
              end
            end
            @appointment.save
            @vgroup.completedlumbarpuncture = params[:vgroup][:completedlumbarpuncture]
            @vgroup.save
            
           

        format.html { redirect_to(@lumbarpuncture, :notice => 'Lumbarpuncture was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @lumbarpuncture.errors, :status => :unprocessable_entity }
      end
    end
  end
  

    def lumbarpuncture_search
       @current_tab = "lumbarpunctures"
       params["search_criteria"] =""

       if params[:lumbarpuncture_search].nil?
            params[:lumbarpuncture_search] =Hash.new  
       end

       scan_procedure_array = []
       scan_procedure_array =  (current_user.view_low_scan_procedure_array).split(' ').map(&:to_i)   

  #    @lumbarpunctures = Lumbarpuncture.where("lumbarpunctures.appointment_id in (select appointments.id from appointments,scan_procedures_vgroups where 
  #                                       appointments.vgroup_id = scan_procedures_vgroups.vgroup_id 
  #    and scan_procedure_id in (?))", scan_procedure_array).all
  #     sql = "select * from lumbarpunctures inner join  appointments on appointments.id = lumbarpunctures.appointment_id order by appointment_date desc"
  #      @search = Lumbarpuncture.find_by_sql(sql)
  #     @search = Lumbarpuncture.where("lumbarpunctures.appointment_id in (select appointments.id from appointments)").all
        @search = Lumbarpuncture.search(params[:search])    # parms search makes something which works with where?

        if !params[:lumbarpuncture_search][:scan_procedure_id].blank?
           @search =@search.where("lumbarpunctures.appointment_id in (select appointments.id from appointments,scan_procedures_vgroups where 
                                                  appointments.vgroup_id = scan_procedures_vgroups.vgroup_id 
                                                  and scan_procedure_id in (?))",params[:lumbarpuncture_search][:scan_procedure_id])
           @scan_procedures = ScanProcedure.where("id in (?)",params[:lumbarpuncture_search][:scan_procedure_id])
           params["search_criteria"] = params["search_criteria"] +", "+@scan_procedures.sort_by(&:codename).collect {|sp| sp.codename}.join(", ").html_safe
        end

        if !params[:lumbarpuncture_search][:enumber].blank?
           @search =@search.where(" lumbarpunctures.appointment_id in (select appointments.id from enrollment_vgroup_memberships,enrollments, appointments
            where enrollment_vgroup_memberships.vgroup_id= appointments.vgroup_id 
            and enrollment_vgroup_memberships.enrollment_id = enrollments.id and lower(enrollments.enumber) in (lower(?)))",params[:lumbarpuncture_search][:enumber])
            params["search_criteria"] = params["search_criteria"] +",  enumber "+params[:lumbarpuncture_search][:enumber]
        end      

        if !params[:lumbarpuncture_search][:rmr].blank? 
            @search = @search.where(" lumbarpunctures.appointment_id in (select appointments.id from appointments,vgroups
                      where appointments.vgroup_id = vgroups.id and  lower(vgroups.rmr) in (lower(?)   ))",params[:lumbarpuncture_search][:rmr])
            params["search_criteria"] = params["search_criteria"] +",  RMR "+params[:lumbarpuncture_search][:rmr]
        end

         #  build expected date format --- between, >, < 
         v_date_latest =""
         #want all three date parts

         if !params[:lumbarpuncture_search]["#{'latest_timestamp'}(1i)"].blank? && !params[:lumbarpuncture_search]["#{'latest_timestamp'}(2i)"].blank? && !params[:lumbarpuncture_search]["#{'latest_timestamp'}(3i)"].blank?
              v_date_latest = params[:lumbarpuncture_search]["#{'latest_timestamp'}(1i)"] +"-"+params[:lumbarpuncture_search]["#{'latest_timestamp'}(2i)"].rjust(2,"0")+"-"+params[:lumbarpuncture_search]["#{'latest_timestamp'}(3i)"].rjust(2,"0")
         end

         v_date_earliest =""
         #want all three date parts

         if !params[:lumbarpuncture_search]["#{'earliest_timestamp'}(1i)"].blank? && !params[:lumbarpuncture_search]["#{'earliest_timestamp'}(2i)"].blank? && !params[:lumbarpuncture_search]["#{'earliest_timestamp'}(3i)"].blank?
               v_date_earliest = params[:lumbarpuncture_search]["#{'earliest_timestamp'}(1i)"] +"-"+params[:lumbarpuncture_search]["#{'earliest_timestamp'}(2i)"].rjust(2,"0")+"-"+params[:lumbarpuncture_search]["#{'earliest_timestamp'}(3i)"].rjust(2,"0")
          end

         if v_date_latest.length>0 && v_date_earliest.length >0
           @search = @search.where(" lumbarpunctures.appointment_id in (select appointments.id from appointments where appointments.appointment_date between ? and ? )",v_date_earliest,v_date_latest)
           params["search_criteria"] = params["search_criteria"] +",  visit date between "+v_date_earliest+" and "+v_date_latest
         elsif v_date_latest.length>0
           @search = @search.where(" lumbarpunctures.appointment_id in (select appointments.id from appointments where appointments.appointment_date < ?  )",v_date_latest)
            params["search_criteria"] = params["search_criteria"] +",  visit date before "+v_date_latest 
         elsif  v_date_earliest.length >0
           @search = @search.where(" lumbarpunctures.appointment_id in (select appointments.id from appointments where appointments.appointment_date > ? )",v_date_earliest)
            params["search_criteria"] = params["search_criteria"] +",  visit date after "+v_date_earliest
          end

          if !params[:lumbarpuncture_search][:gender].blank?
             @search =@search.where(" lumbarpunctures.appointment_id in (select appointments.id from participants,  enrollment_vgroup_memberships, enrollments,appointments
              where enrollment_vgroup_memberships.enrollment_id = enrollments.id and enrollments.participant_id = participants.id 
              and enrollment_vgroup_memberships.vgroup_id = appointments.vgroup_id
                     and participants.gender is not NULL and participants.gender in (?) )", params[:lumbarpuncture_search][:gender])
              if params[:lumbarpuncture_search][:gender] == 1
                 params["search_criteria"] = params["search_criteria"] +",  sex is Male"
              elsif params[:lumbarpuncture_search][:gender] == 2
                 params["search_criteria"] = params["search_criteria"] +",  sex is Female"
              end
          end   

          if !params[:lumbarpuncture_search][:min_age].blank? && params[:lumbarpuncture_search][:max_age].blank?
              @search = @search.where("  lumbarpunctures.appointment_id in (select appointments.id from participants,  enrollment_vgroup_memberships, enrollments, scan_procedures_vgroups,appointments
                                 where enrollment_vgroup_memberships.enrollment_id = enrollments.id and enrollments.participant_id = participants.id
                              and  scan_procedures_vgroups.vgroup_id = enrollment_vgroup_memberships.vgroup_id 
                              and appointments.vgroup_id = enrollment_vgroup_memberships.vgroup_id
                              and round((DATEDIFF(appointments.appointment_date,participants.dob)/365.25),2) >= ?   )",params[:lumbarpuncture_search][:min_age])
              params["search_criteria"] = params["search_criteria"] +",  age at visit >= "+params[:lumbarpuncture_search][:min_age]
          elsif params[:lumbarpuncture_search][:min_age].blank? && !params[:lumbarpuncture_search][:max_age].blank?
               @search = @search.where("  lumbarpunctures.appointment_id in (select appointments.id from participants,  enrollment_vgroup_memberships, enrollments, scan_procedures_vgroups,appointments
                                  where enrollment_vgroup_memberships.enrollment_id = enrollments.id and enrollments.participant_id = participants.id
                               and  scan_procedures_vgroups.vgroup_id = enrollment_vgroup_memberships.vgroup_id 
                               and appointments.vgroup_id = enrollment_vgroup_memberships.vgroup_id
                           and round((DATEDIFF(appointments.appointment_date,participants.dob)/365.25),2) <= ?   )",params[:lumbarpuncture_search][:max_age])
              params["search_criteria"] = params["search_criteria"] +",  age at visit <= "+params[:lumbarpuncture_search][:max_age]
          elsif !params[:lumbarpuncture_search][:min_age].blank? && !params[:lumbarpuncture_search][:max_age].blank?
             @search = @search.where("   lumbarpunctures.appointment_id in (select appointments.id from participants,  enrollment_vgroup_memberships, enrollments, scan_procedures_vgroups,appointments
                                where enrollment_vgroup_memberships.enrollment_id = enrollments.id and enrollments.participant_id = participants.id
                             and  scan_procedures_vgroups.vgroup_id = enrollment_vgroup_memberships.vgroup_id 
                             and appointments.vgroup_id = enrollment_vgroup_memberships.vgroup_id
                         and round((DATEDIFF(appointments.appointment_date,participants.dob)/365.25),2) between ? and ?   )",params[:lumbarpuncture_search][:min_age],params[:lumbarpuncture_search][:max_age])
            params["search_criteria"] = params["search_criteria"] +",  age at visit between "+params[:lumbarpuncture_search][:min_age]+" and "+params[:lumbarpuncture_search][:max_age]
          end
          # trim leading ","
          params["search_criteria"] = params["search_criteria"].sub(", ","")
          # pass to download file?

      @search =  @search.where("lumbarpunctures.appointment_id in (select appointments.id from appointments,scan_procedures_vgroups where 
                                                 appointments.vgroup_id = scan_procedures_vgroups.vgroup_id 
                                                 and scan_procedure_id in (?))", scan_procedure_array)


      @lumbarpunctures =  @search.page(params[:page])

      ### LOOK WHERE TITLE IS SHOWING UP
      @collection_title = 'All Lumbarpuncture appts'

      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @lumbarpunctures }
      end
    end
    
 def lp_search
     # make @conditions from search form input, access control in application controller run_search
     @conditions = []
     @current_tab = "lumbarpunctures"
     params["search_criteria"] =""
      hide_date_flag_array = []
      hide_date_flag_array =  (current_user.hide_date_flag_array).split(' ').map(&:to_i)
      @hide_page_flag = 'N'
      if hide_date_flag_array.count > 0
        @hide_page_flag = 'Y'
      end

     if params[:lp_search].nil?
          params[:lp_search] =Hash.new  
          params[:lp_search][:lp_status] = "yes"
     end
     
     if !params[:lp_search][:scan_procedure_id].blank?
        condition =" lumbarpunctures.appointment_id in (select appointments.id from appointments,scan_procedures_vgroups where 
                                               appointments.vgroup_id = scan_procedures_vgroups.vgroup_id 
                                               and scan_procedure_id in ("+params[:lp_search][:scan_procedure_id].join(',').gsub(/[;:'"()=<>]/, '')+"))"
        @conditions.push(condition)
        @scan_procedures = ScanProcedure.where("id in (?)",params[:lp_search][:scan_procedure_id])
        params["search_criteria"] = params["search_criteria"] +", "+@scan_procedures.sort_by(&:codename).collect {|sp| sp.codename}.join(", ").html_safe
     end
 
     if !params[:lp_search][:enumber].blank?
       if params[:lp_search][:enumber].include?(',') # string of enumbers
        v_enumber =  params[:lp_search][:enumber].gsub(/ /,'').gsub(/'/,'').downcase
        v_enumber = v_enumber.gsub(/,/,"','")
          condition =" lumbarpunctures.appointment_id in (select appointments.id from enrollment_vgroup_memberships,enrollments, appointments
             where enrollment_vgroup_memberships.vgroup_id= appointments.vgroup_id 
             and enrollment_vgroup_memberships.enrollment_id = enrollments.id and lower(enrollments.enumber) in ('"+v_enumber.gsub(/[;:"()=<>]/, '')+"'))"         
       else
        condition =" lumbarpunctures.appointment_id in (select appointments.id from enrollment_vgroup_memberships,enrollments, appointments
         where enrollment_vgroup_memberships.vgroup_id= appointments.vgroup_id 
         and enrollment_vgroup_memberships.enrollment_id = enrollments.id and lower(enrollments.enumber) in (lower('"+params[:lp_search][:enumber].gsub(/[;:'"()=<>]/, '')+"')))"
       end
       @conditions.push(condition)
       params["search_criteria"] = params["search_criteria"] +",  enumber "+params[:lp_search][:enumber]
     end      

     if !params[:lp_search][:rmr].blank? 
         condition =" lumbarpunctures.appointment_id in (select appointments.id from appointments,vgroups
                   where appointments.vgroup_id = vgroups.id and  lower(vgroups.rmr) in (lower('"+params[:lp_search][:rmr].gsub(/[;:'"()=<>]/, '')+"')   ))"
         @conditions.push(condition)           
         params["search_criteria"] = params["search_criteria"] +",  RMR "+params[:lp_search][:rmr]
     end  
     
      if !params[:lp_search][:lp_status].blank? 
          condition =" lumbarpunctures.appointment_id in (select appointments.id from appointments,vgroups
                              where appointments.vgroup_id = vgroups.id and  lower(vgroups.completedlumbarpuncture) in (lower('"+params[:lp_search][:lp_status].gsub(/[;:'"()=<>]/, '')+"')   ))"
          @conditions.push(condition)
          params["search_criteria"] = params["search_criteria"] +",  LP status "+params[:lp_search][:lp_status]
      end 

     #  build expected date format --- between, >, < 
     v_date_latest =""
     #want all three date parts
     if !params[:lp_search]["#{'latest_timestamp'}(1i)"].blank? && !params[:lp_search]["#{'latest_timestamp'}(2i)"].blank? && !params[:lp_search]["#{'latest_timestamp'}(3i)"].blank?
          v_date_latest = params[:lp_search]["#{'latest_timestamp'}(1i)"] +"-"+params[:lp_search]["#{'latest_timestamp'}(2i)"].rjust(2,"0")+"-"+params[:lp_search]["#{'latest_timestamp'}(3i)"].rjust(2,"0")
     end
     v_date_earliest =""
     #want all three date parts
     if !params[:lp_search]["#{'earliest_timestamp'}(1i)"].blank? && !params[:lp_search]["#{'earliest_timestamp'}(2i)"].blank? && !params[:lp_search]["#{'earliest_timestamp'}(3i)"].blank?
           v_date_earliest = params[:lp_search]["#{'earliest_timestamp'}(1i)"] +"-"+params[:lp_search]["#{'earliest_timestamp'}(2i)"].rjust(2,"0")+"-"+params[:lp_search]["#{'earliest_timestamp'}(3i)"].rjust(2,"0")
      end
     v_date_latest = v_date_latest.gsub(/[;:'"()=<>]/, '')
     v_date_earliest = v_date_earliest.gsub(/[;:'"()=<>]/, '')
     if v_date_latest.length>0 && v_date_earliest.length >0
       condition ="  lumbarpunctures.appointment_id in (select appointments.id from appointments where appointments.appointment_date between '"+v_date_earliest+"' and '"+v_date_latest+"' )"
       @conditions.push(condition)
       params["search_criteria"] = params["search_criteria"] +",  visit date between "+v_date_earliest+" and "+v_date_latest
     elsif v_date_latest.length>0
       condition ="  lumbarpunctures.appointment_id in (select appointments.id from appointments where appointments.appointment_date < '"+v_date_latest+"'  )"
        @conditions.push(condition)
        params["search_criteria"] = params["search_criteria"] +",  visit date before "+v_date_latest 
     elsif  v_date_earliest.length >0
       condition ="  lumbarpunctures.appointment_id in (select appointments.id from appointments where appointments.appointment_date > '"+v_date_earliest+"' )"
        @conditions.push(condition)
        params["search_criteria"] = params["search_criteria"] +",  visit date after "+v_date_earliest
      end

      if !params[:lp_search][:gender].blank?
         condition ="  lumbarpunctures.appointment_id in (select appointments.id from participants,  enrollment_vgroup_memberships, enrollments,appointments
          where enrollment_vgroup_memberships.enrollment_id = enrollments.id and enrollments.participant_id = participants.id 
          and enrollment_vgroup_memberships.vgroup_id = appointments.vgroup_id
                 and participants.gender is not NULL and participants.gender in ("+params[:lp_search][:gender].gsub(/[;:'"()=<>]/, '')+") )"
          @conditions.push(condition)
          if params[:lp_search][:gender] == 1
             params["search_criteria"] = params["search_criteria"] +",  sex is Male"
          elsif params[:lp_search][:gender] == 2
             params["search_criteria"] = params["search_criteria"] +",  sex is Female"
          end
      end   

      if !params[:lp_search][:min_age].blank? && params[:lp_search][:max_age].blank?
          condition ="   lumbarpunctures.appointment_id in (select appointments.id from participants,  enrollment_vgroup_memberships, enrollments, scan_procedures_vgroups,appointments
                             where enrollment_vgroup_memberships.enrollment_id = enrollments.id and enrollments.participant_id = participants.id
                          and  scan_procedures_vgroups.vgroup_id = enrollment_vgroup_memberships.vgroup_id 
                          and appointments.vgroup_id = enrollment_vgroup_memberships.vgroup_id
                          and round((DATEDIFF(appointments.appointment_date,participants.dob)/365.25),2) >= "+params[:lp_search][:min_age].gsub(/[;:'"()=<>]/, '')+"   )"
           @conditions.push(condition)
          params["search_criteria"] = params["search_criteria"] +",  age at visit >= "+params[:lp_search][:min_age]
      elsif params[:lp_search][:min_age].blank? && !params[:lp_search][:max_age].blank?
           condition ="   lumbarpunctures.appointment_id in (select appointments.id from participants,  enrollment_vgroup_memberships, enrollments, scan_procedures_vgroups,appointments
                              where enrollment_vgroup_memberships.enrollment_id = enrollments.id and enrollments.participant_id = participants.id
                           and  scan_procedures_vgroups.vgroup_id = enrollment_vgroup_memberships.vgroup_id 
                           and appointments.vgroup_id = enrollment_vgroup_memberships.vgroup_id
                       and round((DATEDIFF(appointments.appointment_date,participants.dob)/365.25),2) <= "+params[:lp_search][:max_age].gsub(/[;:'"()=<>]/, '')+"   )"
          @conditions.push(condition)
          params["search_criteria"] = params["search_criteria"] +",  age at visit <= "+params[:lp_search][:max_age]
      elsif !params[:lp_search][:min_age].blank? && !params[:lp_search][:max_age].blank?
         condition ="    lumbarpunctures.appointment_id in (select appointments.id from participants,  enrollment_vgroup_memberships, enrollments, scan_procedures_vgroups,appointments
                            where enrollment_vgroup_memberships.enrollment_id = enrollments.id and enrollments.participant_id = participants.id
                         and  scan_procedures_vgroups.vgroup_id = enrollment_vgroup_memberships.vgroup_id 
                         and appointments.vgroup_id = enrollment_vgroup_memberships.vgroup_id
                     and round((DATEDIFF(appointments.appointment_date,participants.dob)/365.25),2) between "+params[:lp_search][:min_age].gsub(/[;:'"()=<>]/, '')+" and "+params[:lp_search][:max_age].gsub(/[;:'"()=<>]/, '')+"   )"
        @conditions.push(condition)
        params["search_criteria"] = params["search_criteria"] +",  age at visit between "+params[:lp_search][:min_age]+" and "+params[:lp_search][:max_age]
      end
      # trim leading ","
      params["search_criteria"] = params["search_criteria"].sub(", ","")

      # adjust columns and fields for html vs xls
      request_format = request.formats.to_s
      @html_request ="Y"
      case  request_format
        when "[text/html]","text/html" then  # application/html ?
          @column_headers = ['Date','Protocol','Enumber','RMR','LP status','LP abnormality','LP success','LP followup','Completed Fast','24hr Headache','Needle Size','LP Note', 'Appt Note'] # need to look up values
          # Protocol,Enumber,RMR,Appt_Date get prepended to the fields, appointment_note appended
          @column_number =   @column_headers.size
          @fields =["vgroups.completedlumbarpuncture", "CASE lumbarpunctures.lpabnormality WHEN 1 THEN 'yes' ELSE 'no' end" ,"CASE lumbarpunctures.lpsuccess WHEN 1 THEN 'yes' ELSE 'no' end ","lumbarpunctures.lpfollownote",
            "CASE lumbarpunctures.completedlpfast WHEN 1 THEN 'yes' ELSE 'no' end","lumbarpunctures.followupheadache","lumbarpunctures.needlesize",
            "lumbarpunctures.lumbarpuncture_note","lumbarpunctures.id"] # vgroups.id vgroup_id always first, include table name
          @left_join = ["LEFT JOIN employees on lumbarpunctures.lp_exam_md_id = employees.id"] # left join needs to be in sql right after the parent table!!!!!!!
        else
              @html_request ="N"
              @column_headers = ['Date','Protocol','Enumber','RMR','LP success','LP abnormality','LP followup','LP MD','Completed Fast','Fast hrs','Fast min','LP status','24hr Headache','Needle Size','LP start Hour', 'LP start Minute','LP end Hour', 'LP end Minute','LP Note','BP Systol','BP Diastol','Pulse','Blood Glucose','Age at Appt', 'Appt Note'] # need to look up values
              # Protocol,Enumber,RMR,Appt_Date get prepended to the fields, appointment_note appended
              @column_number =   @column_headers.size
              @fields =["CASE lumbarpunctures.lpsuccess WHEN 1 THEN 'Yes' ELSE 'No' end ","CASE lumbarpunctures.lpabnormality WHEN 1 THEN 'Yes' ELSE 'No' end" ,"lumbarpunctures.lpfollownote",
                 "concat(employees.first_name,' ',employees.last_name)",
                "CASE lumbarpunctures.completedlpfast WHEN 1 THEN 'Yes' ELSE 'No' end",
                "lumbarpunctures.lpfasttotaltime","lumbarpunctures.lpfasttotaltime_min","vgroups.completedlumbarpuncture","lumbarpunctures.followupheadache","lumbarpunctures.needlesize","lumbarpunctures.lpstarttime_hour","lumbarpunctures.lpstarttime_minute","lumbarpunctures.lpendtime_hour","lumbarpunctures.lpendtime_minute","lumbarpunctures.lumbarpuncture_note","vitals.bp_systol","vitals.bp_diastol","vitals.pulse","vitals.bloodglucose","appointments.age_at_appointment","lumbarpunctures.id"] # vgroups.id vgroup_id always first, include table name
              @left_join = ["LEFT JOIN employees on lumbarpunctures.lp_exam_md_id = employees.id",
                            "LEFT JOIN vitals on lumbarpunctures.appointment_id = vitals.appointment_id"] # left join needs to be in sql right after the parent table!!!!!!!
        end
      @tables =['lumbarpunctures'] # trigger joins --- vgroups and appointments by default

      #@conditions =[] # ["scan_procedures.codename='johnson.pipr.visit1'"] # need look up for like, lt, gt, between  
      @order_by =["appointments.appointment_date DESC", "vgroups.rmr"]
            
     @results = self.run_search   # in the application controller
     @results_total = @results  # pageination makes result count wrong
     t = Time.now 
     @export_file_title ="Search Criteria: "+params["search_criteria"]+" "+@results_total.size.to_s+" records "+t.strftime("%m/%d/%Y %I:%M%p")
    
     ### LOOK WHERE TITLE IS SHOWING UP
     @collection_title = 'All Lumbarpuncture appts'

     respond_to do |format|
       format.xls # lp_search.xls.erb
       format.xml  { render :xml => @lumbarpunctures }       
       format.html {@results = Kaminari.paginate_array(@results).page(params[:page]).per(50)} # lp_search.html.erb
     end
   end
  
  

  # DELETE /lumbarpunctures/1
  # DELETE /lumbarpunctures/1.xml
  def destroy
    scan_procedure_array = []
    scan_procedure_array =  (current_user.edit_low_scan_procedure_array).split(' ').map(&:to_i)
          hide_date_flag_array = []
      hide_date_flag_array =  (current_user.hide_date_flag_array).split(' ').map(&:to_i)
      @hide_page_flag = 'N'
      if hide_date_flag_array.count > 0
        @hide_page_flag = 'Y'
      end
     
    @lumbarpuncture = Lumbarpuncture.where("lumbarpunctures.appointment_id in (select appointments.id from appointments,scan_procedures_vgroups where 
                                      appointments.vgroup_id = scan_procedures_vgroups.vgroup_id 
                                      and scan_procedure_id in (?))", scan_procedure_array).find(params[:id])
    
    if @lumbarpuncture.appointment_id > 3156 # sure appointment_id not used by any other
       @appointment = Appointment.find(@lumbarpuncture.appointment_id)
       @appointment.destroy
    end
    @lumbarpuncture.destroy

    respond_to do |format|
      format.html { redirect_to(lp_search_path) }
      format.xml  { head :ok }
    end
  end
end
