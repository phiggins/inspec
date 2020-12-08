require "inspec/globals"

module InspecPlugins
  module Compliance
    # stores configuration on local filesystem
    class Configuration
      def initialize
        @config_path = File.join(Inspec.config_dir, "compliance")
        # ensure the directory is available
        unless File.directory?(@config_path)
          FileUtils.mkdir_p(@config_path)
        end
        # set config file path
        @config_file = File.join(@config_path, "/config.json")
        @config = {}

        # load the data
        get
      end

      # direct access to config
      def [](key)
        @config[key]
      end

      def []=(key, value)
        @config[key] = value
      end

      def key?(key)
        @config.key?(key)
      end

      def clean
        @config = {}
      end

      # return the json data
      def get
        if File.exist?(@config_file)
          file = File.read(@config_file)
          @config = JSON.parse(file)
        end
        @config
      end

      # stores a hash to json
      def store
        File.open(@config_file, "w") do |f|
          f.chmod(0600)
          f.write(@config.to_json)
        end
      end

      # deletes data
      def destroy
        if File.exist?(@config_file)
          File.delete(@config_file)
        else
          true
        end
      end

      # return if the (stored) api version supports a certain feature
      def supported?(feature)
        sup = version_with_support(feature)

        # we do not know the version, therefore we do not know if its possible to use the feature
        return if self["version"].nil? || self["version"]["version"].nil?

        Gem::Version.new(self["version"]["version"]) >= sup
      end

      private

      # for a feature, returns:
      #  - a version v0:                      v supports v0       iff v0 <= v
      def version_with_support(feature)
        case feature.to_sym
        when :oidc
          Gem::Version.new("0.16.19")
        else
          Gem::Version.new("0.0.0")
        end
      end
    end
  end
end
