# encoding: utf-8
class QuestionformsController < ApplicationController
  # GET /questionforms
  # GET /questionforms.xml
  def index
    @questionforms = Questionform.where("1=1").order('status_flag desc, entrance_page_type,tab_type,display_order,description')

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @questionforms }
    end
  end

  # GET /questionforms/1
  # GET /questionforms/1.xml
  def show
    @questionform = Questionform.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @questionform }
    end
  end

  # GET /questionforms/new
  # GET /questionforms/new.xml
  def new
    @questionform = Questionform.new
    @questionform.display_order = 0
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @questionform }
    end
  end
  
  def displayform
    
     render :template => "questionforms/displayform"
  end
  
  def editform
     render :template => "questionforms/editform"
  end

  # GET /questionforms/1/edit
  def edit
    @questionform = Questionform.find(params[:id])
  end

  # POST /questionforms
  # POST /questionforms.xml
  def create
    @questionform = Questionform.new(questionform_params)#params[:questionform])
    
    respond_to do |format|
      if @questionform.save
        format.html { redirect_to(@questionform, :notice => 'Questionform was successfully created.') }
        format.xml  { render :xml => @questionform, :status => :created, :location => @questionform }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @questionform.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /questionforms/1
  # PUT /questionforms/1.xml
  def update
    @questionform = Questionform.find(params[:id])

    respond_to do |format|
      if @questionform.update(questionform_params)#params[:questionform], :without_protection => true)
        format.html { redirect_to(@questionform, :notice => 'Questionform was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @questionform.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /questionforms/1
  # DELETE /questionforms/1.xml
  def destroy
    @questionform = Questionform.find(params[:id])
    @questionform.destroy

    respond_to do |format|
      format.html { redirect_to(questionforms_url) }
      format.xml  { head :ok }
    end
  end

 
  def displayform_pdf   #(p_q_data_form_id, p_q_form_id)

    pdf = Prawn::Document.new
    pdf.font('Helvetica', size: 8)
    v_value = "hello world"
    pdf.text v_value

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
  
  end

  
  def question_enter
   # params["q_data_form_id"] = "9"

    if params["q_data_form_id"].length > 0
      @q_data_form = QDataForm.find(params["q_data_form_id"])
    else
      @q_data_form = QDataForm.new()
    end
    @q_data_form.participant_id = params["value_link"]["participant_id"]
    @q_data_form.visit_id = params["value_link"]["visit_id"]
    @q_data_form.enrollment_id = params["value_link"]["enrollment_id"]
    @q_data_form.appointment_id =  params["value_link"]["appointment_id"]
    @q_data_form.scan_procedure_id = params["value_link"]["scan_procedure_id"]
    @q_data_form.questionform_id = params["questionform_id"]

    @q_data_form.user = current_user
    if params["q_data_form_id"].length > 0
      @q_data_form.save  #update(@q_data_form)
    else
      @q_data_form.save
    end
   
    # insert or update   if the q_data_forms.id is null
    # insert or update if q_data.id is null
    # global update or base_table.base_column update with value_link
    # redirect to original form or saved page
    
    # loop thru questions
    question_list = params["question_id"]
    question_list.each do |q_id| 
      @question = Question.find(q_id)
      if !@question.value_type_1.blank? || !@question.value_type_2.blank? ||  !@question.value_type_3.blank? # exclude phrase only questions
        v_value_link = "-1"
        if params["q_data_id"][q_id].length  > 0
          @q_data = QDatum.find(params["q_data_id"][q_id])
        else
          @q_data = QDatum.new()
        end        
        
        if @question.value_link == "participant"
            v_value_link =  params["value_link"]["participant_id"]
        elsif   @question.value_link == "visit"
            v_value_link =  params["value_link"]["visit_id"]
        elsif  @question.value_link == "enrollment"
            v_value_link =  params["value_link"]["enrollment_id"]
        elsif   @question.value_link == "appointment"
            v_value_link =  params["value_link"]["appointment_id"]
        end
        @q_data.value_link = v_value_link
        @q_data.q_data_form_id = @q_data_form.id
        @q_data.question_id = q_id
        if @question.value_type_1 == "time"
          if !params["value_1"][q_id]["(4i)"].blank? && !params["value_1"][q_id]["(5i)"].blank? 
           @q_data.value_1 =  params["value_1"][q_id]["(4i)"] +"-"+params["value_1"][q_id]["(5i)"]
           #.rjust(2,"0")+"-"+params[:mri_search]["#{'latest_timestamp'}(3i)"].rjust(2,"0")
           end

        elsif @question.value_type_1 == "date"
         if !params["value_1"][q_id]["(1i)"].blank? && !params["value_1"][q_id]["(2i)"].blank? && !params["value_1"][q_id]["(3i)"].blank? 
           @q_data.value_1 =  params["value_1"][q_id]["(1i)"] +"-"+params["value_1"][q_id]["(2i)"] +"-"+params["value_1"][q_id]["(3i)"]
           #.rjust(2,"0")+"-"+params[:mri_search]["#{'latest_timestamp'}(3i)"].rjust(2,"0")
           end 
         elsif @question.value_type_1 == "date_dob"
          if !params["value_1"][q_id]["(1i)"].blank? && !params["value_1"][q_id]["(2i)"].blank? && !params["value_1"][q_id]["(3i)"].blank? 
            @q_data.value_1 =  params["value_1"][q_id]["(1i)"] +"-"+params["value_1"][q_id]["(2i)"] +"-"+params["value_1"][q_id]["(3i)"]
            #.rjust(2,"0")+"-"+params[:mri_search]["#{'latest_timestamp'}(3i)"].rjust(2,"0")
            end
        elsif @question.value_type_1 =="date_time"
         if !params["value_1"][q_id]["(1i)"].blank? && !params["value_1"][q_id]["(2i)"].blank?  && !params["value_1"][q_id]["(3i)"].blank? && !params["value_1"][q_id]["(4i)"].blank? && !params["value_1"][q_id]["(5i)"].blank? 
           @q_data.value_1 =  params["value_1"][q_id]["(1i)"] +"-"+params["value_1"][q_id]["(2i)"] +"-"+params["value_1"][q_id]["(3i)"] +"-"+ params["value_1"][q_id]["(4i)"] +"-"+params["value_1"][q_id]["(5i)"]
           #.rjust(2,"0")+"-"+params[:mri_search]["#{'latest_timestamp'}(3i)"].rjust(2,"0")
           end
        elsif !params["value_1"][q_id].blank? 
          @q_data.value_1 = params["value_1"][q_id].join(',').gsub("'","''")
        end
        if @question.value_type_2 == "time"
          if !params["value_2"][q_id]["(4i)"].blank? && !params["value_2"][q_id]["(5i)"].blank? 
           @q_data.value_2 =  params["value_2"][q_id]["(4i)"] +"-"+params["value_2"][q_id]["(5i)"]
           #.rjust(2,"0")+"-"+params[:mri_search]["#{'latest_timestamp'}(3i)"].rjust(2,"0")
           end

        elsif @question.value_type_2 == "date"
         if !params["value_2"][q_id]["(1i)"].blank? && !params["value_2"][q_id]["(2i)"].blank? && !params["value_2"][q_id]["(3i)"].blank? 
           @q_data.value_2 =  params["value_2"][q_id]["(1i)"] +"-"+params["value_2"][q_id]["(2i)"]+"-"+params["value_2"][q_id]["(3i)"]
           #.rjust(2,"0")+"-"+params[:mri_search]["#{'latest_timestamp'}(3i)"].rjust(2,"0")
           end  
         elsif @question.value_type_2 == "date_dob"
          if !params["value_2"][q_id]["(1i)"].blank? && !params["value_2"][q_id]["(2i)"].blank? && !params["value_2"][q_id]["(3i)"].blank? 
            @q_data.value_2 =  params["value_2"][q_id]["(1i)"] +"-"+params["value_2"][q_id]["(2i)"]+"-"+params["value_2"][q_id]["(3i)"]
            #.rjust(2,"0")+"-"+params[:mri_search]["#{'latest_timestamp'}(3i)"].rjust(2,"0")
            end
        elsif @question.value_type_2 =="date_time"
         if !params["value_2"][q_id]["(1i)"].blank? && !params["value_2"][q_id]["(2i)"].blank? && !params["value_2"][q_id]["(3i)"].blank? && !params["value_2"][q_id]["(4i)"].blank? && !params["value_2"][q_id]["(5i)"].blank? 
           @q_data.value_2 =  params["value_2"][q_id]["(1i)"] +"-"+params["value_2"][q_id]["(2i)"]+"-"+params["value_2"][q_id]["(3i)"] +"-"+ params["value_2"][q_id]["(4i)"] +"-"+params["value_2"][q_id]["(5i)"]
           #.rjust(2,"0")+"-"+params[:mri_search]["#{'latest_timestamp'}(3i)"].rjust(2,"0")
           end
        elsif !params["value_2"][q_id].blank? 
          @q_data.value_2 = params["value_2"][q_id].join(',').gsub("'","''")
        end
        if @question.value_type_3 == "time"
          if !params["value_3"][q_id]["(4i)"].blank? && !params["value_3"][q_id]["(5i)"].blank? 
           @q_data.value_3 =  params["value_3"][q_id]["(4i)"] +"-"+params["value_3"][q_id]["(5i)"]
           #.rjust(2,"0")+"-"+params[:mri_search]["#{'latest_timestamp'}(3i)"].rjust(2,"0")
           end

        elsif @question.value_type_3 == "date"
         if !params["value_3"][q_id]["(1i)"].blank? && !params["value_3"][q_id]["(2i)"].blank? && !params["value_3"][q_id]["(3i)"].blank? 
           @q_data.value_3 = params["value_3"][q_id]["(1i)"] +"-"+params["value_3"][q_id]["(2i)"]+"-"+params["value_3"][q_id]["(3i)"]
           #.rjust(2,"0")+"-"+params[:mri_search]["#{'latest_timestamp'}(3i)"].rjust(2,"0")
           end  
         elsif @question.value_type_3 == "date_dob"
          if !params["value_3"][q_id]["(1i)"].blank? && !params["value_3"][q_id]["(2i)"].blank? && !params["value_3"][q_id]["(3i)"].blank? 
            @q_data.value_3 = params["value_3"][q_id]["(1i)"] +"-"+params["value_3"][q_id]["(2i)"]+"-"+params["value_3"][q_id]["(3i)"]
            #.rjust(2,"0")+"-"+params[:mri_search]["#{'latest_timestamp'}(3i)"].rjust(2,"0")
            end
        elsif @question.value_type_3 =="date_time"
         if !params["value_3"][q_id]["(1i)"].blank? && !params["value_3"][q_id]["(2i)"].blank? && !params["value_3"][q_id]["(3i)"].blank? && !params["value_3"][q_id]["(4i)"].blank? && !params["value_3"][q_id]["(5i)"].blank? 
           @q_data.value_3 =  params["value_3"][q_id]["(1i)"] +"-"+params["value_3"][q_id]["(2i)"]+"-"+params["value_3"][q_id]["(3i)"] +"-"+params["value_3"][q_id]["(4i)"] +"-"+params["value_3"][q_id]["(5i)"]
           #.rjust(2,"0")+"-"+params[:mri_search]["#{'latest_timestamp'}(3i)"].rjust(2,"0")
           end
        elsif !params["value_3"][q_id].blank? 
          @q_data.value_3 = params["value_3"][q_id].join(',').gsub("'","''")
        end
    if v_value_link != "-1"
        if params["q_data_id"][q_id].length  > 0
          @q_data.save # update(@q_data)
        else
          @q_data.save
        end
        # global_update_insert further down
        if @question.global_update_1 == "Y" and  !params["value_1"][q_id].blank? 
          sql = "update q_data set value_1 = '"+@q_data.value_1+"'
                   where question_id = "+@q_data.question_id.to_s+"
                   and value_link ="+@q_data.value_link.to_s
          connection = ActiveRecord::Base.connection();        
          results = connection.execute(sql)
                   
          if !@question.base_table_1.blank? and !@question.base_column_1.blank?
            if @question.base_table_1 == "appointments" or @question.base_table_1 == "participants" 
              if @q_data.value_1 == ""    # problem on unique index on wrapnum and reggieid
                sql ="update  "+@question.base_table_1+"
                    set "+@question.base_table_1+"."+@question.base_column_1+" = NULL 
                    where "+@question.value_link+"s.id = "+@q_data.value_link.to_s        
               else
                sql ="update  "+@question.base_table_1+"
                    set "+@question.base_table_1+"."+@question.base_column_1+" = '"+@q_data.value_1+"'
                    where "+@question.value_link+"s.id = "+@q_data.value_link.to_s   
              end                                         
            else    
              if @q_data.value_1 == "" # problem with "" and integer field
                 sql ="update  "+@question.base_table_1+"
                  set "+@question.base_table_1+"."+@question.base_column_1+" =  NULL
                  where "+@question.value_link+"_id = "+@q_data.value_link.to_s
              else                    
                 sql ="update  "+@question.base_table_1+"
                  set "+@question.base_table_1+"."+@question.base_column_1+" = '"+@q_data.value_1+"'
                  where "+@question.value_link+"_id = "+@q_data.value_link.to_s
               end
            end
              connection = ActiveRecord::Base.connection();        
              results = connection.execute(sql)
          end
        end
        
        if @question.global_update_2 == "Y" and  !params["value_2"][q_id].blank? 
          sql = "update q_data set value_2 = '"+@q_data.value_2+"'
                   where question_id = "+@q_data.question_id.to_s+"
                   and value_link ="+@q_data.value_link.to_s
          connection = ActiveRecord::Base.connection();        
          results = connection.execute(sql)
                   
          if !@question.base_table_2.blank? and !@question.base_column_2.blank?
            if @question.base_table_2 == "appointments" or @question.base_table_2 == "participants" 
              if @q_data.value_2 == ""   # problem on unique index on wrapnum and reggieid
                sql ="update  "+@question.base_table_2+"
                      set "+@question.base_table_2+"."+@question.base_column_2+" = NULL
                      where "+@question.value_link+"s.id = "+@q_data.value_link.to_s
              else              
                sql ="update  "+@question.base_table_2+"
                    set "+@question.base_table_2+"."+@question.base_column_2+" = '"+@q_data.value_2+"'
                    where "+@question.value_link+"s.id = "+@q_data.value_link.to_s 
              end             
            else
              if @q_data.value_2 == "" # problem with "" and integer field
                sql ="update  "+@question.base_table_2+"
                  set "+@question.base_table_2+"."+@question.base_column_2+" = NULL
                  where "+@question.value_link+"_id = "+@q_data.value_link.to_s
              else
                sql ="update  "+@question.base_table_2+"
                  set "+@question.base_table_2+"."+@question.base_column_2+" = '"+@q_data.value_2+"'
                  where "+@question.value_link+"_id = "+@q_data.value_link.to_s
              end
            end
              connection = ActiveRecord::Base.connection();      
              results = connection.execute(sql)
          end
        end        
        
        if @question.global_update_3 == "Y" and  !params["value_3"][q_id].blank? 
          sql = "update q_data set value_3 = '"+@q_data.value_3+"'
                   where question_id = "+@q_data.question_id.to_s+"
                   and value_link ="+@q_data.value_link.to_s
          connection = ActiveRecord::Base.connection();        
          results = connection.execute(sql)
                   
          if !@question.base_table_3.blank? and !@question.base_column_3.blank?
            if @question.base_table_3 == "appointments" or @question.base_table_3 == "participants" 
              if @q_data.value_3 == ""  # problem on unique index on wrapnum and reggieid
                sql ="update  "+@question.base_table_3+"
                    set "+@question.base_table_3+"."+@question.base_column_3+" = NULL
                    where "+@question.value_link+"s.id = "+@q_data.value_link.to_s              
                
              else              
                sql ="update  "+@question.base_table_3+"
                    set "+@question.base_table_3+"."+@question.base_column_3+" = '"+@q_data.value_3+"'
                    where "+@question.value_link+"s.id = "+@q_data.value_link.to_s 
              end             
            else 
              if @q_data.value_3 == "" # problem with "" and integer field
                sql ="update  "+@question.base_table_3+"
                  set "+@question.base_table_3+"."+@question.base_column_3+" = NULL
                  where "+@question.value_link+"_id = "+@q_data.value_link.to_s
              else
                sql ="update  "+@question.base_table_3+"
                  set "+@question.base_table_3+"."+@question.base_column_3+" = '"+@q_data.value_3+"'
                  where "+@question.value_link+"_id = "+@q_data.value_link.to_s
              end
             end
              connection = ActiveRecord::Base.connection();        
              results = connection.execute(sql)
          end
        end  
        # ALSO NEED date and by who
        if @question.global_update_insert_1 == "Y" and  !params["value_1"][q_id].blank? 
          sql = "update q_data set value_1 = '"+@q_data.value_1+"'
                   where question_id = "+@q_data.question_id.to_s+"
                   and value_link ="+@q_data.value_link.to_s
          connection = ActiveRecord::Base.connection();        
          results = connection.execute(sql)
                   
          if !@question.base_table_1.blank? and !@question.base_column_1.blank?
            if @question.base_table_1 == "appointments" or @question.base_table_1 == "participants" 
              if @q_data.value_1 == ""    # problem on unique index on wrapnum and reggieid
                sql ="update  "+@question.base_table_1+"
                    set "+@question.base_table_1+"."+@question.base_column_1+" = NULL 
                    where "+@question.value_link+"s.id = "+@q_data.value_link.to_s        
               else
                sql ="update  "+@question.base_table_1+"
                    set "+@question.base_table_1+"."+@question.base_column_1+" = '"+@q_data.value_1+"'
                    where "+@question.value_link+"s.id = "+@q_data.value_link.to_s   
              end                                         
            else    
                 if @q_data.value_1 == ""  # problem with "" and integer field  
                        sql ="update  "+@question.base_table_1+"
                        set "+@question.base_table_1+"."+@question.base_column_1+" = NULL
                        where "+@question.value_link+"_id = "+@q_data.value_link.to_s 
                 else                 
                    sql ="update  "+@question.base_table_1+"
                        set "+@question.base_table_1+"."+@question.base_column_1+" = '"+@q_data.value_1+"'
                        where "+@question.value_link+"_id = "+@q_data.value_link.to_s
                 end
            end
              connection = ActiveRecord::Base.connection();        
              results = connection.execute(sql)
          end
        end
        
        if @question.global_update_insert_2 == "Y" and  !params["value_2"][q_id].blank? 
          sql = "update q_data set value_2 = '"+@q_data.value_2+"'
                   where question_id = "+@q_data.question_id.to_s+"
                   and value_link ="+@q_data.value_link.to_s
          connection = ActiveRecord::Base.connection();        
          results = connection.execute(sql)
                   
          if !@question.base_table_2.blank? and !@question.base_column_2.blank?
            if @question.base_table_2 == "appointments" or @question.base_table_2 == "participants" 
              if @q_data.value_2 == ""   # problem on unique index on wrapnum and reggieid
                sql ="update  "+@question.base_table_2+"
                      set "+@question.base_table_2+"."+@question.base_column_2+" = NULL
                      where "+@question.value_link+"s.id = "+@q_data.value_link.to_s
              else              
                sql ="update  "+@question.base_table_2+"
                    set "+@question.base_table_2+"."+@question.base_column_2+" = '"+@q_data.value_2+"'
                    where "+@question.value_link+"s.id = "+@q_data.value_link.to_s 
              end             
            else
              if @q_data.value_2 == "" # problem with "" and integer field  
                 sql ="update  "+@question.base_table_2+"
                  set "+@question.base_table_2+"."+@question.base_column_2+" = NULL
                  where "+@question.value_link+"_id = "+@q_data.value_link.to_s
              else
                 sql ="update  "+@question.base_table_2+"
                  set "+@question.base_table_2+"."+@question.base_column_2+" = '"+@q_data.value_2+"'
                  where "+@question.value_link+"_id = "+@q_data.value_link.to_s
               end
            end
              connection = ActiveRecord::Base.connection();      
              results = connection.execute(sql)
          end
        end        
        
        if @question.global_update_insert_3 == "Y" and  !params["value_3"][q_id].blank? 
          sql = "update q_data set value_3 = '"+@q_data.value_3+"'
                   where question_id = "+@q_data.question_id.to_s+"
                   and value_link ="+@q_data.value_link.to_s
          connection = ActiveRecord::Base.connection();        
          results = connection.execute(sql)
                   
          if !@question.base_table_3.blank? and !@question.base_column_3.blank?
            if @question.base_table_3 == "appointments" or @question.base_table_3 == "participants" 
              if @q_data.value_3 == ""  # problem on unique index on wrapnum and reggieid
                sql ="update  "+@question.base_table_3+"
                    set "+@question.base_table_3+"."+@question.base_column_3+" = NULL
                    where "+@question.value_link+"s.id = "+@q_data.value_link.to_s              
                
              else              
                sql ="update  "+@question.base_table_3+"
                    set "+@question.base_table_3+"."+@question.base_column_3+" = '"+@q_data.value_3+"'
                    where "+@question.value_link+"s.id = "+@q_data.value_link.to_s 
              end             
            else
                  if @q_data.value_3 == ""  # problem with "" and integer field 
                    sql ="update  "+@question.base_table_3+"
                       set "+@question.base_table_3+"."+@question.base_column_3+" = NULL
                       where "+@question.value_link+"_id = "+@q_data.value_link.to_s
                  else
                    sql ="update  "+@question.base_table_3+"
                       set "+@question.base_table_3+"."+@question.base_column_3+" = '"+@q_data.value_3+"'
                       where "+@question.value_link+"_id = "+@q_data.value_link.to_s
                  end
             end
              connection = ActiveRecord::Base.connection();        
              results = connection.execute(sql)
          end
        end 
       end  
      end
    end

    
     @questionform = Questionform.find(params["questionform_id"])

     lh_forms = Questionform.where("current_tab ='blooddraws'").where("status_flag = 'Y'")
     np_forms = Questionform.where("current_tab ='neuropsyches'").where("status_flag = 'Y'")
     qu_forms = Questionform.where("current_tab ='questionnaires'").where("status_flag = 'Y'")
# NEED questionform to have path to call + value_link
  if lh_forms.exists?(params["questionform_id"].to_i) # == "12"   #  need the taget page plus the blooddraw object based on appointment_id -- need to know its an Appointment object
    @blooddraw = Blooddraw.where("appointment_id in (?)",params["value_link"]["appointment_id"])
    var = '/blooddraws/'+@blooddraw[0].id.to_s

    respond_to do |format|
      format.html { redirect_to( var, :notice => 'Questionform was successfully updated.' )}
      format.xml  { render :xml => @questionforms }
    end
  elsif np_forms.exists?(params["questionform_id"].to_i) # == "13"   #  need the taget page plus the neuropsych object based on appointment_id -- need to know its an Appointment object
      @neuropsych = Neuropsych.where("appointment_id in (?)",params["value_link"]["appointment_id"])
      var = '/neuropsyches/'+@neuropsych[0].id.to_s

      respond_to do |format|
        format.html { redirect_to( var, :notice => 'Questionform was successfully updated.' )}
        format.xml  { render :xml => @questionforms }
      end
    elsif qu_forms.exists?(params["questionform_id"].to_i) #== "14"   #  need the taget page plus the questionnaire object based on appointment_id -- need to know its an Appointment object
        @questionnaire = Questionnaire.where("appointment_id in (?)",params["value_link"]["appointment_id"])
        var = '/questionnaires/'+@questionnaire[0].id.to_s

        respond_to do |format|
          format.html { redirect_to( var, :notice => 'Questionform was successfully updated.' )}
          format.xml  { render :xml => @questionforms }
        end
  else
    respond_to do |format|
      format.html { redirect_to(@questionform, :notice => 'Questionform was successfully updated.') }
      format.xml  { render :xml => @questionforms }
    end    
   end
  end  
  private
    def set_questionform
       @questionform = Questionform.find(params[:id])
    end
   def questionform_params
          params.require(:questionform).permit(:status_flag,:description,:long_description,:display_order,:parent_questionform_id,:entrance_page_type,:target_page,:tab_type,:current_tab,:view_name,:tab_default_yn,:short_description,:id)
   end
  
end
