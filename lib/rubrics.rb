module FHIR
  class Rubrics

    @@disabled = [:us_core, :standard_health_record]
    @@rubrics = {}

    def self.apply(record)
      report = {}
      @@rubrics.each do |key,rubric| 
        report[key] = rubric.call(record) unless @@disabled.include?(key)
      end
      report
    end

    def self.rubric(key,&block)
      @@rubrics[key] = block
    end

    def self.response(points,message)
      {:points=>points,:message=>message}
    end

    def self.enable(rubric)
      @@disabled.delete(rubric)
    end

    def self.disable(rubric)
      @@disabled << rubric unless @@disabled.include?(rubric)
    end

  end
end
