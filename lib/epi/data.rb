require 'pathname'
require 'forwardable'

module Epi
  class Data
    include Exceptions

    ROOT_HOME = '/etc/epi'

    class << self
      extend Forwardable

      delegate [:[], :[]=, :read, :write, :root?, :save, :reload, :home] => :default_instance

      %w[daemon_pid].each do |property|
        define_method(property) { read property }
        define_method(property + '=') { |value| write property, value }
      end

      def configuration_paths
        self['configuration_paths'] ||= []
      end

      def jobs
        self['jobs'] ||= {}
      end

      def jobs=(value)
        self['jobs'] = value
      end

      # Get the default data storage instance
      # @return [self]
      def default_instance
        @default_instance ||= new(detect_home_dir)
      end

      # Remove the default instance. Useful if the home path changes.
      def reset!
        @default_instance = nil
      end

      private

      # Try to guess the Epi home directory, by first looking at the
      # `EPI_HOME` environment variable, then '/etc/epi', then '~/.epi'
      # @return [String]
      def detect_home_dir
        custom_home_dir || root_home_dir || user_home_dir
      end

      # The home directory specified in the environment
      # @return [String|NilClass]
      def custom_home_dir
        ENV['EPI_HOME']
      end

      # The root home directory, if it exists or can be created
      # @return [String|NilClass]
      def root_home_dir
        (Epi.root? || Dir.exist?(ROOT_HOME)) && ROOT_HOME
      end

      # The user's home directory
      # @return [String]
      def user_home_dir
        "#{ENV['HOME'] || '~'}/.epi"
      end

    end

    attr_reader :home

    # @param home [String] The directory in which all working files should be stored.
    def initialize(home)
      @home = Pathname home
      prepare_home!
    end

    # Read a file as UTF-8
    # @param file_name [String] Name of the file to read
    # @return [String|NilClass] Contents of the file, or `nil` if the file doesn't exist.
    def read(file_name)
      path = home + file_name
      path.exist? ? path.read : nil
    end

    # Write a file as UTF-8
    # @param file_name [String] Name of the file to write
    # @param data [Object] Data to be written to the file, or `nil` if the file should be deleted.
    def write(file_name, data)
      path = home + file_name
      if data.nil?
        path.delete if path.exist?
        nil
      else
        data = data.to_s
        path.parent.mkpath
        path.write data
        path.chmod 0644
        data.length
      end
    end

    def data_file
      @data_file ||= home + 'data'
    end

    # Force reload of data from disk
    def reload
      @hash = nil
    end

    # Save data to disk
    def save
      data_file.binwrite Marshal.dump hash
      data_file.chmod 0644
    end

    def hash
      @hash ||= data_file.exist? ? Marshal.load(data_file.binread) : {}
    end

    # Returns true if using root data at /etc/epi, or false if using user data
    # is at ~/.epi
    # @return [TrueClass|FalseClass]
    def root?
      @is_root
    end

    def [](key)
      hash[key.to_s]
    end

    def []=(key, value)
      hash[key.to_s] = value
    end

    private

    # Ensures the home directory exists and is readable
    # @raise [Fatal]
    def prepare_home!
      @is_root = @home.to_s == ROOT_HOME
      home.mkpath
      raise Fatal, 'We need write and execute permissions for ' << home.to_s unless
          home.exist? && home.readable? && home.executable?
    end

  end
end
