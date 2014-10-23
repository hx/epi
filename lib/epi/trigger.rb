module Epi
  class Trigger

    def self.make(job, name, args, handler)
      klass_name = name.camelize
      klass = Triggers.const_defined?(klass_name) && Triggers.const_get(klass_name)
      raise Exceptions::Fatal, "No trigger exists named #{name}" unless Class === klass && klass < self
      klass.new job, handler, *args
    end

    attr_reader :job, :args

    def initialize(job, handler, *args)
      @job = job
      @handler = handler
      @args = args
    end

    def logger
      Epi.logger
    end

    def message
      nil
    end

    def try
      case self
        when ProcessTrigger then job.running_processes.each_value { |process| try_with process }
        when JobTrigger then try_with nil
        else nil
      end
    end

    def try_with(process)
      args = [process].reject(&:nil?)
      if test *args
        text = "Trigger on job #{job.id}"
        text << " (PID #{process.pid})" if process
        text << ": " << message if message
        logger.info text
        @handler.call process || job
      end
    end

    class JobTrigger < self; end
    class ProcessTrigger < self; end

  end
end

Dir[File.expand_path '../triggers/concerns/*.rb', __FILE__].each { |f| require f }
Dir[File.expand_path '../triggers/*.rb', __FILE__].each { |f| require f }
