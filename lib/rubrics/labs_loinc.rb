module FHIR
  class LabsLoinc < FHIR::Rubrics

    # Lab Results should be coded with LOINC's top 2000 codes
    rubric :loinc_labs do |record|
      results = {
        :eligible_fields => 0,
        :validated_fields => 0
      }
      resources = record.entry.map{|e|e.resource}
      resources.each do |resource|
        if FHIR.is_any_version?(resource, 'DiagnosticReport') || FHIR.is_any_version?(resource, 'Observation')
          results[:eligible_fields] += 1
          if resource.code
            results[:validated_fields] += 1 if resource.code.coding.any?{|x| x.system=='http://loinc.org' && FHIR::Terminology.is_top_lab_code?(x.code)}
          end
        end
        if FHIR.is_any_version?(resource, 'Observation')
          if resource.component
            resource.component.each do |comp|
              results[:eligible_fields] += 1
              if comp.code
                results[:validated_fields] += 1 if comp.code.coding.any?{|x| x.system=='http://loinc.org' && FHIR::Terminology.is_top_lab_code?(x.code)}
              end              
            end
          end
        end
      end

      percentage = results[:validated_fields].to_f / results[:eligible_fields].to_f
      percentage = 0.0 if percentage.nan?
      points = 10.0 * percentage
      message = "#{(100 * percentage).to_i}% (#{results[:validated_fields]}/#{results[:eligible_fields]}) of Observations and DiagnosticReports validated against the LOINC Top 2000. Maximum of 10 points."
      response(points.to_i,message)
    end

  end
end
