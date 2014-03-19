module Moodle2CC
  module Moodle2Converter::ConverterHelper
    INTRO_SUFFIX = '_book_intro'
    CHAPTER_SUFFIX = '_chapter'
    FOLDER_SUFFIX = '_folder'
    PAGE_SUFFIX = '_page'
    ASSESSMENT_SUFFIX = '_assessment'
    ASSIGNMENT_SUFFIX = '_assignment'
    COURSE_SUFFIX = '_course'
    DISCUSSION_SUFFIX = '_discussion'
    FILE_SUFFIX = '_file'
    QUESTION_BANK_SUFFIX = '_question_bank'
    MODULE_SUFFIX = '_module'

    ACTIVITY_LOOKUP = {
      Moodle2CC::Moodle2::Models::Page => {suffix: PAGE_SUFFIX, content_type: CanvasCC::Models::ModuleItem::CONTENT_TYPE_WIKI_PAGE},
      Moodle2CC::Moodle2::Models::Assignment => {suffix: ASSIGNMENT_SUFFIX, content_type: CanvasCC::Models::ModuleItem::CONTENT_TYPE_ASSIGNMENT},
      Moodle2CC::Moodle2::Models::Folder => {suffix: FOLDER_SUFFIX, content_type: CanvasCC::Models::ModuleItem::CONTENT_TYPE_WIKI_PAGE},
      Moodle2CC::Moodle2::Models::Forum => {suffix: DISCUSSION_SUFFIX, content_type: CanvasCC::Models::ModuleItem::CONTENT_TYPE_DISCUSSION_TOPIC},
      Moodle2CC::Moodle2::Models::BookChapter => {suffix: CHAPTER_SUFFIX, content_type: CanvasCC::Models::ModuleItem::CONTENT_TYPE_WIKI_PAGE},
      Moodle2CC::Moodle2::Models::Quizzes::Quiz => {suffix: ASSESSMENT_SUFFIX, content_type: CanvasCC::Models::ModuleItem::CONTENT_TYPE_QUIZ}
    }

    def generate_unique_resource_path(base_path, readable_name = nil, file_extension = nil)
      file_name_suffix = readable_name ? '-' + readable_name.downcase.gsub(/\s/, '-') : ''
      ext = file_extension ? ".#{file_extension}" : ''
      File.join(base_path, "#{generate_unique_identifier}#{file_name_suffix}#{ext}")
    end

    def generate_unique_identifier
      "m2#{SecureRandom.uuid.gsub('-', '')}"
    end

    def generate_unique_identifier_for_activity(activity)
      if lookup = ACTIVITY_LOOKUP[activity.class]
        generate_unique_identifier_for(activity.id, lookup[:suffix])
      else
        raise "Unknown activity type: #{activity.class}"
      end
    end

    def generate_unique_identifier_for(id, suffix = nil)
      "m2#{Digest::MD5.hexdigest(id.to_s)}#{suffix}"
    end

    def activity_content_type(activity)
      if lookup = ACTIVITY_LOOKUP[activity.class]
        lookup[:content_type]
      else
        raise "Unknown activity type: #{activity.class}"
      end
    end

  end
end
