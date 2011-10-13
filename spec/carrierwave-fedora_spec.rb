# encoding: utf-8

require 'spec_helper'

class FedoraSpecUploader < CarrierWave::Uploader::Base
  storage :fedora
end
