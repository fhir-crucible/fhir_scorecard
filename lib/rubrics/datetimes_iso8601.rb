module FHIR
  class DateTimesIso8601 < FHIR::Rubrics

    # Codes are present for all codes, Codings, and CodeableConcepts
    rubric :iso8601_dates do |record|
      results = {
        :datetime_fields => 0,
        :iso8601_fields => 0
      }
      resources = record.entry.map{|e|e.resource}
      resources.each do |resource|
        results.merge!(check_metadata(resource)){|k,a,b|a+b}
      end

      percentage = results[:iso8601_fields].to_f / results[:datetime_fields].to_f
      percentage = 0.0 if percentage.nan?
      points = 10.0 * percentage
      message = "#{(100 * percentage).to_i}% (#{results[:iso8601_fields]}/#{results[:datetime_fields]}) of date/time/dateTime/instant fields were populated with reasonable iso8601 values. Maximum of 10 points."
      response(points.to_i,message)
    end

    def self.check_metadata(fhir_model)
      results = {
        :datetime_fields => 0,
        :iso8601_fields => 0
      }
      # check for metadata
      # count all codeable fields
      fhir_model.class::METADATA.each do |key, meta|
        field_name = meta['local_name'] || key
        if ['date','time','dateTime','instant'].include?(meta['type'])
          results[:datetime_fields] += 1
          value = fhir_model.instance_variable_get("@#{field_name}")
          # check that the field is actually the correct type
          if !value.nil?
            if value.is_a?(Array)
              if !value.empty? # the Array has at least one value
                results[:iso8601_fields] += 1 if value.any?{|x|type_okay(meta['type'],x)}
              end
            else # not an Array
              results[:iso8601_fields] += 1 if type_okay(meta['type'],value)
            end
          end
        else
          value = fhir_model.instance_variable_get("@#{field_name}")
          if !value.nil?
            if value.is_a?(Array)
              value.each{|v| results.merge!(check_metadata(v)){ |k,a,b| a + b } if FHIR.is_model?(v) }
            else # not an Array
              results.merge!(check_metadata(value)){ |k,a,b| a + b } if FHIR.is_model?(value)
            end
          end            
        end
      end
      results
    end

    def self.type_okay(type,item)
      okay = false
      begin
        time = Time.iso8601(item)
        okay = true
        if time.year
          okay = (time.year > 1900) && (time.year < (Time.now + (10 * 365 * 24 * 60 * 60)).year)
        end
      rescue Exception => e
        okay = false
      end
      okay
    end

  end
end
