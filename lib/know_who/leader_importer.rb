require 'csv'

module KnowWho
  class LeaderImporter
    def import_files(list)
      Leader.transaction do
        begin_import
        list.each do |file|
          prepare_file(file)
          #raise file.inspect
          #raise importing_file.inspect
          CSV.foreach(
            importing_file,
            headers: true,
            header_converters: :symbol
          ) do |member|
            puts "Processing file: #{file}"
            leader = import_leader(member)
            next if leader.nil?
            puts "Imported #{leader.prefix_name}"
          end
          `rm #{importing_file}`
        end
        finish_import
      end
    end

    def begin_import
      Leader.update_all(member_status: 'pending')
    end

    def import_leader(data)
      #debugger
      Leader.create_or_update(data).tap do |leader|
        leader.update_attribute(:member_status, 'current') if leader
      end
    end

    def finish_import
      #Leader.update_all({member_status: 'former'}, member_status: 'pending')
      Leader.update_all(member_status: 'former')
      Leader.update_all(member_status: 'pending')
    end
    
    def self.active_by_csv
      puts "At start, current_leaders = #{Leader.where(:member_status => "current").count}"
      csv_files = []
      csv_files << File.join('.', 'know_who/raw0/government_1/Members.csv')
      csv_files << File.join('.', 'know_who/raw0/government_1_2/Members.csv')
      csv_files.each do |csv_file|
        LeaderImporter.prepare_file(csv_file)
        
        CSV.foreach(
          LeaderImporter.importing_file,
          headers: true,
          header_converters: :symbol
        ) do |member|
        
          leader = Leader.where(person_id: member[:pid]).first
          if leader
            puts "Found leader: #{leader.id} - #{leader.last_name}"
            leader.update_attribute(:member_status, "current_actual")
          end
        end
      end
    
      leaders = Leader.where(:member_status => "current")
      leaders.each do |leader|
        leader.update_attribute(:member_status, "current_old")
      end
    
      leaders = Leader.where(:member_status => "current_actual")
      leaders.each do |leader|
        leader.update_attribute(:member_status, "current")
      end
    
      puts "At end, current_leaders = #{Leader.where(:member_status => "current").count}"
    
    end
    
    def self.prepare_file(file)
      puts "converting to UTF8"
      # jsj - added 5/9 to allow for OSX differences on iconv
      if Rails.env.development?
        cp_cmd = "cp #{file} #{converting_file}"
        puts_cmd(cp_cmd)
        `#{cp_cmd}`
        puts "Before executing: "
        iconv_cmd = "iconv  -c -t UTF8//TRANSLIT  #{converting_file} > #{importing_file}"
        LeaderImporter.puts_cmd(iconv_cmd)        
        `#{iconv_cmd}`
        # jsj - note that the net effect of above was ZERO - you are deleting the output of iconv
        # before ever using it and above you are importing the neno converteed file
        # I switched it to deleting the converting_file so that the importing file is left around 
        # for a later import
        # same change needs to be made below after being verified
        #raise "foo"
        #`rm #{converting_file}`
      else
        `cp #{file} #{LeaderImporter.converting_file}`
        `iconv --verbose -c --to-code UTF8//TRANSLIT --output #{importing_file} #{converting_file}`
        `rm #{LeaderImporter.converting_file}`
      end
    end

    def self.converting_file
      '/tmp/_converting_to_utf8.csv'
    end

    def self.importing_file
      '/tmp/importing_leaders.csv'
    end
    
    def self.puts_cmd(cmd)
      puts "Before executing: #{cmd}"
    end

    private
    
    def puts_cmd(cmd)
      puts "Before executing: #{cmd}"
    end

    def prepare_file(file)
      puts "converting to UTF8"
      # jsj - added 5/9 to allow for OSX differences on iconv
      if Rails.env.development?
        cp_cmd = "cp #{file} #{converting_file}"
        puts_cmd(cp_cmd)
        `#{cp_cmd}`
        puts "Before executing: "
        iconv_cmd = "iconv  -c -t UTF8//TRANSLIT  #{converting_file} > #{importing_file}"
        puts_cmd(iconv_cmd)        
        `#{iconv_cmd}`
        # jsj - note that the net effect of above was ZERO - you are deleting the output of iconv
        # before ever using it and above you are importing the neno converteed file
        # I switched it to deleting the converting_file so that the importing file is left around 
        # for a later import
        # same change needs to be made below after being verified
        #raise "foo"
        #`rm #{converting_file}`
      else
        `cp #{file} #{converting_file}`
        `iconv --verbose -c --to-code UTF8//TRANSLIT --output #{importing_file} #{converting_file}`
        `rm #{converting_file}`
      end
    end

    def converting_file
      '/tmp/_converting_to_utf8.csv'
    end

    def importing_file
      '/tmp/importing_leaders.csv'
    end
  end
end
