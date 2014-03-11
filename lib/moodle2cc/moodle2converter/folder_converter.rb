module Moodle2CC::Moodle2Converter
  class FolderConverter

    def initialize(moodle_course)
      @moodle_course = moodle_course
    end

    def convert(moodle_folder)
      canvas_page = Moodle2CC::CanvasCC::Model::Page.new
      canvas_page.identifier = "folder-#{moodle_folder.id}"
      canvas_page.page_name = moodle_folder.name
      canvas_page.workflow_state = 'active'
      canvas_page.editing_roles = 'teachers'
      canvas_page.body = generate_body(moodle_folder)
      canvas_page
    end

    private

    def parse_files_from_course(moodle_folder)
      @moodle_course.files.select { |f| moodle_folder.file_ids.include? f.id }
    end

    def generate_body(moodle_folder)
      files = sort_files(parse_files_from_course(moodle_folder))
      html = "<ul>\n"
      files.each do |f|
        link = "<a href=\"%24IMS_CC_FILEBASE%24/#{f.file_name}\">#{f.file_path[1..-1]}#{f.file_name}</a>"
        html += "<li><p>#{link}</p></li>\n"
      end
      html += "</ul>\n"
      html.strip
    end

    def sort_files(files)
      files.sort do |a, b|
        a_depth = a.file_path.scan(/\//).count
        b_depth = b.file_path.scan(/\//).count
        if a_depth == b_depth
          "#{a.file_path[1..-1]}#{a.file_name}" <=> "#{b.file_path[1..-1]}#{b.file_name}"
        else
          a_depth <=> b_depth
        end
      end
    end

  end
end