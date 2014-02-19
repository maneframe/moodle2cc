require 'minitest/autorun'
require 'moodle2cc'
require 'test_helper'

module Moodle2
  class ExtractorTest < MiniTest::Unit::TestCase
    include TestHelper

    # Do nothing
    def setup
      @extractor = Moodle2CC::Moodle2::Extractor.new('path_to_zip')
    end

    # Do nothing
    def teardown

    end

    def test_course_parsing
      course_parser_mock do
        section_parser_mock do |section|
          @extractor.stub(:extract_zip, nil) do
            extracted_course = @extractor.extract
            assert_equal(extracted_course.id_number, 'id_number')
            assert_equal(1, extracted_course.sections.count)
          end
        end
      end
    end

  private

  def course_parser_mock
    course = Moodle2CC::Moodle2::Model::Course.new
    course.id_number = 'id_number'
    course_parser_mock = MiniTest::Mock.new
    course_parser_mock.expect(:parse, course)
    Moodle2CC::Moodle2::CourseParser.stub(:new, course_parser_mock) do
      yield course
    end
  end

  def section_parser_mock
    section = Moodle2CC::Moodle2::Model::Section.new
    section_parser_mock = MiniTest::Mock.new
    section_parser_mock.expect(:parse, [section])
    Moodle2CC::Moodle2::SectionParser.stub(:new, section_parser_mock) do
      yield section
    end
  end

end
end