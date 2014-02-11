require 'minitest/autorun'
require 'moodle2cc'
require 'test_helper'

module CanvasCC
  class CartridgeCreatorTest < MiniTest::Unit::TestCase
    include TestHelper

    class CCFileTest < CartridgeCreatorTest

      def setup
        @tmpdir = Dir.mktmpdir
        course = Moodle2CC::CanvasCC::Model::Course.new
        course.title = 'My Course'
        @cartridge_creator = Moodle2CC::CanvasCC::CartridgeCreator.new(course)
        @ims_generator_mock = MiniTest::Mock.new
        @ims_generator_mock.expect(:generate, 'lorem ipsum')
      end

      def teardown
        FileUtils.rm_r @tmpdir
      end

      def test_zipfile_creation
        Moodle2CC::CanvasCC::ImsManifestGenerator.stub(:new, @ims_generator_mock) do
          imscc_path = @cartridge_creator.create(@tmpdir)
          assert File.exist?(imscc_path)
          Zip::File.open(imscc_path) do |f|
            assert f.find_entry('imsmanifest.xml'), 'imsmanifest.xml should exist'
          end
        end
      end

      def test_filename
        course = MiniTest::Mock.new
        course.expect(:title, 'My Course')
        cartridge_creator = Moodle2CC::CanvasCC::CartridgeCreator.new(course)
        assert_equal(cartridge_creator.filename, 'my_course.imscc')
      end

    end
  end
end