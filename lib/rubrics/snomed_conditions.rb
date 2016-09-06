module FHIR
  class SnomedConditions < FHIR::Rubrics

    # Conditions should be coded with the SNOMED Core Subset
    rubric :snomed_core do |record|
      results = {
        :eligible_fields => 0,
        :validated_fields => 0
      }

      resources = record.entry.map{|e|e.resource}
      resources.each do |resource|
        if resource.is_a?(FHIR::Condition)
          results[:eligible_fields] += 1
          results[:validated_fields] += 1 if snomed_core?(resource.code)
        end
      end

      percentage = results[:validated_fields].to_f / results[:eligible_fields].to_f
      percentage = 0.0 if percentage.nan?
      points = 10.0 * percentage
      message = "#{(100 * percentage).to_i}% (#{results[:validated_fields]}/#{results[:eligible_fields]}) of Condition Resource codes use the SNOMED Core Subset. Maximum of 10 points."
      response(points.to_i,message)
    end

    def self.snomed_core?(codeableconcept)
      return false if codeableconcept.nil? || codeableconcept.coding.nil?
      codeableconcept.coding.any?{|x| x.system=='http://snomed.info/sct' && FHIR::Terminology.is_core_snomed?(x.code)}
    end

  end
end
