# encoding: utf-8
class NeuropsychesController < ApplicationController
  require 'csv'
	before_action :set_neuropsych, only: [:show, :edit, :update, :destroy]   
	respond_to :html  
    def neuropsych_search
       @current_tab = "neuropsyches"
       params["search_criteria"] =""

       if params[:neuropsych_search].nil?
            params[:neuropsych_search] =Hash.new  
       end

       scan_procedure_array = []
       scan_procedure_array =  (current_user.view_low_scan_procedure_array).split(' ').map(&:to_i)  
             hide_date_flag_array = []
      hide_date_flag_array =  (current_user.hide_date_flag_array).split(' ').map(&:to_i)
      @hide_page_flag = 'N'
      if hide_date_flag_array.count > 0
        @hide_page_flag = 'Y'
      end 

  #    @neuropsyches = Blooddraw.where("neuropsyches.appointment_id in (select appointments.id from appointments,scan_procedures_vgroups where 
  #                                       appointments.vgroup_id = scan_procedures_vgroups.vgroup_id 
  #    and scan_procedure_id in (?))", scan_procedure_array).all
  #     sql = "select * from neuropsyches inner join  appointments on appointments.id = neuropsyches.appointment_id order by appointment_date desc"
  #      @search = Blooddraw.find_by_sql(sql)
  #     @search = Blooddraw.where("neuropsyches.appointment_id in (select appointments.id from appointments)").all
        @search = Neuropsych.search(params[:search])    # parms search makes something which works with where?
        @search =@search.where("neuropsyches.appointment_id in (select appointment_id from q_data_forms)")
        if !params[:neuropsych_search][:scan_procedure_id].blank?
           @search =@search.where("neuropsyches.appointment_id in (select appointments.id from appointments,scan_procedures_vgroups where 
                                                  appointments.vgroup_id = scan_procedures_vgroups.vgroup_id 
                                                  and scan_procedure_id in (?))",params[:neuropsych_search][:scan_procedure_id])
           @scan_procedures = ScanProcedure.where("id in (?)",params[:neuropsych_search][:scan_procedure_id])
           params["search_criteria"] = params["search_criteria"] +", "+@scan_procedures.sort_by(&:codename).collect {|sp| sp.codename}.join(", ").html_safe
        end

        if !params[:neuropsych_search][:enumber].blank?
           @search =@search.where(" neuropsyches.appointment_id in (select appointments.id from enrollment_vgroup_memberships,enrollments, appointments
            where enrollment_vgroup_memberships.vgroup_id= appointments.vgroup_id 
            and enrollment_vgroup_memberships.enrollment_id = enrollments.id and lower(enrollments.enumber) in (lower(?)))",params[:neuropsych_search][:enumber])
            params["search_criteria"] = params["search_criteria"] +",  enumber "+params[:neuropsych_search][:enumber]
        end      

        if !params[:neuropsych_search][:rmr].blank? 
            @search = @search.where(" neuropsyches.appointment_id in (select appointments.id from appointments,vgroups
                      where appointments.vgroup_id = vgroups.id and  lower(vgroups.rmr) in (lower(?)   ))",params[:neuropsych_search][:rmr])
            params["search_criteria"] = params["search_criteria"] +",  RMR "+params[:neuropsych_search][:rmr]
        end

         #  build expected date format --- between, >, < 
         v_date_latest =""
         #want all three date parts

         if !params[:neuropsych_search]["#{'latest_timestamp'}(1i)"].blank? && !params[:neuropsych_search]["#{'latest_timestamp'}(2i)"].blank? && !params[:neuropsych_search]["#{'latest_timestamp'}(3i)"].blank?
              v_date_latest = params[:neuropsych_search]["#{'latest_timestamp'}(1i)"] +"-"+params[:neuropsych_search]["#{'latest_timestamp'}(2i)"].rjust(2,"0")+"-"+params[:neuropsych_search]["#{'latest_timestamp'}(3i)"].rjust(2,"0")
         end

         v_date_earliest =""
         #want all three date parts

         if !params[:neuropsych_search]["#{'earliest_timestamp'}(1i)"].blank? && !params[:neuropsych_search]["#{'earliest_timestamp'}(2i)"].blank? && !params[:neuropsych_search]["#{'earliest_timestamp'}(3i)"].blank?
               v_date_earliest = params[:neuropsych_search]["#{'earliest_timestamp'}(1i)"] +"-"+params[:neuropsych_search]["#{'earliest_timestamp'}(2i)"].rjust(2,"0")+"-"+params[:neuropsych_search]["#{'earliest_timestamp'}(3i)"].rjust(2,"0")
          end

         if v_date_latest.length>0 && v_date_earliest.length >0
           @search = @search.where(" neuropsyches.appointment_id in (select appointments.id from appointments where appointments.appointment_date between ? and ? )",v_date_earliest,v_date_latest)
           params["search_criteria"] = params["search_criteria"] +",  visit date between "+v_date_earliest+" and "+v_date_latest
         elsif v_date_latest.length>0
           @search = @search.where(" neuropsyches.appointment_id in (select appointments.id from appointments where appointments.appointment_date < ?  )",v_date_latest)
            params["search_criteria"] = params["search_criteria"] +",  visit date before "+v_date_latest 
         elsif  v_date_earliest.length >0
           @search = @search.where(" neuropsyches.appointment_id in (select appointments.id from appointments where appointments.appointment_date > ? )",v_date_earliest)
            params["search_criteria"] = params["search_criteria"] +",  visit date after "+v_date_earliest
          end

          if !params[:neuropsych_search][:gender].blank?
             @search =@search.where(" neuropsyches.appointment_id in (select appointments.id from participants,  enrollment_vgroup_memberships, enrollments,appointments
              where enrollment_vgroup_memberships.enrollment_id = enrollments.id and enrollments.participant_id = participants.id 
              and enrollment_vgroup_memberships.vgroup_id = appointments.vgroup_id
                     and participants.gender is not NULL and participants.gender in (?) )", params[:neuropsych_search][:gender])
              if params[:neuropsych_search][:gender] == 1
                 params["search_criteria"] = params["search_criteria"] +",  sex is Male"
              elsif params[:neuropsych_search][:gender] == 2
                 params["search_criteria"] = params["search_criteria"] +",  sex is Female"
              end
          end   

          if !params[:neuropsych_search][:min_age].blank? && params[:neuropsych_search][:max_age].blank?
              @search = @search.where("  neuropsyches.appointment_id in (select appointments.id from participants,  enrollment_vgroup_memberships, enrollments, scan_procedures_vgroups,appointments
                                 where enrollment_vgroup_memberships.enrollment_id = enrollments.id and enrollments.participant_id = participants.id
                              and  scan_procedures_vgroups.vgroup_id = enrollment_vgroup_memberships.vgroup_id 
                              and appointments.vgroup_id = enrollment_vgroup_memberships.vgroup_id
                              and round((DATEDIFF(appointments.appointment_date,participants.dob)/365.25),2) >= ?   )",params[:neuropsych_search][:min_age])
              params["search_criteria"] = params["search_criteria"] +",  age at visit >= "+params[:neuropsych_search][:min_age]
          elsif params[:neuropsych_search][:min_age].blank? && !params[:neuropsych_search][:max_age].blank?
               @search = @search.where("  neuropsyches.appointment_id in (select appointments.id from participants,  enrollment_vgroup_memberships, enrollments, scan_procedures_vgroups,appointments
                                  where enrollment_vgroup_memberships.enrollment_id = enrollments.id and enrollments.participant_id = participants.id
                               and  scan_procedures_vgroups.vgroup_id = enrollment_vgroup_memberships.vgroup_id 
                               and appointments.vgroup_id = enrollment_vgroup_memberships.vgroup_id
                           and round((DATEDIFF(appointments.appointment_date,participants.dob)/365.25),2) <= ?   )",params[:neuropsych_search][:max_age])
              params["search_criteria"] = params["search_criteria"] +",  age at visit <= "+params[:neuropsych_search][:max_age]
          elsif !params[:neuropsych_search][:min_age].blank? && !params[:neuropsych_search][:max_age].blank?
             @search = @search.where("   neuropsyches.appointment_id in (select appointments.id from participants,  enrollment_vgroup_memberships, enrollments, scan_procedures_vgroups,appointments
                                where enrollment_vgroup_memberships.enrollment_id = enrollments.id and enrollments.participant_id = participants.id
                             and  scan_procedures_vgroups.vgroup_id = enrollment_vgroup_memberships.vgroup_id 
                             and appointments.vgroup_id = enrollment_vgroup_memberships.vgroup_id
                         and round((DATEDIFF(appointments.appointment_date,participants.dob)/365.25),2) between ? and ?   )",params[:neuropsych_search][:min_age],params[:neuropsych_search][:max_age])
            params["search_criteria"] = params["search_criteria"] +",  age at visit between "+params[:neuropsych_search][:min_age]+" and "+params[:neuropsych_search][:max_age]
          end
          # trim leading ","
          params["search_criteria"] = params["search_criteria"].sub(", ","")
          # pass to download file?

      @search =  @search.where("neuropsyches.appointment_id in (select appointments.id from appointments,scan_procedures_vgroups where 
                                                 appointments.vgroup_id = scan_procedures_vgroups.vgroup_id 
                                                 and scan_procedure_id in (?))", scan_procedure_array)


      @neuropsyches =  @search.page(params[:page])

      ### LOOK WHERE TITLE IS SHOWING UP
      @collection_title = 'All Neuro Psych appts'

      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @neuropsyches }
      end
    end

  
    def np_search  
      if !params[:np_search].blank?
         @np_search_params = np_search_params()
      end
      @conditions = []
       @current_tab = "neuropsyches"
       params["search_criteria"] =""
       v_raw_data ="N"
       if !params[:p_raw_data].nil? and !params[:p_raw_data].blank?
         v_raw_data = params[:p_raw_data]
       end 
       # for search dropdown
        @q_forms = Questionform.where("current_tab in (?)",@current_tab).where("status_flag in (?)","Y")
        @q_form_default = @q_forms.where("tab_default_yn='Y'")

       q_form = Questionform.where("current_tab in (?)",@current_tab).where("tab_default_yn in (?)","Y")
       @q_form_id = q_form[0].id # 13   # use in data_search_q_data
       if !params[:np_search].nil? and !params[:np_search][:questionform_id].blank?
           @q_form_id = params[:np_search][:questionform_id]
        end

       if params[:np_search].nil?
            params[:np_search] =Hash.new 
            # params[:np_search][:np_status] = "yes" 
       end

       scan_procedure_array = []
       scan_procedure_array =  (current_user.view_low_scan_procedure_array).split(' ').map(&:to_i)   

             hide_date_flag_array = []
      hide_date_flag_array =  (current_user.hide_date_flag_array).split(' ').map(&:to_i)
      @hide_page_flag = 'N'
      if hide_date_flag_array.count > 0
        @hide_page_flag = 'Y'
      end

     # swapping out q_form description if different name linked to scan_procedures 
     @q_forms.each do |f|
            if !params[:np_search][:scan_procedure_id].blank?
                @spformdisplays = Questionformnamesp.where("questionform_id in (?) and scan_procedure_id in (?) and scan_procedure_id in (?)",f.id,scan_procedure_array,params[:np_search][:scan_procedure_id])

            else
                @spformdisplays = Questionformnamesp.where("questionform_id in (?) and scan_procedure_id in (?) ",f.id,scan_procedure_array)
            end     
            if !@spformdisplays.nil?
              v_form_name = @spformdisplays.sort_by(&:form_name).collect {|sp| sp.form_name }.join("|")
              v_form_name_array = v_form_name.split("|")
              v_form_name_array = v_form_name_array.uniq
              v_form_name = v_form_name_array.join(", ")
              if !v_form_name.empty?
                  f.description = f.description+","+v_form_name
              end
            end
     end
  #    @neuropsyches = Blooddraw.where("neuropsyches.appointment_id in (select appointments.id from appointments,scan_procedures_vgroups where 
  #                                       appointments.vgroup_id = scan_procedures_vgroups.vgroup_id 
  #    and scan_procedure_id in (?))", scan_procedure_array).all
  #     sql = "select * from neuropsyches inner join  appointments on appointments.id = neuropsyches.appointment_id order by appointment_date desc"
  #      @search = Blooddraw.find_by_sql(sql)
  #     @search = Blooddraw.where("neuropsyches.appointment_id in (select appointments.id from appointments)").all
  #      @search = Neuropsych.search(params[:search])    # parms search makes something which works with where?
        condition ="   neuropsyches.appointment_id in (select appointment_id from q_data_forms)"
        if !params[:np_search][:scan_procedure_id].blank?
           condition ="   neuropsyches.appointment_id in (select appointments.id from appointments,scan_procedures_vgroups where 
                                                  appointments.vgroup_id = scan_procedures_vgroups.vgroup_id 
                                                  and scan_procedure_id in ("+params[:np_search][:scan_procedure_id].join(',').gsub(/[;:'"“”()=<>]/, '')+"))"
           @scan_procedures = ScanProcedure.where("id in (?)",params[:np_search][:scan_procedure_id])
           @conditions.push(condition)
           params["search_criteria"] = params["search_criteria"] +", "+@scan_procedures.sort_by(&:codename).collect {|sp| sp.codename}.join(", ").html_safe
        end

        if !params[:np_search][:enumber].blank?
          params[:np_search][:enumber] = params[:np_search][:enumber].gsub(/ /,'').gsub(/\t/,'').gsub(/\n/,'').gsub(/\r/,'')
          if params[:np_search][:enumber].include?(',') # string of enumbers
           v_enumber =  params[:np_search][:enumber].gsub(/ /,'').gsub(/'/,'').downcase
           v_enumber = v_enumber.gsub(/,/,"','")
            condition ="    neuropsyches.appointment_id in (select appointments.id from enrollment_vgroup_memberships,enrollments, appointments
               where enrollment_vgroup_memberships.vgroup_id= appointments.vgroup_id 
               and enrollment_vgroup_memberships.enrollment_id = enrollments.id and lower(enrollments.enumber) in  ('"+v_enumber.gsub(/[;:"“”()=<>]/, '')+"'))"
          else
           condition ="    neuropsyches.appointment_id in (select appointments.id from enrollment_vgroup_memberships,enrollments, appointments
            where enrollment_vgroup_memberships.vgroup_id= appointments.vgroup_id 
            and enrollment_vgroup_memberships.enrollment_id = enrollments.id and lower(enrollments.enumber) in  (lower('"+params[:np_search][:enumber].gsub(/[;:"“”()=<>]/, '')+"')))"
          end
            @conditions.push(condition)
            params["search_criteria"] = params["search_criteria"] +",  enumber "+params[:np_search][:enumber]
        end      

        if !params[:np_search][:rmr].blank? 
            condition ="    neuropsyches.appointment_id in (select appointments.id from appointments,vgroups
                      where appointments.vgroup_id = vgroups.id and  lower(vgroups.rmr) in (lower('"+params[:np_search][:rmr].gsub(/[;:'"“”()=<>]/, '')+"')   ))"
                      @conditions.push(condition)
            params["search_criteria"] = params["search_criteria"] +",  RMR "+params[:np_search][:rmr]
        end
        
        if !params[:np_search][:reggieid].blank? 
            reggieid_param = params[:np_search][:reggieid]
            if reggieid_param.include?(',')
              #this should solve the trailing comma problem
              reggieid_param = reggieid_param.split(',').select { |x| !x.blank? }.collect { |x| x.strip || x }.join(',')
            end
            condition ="   neuropsyches.appointment_id in (select appointments.id from participants,  enrollment_vgroup_memberships, enrollments,appointments
             where enrollment_vgroup_memberships.enrollment_id = enrollments.id and enrollments.participant_id = participants.id 
             and enrollment_vgroup_memberships.vgroup_id = appointments.vgroup_id
                    and participants.reggieid is not NULL and participants.reggieid in ("+reggieid_param.gsub(/[;:'"“”()=<>]/, '')+") )"
            @conditions.push(condition)
            params["search_criteria"] = params["search_criteria"] +",  Reggie ID ("+reggieid_param+")"
        end

        if !params[:np_search][:np_status].blank? 
            condition =" neuropsyches.appointment_id in (select appointments.id from appointments,vgroups
                                where appointments.vgroup_id = vgroups.id and  lower(vgroups.completedneuropsych) in (lower('"+params[:np_search][:np_status].gsub(/[;:'"“”()=<>]/, '')+"')   ))"
            @conditions.push(condition)
            params["search_criteria"] = params["search_criteria"] +",  NP status "+params[:np_search][:np_status]
        end

         #  build expected date format --- between, >, < 
         v_date_latest =""
         #want all three date parts

         if !params[:np_search]["#{'latest_timestamp'}(1i)"].blank? && !params[:np_search]["#{'latest_timestamp'}(2i)"].blank? && !params[:np_search]["#{'latest_timestamp'}(3i)"].blank?
              v_date_latest = params[:np_search]["#{'latest_timestamp'}(1i)"] +"-"+params[:np_search]["#{'latest_timestamp'}(2i)"].rjust(2,"0")+"-"+params[:np_search]["#{'latest_timestamp'}(3i)"].rjust(2,"0")
         end

         v_date_earliest =""
         #want all three date parts

         if !params[:np_search]["#{'earliest_timestamp'}(1i)"].blank? && !params[:np_search]["#{'earliest_timestamp'}(2i)"].blank? && !params[:np_search]["#{'earliest_timestamp'}(3i)"].blank?
               v_date_earliest = params[:np_search]["#{'earliest_timestamp'}(1i)"] +"-"+params[:np_search]["#{'earliest_timestamp'}(2i)"].rjust(2,"0")+"-"+params[:np_search]["#{'earliest_timestamp'}(3i)"].rjust(2,"0")
          end

         if v_date_latest.length>0 && v_date_earliest.length >0
           condition ="    neuropsyches.appointment_id in (select appointments.id from appointments where appointments.appointment_date between '"+v_date_earliest+"' and '"+v_date_latest+"' )"
           @conditions.push(condition)
           params["search_criteria"] = params["search_criteria"] +",  visit date between "+v_date_earliest+" and "+v_date_latest
         elsif v_date_latest.length>0
           condition ="    neuropsyches.appointment_id in (select appointments.id from appointments where appointments.appointment_date <  '"+v_date_latest+"'  )"
            @conditions.push(condition)
            params["search_criteria"] = params["search_criteria"] +",  visit date before "+v_date_latest 
         elsif  v_date_earliest.length >0
           condition ="    neuropsyches.appointment_id in (select appointments.id from appointments where appointments.appointment_date >  '"+v_date_earliest+"' )"
            @conditions.push(condition)
            params["search_criteria"] = params["search_criteria"] +",  visit date after "+v_date_earliest
          end

          if !params[:np_search][:gender].blank?
             condition ="    neuropsyches.appointment_id in (select appointments.id from participants,  enrollment_vgroup_memberships, enrollments,appointments
              where enrollment_vgroup_memberships.enrollment_id = enrollments.id and enrollments.participant_id = participants.id 
              and enrollment_vgroup_memberships.vgroup_id = appointments.vgroup_id
                     and participants.gender is not NULL and participants.gender in ("+params[:np_search][:gender].gsub(/[;:'"“”()=<>]/, '')+") )"
              @conditions.push(condition)
              if params[:np_search][:gender] == 1
                 params["search_criteria"] = params["search_criteria"] +",  sex is Male"
              elsif params[:np_search][:gender] == 2
                 params["search_criteria"] = params["search_criteria"] +",  sex is Female"
              end
          end   

          if !params[:np_search][:min_age].blank? && params[:np_search][:max_age].blank?
              condition ="     neuropsyches.appointment_id in (select appointments.id from participants,  enrollment_vgroup_memberships, enrollments, scan_procedures_vgroups,appointments
                                 where enrollment_vgroup_memberships.enrollment_id = enrollments.id and enrollments.participant_id = participants.id
                              and  scan_procedures_vgroups.vgroup_id = enrollment_vgroup_memberships.vgroup_id 
                              and appointments.vgroup_id = enrollment_vgroup_memberships.vgroup_id
                              and round((DATEDIFF(appointments.appointment_date,participants.dob)/365.25),2) >= "+params[:np_search][:min_age].gsub(/[;:'"“”()=<>]/, '')+"   )"
              @conditions.push(condition)
              params["search_criteria"] = params["search_criteria"] +",  age at visit >= "+params[:np_search][:min_age]
          elsif params[:np_search][:min_age].blank? && !params[:np_search][:max_age].blank?
               condition ="     neuropsyches.appointment_id in (select appointments.id from participants,  enrollment_vgroup_memberships, enrollments, scan_procedures_vgroups,appointments
                                  where enrollment_vgroup_memberships.enrollment_id = enrollments.id and enrollments.participant_id = participants.id
                               and  scan_procedures_vgroups.vgroup_id = enrollment_vgroup_memberships.vgroup_id 
                               and appointments.vgroup_id = enrollment_vgroup_memberships.vgroup_id
                           and round((DATEDIFF(appointments.appointment_date,participants.dob)/365.25),2) <= "+params[:np_search][:max_age].gsub(/[;:'"“”()=<>]/, '')+"   )"
              @conditions.push(condition)
              params["search_criteria"] = params["search_criteria"] +",  age at visit <= "+params[:np_search][:max_age]
          elsif !params[:np_search][:min_age].blank? && !params[:np_search][:max_age].blank?
             condition ="      neuropsyches.appointment_id in (select appointments.id from participants,  enrollment_vgroup_memberships, enrollments, scan_procedures_vgroups,appointments
                                where enrollment_vgroup_memberships.enrollment_id = enrollments.id and enrollments.participant_id = participants.id
                             and  scan_procedures_vgroups.vgroup_id = enrollment_vgroup_memberships.vgroup_id 
                             and appointments.vgroup_id = enrollment_vgroup_memberships.vgroup_id
                         and round((DATEDIFF(appointments.appointment_date,participants.dob)/365.25),2) between "+params[:np_search][:min_age].gsub(/[;:'"“”()=<>]/, '')+" and "+params[:np_search][:max_age].gsub(/[;:'"“”()=<>]/, '')+"   )"
            @conditions.push(condition)
            params["search_criteria"] = params["search_criteria"] +",  age at visit between "+params[:np_search][:min_age]+" and "+params[:np_search][:max_age]
          end
          # trim leading ","
          params["search_criteria"] = params["search_criteria"].sub(", ","")
          # pass to download file?

    #  @search =  @search.where("neuropsyches.appointment_id in (select appointments.id from appointments,scan_procedures_vgroups where 
    #                                             appointments.vgroup_id = scan_procedures_vgroups.vgroup_id 
    #                                             and scan_procedure_id in (?))", scan_procedure_array)


     # @neuropsyches =  @search.page(params[:page])

    
     # adjust columns and fields for html vs xls
     #request_format = request.formats.to_s  
     v_request_format_array = request.formats
      request_format = v_request_format_array[0]
     @html_request ="Y"
     case  request_format
       when "[text/html]","text/html" then  # application/html ?
         @column_headers = ['Date','Protocol','Enumber','RMR','NP status','NP Note', 'Appt Note'] # need to look up values
         # Protocol,Enumber,RMR,Appt_Date get prepended to the fields, appointment_note appended
         @column_number =   @column_headers.size
         @fields =["vgroups.completedneuropsych", "neuropsyches.neuropsychnote","neuropsyches.id"] # vgroups.id vgroup_id always first, include table name
         @left_join = [""] # left join needs to be in sql right after the parent table!!!!!!!
       else
             @html_request ="N"
             @column_headers = ['Date','Protocol','Enumber','RMR','NP status','NP Note', 'Age at Appt','Appt Note'] # need to look up values
             # Protocol,Enumber,RMR,Appt_Date get prepended to the fields, appointment_note appended
             #@column_number =   @column_headers.size
             @fields =["vgroups.completedneuropsych", "neuropsyches.neuropsychnote","appointments.age_at_appointment","neuropsyches.id"] # vgroups.id vgroup_id always first, include table name
             @left_join = [] # left join needs to be in sql right after the parent table!!!!!!!
             @column_headers_q_data =[]
             @fields_q_data = []
             @left_join_q_data = []
       end
     @tables =['neuropsyches'] # trigger joins --- vgroups and appointments by default

     #@conditions =[] # ["scan_procedures.codename='johnson.pipr.visit1'"] # need look up for like, lt, gt, between  
     @order_by =["appointments.appointment_date DESC", "vgroups.rmr"]
           
   
   if @html_request == "Y"     
       @results = self.run_search   # in the application controller
   elsif @html_request == "N"
        @results = self.run_search_q_data(@tables,@fields ,@left_join,@left_join_vgroup,v_raw_data)   # in the application controller
        @column_number =   @column_headers.size
   end
    @results_total = @results  # pageination makes result count wrong
    t = Time.now 
    v_display_form_name = ""
     if !params[:np_search][:scan_procedure_id].blank?
        @spformdisplays = Questionformnamesp.where("questionform_id in (?) and scan_procedure_id in (?) and scan_procedure_id in (?)",@q_form_id,scan_procedure_array,params[:np_search][:scan_procedure_id])
      else
        @spformdisplays = Questionformnamesp.where("questionform_id in (?) and scan_procedure_id in (?) ",@q_form_id,scan_procedure_array)
      end     
      if !@spformdisplays.nil?
         v_form_name = @spformdisplays.sort_by(&:form_name).collect {|sp| sp.form_name }.join(", ")
          if !v_form_name.empty?
             v_display_form_name = v_form_name
          else
              q_form = Questionform.find(@q_form_id)
              v_display_form_name = q_form.description
          end
      end
    @export_file_title =v_display_form_name+" Search Criteria: "+params["search_criteria"]+" "+@results_total.size.to_s+" records "+t.strftime("%m/%d/%Y %I:%M%p")
    @csv_array = []
    @results_tmp_csv = []
    @results_tmp_csv.push(@export_file_title)
    @csv_array.push(@results_tmp_csv )
    @csv_array.push( @column_headers)
    @results.each do |result| 
       @results_tmp_csv = []
       for i in 0..@column_number-1  # results is an array of arrays%>
          @results_tmp_csv.push(result[i])
       end 
       @csv_array.push(@results_tmp_csv)
    end 
    @csv_str = @csv_array.inject([]) { |csv, row|  csv << CSV.generate_line(row) }.join("") 
    ### LOOK WHERE TITLE IS SHOWING UP
    @collection_title = v_display_form_name+' All Neuro Psych appts'

    respond_to do |format|
      format.xls # lp_search.xls.erb
      format.csv { send_data @csv_str }
      format.xml  { render :xml => @neuropsyches }       
      format.html {@results = Kaminari.paginate_array(@results).page(params[:page]).per(50)} # lp_search.html.erb
    end

    end

  # GET /neuropsyches
  # GET /neuropsyches.xml
  def index
    @neuropsyches = Neuropsych.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @neuropsyches }
    end
  end

    def neuropsych_pdf
      v_q_data_form_id = ""
      v_q_form_id = ""
      if !params[:q_form_id].nil? and !params[:q_data_form_id].blank? and !params[:id].blank?
         v_q_data_form_id = params[:q_data_form_id]
         v_q_form_id = params[:q_form_id]
         # need to evaluate that user has perms on q_data_form_id

           # mimicing show
         scan_procedure_array = []
         scan_procedure_array =  (current_user.view_low_scan_procedure_array).split(' ').map(&:to_i)
         @neuropsych = Neuropsych.where("neuropsyches.appointment_id in (select appointments.id from appointments,scan_procedures_vgroups where 
                                       appointments.vgroup_id = scan_procedures_vgroups.vgroup_id 
                                       and scan_procedure_id in (?))", scan_procedure_array).find(params[:id])

     @appointment = Appointment.find(@neuropsych.appointment_id)
     @vgroup = Vgroup.find(@appointment.vgroup_id)
     @questionform =Questionform.find(v_q_form_id)

      puts "zzzzz v_q_data_form_id="+v_q_data_form_id.to_s+"  v_q_form_id="+v_q_form_id.to_s

      # HOW much of to do here vs in questionform model
      pdf = @questionform.displayform_pdf(v_q_data_form_id,v_q_form_id,@appointment,@vgroup)
      respond_to do |format|
         format.html # show.html.erb
         format.xml  { render :xml => @participant }
         format.pdf do
           send_data pdf.render,
           filename: "export.pdf",
           type: 'application/pdf',
           disposition: 'inline'
         end
      end

     end # params ok
    end

  # GET /neuropsyches/1
  # GET /neuropsyches/1.xml
  def show
    @current_tab = "neuropsyches"
     scan_procedure_array = []
     scan_procedure_array =  (current_user.view_low_scan_procedure_array).split(' ').map(&:to_i)
           hide_date_flag_array = []
      hide_date_flag_array =  (current_user.hide_date_flag_array).split(' ').map(&:to_i)
      @hide_page_flag = 'N'
      if hide_date_flag_array.count > 0
        @hide_page_flag = 'Y'
      end

     @neuropsych = Neuropsych.where("neuropsyches.appointment_id in (select appointments.id from appointments,scan_procedures_vgroups where 
                                       appointments.vgroup_id = scan_procedures_vgroups.vgroup_id 
                                       and scan_procedure_id in (?))", scan_procedure_array).find(params[:id])

     @appointment = Appointment.find(@neuropsych.appointment_id) 
     @vgroup = Vgroup.find(@appointment.vgroup_id)
     sp_list = @vgroup.scan_procedures.collect {|sp| sp.id}.join(",")
     sp_array =[]
     sp_array = sp_list.split(',').map(&:to_i)

     q_form = Questionform.where("current_tab in (?)",@current_tab).where("tab_default_yn in (?)","Y")
     q_form_id = q_form[0].id # 13
     if   !@appointment.questionform_id_list.blank?
            q_form_id_array = (@appointment.questionform_id_list).split(",")
            q_form_id  = q_form_id_array[0]
     end   
     @q_form_id = q_form_id
     @q_forms = Questionform.where("current_tab in (?)",@current_tab).where("status_flag in (?)","Y").where("questionforms.id not in (select questionform_id from questionform_scan_procedures)
                                                                 or (questionforms.id in 
                                                                         (select questionform_id from questionform_scan_procedures where  include_exclude ='include' and scan_procedure_id in ("+sp_array.join(',')+"))
                                                                      and
                                                                  questionforms.id  not in 
                                              (select questionform_id from questionform_scan_procedures where include_exclude ='exclude' and scan_procedure_id in ("+sp_array.join(',')+")))")
         # swapping out q_form description if different name linked to scan_procedures 
     @q_forms.each do |f|
            @spformdisplays = Questionformnamesp.where("questionform_id in (?) and scan_procedure_id in (?)",f.id,sp_array)
            if !@spformdisplays.nil?
              v_form_name = @spformdisplays.sort_by(&:form_name).collect {|sp| sp.form_name }.join(", ")
              if !v_form_name.empty?
                  f.description = v_form_name
              end
            end
     end
     @q_form_default = @q_forms.where("tab_default_yn='Y'")

     if   !@appointment.questionform_id_list.blank? and (params[:appointment].nil?  or (!params[:appointment].nil? and  params[:appointment][:questionform_id_list].blank?) )
            q_form_id_array = (@appointment.questionform_id_list).split(",")
            q_form_id  = q_form_id_array[0]
     end                   

     @neuropsyches = Neuropsych.where("neuropsyches.appointment_id in (select appointments.id from appointments,scan_procedures_vgroups where 
                                 appointments.vgroup_id = scan_procedures_vgroups.vgroup_id 
                                and appointments.appointment_date between ? and ?
                                and scan_procedure_id in (?))", @appointment.appointment_date-2.month,@appointment.appointment_date+2,scan_procedure_array).to_a

     idx = @neuropsyches.index(@neuropsych)
     @older_neuropsych = idx + 1 >= @neuropsyches.size ? nil : @neuropsyches[idx + 1]
     @newer_neuropsych = idx - 1 < 0 ? nil : @neuropsyches[idx - 1]

     @participant = @vgroup.try(:participant)
     @enumbers = @vgroup.enrollments
     
     @q_data_form = QDataForm.where("questionform_id="+q_form_id.to_s+" and appointment_id in (?)",@appointment.id)
     @q_data_form = @q_data_form[0]
     #params[:appointment_id] = @neuropsych.appointment_id
     @questionform =Questionform.find(q_form_id)

     # NEED SCAN PROC ARRAY FOR VGROUP  --- change to vgroup!!
      @a =  Appointment.where("vgroup_id in (?)",@appointment.vgroup_id)
      # switching to vgroup sp
#         a_array =@a.to_a
#        @visits = Visit.where("appointment_id in (?) ",a_array)
#          visit = nil
#          @visits.each do |v| 
# 	       visit = v
# 	     end  
# 	  sp_list = visit.scan_procedures.collect {|sp| sp.id}.join(",")
 	  
 	  @scanprocedures = ScanProcedure.where("id in (?)",sp_array)

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @neuropsych }
    end
  end

  # GET /neuropsyches/new
  # GET /neuropsyches/new.xml
  def new
          hide_date_flag_array = []
      hide_date_flag_array =  (current_user.hide_date_flag_array).split(' ').map(&:to_i)
      @hide_page_flag = 'N'
      if hide_date_flag_array.count > 0
        @hide_page_flag = 'Y'
      end
        @current_tab = "neuropsyches"
        @neuropsych = Neuropsych.new
        vgroup_id = params[:id]
        @vgroup = Vgroup.find(vgroup_id)
        @enumbers = @vgroup.enrollments
        params[:new_appointment_vgroup_id] = vgroup_id
        @appointment = Appointment.new
        @appointment.vgroup_id = vgroup_id
        @appointment.appointment_date = (Vgroup.find(vgroup_id)).vgroup_date
        @appointment.appointment_type ='blood_draw'
    #    @appointment.save  --- save in create step
        @neuropsych.appointment_id = @appointment.id
        sp_list = @vgroup.scan_procedures.collect {|sp| sp.id}.join(",")
        sp_array =[]
        sp_array = sp_list.split(',').map(&:to_i)

        @q_forms = Questionform.where("current_tab in (?)",@current_tab).where("status_flag in (?)","Y").where("questionforms.id not in (select questionform_id from questionform_scan_procedures)
                                                                 or (questionforms.id in 
                                                                         (select questionform_id from questionform_scan_procedures where  include_exclude ='include' and scan_procedure_id in ("+sp_array.join(',')+"))
                                                                      and
                                                                  questionforms.id  not in 
                                              (select questionform_id from questionform_scan_procedures where include_exclude ='exclude' and scan_procedure_id in ("+sp_array.join(',')+")))")
     
        @q_form_default = @q_forms.where("tab_default_yn='Y'")
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @neuropsych }
    end
  end

  # GET /neuropsyches/1/edit
  def edit
    @current_tab = "neuropsyches"
    scan_procedure_array = []
    scan_procedure_array =  (current_user.edit_low_scan_procedure_array).split(' ').map(&:to_i)
          hide_date_flag_array = []
      hide_date_flag_array =  (current_user.hide_date_flag_array).split(' ').map(&:to_i)
      @hide_page_flag = 'N'
      if hide_date_flag_array.count > 0
        @hide_page_flag = 'Y'
      end
    @neuropsych = Neuropsych.where("neuropsyches.appointment_id in (select appointments.id from appointments,scan_procedures_vgroups where 
                                      appointments.vgroup_id = scan_procedures_vgroups.vgroup_id 
                                      and scan_procedure_id in (?))", scan_procedure_array).find(params[:id])
    @appointment = Appointment.find(@neuropsych.appointment_id)
    @vgroup = Vgroup.find(@appointment.vgroup_id)
    @enumbers = @vgroup.enrollments

    q_form = Questionform.where("current_tab in (?)",@current_tab).where("tab_default_yn in (?)","Y")
    q_form_id = q_form[0].id # 13
    if !params[:appointment].nil? and !params[:appointment][:questionform_id_list].blank?
          q_form_id  = params[:appointment][:questionform_id_list]
          q_form = Questionform.find(q_form_id)
    elsif   !@appointment.questionform_id_list.blank?
          q_form_id_array = (@appointment.questionform_id_list).split(",")
          q_form_id  = q_form_id_array[0]
          q_form = Questionform.find(q_form_id)
    end 
    # NEED TO ADD LIMIT BY SCAN PROCEDURE
    sp_list = @vgroup.scan_procedures.collect {|sp| sp.id}.join(",")
    sp_array =[]
    sp_array = sp_list.split(',').map(&:to_i)

    @q_forms = Questionform.where("current_tab in (?)",@current_tab).where("status_flag in (?)","Y").where("questionforms.id not in (select questionform_id from questionform_scan_procedures)
                                                                 or (questionforms.id in 
                                                                         (select questionform_id from questionform_scan_procedures where  include_exclude ='include' and scan_procedure_id in ("+sp_array.join(',')+"))
                                                                      and
                                                                  questionforms.id  not in 
                                              (select questionform_id from questionform_scan_procedures where include_exclude ='exclude' and scan_procedure_id in ("+sp_array.join(',')+")))")
     
          # swapping out q_form description if different name linked to scan_procedures 
     @q_forms.each do |f|
            @spformdisplays = Questionformnamesp.where("questionform_id in (?) and scan_procedure_id in (?)",f.id,sp_array)
            if !@spformdisplays.nil?
              v_form_name = @spformdisplays.sort_by(&:form_name).collect {|sp| sp.form_name }.join(", ")
              if !v_form_name.empty?
                  f.description = v_form_name
              end
            end
     end
    @q_form_default = @q_forms.where("tab_default_yn='Y'")
    
    @q_data_form = QDataForm.where("questionform_id="+q_form_id.to_s+" and appointment_id in (?)",@appointment.id)
    @q_data_form = @q_data_form[0]
    #params[:appointment_id] = @neuropsych.appointment_id
    @questionform =Questionform.find(q_form_id)
    if @q_data_form.nil?
        @q_data_form = QDataForm.new
        @q_data_form.appointment_id = @appointment.id
        @q_data_form.questionform_id = q_form_id
        @q_data_form.save
    end

    # NEED SCAN PROC ARRAY FOR VGROUP  --- change to vgroup!!
  
     @a =  Appointment.where("vgroup_id in (?)",@appointment.vgroup_id)
     # switching to vgroup sp
#        a_array =@a.to_a
#       @visits = Visit.where("appointment_id in (?) ",a_array)
#         visit = nil
#         @visits.each do |v| #
#	       visit = v
#	     end  
#	  sp_list = visit.scan_procedures.collect {|sp| sp.id}.join(",")
	  @scanprocedures = ScanProcedure.where("id in (?)",sp_array)
  end

  # POST /neuropsyches
  # POST /neuropsyches.xml
  def create
     @current_tab = "neuropsyches"
     q_form = Questionform.where("current_tab in (?)",@current_tab).where("tab_default_yn in (?)","Y")
     q_form_id = q_form[0].id # 13
     if !params[:appointment][:questionform_id].blank?
          q_form_id = params[:appointment][:questionform_id]
    end
     scan_procedure_array = []
     scan_procedure_array =  (current_user.edit_low_scan_procedure_array).split(' ').map(&:to_i)
           hide_date_flag_array = []
      hide_date_flag_array =  (current_user.hide_date_flag_array).split(' ').map(&:to_i)
      @hide_page_flag = 'N'
      if hide_date_flag_array.count > 0
        @hide_page_flag = 'Y'
      end
    @neuropsych = Neuropsych.new# (neuropsych_params)#params[:neuropsych])


    appointment_date = nil
    if !params[:appointment]["#{'appointment_date'}(1i)"].blank? && !params[:appointment]["#{'appointment_date'}(2i)"].blank? && !params[:appointment]["#{'appointment_date'}(3i)"].blank?
         appointment_date = params[:appointment]["#{'appointment_date'}(1i)"] +"-"+params[:appointment]["#{'appointment_date'}(2i)"].rjust(2,"0")+"-"+params[:appointment]["#{'appointment_date'}(3i)"].rjust(2,"0")
    end

    vgroup_id =params[:new_appointment_vgroup_id]
    @vgroup = Vgroup.where("vgroups.id in (select vgroup_id from scan_procedures_vgroups where scan_procedure_id in (?))", scan_procedure_array).find(vgroup_id)
    
    @appointment = Appointment.new
    if !params[:appointment][:questionform_id].blank?
          @appointment.questionform_id_list = params[:appointment][:questionform_id]
    end
    @appointment.vgroup_id = vgroup_id
    @appointment.appointment_type ='neuropsych'
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
    @neuropsych.appointment_id = @appointment.id
    @q_data_form = QDataForm.new
    @q_data_form.appointment_id = @appointment.id
    @q_data_form.questionform_id = q_form_id
    @q_data_form.save
    respond_to do |format|
      if @neuropsych.save
        @vgroup.completedneuropsych = params[:vgroup][:completedneuropsych]
        @vgroup.save
=begin    
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
          @vital.appointment_id = @neuropsych.appointment_id
          @vital.pulse = params[:pulse]
          @vital.bp_systol = params[:bp_systol]
          @vital.bp_diastol = params[:bp_diastol]
          @vital.bloodglucose = params[:bloodglucose]
          @vital.save      
        end
=end
        
        format.html { redirect_to(@neuropsych, :notice => 'Neuropsych was successfully created.') }
        format.xml  { render :xml => @neuropsych, :status => :created, :location => @neuropsych }
      else
        @q_data_form.delete
        @appointment.delete
        format.html { render :action => "new" }
        format.xml  { render :xml => @neuropsych.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /neuropsyches/1
  # PUT /neuropsyches/1.xml
  def update
    scan_procedure_array = []
    scan_procedure_array =  (current_user.edit_low_scan_procedure_array).split(' ').map(&:to_i)
          hide_date_flag_array = []
      hide_date_flag_array =  (current_user.hide_date_flag_array).split(' ').map(&:to_i)
      @hide_page_flag = 'N'
      if hide_date_flag_array.count > 0
        @hide_page_flag = 'Y'
      end

    @neuropsych = Neuropsych.where("neuropsyches.appointment_id in (select appointments.id from appointments,scan_procedures_vgroups where 
                                      appointments.vgroup_id = scan_procedures_vgroups.vgroup_id 
                                      and scan_procedure_id in (?))", scan_procedure_array).find(params[:id])

    appointment_date = nil
    if !params[:appointment]["#{'appointment_date'}(1i)"].blank? && !params[:appointment]["#{'appointment_date'}(2i)"].blank? && !params[:appointment]["#{'appointment_date'}(3i)"].blank?
         appointment_date = params[:appointment]["#{'appointment_date'}(1i)"] +"-"+params[:appointment]["#{'appointment_date'}(2i)"].rjust(2,"0")+"-"+params[:appointment]["#{'appointment_date'}(3i)"].rjust(2,"0")
    end

=begin
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
      @vital.appointment_id = @neuropsych.appointment_id
      @vital.pulse = params[:pulse]
      @vital.bp_systol = params[:bp_systol]
      @vital.bp_diastol = params[:bp_diastol]
      @vital.bloodglucose = params[:bloodglucose]
      @vital.save      
    end
=end
    respond_to do |format|
      # not being used - its all appointment fields if @neuropsych.update(params[:neuropsych]) #, :without_protection => true)
        @appointment = Appointment.find(@neuropsych.appointment_id)
        @vgroup = Vgroup.find(@appointment.vgroup_id)
        @appointment.comment = params[:appointment][:comment]
        @appointment.appointment_date =appointment_date
        if !params[:appointment].nil? and !params[:appointment][:appointment_coordinator].nil?
            @appointment.appointment_coordinator = params[:appointment][:appointment_coordinator]
        end
        if !@vgroup.participant_id.blank?
          @participant = Participant.find(@vgroup.participant_id)
          if !@participant.dob.blank?
             @appointment.age_at_appointment = ((@appointment.appointment_date - @participant.dob)/365.25).round(2)
          end
        end
        @appointment.save
        @vgroup.completedneuropsych = params[:vgroup][:completedneuropsych]
      if  @vgroup.save
        format.html { redirect_to(@neuropsych, :notice => 'Neuropsych was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @neuropsych.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /neuropsyches/1
  # DELETE /neuropsyches/1.xml
  def destroy
    scan_procedure_array = []
    scan_procedure_array =  (current_user.edit_low_scan_procedure_array).split(' ').map(&:to_i)
          hide_date_flag_array = []
      hide_date_flag_array =  (current_user.hide_date_flag_array).split(' ').map(&:to_i)
      @hide_page_flag = 'N'
      if hide_date_flag_array.count > 0
        @hide_page_flag = 'Y'
      end
     
    @neuropsych = Neuropsych.where("neuropsyches.appointment_id in (select appointments.id from appointments,scan_procedures_vgroups where 
                                      appointments.vgroup_id = scan_procedures_vgroups.vgroup_id 
                                      and scan_procedure_id in (?))", scan_procedure_array).find(params[:id])
    
    if @neuropsych.appointment_id > 3156 # sure appointment_id not used by any other
       @appointment = Appointment.find(@neuropsych.appointment_id)
       @appointment.destroy
    end
    @neuropsych.destroy

    respond_to do |format|
      format.html { redirect_to(np_search_path) }
      format.xml  { head :ok }
    end
  end  
  private
    def set_neuropsych
       @neuropsych = Neuropsych.find(params[:id])
    end    
    # not really using this
   def neuropsych_params
          params.require(:appointment).permit(:id,:appointment_date,:appointment_coordinator,:comment)# :enteredneuropsych,:enteredneuropsychdate,:enteredneuropsychwho,:completedneuropsych_moved_to_vgroups,:neuropsychnote,:temp_fkneuroid,:temp_fkvisitid,:id)
   end
   def np_search_params
          params.require(:np_search).permit!
   end
end
