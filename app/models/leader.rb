class Leader < ActiveRecord::Base
  belongs_to :state

  #attr_protected :person_id
  #attr_accessor :person_id
  # jsj the above caused no end of issues; attr_protected is a syntax error and 
  # attr_accessor (the replacement) caused Postgres issues; I finally took it out
  # having no idea WHY it was ever implemented

  scope :current, ->      {where(member_status: 'current') }
  scope :state, ->        {where(
                            legislator_type: "SL").order(:last_name)}
  scope :state_house, ->  {where(
                              legislator_type: "SL", chamber: "H").order(:last_name)}
  scope :state_senate, -> {where(
                              legislator_type: "SL", chamber: "S").order(:last_name)}
  scope :us, ->           {where(
                              legislator_type: "FL").order(:last_name)}
  scope :us_house, ->     {where(
                              legislator_type: "FL", chamber: "H").order(:last_name)}
  # scope :us_senate, ->    {where(member_status: 'current',
  #                             legislator_type: "FL", chamber: "S").order(:last_name)}
  scope :us_senate, ->    {where(
                              legislator_type: "FL", chamber: "S").order(:last_name)}

  #before_save :generate_slug
  
  def self.get_last_offset(table, data_scope, state)
    Offset
  end
  
  def self.state_with_position
    #last_served = 
    params = {}
    params[:legislator_type] = "SL"
    params[:member_status] = "current" unless Rails.env.development?
    params[:id] = Leader.
    results = Leader.where(params)
    row_count = results.size
    return Leader.select_row(results, "leader, ""state", "in")
  end
  
  #
  # Options
  #  Store a model of what was last served in the db
  #  Setup a redis server which stores the IDs to serve
  #  Cron job which sets a value in memory of the ids to serve
  #  Can I do it with a limit clause?
  # offset(value) public
  # Specifies the number of rows to skip before returning rows.
  # bin/rails g model Offset

  

  def self.create_or_update(data)
    #leader = Leader.find_or_create_by_person_id(data[:pid])
    #debugger
    leader = Leader.find_or_create_by(person_id: data[:pid])
    debugger if leader.id == 421 && Rails.env.development?
    leader = Leader.update_attributes_from_know_who(leader, data)
    ensure_correct_state(leader, data)
    #debugger
    # Added by jsj on 7/10/18 due to data coming in without a statecode and that
    # blowing up everything
    #debugger if data[:statecode].blank? 
    #return if data[:statecode].blank?    
    debugger if leader.id == 421 && Rails.env.development?
    return if leader.person_id.nil?
    leader.save
    leader.tap { |l| return if l.person_id.nil?; l.save! }
  end

  def self.ensure_correct_state(leader, data)
    puts "statecode = #{data[:statecode]}"
    puts "state = #{data[:state]}"
    state = State.find_by_code(data[:statecode])
    # Added by jsj on 7/10/18 due to data coming in without a statecode and that
    # blowing up everything
    if state.nil?
      state = State.find_by_code(data[:state])
    end
    if leader.state
      unless leader.state.code == state.code
        raise "Know Who data tried to change leader state"
      end
    else
      leader.state = state
    end
  end

  def state_code
    self.state.code.downcase
  end

  def name
    "#{nick_name} #{last_name}"
  end

  def prefix_name
    if legislator_type == "FL" || legislator_type == "FLE"
     "US #{prefix} #{name}"
    else
     "#{prefix} #{name}"
    end
  end

  def photo_src
    return "http://placehold.it/109x148" if photo_path.blank? or photo_file.blank?
    p = photo_path.split("\\")
    "/#{p[1].downcase}/#{p[2]}/#{p[3]}/#{p[4]}/#{photo_file}"
  end

  def href
    "#{API_BASE_URI}/states/#{self.state.code.downcase}/leaders/#{slug}"
  end

  def birthday
    if born_on
      born_on.strftime("#B %e")
    end
  end

  def generate_slug
    #return unless slug.blank?
    self.update_attribute(:slug, nil)
    tmp_slug = prefix_name.parameterize
    count = Leader.where("slug = ? or slug LIKE ?", tmp_slug, "#{tmp_slug}--%").count
    return if count == 1 && self.slug == tmp_slug
    if count < 1
      #self.slug = tmp_slug
      new_slug = tmp_slug
    else
      #self.slug = "#{tmp_slug}--#{count + 1}"
      new_slug = "#{tmp_slug}--#{count + 1}"
    end
    self.update_attribute(:slug, new_slug)
    #self.save
  end
  
  def update_slug
    self.update_attribute(:slug, self.id)
    tmp_slug = prefix_name.parameterize
    count = Leader.where("slug = ? or slug LIKE ?", tmp_slug, "#{tmp_slug}--%").count
    return if count == 1 && self.slug == tmp_slug
    if count < 1
      #self.slug = tmp_slug
      new_slug = tmp_slug
    else
      
      #self.slug = "#{tmp_slug}--#{count + 1}"
      new_slug = "#{tmp_slug}--#{count + 1}"
      count = Leader.where("slug = ? or slug LIKE ?", new_slug, "#{new_slug}--%").count
      if count >= 1
        new_slug = "#{tmp_slug}--#{count + 2}"
      end
      count = Leader.where("slug = ? or slug LIKE ?", new_slug, "#{new_slug}--%").count
      if count >= 1
        new_slug = "#{tmp_slug}--#{count + 3}"
      end
      count = Leader.where("slug = ? or slug LIKE ?", new_slug, "#{new_slug}--%").count
      if count >= 1
        new_slug = "#{tmp_slug}--#{count + 4}"
      end
      count = Leader.where("slug = ? or slug LIKE ?", new_slug, "#{new_slug}--%").count
      if count >= 1
        new_slug = "#{tmp_slug}--#{count + 5}"
      end
      count = Leader.where("slug = ? or slug LIKE ?", new_slug, "#{new_slug}--%").count
      if count >= 1
        new_slug = "#{tmp_slug}--#{count + 6}"
      end
      count = Leader.where("slug = ? or slug LIKE ?", new_slug, "#{new_slug}--%").count
      if count >= 1
        new_slug = "#{tmp_slug}--#{count + 7}"
      end
      count = Leader.where("slug = ? or slug LIKE ?", new_slug, "#{new_slug}--%").count
      if count >= 1
        new_slug = "#{tmp_slug}--#{count + 8}"
      end
      count = Leader.where("slug = ? or slug LIKE ?", new_slug, "#{new_slug}--%").count
      if count >= 1
        new_slug = "#{tmp_slug}--#{count + 9}"
      end
      count = Leader.where("slug = ? or slug LIKE ?", new_slug, "#{new_slug}--%").count
      if count >= 1
        new_slug = "#{tmp_slug}--#{count + 10}"
      end
      count = Leader.where("slug = ? or slug LIKE ?", new_slug, "#{new_slug}--%").count
      if count >= 1
        new_slug = "#{tmp_slug}--#{count + 11}"
      end
      count = Leader.where("slug = ? or slug LIKE ?", new_slug, "#{new_slug}--%").count
      if count >= 1
        new_slug = "#{tmp_slug}--#{count + 12}"
      end
      count = Leader.where("slug = ? or slug LIKE ?", new_slug, "#{new_slug}--%").count
      if count >= 1
        new_slug = "#{tmp_slug}--#{count + 13}"
      end
      count = Leader.where("slug = ? or slug LIKE ?", new_slug, "#{new_slug}--%").count
      if count >= 1
        new_slug = "#{tmp_slug}--#{count + 14}"
      end
      count = Leader.where("slug = ? or slug LIKE ?", new_slug, "#{new_slug}--%").count
      if count >= 1
        new_slug = "#{tmp_slug}--#{count + 15}"
      end
      count = Leader.where("slug = ? or slug LIKE ?", new_slug, "#{new_slug}--%").count
      if count >= 1
        new_slug = "#{tmp_slug}--#{count + 16}"
      end
      
    end
    self.update_column(:slug, new_slug)
  end
  
  # def update_slug
  #   s = self.generate_slug
  #   self.update_attribute(:slug, s)
  # end

  private

  def self.update_attributes_from_know_who(leader, data)
    #debugger
    leader.born_on = birthday(data)
    leader.person_id = data[:pid] if data[:pid]
    leader.legislator_type = data[:legtype] if data[:legtype]
    leader.title = data[:title] if data[:title]
    leader.prefix = data[:prefix] if data[:prefix]
    leader.first_name = data[:firstname] if data[:firstname]
    leader.last_name = data[:lastname] if data[:lastname]
    leader.mid_name = data[:midname] if data[:midname]
    leader.nick_name = data[:nickname] if data[:nickname]
    leader.legal_name = data[:legalname] if data[:legalname]
    leader.party_code = data[:partycode] if data[:partycode]
    leader.district = data[:district] if data[:district]
    leader.district_id = data[:districtid] if data[:districtid]
    leader.family = data[:family] if data[:family]
    leader.religion = data[:religion] if data[:religion]
    leader.email = data[:email] if data[:email]
    leader.website = data[:website] if data[:website]
    leader.webform = data[:webform] if data[:webform]
    leader.weblog = data[:weblog] if data[:weblog]
    leader.blog = data[:weblog] if data[:weblog]
    leader.facebook = data[:facebook] if data[:facebook]
    leader.twitter = data[:twitter] if data[:twitter]
    leader.youtube = data[:youtube] if data[:youtube]
    leader.photo_path = data[:photopath] if data[:photopath]
    leader.photo_file = data[:photofile] if data[:photofile]
    if data[:photofile]
      #debugger
    end
    leader.chamber = data[:chamber] if data[:chamber]
    leader.gender = data[:gender] if data[:gender]
    leader.party_code = data[:partycode] if data[:partycode]
    leader.birth_place = data[:birthplace] if data[:birthplace]
    leader.spouse = data[:spouse] if data[:spouse]
    leader.marital_status = data[:marital] if data[:marital]
    leader.residence = data[:residence] if data[:residence]
    leader.school_1_name = data[:school1] if data[:school1]
    leader.school_1_date = data[:edudate1] if data[:edudate1]
    leader.school_1_degree = data[:degree1] if data[:degree1]
    leader.school_2_name = data[:school2] if data[:school2]
    leader.school_2_date = data[:edudate2] if data[:edudate2]
    leader.school_2_degree = data[:degree2] if data[:degree2]
    leader.school_3_name = data[:school3] if data[:school3]
    leader.school_3_date = data[:edudate3] if data[:edudate3]
    leader.school_3_degree = data[:degree3] if data[:degree3]
    leader.military_1_branch = data[:milbranch1] if data[:milbranch1]
    leader.military_1_rank = data[:milrank1] if data[:milrank1]
    leader.military_1_dates = data[:mildates1] if data[:mildates1]
    leader.military_2_branch = data[:milbranch2] if data[:milbranch2]
    leader.military_2_rank = data[:milrank2] if data[:milrank2]
    leader.military_2_dates = data[:mildates2] if data[:mildates2]
    leader.mail_name = data[:mailname] if data[:mailname]
    leader.mail_title = data[:mailtitle] if data[:mailtitle]
    leader.mail_address_1 = data[:mailaddr1] if data[:mailaddr1]
    leader.mail_address_2 = data[:mailaddr2] if data[:mailaddr2]
    leader.mail_address_3 = data[:mailaddr3] if data[:mailaddr3]
    leader.mail_address_4 = data[:mailaddr4] if data[:mailaddr4]
    leader.mail_address_5 = data[:mailaddr5] if data[:mailaddr5]
    puts "In update attributes"
    debugger if leader.id == 421 && Rails.env.development?
    
    return leader
  end

  def self.birthday(data)
    unless data[:birthyear].blank? or
           data[:birthmonth].blank? or
           data[:birthdate].blank?
      Date.new(data[:birthyear].to_i,
               data[:birthmonth].to_i,
               data[:birthdate].to_i)
    else
      nil
    end
  end

end
