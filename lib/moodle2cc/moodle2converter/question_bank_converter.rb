module Moodle2CC::Moodle2Converter
  class QuestionBankConverter
    def convert(moodle_category)
      canvas_bank = Moodle2CC::CanvasCC::Model::QuestionBank.new

      canvas_bank.identifier = moodle_category.id
      canvas_bank.title = moodle_category.name

      question_converter = Moodle2CC::Moodle2Converter::QuestionConverters::QuestionConverter.new
      moodle_category.questions.each do |moodle_question|
        canvas_bank.questions << question_converter.convert(moodle_question)
      end

      canvas_bank
    end
  end
end