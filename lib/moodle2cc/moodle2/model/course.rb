class Moodle2CC::Moodle2::Model::Course
  attr_accessor :id_number, :fullname, :shortname, :startdate, :summary, :course_id, :sections

  def initialize
    @sections = []
  end

end