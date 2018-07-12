class LeaderSerializer < ActiveModel::Serializer
  #attributes :id, :first_name, :last_name
  attributes :id, :state_id, :slug, :person_id, :title, :first_name, :last_name, :mid_name, 
  :nick_name, :legal_name, :legislator_type, :chamber, :party_code, :family, :religion,
  :email, :website, :webform, :weblog, :blog, :facebook, :twitter, :youtube, :photo_path,
  :photo_file, :gender, :birth_place, :spouse, :marital_status, :residence, :school_1_name,
  :school_1_date, :school_1_degree, :school_2_name, :school_2_date, :school_2_degree, 
  :school_3_name, :school_3_date, :school_3_degree, :military_1_branch, :military_1_rank,
  :military_1_dates, :military_2_branch, :military_2_rank, :military_2_dates, :mail_name,
  :mail_title, :mail_address_1, :mail_address_2, :mail_address_3, :mail_address_4, 
  :mail_address_5, :born_on, :know_who_data, :biography, :member_status, :state_code
end
