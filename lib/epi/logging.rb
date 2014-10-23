module Epi

  class << self

    DEFAULT_LEVEL = 'info'

    def logger
      @logger ||= make_logger
    end

    def logger=(value)
      @logger = Logger === value ? value : make_logger(value)
    end

    private

    def make_logger(target = nil)
      Logger.new(target || ENV['EPI_LOG'] || default_log_path).tap do |logger|
        logger.level = log_level
      end
    end

    def default_log_path
      Data.home.join('epi.log').to_s
    end

    def log_level
      Logger::Severity.const_get (ENV['EPI_LOG_LEVEL'] || DEFAULT_LEVEL).upcase
    end

  end

end
