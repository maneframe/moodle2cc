module Moodle2CC::Moodle
  class Section
    include HappyMapper

    attr_accessor :course

    class Mod
      include HappyMapper

      attr_accessor :section

      tag 'MODS/MOD'

      element :id, Integer, :tag => 'ID'
      element :instance_id, Integer, :tag => 'INSTANCE'

      def instance
        section.course.mods.find { |mod| mod.id == instance_id }
      end
    end

    tag 'SECTIONS/SECTION'
    element :id, Integer, :tag => 'ID'
    element :number, Integer, :tag => 'NUMBER'
    element :summary, String, :tag => 'SUMMARY'
    element :visible, Boolean, :tag => 'VISIBLE'
    has_many :mods, Mod

    after_parse do |section|
      section.mods.each { |mod| mod.section = section }
    end
  end
end