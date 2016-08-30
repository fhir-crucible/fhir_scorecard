namespace :fhir do

  desc 'console'
  task :console, [] do |t, args|
    binding.pry
  end

  desc 'post-process LOINC Top 2000 common lab results CSV'
  task :process_loinc, [] do |t, args|
    require 'find'
    require 'csv'
    puts 'Looking for `./terminology/LOINC*.csv`...'
    loinc_file = Find.find('terminology').find{|f| /LOINC.*\.csv$/ =~f }
    if loinc_file
      output_filename = 'terminology/scorecard_loinc_2000.txt'
      puts "Writing to #{output_filename}..."
      output = File.open(output_filename,'w:UTF-8')
      line = 0
      begin
        CSV.foreach(loinc_file, encoding: 'iso-8859-1:utf-8', headers: true) do |row|
          line += 1
          next if row.length <=1 || row[1].nil? # skip the categories
          #              CODE    | DESC    | UCUM UNITS
          output.write("#{row[1]}|#{row[2]}|#{row[6]}\n")
        end
      rescue Exception => e
        puts "Error at line #{line}"
        puts e.message
      end
      output.close
      puts 'Done.'
    else
      puts 'LOINC file not found.'
      puts 'Download the LOINC Top 2000 Common Lab Results file'
      puts '  -> http://loinc.org/usage/obs/loinc-top-2000-plus-loinc-lab-observations-us.csv'
      puts 'copy it into your `./terminology` folder, and rerun this task.'
    end
  end
end
