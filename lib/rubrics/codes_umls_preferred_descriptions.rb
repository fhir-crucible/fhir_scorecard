module FHIR
  class CodesUmlsPreferredDescriptions < FHIR::Rubrics

    # SNOMED, LOINC, RxNorm, ICD9, and ICD10 codes in UMLS use preferred descriptions
    rubric :descriptions do |record|
      results = {
        :eligible_fields => 0,
        :correct_descriptions => 0
      }
      resources = record.entry.map{|e|e.resource}
      resources.each do |resource|
        results.merge!(check_fields(resource)){|k,a,b|a+b}
      end

      percentage = results[:correct_descriptions].to_f / results[:eligible_fields].to_f
      percentage = 0.0 if percentage.nan?
      points = 10.0 * percentage
      message = "#{(100 * percentage).to_i}% (#{results[:correct_descriptions]}/#{results[:eligible_fields]}) of SNOMED, LOINC, RxNorm, ICD9, and ICD10 codes use preferred descriptions. Maximum of 10 points."
      response(points.to_i,message)
    end

    def self.check_fields(fhir_model)
      results = {
        :eligible_fields => 0,
        :correct_descriptions => 0
      }
      # check each codeable field
      fhir_model.class::METADATA.each do |key, meta|
        field_name = meta['local_name'] || key
        declared_binding = eligible_binding(meta)
        supposed_to_be_umls = !declared_binding.nil?
        value = fhir_model.instance_variable_get("@#{field_name}")

        if meta['type']=='Coding'
          if value.is_a?(Array)
            value.each do |v| 
              results.merge!(check_coding(v,supposed_to_be_umls,declared_binding)){|k,a,b|a+b}            
            end
          else
            results.merge!(check_coding(value,supposed_to_be_umls,declared_binding)){|k,a,b|a+b}
          end
        elsif meta['type']=='CodeableConcept'
          if value.is_a?(Array)
            value.each do |cc|
              cc.coding.each do |c|
                results.merge!(check_coding(c,supposed_to_be_umls,declared_binding)){|k,a,b|a+b}
              end
            end
          else
            if value.nil?
              results[:eligible_fields] += 1 if supposed_to_be_umls
            else
              value.coding.each do |c|
                results.merge!(check_coding(c,supposed_to_be_umls,declared_binding)){|k,a,b|a+b}
              end
            end
          end
        elsif !value.nil?
          if value.is_a?(Array)
            value.each{|v| results.merge!(check_fields(v)){|k,a,b|a+b} if FHIR.is_model?(v)}
          else # not an Array
            results.merge!(check_fields(value)){|k,a,b|a+b} if FHIR.is_model?(value)
          end
        end
      end
      results
    end

    # This method checks whether or not the coding is eligible and checks the description.
    # A coding is eligible if it is supposed to be UMLS (as declared in the
    # resource metadata) or it is locally declared as one of the UMLS systems.
    # If the coding is eligible, then the description is checked against the preferred description.
    def self.check_coding(coding,supposed_to_be_umls,declared_binding)
      result = {
        :eligible_fields => 0,
        :correct_descriptions => 0
      } 
      if coding.nil?
        result[:eligible_fields] += 1 if supposed_to_be_umls
      else
        local_binding = coding.system || declared_binding
        if supposed_to_be_umls || FHIR::Terminology::CODE_SYSTEMS[local_binding]
          result[:eligible_fields] += 1 
          preferred = FHIR::Terminology.get_description(FHIR::Terminology::CODE_SYSTEMS[local_binding],coding.code)
          result[:correct_descriptions] +=1 if preferred==coding.display
        end
      end
      result
    end

    # This method checks the metadata on this field and returns the binding key (e.g. 'SNOMED')
    # if one of the UMLS code systems was specified. Otherwise, it returns nil.
    def self.eligible_binding(metadata)
      vs_binding = metadata['binding']
      matching_binding = FHIR::Terminology::CODE_SYSTEMS[vs_binding['uri']] if !vs_binding.nil? && vs_binding['uri']

      valid_codes = metadata['valid_codes']
      matching_code_system = valid_codes.keys.find{|k| FHIR::Terminology::CODE_SYSTEMS[k]} if !valid_codes.nil?
      matching_code_system = FHIR::Terminology::CODE_SYSTEMS[matching_code_system] if matching_code_system

      matching_binding || matching_code_system
    end

  end
end
