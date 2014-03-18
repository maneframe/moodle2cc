module Moodle2CC::Moodle2::Parsers
  class AssignmentParser
    include ParserHelper

    ASSIGNMENT_XML = 'assign.xml'
    ASSIGNMENT_MODULE_NAME = 'assign'

    def initialize(backup_dir)
      @backup_dir = backup_dir
    end

    def parse
      activity_dirs = activity_directories(@backup_dir, ASSIGNMENT_MODULE_NAME)
      activity_dirs.map { |dir| parse_assignment(dir) }
    end

    private

    def parse_assignment(dir)
      assignment = Moodle2CC::Moodle2::Models::Assignment.new
      File.open(File.join(@backup_dir, dir, ASSIGNMENT_XML)) do |f|
        xml = Nokogiri::XML(f)
        assignment.id = xml.at_xpath('/activity/assign/@id').value
        assignment.module_id = xml.at_xpath('/activity/@moduleid').value
        assignment.name = parse_text(xml, '/activity/assign/name')
        assignment.intro = parse_text(xml, '/activity/assign/intro')
        assignment.intro_format = parse_text(xml, '/activity/assign/introformat')
        assignment.always_show_description = parse_text(xml, '/activity/assign/alwaysshowdescription')
        assignment.submission_drafts = parse_text(xml, '/activity/assign/submissiondrafts')
        assignment.send_notifications = parse_text(xml, '/activity/assign/sendnotifications')
        assignment.send_late_notifications = parse_text(xml, '/activity/assign/sendlatenotifications')
        assignment.due_date = parse_text(xml, '/activity/assign/duedate')
        assignment.cut_off_date = parse_text(xml, '/activity/assign/cutoffdate')
        assignment.allow_submissions_from_date = parse_text(xml, '/activity/assign/allowsubmissionsfromdate')
        assignment.grade = parse_text(xml, '/activity/assign/grade')
        assignment.time_modified = parse_text(xml, '/activity/assign/timemodified')
        assignment.completion_submit = parse_text(xml, '/activity/assign/completionsubmit')
        assignment.require_submission_statement = parse_text(xml, '/activity/assign/requiresubmissionstatement')
        assignment.team_submission = parse_text(xml, '/activity/assign/teamsubmission')
        assignment.require_all_team_members_submit = parse_text(xml, '/activity/assign/requireallteammemberssubmit')
        assignment.team_submission_grouping_id = parse_text(xml, '/activity/assign/teamsubmissiongroupingid')
        assignment.blind_marking = parse_text(xml, '/activity/assign/blindmarking')
        assignment.reveal_identities = parse_text(xml, '/activity/assign/revealidentities')
        plugins = xml.at_xpath('/activity/assign/plugin_configs')
        assignment.online_text_submission = parse_text(plugins, 'plugin_config[(plugin="onlinetext" and subtype="assignsubmission" and name="enabled")]/value', true)
        assignment.file_submission = parse_text(plugins, 'plugin_config[(plugin="file" and subtype="assignsubmission" and name="enabled")]/value', true)
        assignment.max_files_submission = parse_text(plugins, 'plugin_config[(plugin="file" and subtype="assignsubmission" and name="maxfilesubmissions")]/value', true)
        assignment.max_file_size_submission = parse_text(plugins, 'plugin_config[(plugin="file" and subtype="assignsubmission" and name="maxsubmissionsizebytes")]/value', true)
        assignment.submission_comments = parse_text(plugins, 'plugin_config[(plugin="comments" and subtype="assignsubmission" and name="enabled")]/value', true)
        assignment.feedback_comments = parse_text(plugins, 'plugin_config[(plugin="comments" and subtype="assignfeedback" and name="enabled")]/value', true)
        assignment.feedback_files = parse_text(plugins, 'plugin_config[(plugin="file" and subtype="assignfeedback" and name="enabled")]/value', true)
        assignment.offline_grading_worksheet = parse_text(plugins, 'plugin_config[(plugin="offline" and subtype="assignfeedback" and name="enabled")]/value', true)
      end
      assignment
    end

  end
end