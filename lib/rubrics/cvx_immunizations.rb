module FHIR
  class CVXImmunizations < FHIR::Rubrics

    # Immunizations should be coded with CVX
    rubric :cvx_immunizations do |record|
      results = {
        :eligible_fields => 0,
        :validated_fields => 0
      }

      resources = record.entry.map{|e|e.resource}
      resources.each do |resource|
        if resource.is_a?(FHIR::Immunization)
            results[:eligible_fields] += 1
            results[:validated_fields] += 1 if cvx?(resource.vaccineCode)        
        end
      end

      percentage = results[:validated_fields].to_f / results[:eligible_fields].to_f
      percentage = 0.0 if percentage.nan?
      points = 10.0 * percentage
      message = "#{(100 * percentage).to_i}% (#{results[:validated_fields]}/#{results[:eligible_fields]}) of Immunization vaccine codes use CVX. Maximum of 10 points."
      response(points.to_i,message)
    end

    def self.cvx?(codeableconcept)
      return false if codeableconcept.nil? || codeableconcept.coding.nil?
      codeableconcept.coding.any?{|x| x.system=='http://hl7.org/fhir/sid/cvx' && FHIR::Terminology.get_description('CVX',x.code)}
    end

  end
end
