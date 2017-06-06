module FHIR
  class Completeness < FHIR::Rubrics

    REQUIRED = [
      'AllergyIntolerance','Condition','CarePlan','Immunization',
      'Observation','Encounter'
    ]

    EXPECTED = [ 
      'FamilyMemberHistory','DiagnosticReport','ImagingStudy','VisionPrescription',
      'Practitioner','Organization','Communication','Appointment','DeviceUseStatement',
      'QuestionnaireResponse','Coverage'
    ]

    COMMON_MEDICATIONS = [ 'MedicationStatement','MedicationDispense','MedicationAdministration']

    DSTU2_MEDICATIONS = COMMON_MEDICATIONS + ['MedicationOrder']

    STU3_MEDICATIONS = COMMON_MEDICATIONS + ['MedicationRequest']

    # A Patient Record is not complete without certain required items and medications.
    rubric :completeness do |record|
      
      curr_version_meds = record.is_a?(FHIR::Model) ? STU3_MEDICATIONS : DSTU2_MEDICATIONS

      missing_required = REQUIRED.clone
      missing_expected = EXPECTED.clone
      missing_meds = curr_version_meds.clone

      resources = record.entry.map{|e|e.resource}
      resources.each do |resource|
        if !resource.nil?
          missing_required.delete(resource.resourceType)
          missing_expected.delete(resource.resourceType)
          missing_meds.delete(resource.resourceType)
        end
      end

      # 15 points for required resources
      numerator = (REQUIRED.length.to_f - missing_required.length.to_f)
      numerator += 1 if (missing_meds.length < curr_version_meds.length)
      denominator = REQUIRED.length.to_f + 1.0 # add one for medications
      percentage_required = (  numerator / denominator )
      percentage_required = 0.0 if percentage_required.nan?
      points = 20.0 * percentage_required

      # 5 points for expected resources
      numerator = (EXPECTED.length.to_f - missing_expected.length.to_f)
      denominator = EXPECTED.length.to_f
      percentage_expected = (  numerator / denominator )
      percentage_expected = 0.0 if percentage_expected.nan?
      points += (5.0 * percentage_expected)    

      message = "#{(100 * percentage_required).to_i}% of REQUIRED Resources and #{(100 * percentage_expected).to_i}% of EXPECTED Resources were present. Maximum of 20 points."
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
