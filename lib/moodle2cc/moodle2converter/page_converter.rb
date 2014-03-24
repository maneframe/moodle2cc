module Moodle2CC::Moodle2Converter
  class PageConverter
    include ConverterHelper

    def convert(moodle_page)
      canvas_page = Moodle2CC::CanvasCC::Models::Page.new
      canvas_page.identifier = generate_unique_identifier_for(moodle_page.id) + PAGE_SUFFIX
      canvas_page.page_name = moodle_page.name
      canvas_page.workflow_state = Moodle2CC::CanvasCC::Models::WorkflowState::ACTIVE
      canvas_page.editing_roles = 'teachers'
      canvas_page.body = moodle_page.content
      canvas_page
    end

  end
end