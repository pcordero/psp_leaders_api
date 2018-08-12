require 'csv'
require 'know_who'

namespace :know_who do
  task :full_import => :environment do
    Rake::Task["know_who:download_latest_data"].execute
    Rake::Task["know_who:unzip"].execute
    Rake::Task["know_who:set_current"].execute
    Rake::Task["know_who:import_month"].execute
  end
  
  
  # bundle exec rake know_who:download_latest_data --trace
  task :download_latest_data do
    `mkdir -p know_who/raw`
    #`cd know_who/raw && wget #{ENV['KNOW_WHO_FTP_URL']}/*`
    know_who_ftp_url = "ftp://ftp_capitolcomm:ktr84sbe@205.134.170.180/"
    `cd know_who/raw && wget #{know_who_ftp_url}/*`
    
    
    # URL Address:  ftp://205.134.170.180/
    #
    # User name:  ftp_capitolcomm
    #
    # Password:  ktr84sbe
    
    
    
  end

  # bundle exec rake know_who:import_states --trace
  task :import_states => :environment do
    KnowWho::StateImporter.new.import('spec/fixtures/states.csv')
  end
  
  # bundle exec rake know_who:set_current --trace
  task :set_current => :environment do
    leaders = Leader.where(["DATE(created_at) = ?", Date.today]).where(:member_status => "pending")
    leaders.each do |leader|
      next if leader.last_name == "Vacant"
      leader.update_attribute(:member_status, 'current')
    end
  end

  # bundle exec rake know_who:import_month --trace
  task :import_month => :environment do
    month_dir = ENV['KNOW_WHO_MONTH']
    month_dir = File.join('.', 'know_who/raw/government_1/')
    file_list = Dir["#{month_dir}/*.*"]
    file_list = Dir["#{month_dir}/Members.csv"]
    debugger
    KnowWho::LeaderImporter.new.import_files(file_list)
  end

  # before delete
  # Leader.count
  #    (359.9ms)  SELECT COUNT(*) FROM "leaders"
  # 9425
  
  # bundle exec rake know_who:import_months --trace
  task :import_months => :environment do
    ActiveRecord::Base.connection.execute("Truncate Leaders") if Rails.env.development?
    # federal
    month_dir = ENV['KNOW_WHO_MONTH']
    month_dir1 = File.join('.', 'know_who/raw/government_1/')
    file_list = Dir["#{month_dir1}/*.*"]
    KnowWho::LeaderImporter.new.import_files(file_list)
    #file_list = Dir["#{month_dir}/Members.csv"]
    #debugger
    # state
    month_dir2 = File.join('.', 'know_who/raw/government_1_2/')
    file_list = Dir["#{month_dir2}/*.*"]
    KnowWho::LeaderImporter.new.import_files(file_list)
    
    leaders = Leader.where(["DATE(created_at) = ?", Date.today]).where(:member_status => "pending")
    leaders.each do |leader|
      next if leader.last_name == "Vacant"
      leader.update_attribute(:member_status, 'current')
    end
    
    puts "After executing: :import_months, total leaders = #{Leader.count}"
    puts "After executing: :import_months, total current leaders = #{Leader.where(:member_status => 'current').count}"
    puts "After executing: :import_months, total leaders w/ valid photo_file = #{Leader.where('photo_file IS NOT null').count}"
    puts "After executing: import_months, Spartz count = #{Leader.where(:last_name => 'Spartz').count}"
    puts "After executing: import_months, Abbot count = #{Leader.where(:last_name => 'Abbott', :first_name => 'David').count}"
    puts "After executing: import_months, Buchanan count = #{Leader.where(:last_name => 'Buchanan', :first_name => 'Brian').count}"
  end
  
  # bundle exec rake know_who:import_months_raw0 --trace
  task :import_months_raw0 => :environment do
    ActiveRecord::Base.connection.execute("Truncate Leaders") if Rails.env.development?

    month_dir = ENV['KNOW_WHO_MONTH']
    month_dir1 = File.join('.', 'know_who/raw0/government_1/')
    file_list = Dir["#{month_dir1}/*.*"]
    KnowWho::LeaderImporter.new.import_files(file_list)
    #file_list = Dir["#{month_dir}/Members.csv"]
    #debugger
    month_dir2 = File.join('.', 'know_who/raw0/government_1_2/')
    file_list = Dir["#{month_dir2}/*.*"]
    KnowWho::LeaderImporter.new.import_files(file_list)

    puts "After executing: :import_months_raw0, total leaders = #{Leader.count}"
    puts "After executing: :import_months_raw0, total leaders w/ valid photo_file = #{Leader.where('photo_file IS NOT null').count}"
    puts "After executing: import_months_raw0, Spartz count = #{Leader.where(:last_name => 'Spartz').count}"
    puts "After executing: import_months_raw0, Abbot count = #{Leader.where(:last_name => 'Abbot', :first_name => 'Dave').count}"
    puts "After executing: import_months_raw0, Buchanan count = #{Leader.where(:last_name => 'Buchanan', :first_name => 'Brian').count}"
  end

  task :show_import_months => :environment do
    puts Dir['spec/fixtures/leaders/*'].sort
  end
  
  # bundle exec rake know_who:activate_by_csv --trace
  task :activate_by_csv => :environment do
    KnowWho::LeaderImporter.active_by_csv
  end

  # bundle exec rake know_who:photo_file_from_csv --trace
  task :photo_file_from_csv => :environment do
    KnowWho::LeaderImporter.photo_file_from_csv
  end
  
  # bundle exec rake know_who:copy_images_to_psp --trace
  task :copy_images_to_psp => :environment do
    paths = []
    state_str = "AK/ AR/ AZ/ CO/ DC/ FL/ GU/ IA/ IL/ KS/ LA/ MD/ MI/ MO/ MT/ ND/ NH/ NM/ NY/ OK/ PA/ RI/ SD/ TX/ VA/ VT/ WI/ WY/
