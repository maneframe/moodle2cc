require 'spec_helper'

module Moodle2CC::CanvasCC::Model
  describe WebContent do
    it_behaves_like 'it has an attribute for', :body
  end
end