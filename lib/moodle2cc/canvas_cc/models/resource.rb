module Moodle2CC::CanvasCC::Models
  class Resource

    WEB_CONTENT_TYPE = 'webcontent'

    attr_accessor :files, :href, :type, :dependencies, :identifier

    def initialize
      @files = []
      @dependencies = []
      @ident_postfix = ''
    end

    def attributes
      {
        href: href,
        type: type,
        identifier: identifier
      }.delete_if { |_, v| v.nil? }
    end

  end
end