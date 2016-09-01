require_relative '../test_helper'

class BasicTest < Minitest::Test

  # turn off the ridiculous warnings
  $VERBOSE=nil

  def test_bundle
    bundle = FHIR::Bundle.new
    scorecard = FHIR::Scorecard.new
    report = scorecard.score(bundle.to_json)
    
    assert (report[:points]), 'Scorecard should report points.'
    assert (report[:bundle]), 'Scorecard should report Bundle section.'
    assert (report[:patient]), 'Scorecard should report Patient section.'
    assert (report[:points]==10), 'Scorecard points incorrect.'
    assert (report[:bundle][:points]), 'Bundle section should report points.'
    assert (report[:bundle][:points]==10), 'Bundle section points incorrect.'
    assert (report[:patient][:points]), 'Patient section should report points.'
    assert (report[:patient][:points]==0), 'Patient section points incorrect.'
  end

  def test_not_bundle
    basic = FHIR::Basic.new
    scorecard = FHIR::Scorecard.new
    report = scorecard.score(basic.to_json)

    assert (report[:points]), 'Scorecard should report points.'
    assert (report[:bundle]), 'Scorecard should report Bundle section.'
    assert (report[:points]==0), 'Scorecard points incorrect.'
    assert (report[:bundle][:points]), 'Bundle section should report points.'
    assert (report[:bundle][:points]==0), 'Bundle section points incorrect.'
  end

  def test_bundle_with_patient
    patient = FHIR::Patient.new
    bundle = FHIR::Bundle.new({'entry'=>[ {} ]})
    bundle.entry.first.resource = patient
    scorecard = FHIR::Scorecard.new
    report = scorecard.score(bundle.to_json)

    assert (report[:points]), 'Scorecard should report points.'
    assert (report[:bundle]), 'Scorecard should report Bundle section.'
    assert (report[:patient]), 'Scorecard should report Patient section.'
    assert (report[:points]==20), 'Scorecard points incorrect.'
    assert (report[:bundle][:points]), 'Bundle section should report points.'
    assert (report[:bundle][:points]==10), 'Bundle section points incorrect.'
    assert (report[:patient][:points]), 'Patient section should report points.'
    assert (report[:patient][:points]==10), 'Patient section points incorrect.'
  end

end