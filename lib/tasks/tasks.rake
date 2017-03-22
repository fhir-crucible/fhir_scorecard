namespace :fhir do

  desc 'console'
  task :console, [] do |t, args|
    binding.pry
  end

  desc 'score a FHIR Bundle'
  task :score, [:bundle_path] do |t, args|
    bundle_path = args[:bundle_path]
    if bundle_path.nil?
      puts 'A path to FHIR Bundle is required!'
    else
      contents = File.open(bundle_path,'r:UTF-8',&:read)
      scorecard = FHIR::Scorecard.new
      scorecard.enable_us_core
      scorecard.enable_shr
      report = scorecard.score(contents)
      puts 
      puts "  POINTS            CATEGORY   MESSAGE"
      puts "  ------            --------   -------"
      report.each do |key,value|
        next if key==:points
        printf("   %3d  %22s   %s\n", value[:points], key, value[:message])
      end
      puts "  ------"
      printf("   %3d  %22s\n", report[:points], 'TOTAL')
      puts
    end
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

  desc 'post-process SNOMED Core Subset file'
  task :process_snomed, [] do |t, args|
    require 'find'
    puts 'Looking for `./terminology/SNOMEDCT_CORE_SUBSET*.txt`...'
    snomed_file = Find.find('terminology').find{|f| /SNOMEDCT_CORE_SUBSET.*\.txt$/ =~f }
    if snomed_file
      output_filename = 'terminology/scorecard_snomed_core.txt'
      output = File.open(output_filename,'w:UTF-8')
      line = 0
      begin
        entire_file = File.read(snomed_file)
        puts "Writing to #{output_filename}..."
        entire_file.split("\n").each do |l|
          row = l.split('|')
          line += 1
          next if line==1 # skip the headers
          #              CODE    | DESC    
          output.write("#{row[0]}|#{row[1]}\n")
        end
      rescue Exception => e
        puts "Error at line #{line}"
        puts e.message
      end
      output.close
      puts 'Done.'
    else
      puts 'SNOMEDCT file not found.'
      puts 'Download the SNOMEDCT Core Subset file'
      puts '  -> https://www.nlm.nih.gov/research/umls/Snomed/core_subset.html'
      puts 'copy it into your `./terminology` folder, and rerun this task.'
    end
  end

  desc 'post-process common UCUM codes'
  task :process_ucum, [] do |t, args|
    require 'find'
    puts 'Looking for `./terminology/concepts.tsv`...'
    ucum_file = Find.find('terminology').find{|f| /concepts.tsv$/ =~f }
    if ucum_file
      output_filename = 'terminology/scorecard_ucum.txt'
      output = File.open(output_filename,'w:UTF-8')
      line = 0
      begin
        entire_file = File.read(ucum_file)
        puts "Writing to #{output_filename}..."
        entire_file.split("\n").each do |l|
          row = l.split("\t")
          line += 1
          next if line==1 # skip the headers
          output.write("#{row[0]}\n") # code
          output.write("#{row[5]}\n") if row[0]!=row[5] # synonym
        end
      rescue Exception => e
        puts "Error at line #{line}"
        puts e.message
      end
      output.close
      puts 'Done.'
    else
      puts 'UCUM concepts file not found.'
      puts 'Download the UCUM concepts file'
      puts '  -> http://download.hl7.de/documents/ucum/concepts.tsv'
      puts 'copy it into your `./terminology` folder, and rerun this task.'
    end
  end

  desc 'post-process UMLS terminology file'
  task :process_umls, [] do |t, args|
    require 'find'
    puts 'Looking for `./terminology/MRCONSO.RRF`...'
    input_file = Find.find('terminology').find{|f| f=='terminology/MRCONSO.RRF' }
    if input_file
      start = Time.now
      output_filename = 'terminology/scorecard_umls.txt'
      output = File.open(output_filename,'w:UTF-8')
      line = 0
      excluded = 0
      excluded_systems = Hash.new(0)
      begin
        entire_file = File.read(input_file)
        puts "Writing to #{output_filename}..."
        entire_file.split("\n").each do |l|
          row = l.split('|')
          line += 1
          include_code = false
          codeSystem = row[11]
          code = row[13]
          description = row[14]
          case codeSystem
          when 'SNOMEDCT_US'
            codeSystem = 'SNOMED'
            include_code = (row[4]=='PF' && ['FN','OAF'].include?(row[12]))
          when 'LNC'
            codeSystem = 'LOINC'
            include_code = true
          when 'ICD10CM'
            codeSystem = 'ICD10'
            include_code = (row[12]=='PT')
          when 'ICD10PCS'
            codeSystem = 'ICD10'
            include_code = (row[12]=='PT')            
          when 'ICD9CM'
            codeSystem = 'ICD9'
            include_code = (row[12]=='PT')
          when 'MTHICD9'
            codeSystem = 'ICD9'
            include_code = true
          when 'RXNORM'
            include_code = true
          when 'CVX'
            include_code = (['PT','OP'].include?(row[12]))
          when 'SRC'
            # 'SRC' rows define the data sources in the file
            include_code = false
          else
            include_code = false
            excluded_systems[codeSystem] += 1
          end
          if include_code
            output.write("#{codeSystem}|#{code}|#{description}\n")             
          else
            excluded += 1
          end
        end
      rescue Exception => e
        puts "Error at line #{line}"
        puts e.message
      end
      output.close
      puts "Processed #{line} lines, excluding #{excluded} redundant entries."
      puts "Excluded code systems: #{excluded_systems}" if !excluded_systems.empty?
      finish = Time.now
      minutes = ((finish-start)/60)
      seconds = (minutes - minutes.floor) * 60
      puts "Completed in #{minutes.floor} minute(s) #{seconds.floor} second(s)."
      puts 'Done.'
    else
      puts 'UMLS file not found.'
      puts 'Download the US National Library of Medicine (NLM) Unified Medical Language System (UMLS) Full Release files'
      puts '  -> https://www.nlm.nih.gov/research/umls/licensedcontent/umlsknowledgesources.html'
      puts 'Install the metathesaurus with the following data sources:'
      puts '  CVX|CVX;ICD10CM|ICD10CM;ICD10PCS|ICD10PCS;ICD9CM|ICD9CM;LNC|LNC;MTHICD9|ICD9CM;RXNORM|RXNORM;SNOMEDCT_US|SNOMEDCT'
      puts 'After installation, copy `{install path}/META/MRCONSO.RRF` into your `./terminology` folder, and rerun this task.'
    end
  end
end
