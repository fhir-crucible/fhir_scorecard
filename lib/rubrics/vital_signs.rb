module FHIR
  class VitalSigns < FHIR::Rubrics

    # http://hl7.org/fhir/2016Sep/observation-vitalsigns.html
    VITAL_SIGNS = {
      # '8716-3' => '', # vital signs group
      '9279-1' => [], #'/min', # respitory rate
      '8867-4' => [], #'/min', # heart rate
      '59408-5' => [], #'%', # Oxygen saturation  
      '8310-5' => [], #'Cel', # Body temperature
      '8302-2' => [], #'cm', # Body height
      '9843-4' => [], #'cm', # Head circumference
      '29463-7' => [], #'kg', # Body weight
      '39156-5' => [], #'kg/m2', # Body mass index 
      '55284-4' => ['8480-6','8462-4'] # Blood pressure systolic and diastolic group
      # '8480-6' => 'mm[Hg]', # Systolic blood pressure
      # '8462-4' => 'mm[Hg]', # Diastolic blood pressure
      # '8478-0' => 'mm[Hg]' # Mean blood pressure  
    }

    # Vital Signs should be present with specific LOINC codes
    rubric :vital_signs do |record|
      
      NOT_FOUND = VITAL_SIGNS.clone

      resources = record.entry.map{|e|e.resource}
      resources.each do |resource|
        if resource.is_a?(FHIR::Observation)
          found_code = get_vital_code(resource.code)
          components = NOT_FOUND[ found_code ]
          if components.nil?
            components = []
          else
            components = components.clone
          end
          if components.empty?
            NOT_FOUND.delete(found_code)
          elsif resource.component
            resource.component.each do |component|
              sub_code = get_vital_code(component.code)
              components.delete(sub_code)         
            end
            NOT_FOUND.delete(found_code) if components.empty?
          end
        end
      end

      percentage = ( (VITAL_SIGNS.length.to_f - NOT_FOUND.length.to_f) / (VITAL_SIGNS.length.to_f) )
      percentage = 0.0 if percentage.nan?
      points = 10.0 * percentage
      message = "#{(100 * percentage).to_i}% (#{VITAL_SIGNS.length - NOT_FOUND.length}/#{VITAL_SIGNS.length}) of Vital Signs had at least one recorded Observation. Maximum of 10 points."
      response(points.to_i,message)
    end

    def self.get_vital_code(codeableconcept)
      return nil if codeableconcept.nil? || codeableconcept.coding.nil?

      coding = codeableconcept.coding.find{|x| x.system=='http://loinc.org' && VITAL_SIGNS.has_key?(x.code)}
      code = coding.code if coding
      code
    end

  end
end
