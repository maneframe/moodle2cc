require 'spec_helper'

module Moodle2CC
  describe Moodle2Converter::HtmlConverter do
    subject { Moodle2Converter::HtmlConverter.new(canvas_course, moodle_files) }
    let(:canvas_course) do
      course = CanvasCC::Models::Course.new
      course.files = ('a'..'c').map do |id|
        file = CanvasCC::Models::CanvasFile.new
        file.identifier = id
        file.file_path = '/path/'+ id
        file
      end
      course
    end

    let(:moodle_files) do
      ('a'..'c').map do |hash|
        file = Moodle2::Models::Moodle2File.new
        file.id = hash.ord
        file.content_hash = hash
        file.file_name = "#{hash}#{hash.ord}"
        file.file_path = '/'
        file
      end
    end

    it 'removes id="main" attributes' do
      html = '<div id="main">Some Content</div>'
      expect(subject.convert(html)).to_not include('id="main"')
    end

    it 'replaces moodle2 img src with canvas url' do
      content = '<p>a link to <img src="@@PLUGINFILE@@/a97" alt="Image Description" ></p>'
      html = Nokogiri::HTML.fragment(subject.convert(content))
      expect(html.css('img').first.attr('src')).to eq '%24IMS_CC_FILEBASE%24/path/a'
    end

    it 'replaces moodle 2 url in hrefs with cavans url' do
      content = '<p>a link to <a href="@@PLUGINFILE@@/a97"></p>'
      html = Nokogiri::HTML.fragment(subject.convert(content))
      expect(html.css('a[href]').first.attr('href')).to eq '%24IMS_CC_FILEBASE%24/path/a'
    end

    it 'removes link tags' do
      content = '<p>a link to <link href="@@PLUGINFILE@@/a97"></p>'
      expect(subject.convert(content)).to eq ('<p>a link to </p>')
    end

    it "doesn't replace external links" do
      content = '<p>a link to <img src="www.example.com/sample.gif" alt="Image Description"></p>'
      expect(subject.convert(content)).to eq content
    end

    it 'replaces links with spaces in path' do
      file = CanvasCC::Models::CanvasFile.new
      file.identifier = 'content_hash'
      file.file_path = '/my_dir/'+ 'test.txt'
      file
      canvas_course.files << file

      file = Moodle2::Models::Moodle2File.new
      file.id = 'moodle_file_id'
      file.content_hash = 'content_hash'
      file.file_name = 'text.txt'
      file.file_path = '/path with space/'
      moodle_files << file

      content = '<p>a link to <a href="@@PLUGINFILE@@/path%20with%20space/text.txt"></p>'
      html = Nokogiri::HTML.fragment(subject.convert(content))
      expect(html.css('a[href]').first.attr('href')).to eq '%24IMS_CC_FILEBASE%24/my_dir/test.txt'
    end


  end
end