# encoding: utf-8

require 'spec_helper'

class FedoraSpecUploader < CarrierWave::Uploader::Base
  storage :fedora
end

describe CarrierWave::Storage::Fedora do
  
  describe '#store!' do
    before do
      #Create connection/object
    end

    it 'should have a Rubdora connection'

    it 'should upload the file to the object datastream'

  end

end
