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

        print "Initialize called"
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
        print "Store! called"
        # style/file type?
        print uploader.model.uuid
        ds = fedora_object.datastreams[sanitized_file.filename]
        print "Created filestream"
        ds.controlGroup = 'M'
        ds.file = ::File.new sanitized_file.file, 'r'
        print "Creating Label"
        ds.dsLabel = "Uploaded file: #{sanitized_file.extension}"
        print "Label created"
        ds.save
        print "ds SAVED"
      end

      def identifier
        uploader.filename
      end

      def retrieve!(identifier)
        print "Get that file"
        ds = fedora_object.datastreams[identifier]
        file = Tempfile.new(identifier, 'w')
        file.binmode
        file.write(ds.read)
        file.rewind
        file
      end


      def fedora
        print "Building Fedora connection"
        @@repo ||= Rubydora.connect url: @server_url, user: @username, password: @password 
        p @@repo
        print "Connection Built"
        @@repo
      end

      def fedora_object
        print "Finding/Creating object - First making the connection"
        @object_id = uploader.model.uuid
        object = fedora.find(@object_id)
        saved_object = object.save
        p saved_object
        print "Object found/created"
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
      #   FileUtils.cp(::File.dirname(__FILE__) + "/../config/fedora.yml", config_file) unless config?
      # end

      def config_file
        print 'config file beg'
        save= Rails.root.join("config", "fedora.yml").to_s
        print 'config file end'
        save
      end
      
      def config?
        ::File.file? config_file
      end

      private
      def parse_config config
        print "Parse this s**this!"
        config = find_credentials(config).stringify_keys
        config_junk = (config[Rails.env] || config).symbolize_keys
        print 'Parse this shit END'
        config_junk
      end

      def find_credentials config
        print 'printing out config'
        p config
        print "find cred BEG"
        case config
          when ::File
            rtn = YAML.load_file(config.path)
          when String
            rtn = YAML.load_file(config)
          when Hash
            rtn = config
          else
            raise ArgumentError, "Configuration settings are not a path, file, or hash."
        end
        print "find cred END"

        rtn
      end
    end
  end
end

