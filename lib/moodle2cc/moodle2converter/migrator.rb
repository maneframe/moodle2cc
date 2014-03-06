module Moodle2CC::Moodle2Converter
  class Migrator

    def initialize(source_file, output_dir)
      @extractor = Moodle2CC::Moodle2::Extractor.new(source_file)
      @output_dir = output_dir
    end

    def migrate
      @extractor.extract do |moodle_course|
        cc_course = convert_course(moodle_course)
        cc_course.canvas_modules += convert_sections(moodle_course.sections)
        cc_course.files += convert_files(moodle_course.files)
        cc_course.pages += convert_pages(moodle_course.pages)
        cc_course.discussions += convert_discussions(moodle_course.forums)
        cc_course.assignments += convert_assignments(moodle_course.assignments)
        cc_course.pages += convert_folders(moodle_course)
        @path = Moodle2CC::CanvasCC::CartridgeCreator.new(cc_course).create(@output_dir)
      end
      @path
    end

    def imscc_path
      @path
    end

    private

    def convert_course(moodle_course)
      Moodle2CC::Moodle2Converter::CourseConverter.new.convert(moodle_course)
    end

    def convert_sections(sections)
      section_converter = Moodle2CC::Moodle2Converter::SectionConverter.new
      sections.map { |section| section_converter.convert(section) }
    end

    def convert_files(files)
      file_converter = Moodle2CC::Moodle2Converter::FileConverter.new
      files.uniq! {|f| f.content_hash }.map { |file| file_converter.convert(file) }
    end

    def convert_pages(pages)
      page_converter = Moodle2CC::Moodle2Converter::PageConverter.new
      pages.map { |page| page_converter.convert(page) }
    end

    def convert_discussions(discussions)
      discussion_converter = Moodle2CC::Moodle2Converter::DiscussionConverter.new
      discussions.map { |discussion| discussion_converter.convert(discussion) }
    end

    def convert_assignments(assignments)
      assignment_converter = Moodle2CC::Moodle2Converter::AssignmentConverter.new
      assignments.map { |assignment| assignment_converter.convert(assignment) }
    end

    def convert_folders(moodle_course)
      folder_converter = Moodle2CC::Moodle2Converter::FolderConverter.new(moodle_course)
      moodle_course.folders.map { |folder| folder_converter.convert(folder) }
    end

  end
end