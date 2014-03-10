module Moodle2CC::Moodle2::Parsers
  class SectionParser
    include ParserHelper

    SECTION_XML = 'section.xml'

    def initialize(backup_dir)
      @backup_dir = backup_dir
    end

    def parse
      section_directories.each_with_index.map { |section, i| parse_section(section, i) }
    end

    private

    def parse_section(section_dir, i)
      section = Moodle2CC::Moodle2::Models::Section.new
      File.open(File.join(@backup_dir, section_dir, SECTION_XML)) do |f|
        section_xml = Nokogiri::XML(f)
        section.position = i
        section.id = section_xml.%('/section/@id').value
        section.number = parse_text(section_xml, '/section/number')
        section.name = parse_text(section_xml, '/section/name')
        section.summary = parse_text(section_xml, '/section/summary')
        section.summary_format = parse_text(section_xml, 'section/summaryformat')
        section.sequence = parse_text(section_xml, 'section/sequence')
        section.sequence = section.sequence.split(',') if section.sequence
        section.visible = parse_text(section_xml, 'section/visible') == '1' ? true : false
        section.available_from = parse_text(section_xml, 'section/availablefrom')
        section.available_until = parse_text(section_xml, 'section/availableuntil')
        section.show_availability = parse_text(section_xml, 'section/showavailability')
        section.grouping_id = parse_text(section_xml, 'section/groupingid')
      end
      section
    end

    private

    def section_directories
      File.open(File.join(@backup_dir, Moodle2CC::Moodle2::Extractor::MOODLE_BACKUP_XML)) do |f|
        moodle_backup_xml = Nokogiri::XML(f)
        sections = moodle_backup_xml / '/moodle_backup/information/contents/sections/section'
        sections.map { |section| section./('directory').text }
      end
    end
  end
end