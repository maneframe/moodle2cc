module Moodle2CC::CanvasCC
  class FileMetaWriter

    FILE_META_FILE = 'files_meta.xml'

    def initialize(work_dir, *canvas_files)
      @work_dir = work_dir
      @canvas_files = canvas_files
    end

    def write
      copy_files
      write_xml
    end

    private

    def copy_files

      @canvas_files.each do |canvas_file|
        FileUtils.mkdir_p(File.dirname(File.join(@work_dir, canvas_file.href)))
        FileUtils.cp(canvas_file.file_location, File.join(@work_dir, canvas_file.href))
      end
    end

    def write_xml
      xml = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
        xml.fileMeta(
          'xmlns' => 'http://canvas.instructure.com/xsd/cccv1p0',
          'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
          'xsi:schemaLocation' => 'http://canvas.instructure.com/xsd/cccv1p0 http://canvas.instructure.com/xsd/cccv1p0.xsd'
        )
      end.to_xml
      File.open(File.join(@work_dir, Moodle2CC::CanvasCC::CartridgeCreator::COURSE_SETTINGS_DIR, FILE_META_FILE), 'w') { |f| f.write(xml) }
    end

  end
end