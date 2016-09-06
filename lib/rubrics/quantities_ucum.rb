module FHIR
  class QuantitiesUcum < FHIR::Rubrics

    IGNORE = [
      'TestScript','Task','StructureDefinition','SearchParameter','Questionnaire','QuestionnaireResponse','Parameters','OperationDefinition',
      'Group','ExplanationOfBenefit','Contract','Conformance','Claim','ActivityDefinition'
    ]

    CHECK = [
      'VisionPrescription','SupplyDelivery','Substance','Specimen','Sequence','Observation','NutritionRequest',
      'MedicationStatement','MedicationOrder','MedicationDispense','MedicationAdministration','Medication','Immunization','CarePlan'
    ]

    # Physical quantities should use UCUM
    rubric :ucum_quantities do |record|
      results = {
        :eligible_fields => 0,
        :validated_fields => 0
      }
      resources = record.entry.map{|e|e.resource}
      resources.each do |resource|
        results.merge!(check_fields(resource)){|k,a,b|a+b} if CHECK.include?(resource.resourceType)
      end

      percentage = results[:validated_fields].to_f / results[:eligible_fields].to_f
      percentage = 0.0 if percentage.nan?
      points = 10.0 * percentage
      message = "#{(100 * percentage).to_i}% (#{results[:validated_fields]}/#{results[:eligible_fields]}) of physical quantities used or declared UCUM. Maximum of 10 points."
      response(points.to_i,message)
    end

    def self.check_fields(fhir_model)
      results = {
        :eligible_fields => 0,
        :validated_fields => 0
      }
      # check each codeable field
      fhir_model.class::METADATA.each do |key, meta|
        field_name = meta['local_name'] || key
        value = fhir_model.instance_variable_get("@#{field_name}")

        if meta['type']=='Quantity'
          if value.is_a?(Array)
            value.each do |v| 
              results.merge!(check_quantity(v)){|k,a,b|a+b}            
            end
          else
            results.merge!(check_quantity(value)){|k,a,b|a+b}
          end
        end
      end
      results
    end

    # This method checks whether or not the quantity uses UCUM.
    def self.check_quantity(quantity)
      result = {
        :eligible_fields => 1,
        :validated_fields => 0
      } 
      if quantity && quantity.system && quantity.system.start_with?('http://unitsofmeasure.org')
        result[:validated_fields] +=1 
      elsif quantity && quantity.unit 
        result[:validated_fields] +=1 if FHIR::Terminology.is_known_ucum?(quantity.unit)        
      end
      result
    end
  end
end
