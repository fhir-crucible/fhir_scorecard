module FHIR
  class ReferencesResolve < FHIR::Rubrics

    # All References should resolve to Resources within the Bundle.
    rubric :references_resolve do |record|
      results = {
        :eligible_fields => 0,
        :validated_fields => 0
      }

      resources = record.entry.map{|e|e.resource}
      resources.each do |resource|
        results.merge!(check_metadata(resource,record)){|k,a,b|a+b}
      end

      percentage = results[:validated_fields].to_f / results[:eligible_fields].to_f
      percentage = 0.0 if percentage.nan?
      points = 10.0 * percentage
      message = "#{(100 * percentage).to_i}% (#{results[:validated_fields]}/#{results[:eligible_fields]}) of all possible References resolved locally within the Bundle. Maximum of 10 points."
      response(points.to_i,message)
    end

    def self.check_metadata(fhir_model,record)
      results = {
        :eligible_fields => 0,
        :validated_fields => 0
      }
      # check for metadata
      # examine all References
      fhir_model.class::METADATA.each do |key, meta|
        field_name = meta['local_name'] || key
        if meta['type']=='Reference'
          results[:eligible_fields] += 1
          value = fhir_model.instance_variable_get("@#{field_name}")
          # check that the field is actually the correct type
          if !value.nil?
            if value.is_a?(Array)
              if !value.empty? # the Array has at least one value
                results[:eligible_fields] += (value.length-1)
                value.each do |ref|
                  results[:validated_fields] += 1 if local_reference?(ref,record,fhir_model.contained)
                end
              end
            else # not an Array
              results[:validated_fields] += 1 if local_reference?(value,record,fhir_model.contained)
            end
          end
        else
          value = fhir_model.instance_variable_get("@#{field_name}")
          if !value.nil?
            if value.is_a?(Array)
              value.each{ |v| results.merge!(check_metadata(v, record)){ |k,a,b| a + b } if FHIR.is_model?(v) }
            else # not an Array
              results.merge!(check_metadata(value, record)){ |k,a,b| a + b } if FHIR.is_model?(value)
            end
          end            
        end
      end
      results
    end

    def self.local_reference?(reference,record,contained)
      if contained && reference.reference && reference.reference.start_with?('#')
        contained.each do |resource|
          return true if reference.reference[1..-1]==resource.id
        end
      end
      record.entry.each do |entry|
        return true if reference_matchs?(reference,entry)
      end
      false    
    end

    def self.reference_matchs?(reference,entry)
      return false if (reference.nil? || reference.reference.nil?)
      if reference.reference.start_with?('urn:uuid:')
        (reference.reference == entry.fullUrl)
      else
        # some weaknesses here:
        # 'Patient/20' will match both 'http://foo/Patient/20/_history/1' and 'http://foo/Patient/20303/_history/1' 
        ((entry.fullUrl =~ /#{reference.reference}/) || (entry.resource && entry.resource.id =~ /#{reference.reference}/ ))
      end
    end

  end
end
