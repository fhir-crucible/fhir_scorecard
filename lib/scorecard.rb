module FHIR
  class Scorecard

    attr_accessor :report
    attr_accessor :points

    def score(bundle, version = 'STU3')
      @report = {}
      @points = 0

      # first check if a bundle object was passed in
      if bundle.is_a?(FHIR::Bundle)
        @bundle_class = FHIR::Bundle
        @patient_class = FHIR::Patient

      elsif bundle.is_a?(FHIR::DSTU2::Bundle)
        @bundle_class = FHIR::DSTU2::Bundle
        @patient_class = FHIR::DSTU2::Patient

      elsif version == 'STU3' # if not passed a bundle object, consider the version
        bundle = FHIR.from_contents(bundle)

        @bundle_class = FHIR::Bundle
        @patient_class = FHIR::Patient
      elsif version == 'DSTU2'
        bundle = FHIR::DSTU2.from_contents(bundle)

        @bundle_class = FHIR::DSTU2::Bundle
        @patient_class = FHIR::DSTU2::Patient
      else
        raise "Unsupported FHIR version provided: #{version}. Expected 'STU3' or 'DSTU2'."
      end
      
      if bundle.is_a?(@bundle_class)
        @points += 10
        @report[:bundle] = { points: 10, message: 'Patient Record is a FHIR Bundle.' }

        # Check that the patient record contains a FHIR Patient.
        @patient = nil
        count = 0
        bundle.entry.each do |entry|
          if entry.resource && entry.resource.is_a?(@patient_class)
            @patient = entry.resource
            count += 1
          end
        end
        if @patient && count==1
          @points += 10
          @report[:patient] = { points: 10, message: 'Patient Record contains one FHIR Patient.' }
        else
          @report[:patient] = { points: 0, message: 'Patient Record must contain one FHIR Patient.' }
        end

        report.merge!(FHIR::Rubrics.apply(bundle))

      else
        @report[:bundle] = { points: 0, message: 'Patient Record must be a FHIR Bundle.' }
      end

      @report[:points] = @report.values.inject(0){ |sum,section| sum += section[:points] }
      @report
    end


    def enable_us_core
      FHIR::Rubrics.enable(:us_core)
    end

    def enable_shr
      FHIR::Rubrics.enable(:standard_health_record)
    end
  end
end
