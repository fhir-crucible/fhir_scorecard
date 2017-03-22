module FHIR
  class USCoreRubric < FHIR::Rubrics

    # Resources should adhere to the US Core Implementation Guide (IG)
    rubric :us_core do |record|
      results = {
        :eligible_resources => 0,
        :validated_resources => 0
      }

      resources = record.entry.map{|e|e.resource}
      resources.each do |resource|
        profile = FHIR::ImplementationGuideLookup.guess_uscore_profile(resource)
        if profile
          results[:eligible_resources] += 1
          results[:validated_resources] += 1 if profile.validates_resource?(resource)
        end
      end

      percentage = results[:validated_resources].to_f / results[:eligible_resources].to_f
      percentage = 0.0 if percentage.nan?
      points = 10.0 * percentage
      message = "#{(100 * percentage).to_i}% (#{results[:validated_resources]}/#{results[:eligible_resources]}) of eligible resources conform to the US Core Implementation Guide."
      response(points.to_i,message)
    end

  end
end
