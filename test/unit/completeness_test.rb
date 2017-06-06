require_relative '../test_helper'

class CompletenessTest < Minitest::Test

  # turn off the ridiculous warnings
  $VERBOSE=nil

  def test_empty_record_stu3
    patient = FHIR::Patient.new
    bundle = FHIR::Bundle.new({ 'entry'=>[ { 'resource' => patient.to_hash } ] })
    scorecard = FHIR::Scorecard.new
    report = scorecard.score(bundle)
    assert_sections_exist(report, :points, :bundle, :patient, :completeness)
    # expected points = 0, because they have no required or expected elements
    assert_equal(0, report[:completeness][:points], "Completeness section points incorrect.")
  end

  def test_1_required_stu3
    patient = FHIR::Patient.new
    condition = FHIR::Condition.new('code' => { 'coding' => { 'code' => '254230001', 'system'=> 'http://snomed.info/sct' } })
    bundle = FHIR::Bundle.new({ 'entry'=>[ { 'resource' => patient.to_hash }, { 'resource' => condition.to_hash } ] })
    scorecard = FHIR::Scorecard.new
    report = scorecard.score(bundle)
    assert_sections_exist(report, :points, :bundle, :patient, :completeness)
    # expected points = 2 because 1/7 * 20 gets truncated to 2
    assert_equal(2, report[:completeness][:points], "Completeness section points incorrect.")
  end

  def test_1_expected_stu3
    patient = FHIR::Patient.new
    vis_pres = FHIR::VisionPrescription.new
    appt = FHIR::Appointment.new( 'status' => 'fulfilled' )
    device = FHIR::DeviceUseStatement.new( 'status' => 'active' )
    bundle = FHIR::Bundle.new({ 'entry'=>[ { 'resource' => patient.to_hash }, 
                                           { 'resource' => appt.to_hash },
                                           { 'resource' => device.to_hash },
                                           { 'resource' => vis_pres.to_hash }, # intentionally including the VisionPrescription twice
                                           { 'resource' => vis_pres.to_hash }, ] }) 
    scorecard = FHIR::Scorecard.new
    report = scorecard.score(bundle)
    assert_sections_exist(report, :points, :bundle, :patient, :completeness)
    # expected points = 1 because 3 present of 11 expected * 5.0 points... 3/11 * 5 gets truncated to 1
    assert_equal(1, report[:completeness][:points], "Completeness section points incorrect.")
  end

  def test_medication_stu3
    patient = FHIR::Patient.new
    med_order = FHIR::MedicationRequest.new('medicationCodeableConcept' => { 'coding' => { 'code'=>'161', 'system'=> 'http://www.nlm.nih.gov/research/umls/rxnorm'}})
    bundle = FHIR::Bundle.new({ 'entry'=>[ { 'resource' => patient.to_hash }, { 'resource' => med_order.to_hash } ] })
    scorecard = FHIR::Scorecard.new
    report = scorecard.score(bundle)
    assert_sections_exist(report, :points, :bundle, :patient, :completeness)
    # expected points = 2 because 1/7 * 20 gets truncated to 2
    assert_equal(2, report[:completeness][:points], "Completeness section points incorrect.")    
  end

  def test_empty_record_dstu2
    patient = FHIR::DSTU2::Patient.new( 'active' => true )
    bundle = FHIR::DSTU2::Bundle.new({ 'entry'=>[ { 'resource' => patient.to_hash } ] })
    scorecard = FHIR::Scorecard.new
    report = scorecard.score(bundle)
    assert_sections_exist(report, :points, :bundle, :patient, :completeness)
    # expected points = 0, because they have no required or expected elements
    assert_equal(0, report[:completeness][:points], "Completeness section points incorrect.")
  end

  def test_1_required_dstu2
    patient = FHIR::DSTU2::Patient.new( 'active' => true )
    condition = FHIR::DSTU2::Condition.new('code' => { 'coding' => { 'code' => '254230001', 'system'=> 'http://snomed.info/sct' } })
    bundle = FHIR::DSTU2::Bundle.new({ 'entry'=>[ { 'resource' => patient.to_hash }, { 'resource' => condition.to_hash } ] })
    scorecard = FHIR::Scorecard.new
    report = scorecard.score(bundle)
    assert_sections_exist(report, :points, :bundle, :patient, :completeness)
    # expected points = 2 because 1/7 * 20 gets truncated to 2
    assert_equal(2, report[:completeness][:points], "Completeness section points incorrect.")
  end

  def test_1_expected_dstu2
    patient = FHIR::DSTU2::Patient.new( 'active' => true )
    vis_pres = FHIR::DSTU2::VisionPrescription.new( 'dateWritten' => '2017-01-01')
    appt = FHIR::DSTU2::Appointment.new( 'status' => 'fulfilled' )
    device = FHIR::DSTU2::DeviceUseStatement.new( 'recordedOn' => '2017-01-01')
    bundle = FHIR::DSTU2::Bundle.new({ 'entry'=>[ { 'resource' => patient.to_hash }, 
                                           { 'resource' => appt.to_hash },
                                           { 'resource' => device.to_hash },
                                           { 'resource' => vis_pres.to_hash }, # intentionally including the VisionPrescription twice
                                           { 'resource' => vis_pres.to_hash } ] })
    scorecard = FHIR::Scorecard.new
    report = scorecard.score(bundle)
    assert_sections_exist(report, :points, :bundle, :patient, :completeness)
    # expected points = 1 because 3 present of 11 expected * 5.0 points... 3/11 * 5 gets truncated to 1
    assert_equal(1, report[:completeness][:points], "Completeness section points incorrect.")
  end

  def test_medication_dstu2
    patient = FHIR::DSTU2::Patient.new( 'active' => true )
    med_order = FHIR::DSTU2::MedicationOrder.new('medicationCodeableConcept' => { 'coding' => { 'code'=>'161', 'system'=> 'http://www.nlm.nih.gov/research/umls/rxnorm'}})
    bundle = FHIR::DSTU2::Bundle.new({ 'entry'=>[ { 'resource' => patient.to_hash }, { 'resource' => med_order.to_hash } ] })
    scorecard = FHIR::Scorecard.new
    report = scorecard.score(bundle)
    assert_sections_exist(report, :points, :bundle, :patient, :completeness)
    # expected points = 2 because 1/7 * 20 gets truncated to 2
    assert_equal(2, report[:completeness][:points], "Completeness section points incorrect.")    
  end

  def assert_sections_exist(report, *sections)
    sections.each do |section|
      assert(report[section], "Scorecard should report #{section} section.")
    end
  end
end
