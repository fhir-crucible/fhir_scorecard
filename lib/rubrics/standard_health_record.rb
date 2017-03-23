module FHIR
  class StandardHealthRecordRubric < FHIR::Rubrics

    # Resources should adhere to the Standard Health Record (SHR) Implementation Guide (IG)
    rubric :standard_health_record do |record|
      results = {
        :eligible_resources => 0,
        :validated_resources => 0
      }

      resources = record.entry.map{|e|e.resource}
      resources.each_with_index do |resource, index|
        profile = FHIR::ImplementationGuideLookup.guess_shr_profile(resource)
        if profile
          results[:eligible_resources] += 1
          errors = profile.validate_resource(resource)
          if errors.empty?
            results[:validated_resources] += 1
          else
            puts "------------------------------"
            puts "#{index+1} of #{resources.size}"
            puts "Profile: #{profile.id}"
            puts "ERRORS"
            puts errors
            puts "WARNINGS"
            puts profile.warnings
          end
        end
      end

      percentage = results[:validated_resources].to_f / results[:eligible_resources].to_f
      percentage = 0.0 if percentage.nan?
      points = 10.0 * percentage
      message = "#{(100 * percentage).to_i}% (#{results[:validated_resources]}/#{results[:eligible_resources]}) of eligible resources conform to the Standard Health Record (SHR) Implementation Guide."
      response(points.to_i,message)
    end

  end
end
