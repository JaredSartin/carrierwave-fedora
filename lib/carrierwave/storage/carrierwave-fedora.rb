require "carrierwave-fedora/version"

module CarrierWave
  module Storage
    class Fedora < Abstract

      def initialize(uploader)
        @fedora_config = parse_config(@options[:fedora_config])
        @host = @fedora_config[:host]
        @port = @fedora_config[:port]
        @context = @fedora_config[:context]
      end
      
      def store!(file)
        # style/file type?
        ds = fedora_object.datastreams["STREAMNAME"]
        ds.controlGroup = 'M'
        ds.file = file
        ds.dsLabel = "Uploaded file: #{File.extname(file)}"
        ds.save
      end

      def retrieve!(identifier) # version/datastream/style)
        # look up Fedora object by identifier
        # open version/datastream on object
      end


      def fedora
        @@repo ||= Rubydora.connect url: @server_url, user: @fedora_config[:user], password: @fedora_config[:password] 
        @@repo
      end

      def fedora_object
        # @object_id = instance.uuid || @custom_pid || path()
        object = fedora.find('carrierwavetest:1')
        saved_object = object.save
        # carrierwave_versions = object.datastreams['carrierwave_versions']
        # if carrierwave_versions.new?
        #   carrierwave_versions.controlGroup = 'M'
        #   carrierwave_versions.dsLabel = "Paperclip styles - Used for deletion tracking"
        #   carrierwave_versions.content = " "
        #   carrierwave_versions.mimeType = "text/plain"
        #   carrierwave_versions.save
        # end
        saved_object
      end


      # def setup!
      #   FileUtils.cp(File.dirname(__FILE__) + "/../config/fedora.yml", config_file) unless config?
      # end

      def config_file
        Rails.root.join("config", "fedora.yml").to_s
      end
      
      def config?
        File.file? config_file
      end

      private
      def parse_config config
        config = find_credentials(config).stringify_keys
        (config[Rails.env] || config).symbolize_keys
      end

      def find_credentials config
        case config
          when File
            YAML.load_file(config.path)
          when String
            YAML.load_file(config)
          when Hash
            config
          else
            raise ArgumentError, "Configuration settings are not a path, file, or hash."
        end
      end
    end
  end
end
