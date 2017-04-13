# encoding: utf-8
class AppointmentsController < ApplicationController  
  before_action :set_appointment, only: [:show, :edit, :update, :destroy]   
	respond_to :html
  # GET /appointments
  # GET /appointments.xml
  def index
    @appointments = Appointment.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @appointments }
    end
  end

  # GET /appointments/1
  # GET /appointments/1.xml
  def show
    @appointment = Appointment.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @appointment }
    end
  end

  # GET /appointments/new
  # GET /appointments/new.xml
  def new
    @appointment = Appointment.new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @appointment }
    end
  end

  # GET /appointments/1/edit
  def edit
    @appointment = Appointment.find(params[:id])
  end

  # POST /appointments
  # POST /appointments.xml
  def create
    @appointment = Appointment.new(appointment_params)#params[:appointment])
  
    respond_to do |format|
      if @appointment.save
        @vital = Vital.new
        @vital.appointment_id = @appointment.id
        @vital.save
        format.html { redirect_to(@appointment, :notice => 'Appointment was successfully created.') }
        format.xml  { render :xml => @appointment, :status => :created, :location => @appointment }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @appointment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /appointments/1
  # PUT /appointments/1.xml
  def update
    @appointment = Appointment.find(params[:id])

    respond_to do |format|
      if @appointment.update(appointment_params)#params[:appointment], :without_protection => true)
        format.html { redirect_to(@appointment, :notice => 'Appointment was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @appointment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /appointments/1
  # DELETE /appointments/1.xml
  def destroy
    @appointment = Appointment.find(params[:id])
    # check if last appointment for a vgroup   
    
    @appointment.destroy

    respond_to do |format|
      format.html { redirect_to(appointments_url) }
      format.xml  { head :ok }
    end
  end  
  private
    def set_appointment
       @appointment = Appointment.find(params[:id])
    end
   def appointment_params
          params.require(:appointment).permit(:temp_visit_id,:age_at_appointment,:questionform_id_list,:appointment_coordinator,:secondary_key,:user_id,:employee_id,:id,:appointment_date,:vgroup_id,:comment,:appointment_type)
   end
end
