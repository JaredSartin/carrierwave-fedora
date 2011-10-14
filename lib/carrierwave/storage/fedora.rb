require "carrierwave-fedora/version"

module CarrierWave
  module Storage
    class Fedora < Abstract

      def print(message)
        puts "*"*100
        puts message
        puts "*"*100
      end

      def initialize(uploader)
        @uploader = uploader

        @fedora_config = parse_config(config_file)
        @host = @fedora_config[:host]
        @port = @fedora_config[:port]
        @context = @fedora_config[:context]
        @username = @fedora_config[:user]
        @password = @fedora_config[:password]
        @server_url = "http\://#{@host}\:#{@port}/#{@context}"
        print "Initialize ended"
      end
      
      def store!(sanitized_file)
        # style/file type?
        ds = new_fedora_object.datastreams[sanitized_file.filename]
        ds.controlGroup = 'M'
        ds.file = ::File.new sanitized_file.file, 'r'
        ds.dsLabel = "Uploaded file: #{sanitized_file.extension}"
        ds.save
      end

      def identifier
        uploader.filename
      end

      def retrieve!(the_identifier)
        print "Get that file #{the_identifier}"
        ds = fedora_object.datastreams[the_identifier]
        file = Tempfile.new(the_identifier)
        file.binmode
        file.puts(ds.read)
        file.rewind
        file
      end


      def fedora
        @@repo ||= Rubydora.connect url: @server_url, user: @username, password: @password 
        @@repo
      end

      def new_fedora_object
        @object_id = uploader.model.uuid
        object = fedora.find(@object_id)
        object.save
        # carrierwave_versions = object.datastreams['carrierwave_versions']
        # if carrierwave_versions.new?
        #   carrierwave_versions.controlGroup = 'M'
        #   carrierwave_versions.dsLabel = "Paperclip styles - Used for deletion tracking"
        #   carrierwave_versions.content = " "
        #   carrierwave_versions.mimeType = "text/plain"
        #   carrierwave_versions.save
        # end
      end

      def fedora_object
        @object_id = uploader.model.uuid
        p @object_id
        object = fedora.find(@object_id)
        
        raise "object not found" if object.new?
        object
      end

      # def setup!
      #   FileUtils.cp(::File.dirname(__FILE__) + "/../config/fedora.yml", config_file) unless config?
      # end

      def config_file
        Rails.root.join("config", "fedora.yml").to_s
      end
      
      def config?
        ::File.file? config_file
      end

      private
      def parse_config config
        config = find_credentials(config).stringify_keys
        (config[Rails.env] || config).symbolize_keys
      end

      def find_credentials config
        case config
          when ::File
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


