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
        report[:bundle] = { :points=>10, :message=>'Patient Record is a FHIR Bundle.'}
      else
        report[:bundle] = { :points=>0, :message=>'Patient Record must be a FHIR Bundle.'}
      end

      # Check that the patient record contains a FHIR Patient.
      if bundle.is_a?(FHIR::Bundle)
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
          report[:patient] = { :points=>10, :message=>'Patient Record contains one FHIR Patient.'}
        else
          report[:patient] = { :points=>0, :message=>'Patient Record must contain one FHIR Patient.'}
        end
      end

      @report[:points] = @points
      @report
    end

  end
end