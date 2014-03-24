require 'spec_helper'

module Moodle2CC::CanvasCC
  describe QuestionBankWriter do
    subject { Moodle2CC::CanvasCC::QuestionBankWriter.new(work_dir, question_bank) }
    let(:work_dir) { Dir.mktmpdir }
    let(:question_bank) { Moodle2CC::CanvasCC::Models::QuestionBank.new }

    after(:each) do
      FileUtils.rm_r work_dir
    end

    it 'creates the question bank xml file' do
      question = Moodle2CC::CanvasCC::Models::Question.new
      question.identifier = 42

      QuestionWriter.register_writer_type(nil)
      QuestionWriter.stub(:write_responses)
      QuestionWriter.stub(:write_response_conditions)

      question_bank.identifier = 'qb_id'
      question_bank.title = 'Bank title'
      question_bank.questions = [question]

      subject.write
      xml = Nokogiri::XML(File.read(File.join(work_dir, question_bank.question_bank_resource.href)))

      root = xml.at_xpath('xmlns:questestinterop')
      expect(root).to_not be_nil
      expect(root.%('objectbank').attributes['ident'].value).to eq question_bank.identifier

      meta = root.%('objectbank/qtimetadata/qtimetadatafield')
      expect(meta.%('fieldlabel').text).to eq 'bank_title'
      expect(meta.%('fieldentry').text).to eq question_bank.title

      expect(root.%('objectbank/item').attributes['ident'].value).to eq question.identifier.to_s
    end
  end
end