AL/ AS/ CA/ CT/ DE/ GA/ HI/ ID/ IN/ KY/ MA/ ME/ MN/ MS/ NC/ NE/ NJ/ NV/ OH/ OR/ PR/ SC/ TN/ UT/ VI/ WA/ WV/".gsub(/\//,'')
    states = state_str.split(" ")
    states.each do |state|
      paths << [
        File.join(Rails.root, "know_who/raw/Photos/FL/H/"),
        "/Users/sjohnson/fuzzygroup/consulting/new_leaders_original/psp/public/photos/FL/H/"]
      paths << [
        File.join(Rails.root, "know_who/raw/Photos/FL/S/"), 
        "/Users/sjohnson/fuzzygroup/consulting/new_leaders_original/psp/public/photos/FL/S/"]
      paths << [
        File.join(Rails.root, "know_who/raw/'Photos 2'/SL/#{state}/H/"), 
        "/Users/sjohnson/fuzzygroup/consulting/new_leaders_original/psp/public/photos/SL/#{state}/H/"]
      paths << [
        File.join(Rails.root, "know_who/raw/'Photos 2'/SL/#{state}/S/"), 
        "/Users/sjohnson/fuzzygroup/consulting/new_leaders_original/psp/public/photos/SL/#{state}/S/"]
      # paths << [
      #   File.join(Rails.root, "know_who/raw0/Photos/FL/H/"),
      #   "/Users/sjohnson/fuzzygroup/consulting/new_leaders_original/psp/public/photos/FL/H/"
      # ]
      # paths << [
      #   File.join(Rails.root, "know_who/raw0/Photos/FL/S/"),
      #   "/Users/sjohnson/fuzzygroup/consulting/new_leaders_original/psp/public/photos/FL/S/"
      # ]
      paths << [
        File.join(Rails.root, "know_who/raw0/Photos/SL/#{state}/H/"), 
        "/Users/sjohnson/fuzzygroup/consulting/new_leaders_original/psp/public/photos/SL/#{state}/H/"
      ]
      paths << [
        File.join(Rails.root, "know_who/raw0/Photos/SL/#{state}/S/"), 
        "/Users/sjohnson/fuzzygroup/consulting/new_leaders_original/psp/public/photos/SL/#{state}/S/"
      ]
      paths << [
        File.join(Rails.root, "know_who/raw0/Photos_2/FL/S/"), 
        "/Users/sjohnson/fuzzygroup/consulting/new_leaders_original/psp/public/photos/SL/#{state}/S/"
      ]
      paths << [
        File.join(Rails.root, "know_who/raw0/Photos_2/FL/H/"), 
        "/Users/sjohnson/fuzzygroup/consulting/new_leaders_original/psp/public/photos/SL/#{state}/S/"
      ]
      # paths << [
      #   File.join(Rails.root, "know_who/raw0/Photos_2/SL/#{state}/H/"),
      #   "/Users/sjohnson/fuzzygroup/consulting/new_leaders_original/psp/public/photos/SL/#{state}/H/"
      # ]
      # paths << [
      #   File.join(Rails.root, "know_who/raw0/Photos_2/SL/#{state}/S/"),
      #   "/Users/sjohnson/fuzzygroup/consulting/new_leaders_original/psp/public/photos/SL/#{state}/S/"
      # ]
    end
    
    #cp /Users/sjohnson/fuzzygroup/consulting/new-leaders-api2/know_who/raw/'Photos 2'/SL/WI/H/* /Users/sjohnson/fuzzygroup/consulting/new_leaders_original/psp/public/photos/SL/WI/H/
    
    paths.each do |path_tuple|
      source = path_tuple[0]
      dest = path_tuple[1]
      `cp -p -r #{source}* #{dest}`
    end
  end
  
  # bundle exec rake know_who:update_slugs --trace
  task :update_slugs => :environment do
    leaders = Leader.all
    # leaders.each do |leader|
    #   leader.update_attribute(:slug, nil)
    # end
    
    leaders.each do |l|
      puts "Processing leader: #{l.id}"
      l.generate_slug
    end
  end
  
end
