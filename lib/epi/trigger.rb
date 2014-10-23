module Epi
  class Trigger

    attr_reader :job, :args

    def initialize(job, *args)
      @job = job
      @args = args
    end

    class JobTrigger < self; end
    class ProcessTrigger < self; end

  end
end

Dir[File.expand_path '../triggers/concerns/*.rb', __FILE__].each { |f| require f }
Dir[File.expand_path '../triggers/*.rb', __FILE__].each { |f| require f }
