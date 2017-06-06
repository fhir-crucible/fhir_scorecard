module FHIR
  class CVXMeds < FHIR::Rubrics

    # Medications should *NOT* be coded with CVX
    rubric :cvx_medications do |record|
      results = {
        :eligible_fields => 0,
        :validated_fields => 0
      }
      # Medication.code (CodeableConcept)
      # MedicationAdministration.medicationCodeableConcept / medicationReference
      # MedicationDispense.medicationCodeableConcept / medicationReference
      # MedicationRequest.medicationCodeableConcept / medicationReference -- in STU3
      # MedicationOrder.medicationCodeableConcept / medicationReference -- in DSTU2
      # MedicationStatement.medicationCodeableConcept / medicationReference

      resources = record.entry.map{|e|e.resource}
      resources.each do |resource|
        if FHIR.is_any_version?(resource, 'Medication')
            results[:eligible_fields] += 1
            results[:validated_fields] += 1 if cvx?(resource.code)        
        elsif (
            resource.is_a?(FHIR::MedicationRequest) || resource.is_a?(FHIR::DSTU2::MedicationOrder) ||
            FHIR.is_any_version?(resource, 'MedicationDispense') ||
            FHIR.is_any_version?(resource, 'MedicationAdministration') ||
            FHIR.is_any_version?(resource, 'MedicationStatement') )
          if resource.medicationCodeableConcept
            results[:eligible_fields] += 1
            results[:validated_fields] += 1 if cvx?(resource.medicationCodeableConcept)
          elsif resource.medicationReference
            results[:eligible_fields] += 1
            results[:validated_fields] += 1 if local_cvx_reference?(resource.medicationReference,record,resource.contained)            
          end
        end
      end

      percentage = results[:validated_fields].to_f / results[:eligible_fields].to_f
      percentage = 0.0 if percentage.nan?
      points = -10.0 * percentage
      message = "#{(100 * percentage).to_i}% (#{results[:validated_fields]}/#{results[:eligible_fields]}) of Medication[x] Resource codes use CVX. Maximum of 10 point penalty."
      response(points.to_i,message)
    end

    def self.cvx?(codeableconcept)
      return false if codeableconcept.nil? || codeableconcept.coding.nil?
      codeableconcept.coding.any?{|x| x.system=='http://hl7.org/fhir/sid/cvx' && FHIR::Terminology.get_description('CVX',x.code)}
    end

    def self.local_cvx_reference?(reference,record,contained)
      if contained && reference.reference && reference.reference.start_with?('#')
        contained.each do |resource|
          return true if FHIR.is_any_version?(resource, 'Medication') && reference.reference[1..-1]==resource.id
        end
      end
      record.entry.each do |entry|
        if FHIR.is_any_version?(entry.resource, 'Medication') && reference_matchs?(reference,entry)
          return true
        end
      end
      false    
    end

    def self.reference_matchs?(reference,entry)
      if reference.reference.start_with?('urn:uuid:')
        (reference.reference == entry.fullUrl)
      elsif reference.reference.include?('Medication/')
        (reference.reference.split('Medication/').last.split('/').first == entry.id)
      else 
        false # unable to verify reference points to CVX
      end
    end

  end
end
