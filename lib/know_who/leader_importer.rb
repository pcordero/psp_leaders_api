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
      Leader.create_or_update(data).tap do |leader|
        leader.update_attribute(:member_status, 'current')
      end
    end

    def finish_import
      #Leader.update_all({member_status: 'former'}, member_status: 'pending')
      Leader.update_all(member_status: 'former')
      Leader.update_all(member_status: 'pending')
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
