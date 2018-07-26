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
  end
  
  # bundle exec rake know_who:import_months_raw0 --trace
  task :import_months_raw0 => :environment do
    month_dir = ENV['KNOW_WHO_MONTH']
    month_dir1 = File.join('.', 'know_who/raw0/government_1/')
    file_list = Dir["#{month_dir1}/*.*"]
    KnowWho::LeaderImporter.new.import_files(file_list)
    #file_list = Dir["#{month_dir}/Members.csv"]
    #debugger
    month_dir2 = File.join('.', 'know_who/raw0/government_1_2/')
    file_list = Dir["#{month_dir2}/*.*"]
    KnowWho::LeaderImporter.new.import_files(file_list)
  end

  task :show_import_months => :environment do
    puts Dir['spec/fixtures/leaders/*'].sort
  end
  
  # bundle exec rake know_who:activate_by_csv --trace
  task :activate_by_csv => :environment do
    KnowWho::LeaderImporter.active_by_csv
  end
end
