module Moodle2CC::CanvasCC
  module FormatHelper
    def generate_unique_resource_path(base_path, readable_name = nil, file_extension = nil)
      file_name_suffix = readable_name ? '-' + readable_name.downcase.gsub(/\s/, '-') : ''
      ext = file_extension ? ".#{file_extension}" : ''
      File.join(base_path, "#{generate_unique_identifier}#{file_name_suffix}#{ext}")
    end

    def generate_unique_identifier
      "CC-" + SecureRandom.uuid
    end
  end
end
