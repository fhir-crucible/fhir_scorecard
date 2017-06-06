require_relative '../test_helper'

class FHIRHelperTest < Minitest::Test
  def test_is_any_version
    object = FHIR::Patient.new
    assert(FHIR.is_any_version?(object, 'Patient'))
    refute(FHIR.is_any_version?(object, 'Bundle'))

    object = FHIR::DSTU2::Patient.new
    assert(FHIR.is_any_version?(object, 'Patient'))
    refute(FHIR.is_any_version?(object, 'Bundle'))

    object = FHIR::Bundle.new
    assert(FHIR.is_any_version?(object, 'Bundle'))
    refute(FHIR.is_any_version?(object, 'Patient'))

    object = FHIR::DSTU2::Bundle.new
    assert(FHIR.is_any_version?(object, 'Bundle'))
    refute(FHIR.is_any_version?(object, 'Patient'))
    
    object = FHIR::MedicationRequest.new # class only exists in 3, not 2
    assert(FHIR.is_any_version?(object, 'MedicationRequest'))
    refute(FHIR.is_any_version?(object, 'MedicationOrder'))

    object = FHIR::DSTU2::MedicationOrder.new # class only exists in 2, not 3
    assert(FHIR.is_any_version?(object, 'MedicationOrder'))
    refute(FHIR.is_any_version?(object, 'MedicationRequest'))

    refute(FHIR.is_any_version?(object, 'ThisClassDoesNotExistAnywhere'))
  end
end