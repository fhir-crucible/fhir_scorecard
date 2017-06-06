module FHIR
  # check whether the given object is an instance of any version of the given resource type
  # if you only care about a single version, don't use this, just use x.is_a?(FHIR::Whatever)
  def self.is_any_version?(object, resource_type)
    # resource type should be a string
    # TODO: maybe expand this to accept a map, ex { dstu2: 'MedicationOrder', stu3: 'MedicationRequest' }

    classnames = ["FHIR::#{resource_type}", "FHIR::DSTU2::#{resource_type}"]

    classnames.any? do |classname|
      klass = Object.const_defined?(classname) && Object.const_get(classname) # get the class for the name
      # note that there may not be a class with that name, in which case const_defined => false
      klass && object.is_a?(klass)
    end
  end

  # shorter version for this one class that is used all over the place
  def self.is_model?(object)
    object.is_a?(FHIR::Model) || object.is_a?(FHIR::DSTU2::Model)
  end
end