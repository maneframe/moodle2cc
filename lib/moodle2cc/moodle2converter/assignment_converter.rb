module Moodle2CC::Moodle2Converter
  class AssignmentConverter
    include ConverterHelper

    def convert(moodle_assignment, moodle_grading_scales)

      canvas_assignment = Moodle2CC::CanvasCC::Models::Assignment.new
      canvas_assignment.identifier = generate_unique_identifier_for_activity(moodle_assignment)
      canvas_assignment.title = truncate_text(moodle_assignment.name)
      canvas_assignment.body = moodle_assignment.intro
      canvas_assignment.due_at = Time.at(Integer(moodle_assignment.due_date)) if moodle_assignment.due_date
      canvas_assignment.lock_at = Time.at(Integer(moodle_assignment.cut_off_date)) if moodle_assignment.cut_off_date
      canvas_assignment.unlock_at = Time.at(Integer(moodle_assignment.allow_submissions_from_date)) if moodle_assignment.allow_submissions_from_date
      canvas_assignment.workflow_state = workflow_state(moodle_assignment.visible)
      canvas_assignment.external_tool_url = moodle_assignment.external_tool_url
      points = Float(moodle_assignment.grade).to_i
      if points > 0 || scale = moodle_grading_scales[-1 * points] # moodle uses negative numbers for grading scale ids
        if scale && scale.count == 2
          # I'm asssuming that if there's only two choices, that the best way to convert it will probably be pass/fail
          canvas_assignment.grading_type = 'pass_fail'
        else
          canvas_assignment.grading_type = 'points'
          canvas_assignment.points_possible = points
        end
        canvas_assignment.submission_types << 'online_text_entry' if moodle_assignment.online_text_submission == '1'
        canvas_assignment.submission_types << 'online_upload' if moodle_assignment.file_submission == '1'
        canvas_assignment.submission_types << 'external_tool' if moodle_assignment.external_tool_url && moodle_assignment.external_tool_url.length > 0
      else
        canvas_assignment.grading_type = 'not_graded'
        canvas_assignment.submission_types << 'not_graded'
      end

      canvas_assignment
    end
  end
end