module FHIR
  class Scorecard

    attr_accessor :report
    attr_accessor :points

    def score(bundle_raw)
      @report = {}
      @points = 0

      # Check that the patient record is a FHIR Bundle.
      bundle = FHIR.from_contents(bundle_raw)
      if bundle.is_a?(FHIR::Bundle)
        @points += 10
        @report[:bundle] = { :points=>10, :message=>'Patient Record is a FHIR Bundle.'}
      else
        @report[:bundle] = { :points=>0, :message=>'Patient Record must be a FHIR Bundle.'}
      end

      if bundle.is_a?(FHIR::Bundle)

        # Check that the patient record contains a FHIR Patient.
        @patient = nil
        count = 0
        bundle.entry.each do |entry|
          if entry.resource && entry.resource.is_a?(FHIR::Patient)
            @patient = entry.resource
            count += 1
          end
        end
        if @patient && count==1
          @points += 10
          @report[:patient] = { :points=>10, :message=>'Patient Record contains one FHIR Patient.'}
        else
          @report[:patient] = { :points=>0, :message=>'Patient Record must contain one FHIR Patient.'}
        end

        report.merge!(FHIR::Rubrics.apply(bundle))
      end

      @report[:points] = @report.values.inject(0){|sum,section| sum+=section[:points]}
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