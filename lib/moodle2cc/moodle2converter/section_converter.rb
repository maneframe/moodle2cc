module Moodle2CC
  class Moodle2Converter::SectionConverter
    include Moodle2Converter::ConverterHelper

    ACTIVITY_CONVERTERS = {
        Moodle2::Models::Book => Moodle2Converter::BookConverter
    }

    def initialize
      @converters ={}
    end

    def convert(moodle_section)
      canvas_module = CanvasCC::Models::CanvasModule.new
      canvas_module.identifier = generate_unique_identifier_for(moodle_section.id, MODULE_SUFFIX)
      canvas_module.title = moodle_section.name
      canvas_module.workflow_state = moodle_section.visible ? CanvasCC::Models::WorkflowState::ACTIVE : CanvasCC::Models::WorkflowState::UNPUBLISHED

      canvas_module.module_items += convert_activity(moodle_section) if moodle_section.summary && !moodle_section.summary.strip.empty?
      canvas_module.module_items += moodle_section.activities.map { |a| convert_activity(a) }
      canvas_module.module_items = canvas_module.module_items.flatten.compact

      canvas_module
    end

    def convert_to_summary_page(moodle_section)
      canvas_page = CanvasCC::Models::Page.new
      canvas_page.identifier = generate_unique_identifier_for_activity(moodle_section)
      canvas_page.title = moodle_section.name
      canvas_page.workflow_state = CanvasCC::Models::WorkflowState::ACTIVE
      canvas_page.editing_roles = CanvasCC::Models::Page::EDITING_ROLE_TEACHER
      canvas_page.body = moodle_section.summary
      canvas_page.href = generate_unique_resource_path(CanvasCC::Models::Page::WIKI_CONTENT, "#{moodle_section.name} summary")

      canvas_page
    end

    def convert_activity(moodle_activity)
      begin
        activity_converter_for(moodle_activity).convert_to_module_items(moodle_activity)
      rescue Exception => e
        puts e.message
      end
    end

    def convert_to_module_items(moodle_activity)
      module_item = CanvasCC::Models::ModuleItem.new
      module_item.identifier = generate_unique_identifier
      module_item.workflow_state = CanvasCC::Models::WorkflowState::ACTIVE
      module_item.title = moodle_activity.name
      module_item.identifierref = generate_unique_identifier_for_activity(moodle_activity) unless moodle_activity.is_a? Moodle2::Models::Label
      module_item.content_type = activity_content_type(moodle_activity)
      module_item.indent = '0'

      [module_item]
    end

    private

    def activity_converter_for(moodle_activity)
      @converters[moodle_activity.class] ||=
        ACTIVITY_CONVERTERS[moodle_activity.class] ? ACTIVITY_CONVERTERS[moodle_activity.class].new : self
    end

  end
end