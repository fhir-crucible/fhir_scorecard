module FHIR
  class CodesExist < FHIR::Rubrics

    # Codes are present for all codes, Codings, and CodeableConcepts
    rubric :codes_exist do |record|
      results = {
        :codeable_fields => 0,
        :coded_fields => 0
      }
      resources = record.entry.map{|e|e.resource}
      resources.each do |resource|
        results.merge!(check_metadata(resource)){|k,a,b|a+b}
      end

      percentage = results[:coded_fields].to_f / results[:codeable_fields].to_f
      percentage = 0.0 if percentage.nan?
      points = 10.0 * percentage
      message = "#{(100 * percentage).to_i}% (#{results[:coded_fields]}/#{results[:codeable_fields]}) of codes, Codings, and CodeableConcepts had values. Maximum of 10 points."
      response(points.to_i,message)
    end

    def self.check_metadata(fhir_model)
      results = {
        :codeable_fields => 0,
        :coded_fields => 0
      }
      # check for metadata
      # count all codeable fields
      fhir_model.class::METADATA.each do |key, meta|
        field_name = meta['local_name'] || key
        if ['code','Coding','CodeableConcept'].include?(meta['type'])
          results[:codeable_fields] += 1
          value = fhir_model.instance_variable_get("@#{field_name}")
          # check that the field is actually the correct type
          if !value.nil?
            if value.is_a?(Array)
              if !value.empty? # the Array has at least one value
                results[:coded_fields] += 1 if value.any?{|x|type_okay(meta['type'],x)}
              end
            else # not an Array
              results[:coded_fields] += 1 if type_okay(meta['type'],value)
            end
          end
        else
          value = fhir_model.instance_variable_get("@#{field_name}")
          if !value.nil?
            if value.is_a?(Array)
              value.each{|v| results.merge!(check_metadata(v)){|k,a,b|a+b} if v.is_a?(FHIR::Model)}
            else # not an Array
              results.merge!(check_metadata(value)){|k,a,b|a+b} if value.is_a?(FHIR::Model)
            end
          end            
        end
      end
      results
    end

    def self.type_okay(type,item)
      case type
      when 'code'
        item.is_a?(String)
      when 'Coding'
        item.is_a?(FHIR::Coding) && !item.code.nil? && !item.system.nil?
      when 'CodeableConcept'
        item.is_a?(FHIR::CodeableConcept) && item.coding.any?{|c| c.is_a?(FHIR::Coding) && !c.code.nil? && !c.system.nil?}
      else
        false
      end
    end

  end
end
