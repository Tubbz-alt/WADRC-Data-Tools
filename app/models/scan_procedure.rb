class ScanProcedure < ActiveRecord::Base
  has_and_belongs_to_many :visits  
  has_and_belongs_to_many :vgroups  
  validates_uniqueness_of :codename
  has_many :consent_form_scan_procedures,:dependent => :destroy
  #has_and_belongs_to_many :consent_form    -- was causing delete error - looking for consent_formS_scan_procedures

  def visit_abbr(iv="")
  	#because sometimes we want this to return "_v1"
  	out = iv

  	#check the codename to see if this is "visit2", "visit3", etc.
  	(2..8).to_a.each do |x|
  		if codename.include?("visit#{x}")
  			out = "_v#{x}"
  		end
  	end

  	#or if there's a special abbreviation for this visit
  	if !visit_number_abbreviation.nil? and visit_number_abbreviation > "" and out == ""
  		out = "_#{visit_number_abbreviation}"
  	end 

  	return out
  end

  def protocol
    proto = Protocol.where("id = ?",protocol_id).first

    proto
  end

end
