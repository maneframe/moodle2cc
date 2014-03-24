require 'spec_helper'

module Moodle2CC::Moodle2Converter::QuestionConverters
  describe TrueFalseConverter do

    it 'converts truefalse questions' do
      moodle_question = Moodle2CC::Moodle2::Models::Quizzes::Question.create('truefalse')
      moodle_question.id = 'something'

      true_answer = Moodle2CC::Moodle2::Models::Quizzes::Answer.new
      true_answer.id = 'tr00'
      false_answer = Moodle2CC::Moodle2::Models::Quizzes::Answer.new
      false_answer.id = 'furse'
      moodle_question.answers = [true_answer, false_answer]
      moodle_question.true_answer = true_answer.id
      moodle_question.false_answer = false_answer.id

      converted_question = QuestionConverter.new.convert(moodle_question)

      expect(converted_question.identifier).to eq moodle_question.id
      expect(converted_question.answers.detect{|a| a.id == true_answer.id}.fraction).to eq 1.0
      expect(converted_question.answers.detect{|a| a.id == false_answer.id}.fraction).to eq 0.0
    end

  end
end