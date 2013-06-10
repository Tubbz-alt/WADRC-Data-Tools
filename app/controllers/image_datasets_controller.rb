# encoding: utf-8
class ImageDatasetsController < ApplicationController # AuthorizedController #  ApplicationController
#   load_and_authorize_resource
  before_filter :set_current_tab
  
  def set_current_tab
    @current_tab = "image_datasets"
  end
  
  def check_image_quality
   scan_procedure_array = (current_user.view_low_scan_procedure_array).split(' ').map(&:to_i)
    @image_dataset = ImageDataset.where("image_datasets.visit_id in (select visit_id from scan_procedures_visits where scan_procedure_id in (?))", scan_procedure_array).find(params[:id])
    @qc = ImageDatasetQualityCheck.new
    @qc.user = current_user
    @qc.image_dataset = @image_dataset
    
    respond_to do |format|
      format.html # check_image_quality.html.erb
    end
  end
  
  # GET /image_datasets
  # GET /image_datasets.xml
  def index
    scan_procedure_array = (current_user.view_low_scan_procedure_array).split(' ').map(&:to_i)
    @sp_array = []
    if params[:visit_id]
      @visit = Visit.where("visits.id in (select visit_id from scan_procedures_visits where scan_procedure_id in (?))", scan_procedure_array).find(params[:visit_id])
      @search = @visit.image_datasets.search(params[:search])
      @image_datasets = @search.relation.page(params[:page]).per(50).all
      @total_count = @image_datasets.count
      @page_title = "All Image Datasets for Visit #{@visit.rmr}"
    else
        #   @image_datasets = ImageDataset.find_all_by_visit_id(params[:visit_id])# .paginate(:page => params[:page], :per_page => PER_PAGE)
        #   @visit = Visit.find(params[:visit_id])
        #   @total_count = @image_datasets.count
        #   @page_title = "All Image Datasets for Visit #{@visit.rmr}"
        # else
        if !params[:visit].blank? and !params[:visit][:scan_procedure_id].blank?
          scan_procedure_id_list = params[:visit][:scan_procedure_id].join(',')
          @sp_array =   scan_procedure_id_list.split(",")
          # params[:lh_search][:scan_procedure_id].join(',')
                if !params[:search].blank? && !params[:search][:meta_sort].blank? ## want to limit  last 2 months when nothing searched for
                  @page_title = "All Image Datasets "
           @search = ImageDataset.where("image_datasets.visit_id in (select scan_procedures_visits.visit_id from scan_procedures_visits where scan_procedure_id in (?))
                                     and image_datasets.visit_id in (select scan_procedures_visits.visit_id from scan_procedures_visits where scan_procedure_id in (?))", scan_procedure_array,params[:visit][:scan_procedure_id]).search(params[:search])
                elsif !params[:search].blank?
                  @page_title = "All Image Datasets "
           @search = ImageDataset.where("image_datasets.visit_id in (select scan_procedures_visits.visit_id from scan_procedures_visits where scan_procedure_id in (?))
                                               and image_datasets.visit_id in (select scan_procedures_visits.visit_id from scan_procedures_visits where scan_procedure_id in (?))", scan_procedure_array,params[:visit][:scan_procedure_id]).search(params[:search])          
                else
                 @page_title = "All Image Datasets "
          @search = ImageDataset.where("image_datasets.visit_id in (select scan_procedures_visits.visit_id from scan_procedures_visits where scan_procedure_id in (?))
                                       and image_datasets.visit_id in (select scan_procedures_visits.visit_id from scan_procedures_visits where scan_procedure_id in (?))", scan_procedure_array,params[:visit][:scan_procedure_id]).search(params[:search])
                 end        
        else      
          if !params[:search].blank? && !params[:search][:meta_sort].blank? ## want to limit  last 2 months when nothing searched for
            @page_title = "All Image Datasets "
     @search = ImageDataset.where("image_datasets.visit_id in (select scan_procedures_visits.visit_id from scan_procedures_visits where scan_procedure_id in (?))", scan_procedure_array).search(params[:search])
          elsif !params[:search].blank?
            @page_title = "All Image Datasets "
     @search = ImageDataset.where("image_datasets.visit_id in (select scan_procedures_visits.visit_id from scan_procedures_visits where scan_procedure_id in (?))", scan_procedure_array).search(params[:search])          
          else
           @page_title = "All Image Datasets - last 2 months"
    @search = ImageDataset.where("image_datasets.visit_id in (select visits.id from visits where visits.date > DATE_SUB(NOW(), INTERVAL 2 MONTH) )
                                 and image_datasets.visit_id in (select scan_procedures_visits.visit_id from scan_procedures_visits where scan_procedure_id in (?))", scan_procedure_array).search(params[:search])
           end 
         end   
        #  @search = ImageDataset.search(params[:search])

          # Set pagination and reporting options depending on the requested format
          # (ie Don't paginate datasets on CSV download.)
          if params[:format]
            
            @image_datasets = @search.relation
      
            # Eventually, we'll be able to set exactly what we want included in the 
            # report from the web interface. For now, we'll do it programatically 
            # here in the controller.
            light_include_options = {:image_dataset_quality_checks, :image_comments   }
            heavy_include_options = {
              :image_dataset_quality_checks => {:except => [:id]},
              :image_comments => {:except => [:id]},
              :visit => {:methods => :age_at_visit, :only => [:scanner_source, :date], :include => {
                :enrollments => {:only => [:enumber], :include => { 
                  :participant => { :methods => :genetic_status, :only => [:gender, :wrapnum, :ed_years] }
                }  }
              }} 
            }
          else
            @image_datasets = @search.relation.page(params[:page])
          end

          # @total_count = all_images.size # I'm not sure where this method is coming from, but it's breaking in ActiveResource
          @total_count = ImageDataset.count
          
        end

        respond_to do |format|
          format.html # index.html.erb
          format.xml  { render :text => @image_datasets.to_xml(:except => [:dicom_taghash])}
          format.csv  { render :csv => ImageDataset.csv_download(@image_datasets, heavy_include_options) }
        end
      end
  # GET /image_datasets/1
  # GET /image_datasets/1.xml
  def show
    scan_procedure_array = (current_user.view_low_scan_procedure_array).split(' ').map(&:to_i)
    @image_dataset = ImageDataset.where("image_datasets.visit_id in (select visit_id from scan_procedures_visits where scan_procedure_id in (?))", scan_procedure_array).find(params[:id])
    @visit = @image_dataset.visit
    @image_datasets = @visit.image_datasets
    
    @image_comment = ImageComment.new
    @image_comments = @image_dataset.image_comments
    @next_image_dataset = @image_datasets[@image_datasets.index(@image_dataset) + 1 ]
    @previous_image_dataset = @image_datasets[@image_datasets.index(@image_dataset) - 1 ]
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @image_dataset }
    end
  end

  # GET /image_datasets/new
  # GET /image_datasets/new.xml
  def new
    @image_dataset = ImageDataset.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @image_dataset }
    end
  end

  # GET /image_datasets/1/edit
  def edit
    scan_procedure_array = (current_user.edit_low_scan_procedure_array).split(' ').map(&:to_i)
    @image_dataset = ImageDataset.where("image_datasets.visit_id in (select visit_id from scan_procedures_visits where scan_procedure_id in (?))", scan_procedure_array).find(params[:id])
  end

  # POST /image_datasets
  # POST /image_datasets.xml
  def create
    @image_dataset = ImageDataset.new(params[:image_dataset])
    @image_dataset.user = current_user
    respond_to do |format|
      if @image_dataset.save
        # problem with some SCREENSAVE sereies description, null rep_time causing error
        if @image_dataset.series_description == 'SCREENSAVE' and @image_dataset.rep_time.blank?
          @image_dataset.rep_time = 0
          @image_dataset.save
          # if save not work
          #sql = "UPDATE image_datasets set rep_time=0 where rep_time is NULL and id="+@image_dataset.id.to_s
          #connection = ActiveRecord::Base.connection();
          #results = connection.execute(sql)
        end
        flash[:notice] = 'ImageDataset was successfully created.'
        format.html { redirect_to(@image_dataset) }
        format.xml  { render :xml => @image_dataset, :status => :created, :location => @image_dataset }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @image_dataset.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /image_datasets/1
  # PUT /image_datasets/1.xml
  def update
    scan_procedure_array = (current_user.edit_low_scan_procedure_array).split(' ').map(&:to_i)
    @image_dataset = ImageDataset.where("image_datasets.visit_id in (select visit_id from scan_procedures_visits where scan_procedure_id in (?))", scan_procedure_array).find(params[:id])

    respond_to do |format|
      if @image_dataset.update_attributes(params[:image_dataset])
        flash[:notice] = 'ImageDataset was successfully updated.'
        format.html { redirect_to(@image_dataset) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @image_dataset.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /image_datasets/1
  # DELETE /image_datasets/1.xml
  def destroy
    scan_procedure_array = (current_user.edit_low_scan_procedure_array).split(' ').map(&:to_i)
    @image_dataset = ImageDataset.where("image_datasets.visit_id in (select visit_id from scan_procedures_visits where scan_procedure_id in (?))", scan_procedure_array).find(params[:id])
    @image_dataset.destroy

    respond_to do |format|
      format.html { redirect_to(image_datasets_url) }
      format.xml  { head :ok }
    end
  end
end
