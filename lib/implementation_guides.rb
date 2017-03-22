module FHIR
  class ImplementationGuideLookup

    @@resources = File.expand_path './resources', File.dirname(File.absolute_path(__FILE__))
    @@loaded = false

    @@us_core = {}
    @@standard_health_record = {}
    @@shr_indicators = {}

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
            data['fixedValues'].each do |requirement|
              # indicators = false if requirement not met
              actual_value = FluentPath.evaluate(requirement['path'],resource.to_hash)
              expected_value = requirement['value']
              binding.pry if actual_value!=expected_value
              # TODO this won't work... 
              # - actual value is or should be an array
              # - expected value is or should be an array
              # - data types in actual, primitive JSON in expected
              indicators = false if actual_value!=expected_value
            end
            return @@standard_health_record[uri] if indicators
          end
        end
        # if the heuristics do not help, guess the first profile that matches on resource type
        @@standard_health_record.each do |url, thing|
          if thing.is_a?(FHIR::StructureDefinition)
            return thing if thing.type == resource.resourceType
          end
        end
      end
      nil
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
