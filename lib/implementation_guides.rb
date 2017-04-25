module FHIR
  class ImplementationGuideLookup

    @@resources = File.expand_path './resources', File.dirname(File.absolute_path(__FILE__))
    @@loaded = false

    @@us_core = {}
    @@standard_health_record = {}
    @@shr_indicators = {}

    @@shr_defaults = {
      'Practitioner' => 'http://standardhealthrecord.org/fhir/StructureDefinition/shr-actor-Practitioner',
      'Organization' => 'http://standardhealthrecord.org/fhir/StructureDefinition/shr-actor-Organization',
      'RelatedPerson' => 'http://standardhealthrecord.org/fhir/StructureDefinition/shr-actor-RelatedPerson',
      'AllergyIntolerance' => 'http://standardhealthrecord.org/fhir/StructureDefinition/shr-allergy-AllergyIntolerance',
      'BodySite' => 'http://standardhealthrecord.org/fhir/StructureDefinition/shr-core-BodySite',
      'Patient' => 'http://standardhealthrecord.org/fhir/StructureDefinition/shr-demographics-PersonOfRecord',
      'Coverage' => 'http://standardhealthrecord.org/fhir/StructureDefinition/shr-demographics-HealthInsurance',
      'Device' => 'http://standardhealthrecord.org/fhir/StructureDefinition/shr-device-Device',
      'DeviceUseStatement' => 'http://standardhealthrecord.org/fhir/StructureDefinition/shr-device-DeviceUse',
      'Encounter' => 'http://standardhealthrecord.org/fhir/StructureDefinition/shr-encounter-Encounter',
      'Immunization' => 'http://standardhealthrecord.org/fhir/StructureDefinition/shr-immunization-Immunization',
      'Medication' => 'http://standardhealthrecord.org/fhir/StructureDefinition/shr-medication-Medication',
      'MedicationStatement' => 'http://standardhealthrecord.org/fhir/StructureDefinition/shr-medication-MedicationUse',
      'MedicationRequest' => 'http://standardhealthrecord.org/fhir/StructureDefinition/shr-medication-MedicationPrescription',
      'DiagnosticReport' => 'http://standardhealthrecord.org/fhir/StructureDefinition/shr-observation-Panel',
      'Observation' => 'http://standardhealthrecord.org/fhir/StructureDefinition/shr-observation-Observation',
      'Condition' => 'http://standardhealthrecord.org/fhir/StructureDefinition/shr-problem-Problem',
      'Procedure' => 'http://standardhealthrecord.org/fhir/StructureDefinition/shr-procedure-Procedure'
    }

    def self.guess_shr_profile(resource)
      load_guides
      if resource && !@@shr_indicators.nil? && !@@shr_indicators.empty?
        # if the profile is given, we don't need to guess
        if resource.meta && resource.meta.profile && !resource.meta.profile.empty?
          resource.meta.profile.each do |uri|
            return @@standard_health_record[uri] if @@standard_health_record[uri]
          end
        end
        # if the profile is not named, then we need to guess using some heuristic indicators
        @@shr_indicators.each do |url, data|
          if data['resource'] == resource.resourceType
            indicators = true
            resource_hash = resource.to_hash
            data['fixedValues'].each do |requirement|
              # indicators = false if requirement not met
              steps = requirement['path'].split('.')
              steps.delete(data['resource'])
              actual_values = select(steps, resource_hash)
              expected_value = requirement['value']
              if actual_values.nil? || (actual_values.is_a?(Array) && actual_values.empty?)
                indicators = false
              elsif actual_values.is_a?(Array)
                actual_values.each do |onevalue|
                  if onevalue.is_a?(Hash)
                    if onevalue['coding']
                      actual_code = onevalue['coding'].map{|x|x['code']}
                      expected_code = expected_value['coding'].map{|x|x['code']}
                      any_match = false
                      actual_code.each do |x|
                        any_match = true if expected_code.include?(x)
                      end
                      indicators = false unless any_match
                    else
                      expected_value.each do |key, value|
                        indicators = false unless onevalue[key] == value
                      end
                    end
                  end
                end
              elsif actual_values.is_a?(Hash)
                if actual_values['coding']
                  actual_code = actual_values['coding'].map{|x|x['code']}
                  expected_code = expected_value['coding'].map{|x|x['code']}
                  any_match = false
                  actual_code.each do |x|
                    any_match = true if expected_code.include?(x)
                  end
                  indicators = false unless any_match
                else
                  expected_value.each do |key, value|
                    indicators = false unless actual_values[key] == value
                  end
                end
              elsif actual_values.is_a?(TrueClass) || actual_values.is_a?(FalseClass)
                indicators = false unless actual_values == expected_value
              end
            end
            return @@standard_health_record[uri] if indicators
          end
        end
        # if the heuristics do not help, use a default if possible
        default = @@shr_defaults[resource.resourceType]
        return @@standard_health_record[default] if default
      end
      nil
    end

    def self.select(steps=[], obj)
      return obj if steps.nil? || steps.empty?
      copysteps = steps.clone
      if obj.is_a?(Hash)
        step = copysteps.delete_at(0)
        obj = obj[step]
        select(copysteps, obj)
      elsif obj.is_a?(Array)
        obj.map do |x|
          select(copysteps, x)
        end
      end
    end

    def self.guess_uscore_profile(resource)
      load_guides
       if resource
        # if the profile is given, we don't need to guess
        if resource.meta && resource.meta.profile && !resource.meta.profile.empty?
          resource.meta.profile.each do |uri|
            return @@us_core[uri] if @@us_core[uri]
          end
        end
        # TODO consider VitalSigns/Observations
        # Otherwise, guess the first profile that matches on resource type
        @@us_core.each do |url, thing|
          if thing.is_a?(FHIR::StructureDefinition)
            return thing if thing.type == resource.resourceType
          end
        end
      end
      nil
    end

    def self.lookup(url)
      load_guides
      @@us_core[url] || @@standard_health_record[url] || nil
    end

    def self.load_guides
      if !@@loaded
        begin
          # load all the FHIR resources in the US Core Implementation Guide
          Dir.glob(File.join(@@resources,'us_core','**','*.json')).each do |filename|
            raw = File.open(filename,'r:UTF-8',&:read)
            resource = FHIR.from_contents(raw)
            if resource
              @@us_core[resource.id] = resource if resource.id
              @@us_core[resource.url] = resource if resource.url
            end
          end
        rescue => error
          FHIR.logger.error error
        end

        begin
          # load all the FHIR resources in the Standard Health Record Implementation Guide
          Dir.glob(File.join(@@resources,'standard_health_record','**','*.json')).each do |filename|
            raw = File.open(filename,'r:UTF-8',&:read)
            resource = FHIR.from_contents(raw)
            if resource
              @@standard_health_record[resource.id] = resource if resource.id
              @@standard_health_record[resource.url] = resource if resource.url
            end
          end
        rescue => error
          FHIR.logger.error error
        end

        begin
          # load some indicators to help guess which SHR profile to use
          filename = File.join(@@resources,'profile_indicators.json')
          raw = File.open(filename,'r:UTF-8',&:read)
          @@shr_indicators = JSON.parse(raw)
        rescue => error
          @@shr_indicators = {}
          FHIR.logger.error error
        end        

        @@loaded = true
      end
    end

  end
end
