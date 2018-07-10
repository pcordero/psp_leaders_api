require 'csv'
require 'know_who'

# bundle exec rake know_who:download_latest_data --trace
namespace :know_who do
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

  task :import_states => :environment do
    KnowWho::StateImporter.new.import('spec/fixtures/states.csv')
  end

  task :import_month => :environment do
    month_dir = ENV['KNOW_WHO_MONTH']
    file_list = Dir["#{month_dir}/*.*"]
    KnowWho::LeaderImporter.new.import_files(file_list)
  end

  task :show_import_months => :environment do
    puts Dir['spec/fixtures/leaders/*'].sort
  end
end
