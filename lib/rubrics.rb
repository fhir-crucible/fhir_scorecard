module FHIR
  class Rubrics

    @@rubrics = {}

    def self.apply(record)
      report = {}
      @@rubrics.each do |key,rubric| 
        report[key] = rubric.call(record)
      end
      report
    end

    def self.rubric(key,&block)
      @@rubrics[key] = block
    end

    def self.response(points,message)
      {:points=>points,:message=>message}
    end

  end
end
