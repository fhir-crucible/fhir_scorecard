module FHIR
  class SmokingStatus < FHIR::Rubrics

    SMOKING_CODES = [
      '449868002', #Current every day smoker  
      '428041000124106', #Current some day smoker 
      '8517006', #Former smoker 
      '266919005', #Never smoker  
      '77176002', #Smoker, current status unknown  
      '266927001', #Unknown if ever smoked  
      '428071000124103', #Current Heavy tobacco smoker  
      '428061000124105' #Current Light tobacco smoker
    ]

    # The Patient Record should include Smoking Status
    rubric :smoking_status do |record|
      
      resources = record.entry.map{|e|e.resource}
      has_smoking_status = resources.any? do |resource|
        FHIR.is_any_version?(resource, 'Observation') && smoking_observation?(resource)
      end

      if has_smoking_status
        points = 10
      else
        points = 0
      end

      message = "The Patient Record should include Smoking Status (DAF-core-smokingstatus profile on Observation)."
      response(points.to_i,message)
    end

    def self.smoking_observation?(resource)
      smoking_code?(resource.code) && smoking_value?(resource.valueCodeableConcept)
    end

    def self.smoking_code?(codeableconcept)
      return false if codeableconcept.nil? || codeableconcept.coding.nil?
      codeableconcept.coding.any?{|x| x.system=='http://loinc.org' && x.code=='72166-2'}
    end

    def self.smoking_value?(codeableconcept)
      return false if codeableconcept.nil? || codeableconcept.coding.nil?
      codeableconcept.coding.any?{|x| x.system=='http://snomed.info/sct' && SMOKING_CODES.include?(x.code)}
    end

  end
end
