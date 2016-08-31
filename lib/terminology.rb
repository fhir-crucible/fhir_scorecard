module FHIR
  class Terminology

    @@term_root = File.expand_path '../terminology',File.dirname(File.absolute_path(__FILE__))

    @@loaded = false
    @@top_lab_code_units = {}
    @@top_lab_code_descriptions = {}
    @@known_codes = {}

    def self.load_terminology
      if !@@loaded
        # load the top lab codes
        filename = File.join(@@term_root,'scorecard_loinc_2000.txt')
        raw = File.open(filename,'r:UTF-8',&:read)
        raw.split("\n").each do |line|
          row = line.split('|')
          @@top_lab_code_descriptions[row[0]] = row[1] if !row[1].nil?
          @@top_lab_code_units[row[0]] = row[2] if !row[2].nil?
        end

        # load the known codes
        filename = File.join(@@term_root,'scorecard_umls.txt')
        raw = File.open(filename,'r:UTF-8',&:read)
        raw.split("\n").each do |line|
          row = line.split('|')
          codeSystem = row[0]
          code = row[1]
          description = row[2]
          if @@known_codes[codeSystem]
            codeSystemHash = @@known_codes[codeSystem]
          else
            codeSystemHash = {}
            @@known_codes[codeSystem] = codeSystemHash
          end
          codeSystemHash[code] = description
        end

        @@loaded = true
      end
    end

    def self.get_description(system,code)
      load_terminology
      if @@known_codes[system]
        @@known_codes[system][code]
      else
        nil
      end
    end

    def self.is_top_lab_code?(code)
      load_terminology
      !@@top_lab_code_units[code].nil?
    end

    def self.lab_units(code)
      load_terminology
      @@top_lab_code_units[code]
    end

    def self.lab_description(code)
      load_terminology
      @@top_lab_code_descriptions[code]
    end
  end
end