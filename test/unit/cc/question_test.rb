require 'nokogiri'
require 'minitest/autorun'
require 'test/test_helper'
require 'moodle2cc'

class TestUnitCCQuestion < MiniTest::Unit::TestCase
  include TestHelper

  def setup
    convert_moodle_backup
    @mod = @backup.course.mods.find { |mod| mod.mod_type == 'quiz' }
    @question_instance = @mod.question_instances.first
    @question = @question_instance.question
  end

  def teardown
    clean_tmp_folder
  end

  def match_question!
    @question.type = 'match'

    match1 = Moodle2CC::Moodle::Question::Match.new
    match1.code = 123
    match1.question_text = 'Ruby on Rails is written in this language'
    match1.answer_text = 'Ruby'

    match2 = Moodle2CC::Moodle::Question::Match.new
    match2.code = 234
    match2.question_text = ''
    match2.answer_text = 'Python'

    match3 = Moodle2CC::Moodle::Question::Match.new
    match3.code = 345
    match3.question_text = 'Files with .coffee extension use which language?'
    match3.answer_text = 'CoffeeScript'

    @question.matches = [match1, match2, match3]
  end

  def multiple_choice_question!
    @question.type = 'multichoice'

    answer1 = Moodle2CC::Moodle::Question::Answer.new
    answer1.id = 123
    answer1.text = 'Ruby'
    answer1.fraction = 1
    answer1.feedback = 'Yippee!'

    answer2 = Moodle2CC::Moodle::Question::Answer.new
    answer2.id = 234
    answer2.text = 'CoffeeScript'
    answer2.fraction = 0.75
    answer2.feedback = 'Nope'

    answer3 = Moodle2CC::Moodle::Question::Answer.new
    answer3.id = 345
    answer3.text = 'Java'
    answer3.fraction = 0.25
    answer3.feedback = 'No way'

    answer4 = Moodle2CC::Moodle::Question::Answer.new
    answer4.id = 456
    answer4.text = 'Clojure'
    answer4.fraction = 0
    answer4.feedback = 'Not even close'

    @question.answers = [answer1, answer2, answer3, answer4]
  end

  def numerical_question!
    @question_instance = @mod.question_instances.map { |qi| qi if qi.question.type == 'numerical' }.compact.first
    @question = @question_instance.question
  end

  def short_answer_question!
    @question_instance = @mod.question_instances.map { |qi| qi if qi.question.type == 'shortanswer' }.compact.first
    @question = @question_instance.question
  end

  def true_false_question!
    @question_instance = @mod.question_instances.map { |qi| qi if qi.question.type == 'truefalse' }.compact.first
    @question = @question_instance.question
  end

  def test_it_converts_id
    @question.id = 989
    question = Moodle2CC::CC::Question.new @question_instance
    assert_equal 989, question.id
  end

  def test_it_converts_title
    @question.name = "Basic Arithmetic"
    question = Moodle2CC::CC::Question.new @question_instance
    assert_equal "Basic Arithmetic", question.title
  end

  def test_it_converts_question_type
    @question.type = 'calculated'
    question = Moodle2CC::CC::Question.new @question_instance
    assert_equal 'calculated_question', question.question_type

    @question.type = 'description'
    question = Moodle2CC::CC::Question.new @question_instance
    assert_equal 'text_only_question', question.question_type

    @question.type = 'essay'
    question = Moodle2CC::CC::Question.new @question_instance
    assert_equal 'essay_question', question.question_type

    @question.type = 'match'
    question = Moodle2CC::CC::Question.new @question_instance
    assert_equal 'matching_question', question.question_type

    @question.type = 'multianswer'
    question = Moodle2CC::CC::Question.new @question_instance
    assert_equal 'multiple_answers_question', question.question_type

    @question.type = 'multichoice'
    question = Moodle2CC::CC::Question.new @question_instance
    assert_equal 'multiple_choice_question', question.question_type

    @question.type = 'shortanswer'
    question = Moodle2CC::CC::Question.new @question_instance
    assert_equal 'short_answer_question', question.question_type

    @question.type = 'numerical'
    question = Moodle2CC::CC::Question.new @question_instance
    assert_equal 'numerical_question', question.question_type

    @question.type = 'truefalse'
    question = Moodle2CC::CC::Question.new @question_instance
    assert_equal 'true_false_question', question.question_type
  end

  def test_it_converts_points_possible
    @question_instance.grade = 5
    question = Moodle2CC::CC::Question.new @question_instance
    assert_equal 5, question.points_possible
  end

  def test_it_converts_material
    @question.text = "How much is {a} + {b} ?"
    question = Moodle2CC::CC::Question.new @question_instance
    assert_equal "How much is [a] + [b] ?", question.material
  end

  def test_it_converts_general_feedback
    @question.general_feedback = "This should be easy"
    question = Moodle2CC::CC::Question.new @question_instance
    assert_equal "This should be easy", question.general_feedback
  end

  def test_it_converts_answer_tolerance
    @question.calculations.first.tolerance = 0.01
    question = Moodle2CC::CC::Question.new @question_instance
    assert_equal 0.01, question.answer_tolerance
  end

  def test_it_converts_formula_decimal_places
    calculation = @question.calculations.first
    calculation.correct_answer_format = 1 # decimal
    calculation.correct_answer_length = 2

    question = Moodle2CC::CC::Question.new @question_instance
    assert_equal 2, question.formula_decimal_places

    calculation.correct_answer_format = 2 # significant figures

    question = Moodle2CC::CC::Question.new @question_instance
    assert_equal 0, question.formula_decimal_places
  end

  def test_it_converts_formulas
    answer1 = @question.answers.first
    answer2 = answer1.dup
    @question.answers << answer2

    answer1.text = '{a} + {b}'
    answer2.text = '{a} * {b}'

    question = Moodle2CC::CC::Question.new @question_instance
    assert_equal 2, question.formulas.length
    assert_equal 'a+b', question.formulas.first
    assert_equal 'a*b', question.formulas.last
  end

  def test_it_converts_vars
    calculation = @question.calculations.first
    ds_def1 = calculation.dataset_definitions.first
    ds_def2 = calculation.dataset_definitions.last

    ds_def1.name = 'a'
    ds_def1.options = 'uniform:3.0:9.0:3'

    ds_def2.name = 'b'
    ds_def2.options = 'uniform:1.0:10.0:1'

    question = Moodle2CC::CC::Question.new @question_instance
    assert_equal 2, question.vars.length
    assert_equal({:name => 'a', :scale => '3', :min => '3.0', :max => '9.0'}, question.vars.first)
    assert_equal({:name => 'b', :scale => '1', :min => '1.0', :max => '10.0'}, question.vars.last)
  end

  def test_it_converts_var_sets
    calculation = @question.calculations.first
    ds_def1 = calculation.dataset_definitions.first
    ds_def2 = calculation.dataset_definitions.last

    ds_def1.name = 'a'
    ds_item1 = ds_def1.dataset_items.first
    ds_item2 = ds_item1.dup
    ds_def1.dataset_items[1] = ds_item2

    ds_item1.number = 1
    ds_item1.value = 3.0
    ds_item2.number = 2
    ds_item2.value = 5.5

    ds_def2.name = 'b'
    ds_item1 = ds_def2.dataset_items.first
    ds_item2 = ds_item1.dup
    ds_def2.dataset_items[1] = ds_item2

    ds_item1.number = 1
    ds_item1.value = 6.0
    ds_item2.number = 2
    ds_item2.value = 1.0

    question = Moodle2CC::CC::Question.new @question_instance
    assert_equal 2, question.var_sets.length
    assert_equal({:vars => {'a' => 3.0, 'b' => 6.0}, :answer => 9.0}, question.var_sets.first)
    assert_equal({:vars => {'a' => 5.5, 'b' => 1.0}, :answer => 6.5}, question.var_sets.last)
  end

  def test_it_converts_matches
    match_question!

    question = Moodle2CC::CC::Question.new @question_instance
    assert_equal 2, question.matches.length
    assert_equal({
      :question => 'Ruby on Rails is written in this language',
      :answers => {123 => 'Ruby', 234 => 'Python', 345 => 'CoffeeScript'},
      :answer => 123
    }, question.matches.first)
    assert_equal({
      :question => 'Files with .coffee extension use which language?',
      :answers => {123 => 'Ruby', 234 => 'Python', 345 => 'CoffeeScript'},
      :answer => 345
    }, question.matches.last)
  end

  def test_it_converts_numericals
    answer = Moodle2CC::Moodle::Question::Answer.new
    answer.id = 43
    answer.text = "Blah"
    numerical = Moodle2CC::Moodle::Question::Numerical.new
    numerical.answer_id = 43
    numerical.tolerance = 3
    @question.numericals = [numerical]
    @question.answers = [answer]
    question = Moodle2CC::CC::Question.new @question_instance

    assert_equal 1, question.numericals.length

    assert_equal({
      :answer => question.answers.first,
      :tolerance => 3,
    }, question.numericals.first)
  end

  def test_it_converts_answers
    multiple_choice_question!

    question = Moodle2CC::CC::Question.new @question_instance
    assert_equal 4, question.answers.length

    assert_equal({
      :id => 123,
      :text => 'Ruby',
      :fraction => 1,
      :feedback => 'Yippee!'
    }, question.answers[0])
    assert_equal({
      :id => 234,
      :text => 'CoffeeScript',
      :fraction => 0.75,
      :feedback => 'Nope'
    }, question.answers[1])
    assert_equal({
      :id => 345,
      :text => 'Java',
      :fraction => 0.25,
      :feedback => 'No way'
    }, question.answers[2])
    assert_equal({
      :id => 456,
      :text => 'Clojure',
      :fraction => 0,
      :feedback => 'Not even close'
    }, question.answers[3])
  end

  def test_it_has_an_identifier
    @question.id = 989
    question = Moodle2CC::CC::Question.new @question_instance
    assert_equal 'i04823ed56ffd4fd5f9c21db0cf25be6c', question.identifier
    # question_989
  end

  def test_it_creates_item_xml
    question = Moodle2CC::CC::Question.new @question_instance
    node = Builder::XmlMarkup.new
    xml = Nokogiri::XML(question.create_item_xml(node))

    assert xml.root
    assert_equal 'item', xml.root.name
    assert_equal 'Basic Arithmetic', xml.root.attributes['title'].value
    assert_equal 'i04823ed56ffd4fd5f9c21db0cf25be6c', xml.root.attributes['ident'].value

    assert xml.root.xpath('itemmetadata/qtimetadata/qtimetadatafield[fieldlabel="question_type" and fieldentry="calculated_question"]').first, 'does not have meta data for question type'
    assert xml.root.xpath('itemmetadata/qtimetadata/qtimetadatafield[fieldlabel="points_possible" and fieldentry="1"]').first, 'does not have meta data for points possible'
    # assert xml.root.xpath('itemmetadata/qtimetadata/qtimetadatafield[fieldlabel="assessment_question_identifierref" and fieldentry="1"]').first, 'does not have meta data for assessment_question_identifierref'

    assert_equal 'How much is [a] + [b] ?', xml.root.xpath('presentation/material/mattext[@texttype="text/html"]').text

    # Score
    outcome = xml.root.xpath('resprocessing/outcomes/decvar').first
    assert_equal '100', outcome.attributes['maxvalue'].value
    assert_equal '0', outcome.attributes['minvalue'].value
    assert_equal 'SCORE', outcome.attributes['varname'].value
    assert_equal 'Decimal', outcome.attributes['vartype'].value

    # General Feedback
    general_feedback = xml.root.xpath('resprocessing/respcondition[1]').first
    assert_equal 'Yes', general_feedback.attributes['continue'].value
    assert general_feedback.xpath('conditionvar/other').first, 'does not contain conditionvar'
    assert_equal 'Response', general_feedback.xpath('displayfeedback').first.attributes['feedbacktype'].value
    assert_equal 'general_fb', general_feedback.xpath('displayfeedback').first.attributes['linkrefid'].value

    general_feedback = xml.root.xpath('itemfeedback[@ident="general_fb"]').first
    assert general_feedback, 'no feeback node'
    material = general_feedback.xpath('flow_mat/material/mattext[@texttype="text/plain"]').first
    assert material, 'no feedback text'
    assert_equal 'This should be easy', material.text
  end

  def test_it_creates_item_xml_for_calculated_question
    @question.type = 'calculated'
    question = Moodle2CC::CC::Question.new @question_instance
    node = Builder::XmlMarkup.new
    xml = Nokogiri::XML(question.create_item_xml(node))

    response = xml.root.xpath('presentation/response_str').first
    assert_equal 'Single', response.attributes['rcardinality'].value
    assert_equal 'response1', response.attributes['ident'].value
    assert_equal 'Decimal', response.xpath('render_fib').first.attributes['fibtype'].value
    assert_equal 'answer1', response.xpath('render_fib/response_label').first.attributes['ident'].value

    # Correct Condition
    condition = xml.root.xpath('resprocessing/respcondition[@title="correct"]').first
    assert condition, 'correct condition node does not exist'
    assert condition.xpath('conditionvar/other').first, 'conditionvar does not exist for correct condition node'
    setvar = condition.xpath('setvar').first
    assert setvar, 'setvar does not exist for correct condition node'
    assert_equal 'SCORE', setvar.attributes['varname'].value
    assert_equal 'Set', setvar.attributes['action'].value
    assert_equal '100', setvar.text

    # Incorrect Condition
    condition = xml.root.xpath('resprocessing/respcondition[@title="incorrect"]').first
    assert condition, 'incorrect condition node does not exist'
    assert condition.xpath('conditionvar/other').first, 'conditionvar does not exist for incorrect condition node'
    setvar = condition.xpath('setvar').first
    assert setvar, 'setvar does not exist for incorrect condition node'
    assert_equal 'SCORE', setvar.attributes['varname'].value
    assert_equal 'Set', setvar.attributes['action'].value
    assert_equal '0', setvar.text

    # Calculations
    calculated = xml.root.xpath('itemproc_extension/calculated').first
    assert calculated, 'calculated node does not exist'
    assert_equal '0.01', calculated.xpath('answer_tolerance').text

    # Formulas
    assert calculated.xpath('formulas[@decimal_places="2"]').first, 'calculated node does not contain formulas with decimal_places'
    assert calculated.xpath('formulas/formula["a+b"]').first, 'calculated node does not contain the formula a+b'

    # Var
    a_var = calculated.xpath('vars/var[@scale="1"][@name="a"]').first
    assert a_var, 'calculated node does not have variable for a'
    assert_equal '1.0', a_var.xpath('min').text
    assert_equal '10.0', a_var.xpath('max').text
    b_var = calculated.xpath('vars/var[@scale="1"][@name="b"]').first
    assert b_var, 'calculated node does not have variable for b'
    assert_equal '1.0', b_var.xpath('min').text
    assert_equal '10.0', b_var.xpath('max').text

    # Var Sets
    var_set1 = calculated.xpath('var_sets/var_set[1]').first
    assert var_set1, 'first var_set does not exist'
    assert_equal '3060', var_set1.attributes['ident'].value
    assert var_set1.xpath('var[@name="a"][3.0]'), 'first var_set does not have a value for a'
    assert var_set1.xpath('var[@name="b"][6.0]'), 'first var_set does not have a value for b'
    assert var_set1.xpath('answer[9.0]'), 'first var_set does not have an answer'

    var_set2 = calculated.xpath('var_sets/var_set[2]').first
    assert var_set2, 'second var_set does not exist'
    assert_equal '5510', var_set2.attributes['ident'].value
    assert var_set2.xpath('var[@name="a"][5.5]'), 'second var_set does not have a value for a'
    assert var_set2.xpath('var[@name="b"][1.0]'), 'second var_set does not have a value for b'
    assert var_set2.xpath('answer[6.5]'), 'second var_set does not have an answer'
  end

  def test_it_creates_item_xml_for_essay_question
    @question.type = 'essay'
    question = Moodle2CC::CC::Question.new @question_instance
    node = Builder::XmlMarkup.new
    xml = Nokogiri::XML(question.create_item_xml(node))

    response = xml.root.xpath('presentation/response_str').first
    assert_equal 'Single', response.attributes['rcardinality'].value
    assert_equal 'response1', response.attributes['ident'].value
    assert_equal 'No', response.xpath('render_fib/response_label').first.attributes['rshuffle'].value
    assert_equal 'answer1', response.xpath('render_fib/response_label').first.attributes['ident'].value

    # No Continue Condition
    condition = xml.root.xpath('resprocessing/respcondition[@continue="No"]').first
    assert condition, 'no continue condition node does not exist'
    assert condition.xpath('conditionvar/other').first, 'conditionvar does not exist for no continue condition node'
  end

  def test_it_creates_item_xml_for_matching_question
    match_question!

    question = Moodle2CC::CC::Question.new @question_instance
    node = Builder::XmlMarkup.new
    xml = Nokogiri::XML(question.create_item_xml(node))

    response = xml.root.xpath('presentation/response_lid[@ident="response_123"]').first
    assert response, 'response for first matching question does not exist'
    assert_equal 'Ruby on Rails is written in this language', response.xpath('material/mattext[@texttype="text/plain"]').text
    assert_equal 'Ruby', response.xpath('render_choice/response_label[@ident="123"]/material/mattext').text
    assert_equal 'Python', response.xpath('render_choice/response_label[@ident="234"]/material/mattext').text
    assert_equal 'CoffeeScript', response.xpath('render_choice/response_label[@ident="345"]/material/mattext').text

    response = xml.root.xpath('presentation/response_lid[@ident="response_345"]').first
    assert response, 'response for second matching question does not exist'
    assert_equal 'Files with .coffee extension use which language?', response.xpath('material/mattext[@texttype="text/plain"]').text
    assert_equal 'Ruby', response.xpath('render_choice/response_label[@ident="123"]/material/mattext').text
    assert_equal 'Python', response.xpath('render_choice/response_label[@ident="234"]/material/mattext').text
    assert_equal 'CoffeeScript', response.xpath('render_choice/response_label[@ident="345"]/material/mattext').text

    condition = xml.root.xpath('resprocessing/respcondition/conditionvar[varequal=123]/..').first
    assert condition, 'first matching condition does not exist'
    assert condition.xpath('conditionvar/varequal[@respident="response_123"]').first, 'condition does not reference correct response'
    set_var = condition.xpath('setvar').first
    assert_equal 'SCORE', set_var.attributes['varname'].value
    assert_equal 'Add', set_var.attributes['action'].value
    assert_equal '50.00', set_var.text

    condition = xml.root.xpath('resprocessing/respcondition/conditionvar[varequal=345]/..').first
    assert condition, 'second matching condition does not exist'
    assert condition.xpath('conditionvar/varequal[@respident="response_345"]').first, 'condition does not reference correct response'
    set_var = condition.xpath('setvar').first
    assert_equal 'SCORE', set_var.attributes['varname'].value
    assert_equal 'Add', set_var.attributes['action'].value
    assert_equal '50.00', set_var.text
  end

  def test_it_creates_item_xml_for_multiple_choice_question
    multiple_choice_question!

    question = Moodle2CC::CC::Question.new @question_instance
    node = Builder::XmlMarkup.new
    xml = Nokogiri::XML(question.create_item_xml(node))

    # Responses
    response = xml.root.xpath('presentation/response_lid[@ident="response1"]').first
    assert response, 'response for multiple choice question does not exist'
    assert_equal 'Single', response.attributes['rcardinality'].value
    assert_equal 'Ruby', response.xpath('render_choice/response_label[@ident="123"]/material/mattext[@texttype="text/plain"]').text
    assert_equal 'CoffeeScript', response.xpath('render_choice/response_label[@ident="234"]/material/mattext[@texttype="text/plain"]').text
    assert_equal 'Java', response.xpath('render_choice/response_label[@ident="345"]/material/mattext[@texttype="text/plain"]').text
    assert_equal 'Clojure', response.xpath('render_choice/response_label[@ident="456"]/material/mattext[@texttype="text/plain"]').text

    # Feedback
    feedback = xml.root.xpath('resprocessing/respcondition[@continue="Yes"]/conditionvar/varequal[@respident="response1" and text()="123"]/../..').first
    assert feedback, 'feedback does not exist for first answer'
    display = feedback.xpath('displayfeedback[@feedbacktype="Response"][@linkrefid="123_fb"]').first
    assert display, 'display feedback does not exist for first answer'

    feedback = xml.root.xpath('resprocessing/respcondition[@continue="Yes"]/conditionvar/varequal[@respident="response1" and text()="234"]/../..').first
    assert feedback, 'feedback does not exist for second answer'
    display = feedback.xpath('displayfeedback[@feedbacktype="Response"][@linkrefid="234_fb"]').first
    assert display, 'display feedback does not exist for second answer'

    feedback = xml.root.xpath('resprocessing/respcondition[@continue="Yes"]/conditionvar/varequal[@respident="response1" and text()="345"]/../..').first
    assert feedback, 'feedback does not exist for third answer'
    display = feedback.xpath('displayfeedback[@feedbacktype="Response"][@linkrefid="345_fb"]').first
    assert display, 'display feedback does not exist for third answer'

    feedback = xml.root.xpath('resprocessing/respcondition[@continue="Yes"]/conditionvar/varequal[@respident="response1" and text()="456"]/../..').first
    assert feedback, 'feedback does not exist for fourth answer'
    display = feedback.xpath('displayfeedback[@feedbacktype="Response"][@linkrefid="456_fb"]').first
    assert display, 'display feedback does not exist for fourth answer'

    feedback = xml.root.xpath('itemfeedback[@ident="123_fb"]/flow_mat/material/mattext[@texttype="text/plain"]').first
    assert feedback, 'feedback text does not exist for first answer'
    assert_equal 'Yippee!', feedback.text

    feedback = xml.root.xpath('itemfeedback[@ident="234_fb"]/flow_mat/material/mattext[@texttype="text/plain"]').first
    assert feedback, 'feedback text does not exist for second answer'
    assert_equal 'Nope', feedback.text

    feedback = xml.root.xpath('itemfeedback[@ident="345_fb"]/flow_mat/material/mattext[@texttype="text/plain"]').first
    assert feedback, 'feedback text does not exist for third answer'
    assert_equal 'No way', feedback.text

    feedback = xml.root.xpath('itemfeedback[@ident="456_fb"]/flow_mat/material/mattext[@texttype="text/plain"]').first
    assert feedback, 'feedback text does not exist for fourth answer'
    assert_equal 'Not even close', feedback.text

    # Conditions
    condition = xml.root.xpath('resprocessing/respcondition[@continue="No"]/conditionvar/varequal[@respident="response1" and text()="123"]/../..').first
    assert condition, 'condition does not exist for first answer'
    var = condition.xpath('setvar[@varname="SCORE" and @action="Set" and text()="100"]').first
    assert var, 'score does not exist for first answer'

    condition = xml.root.xpath('resprocessing/respcondition[@continue="No"]/conditionvar/varequal[@respident="response1" and text()="234"]/../..').first
    assert condition, 'condition does not exist for first answer'
    var = condition.xpath('setvar[@varname="SCORE" and @action="Set" and text()="75"]').first
    assert var, 'score does not exist for second answer'

    condition = xml.root.xpath('resprocessing/respcondition[@continue="No"]/conditionvar/varequal[@respident="response1" and text()="345"]/../..').first
    assert condition, 'condition does not exist for first answer'
    var = condition.xpath('setvar[@varname="SCORE" and @action="Set" and text()="25"]').first
    assert var, 'score does not exist for third answer'
    condition = xml.root.xpath('resprocessing/respcondition[@continue="No"]/conditionvar/varequal[@respident="response1" and text()="456"]/../..').first

    assert condition, 'condition does not exist for first answer'
    var = condition.xpath('setvar[@varname="SCORE" and @action="Set" and text()="0"]').first
    assert var, 'score does not exist for fourth answer'
  end

  def test_it_creates_item_xml_for_numerical_question
    numerical_question!

    question = Moodle2CC::CC::Question.new @question_instance
    node = Builder::XmlMarkup.new
    xml = Nokogiri::XML(question.create_item_xml(node))

    response = xml.root.xpath('presentation/response_str').first
    assert_equal 'Single', response.attributes['rcardinality'].value
    assert_equal 'response1', response.attributes['ident'].value
    assert_equal 'Decimal', response.xpath('render_fib').first.attributes['fibtype'].value
    assert_equal 'answer1', response.xpath('render_fib/response_label').first.attributes['ident'].value

    condition = xml.root.xpath('resprocessing/respcondition[@continue="No"][1]').first
    assert condition, 'condition does not exist for first answer'
    var = condition.xpath('conditionvar/or/varequal[@respident="response1" and text()="28"]').first
    assert var, 'conditionvar varequal does not exist for first answer'
    var = condition.xpath('conditionvar/or/and/vargte[@respident="response1" and text()="26.0"]').first
    assert var, 'conditionvar vargte does not exist for first answer'
    var = condition.xpath('conditionvar/or/and/varlte[@respident="response1" and text()="30.0"]').first
    assert var, 'conditionvar varlte does not exist for first answer'
    setvar = condition.xpath('setvar[@varname="SCORE" and @action="Set" and text()="100"]').first
    assert setvar, 'setvar does not exist for first answer'
    feedback = condition.xpath('displayfeedback[@feedbacktype="Response" and @linkrefid="43_fb"]').first
    assert feedback, 'displayfeedback does not exist for first answer'

    feedback = xml.root.xpath('itemfeedback[@ident="43_fb"]/flow_mat/material/mattext[@texttype="text/plain"]').first
    assert feedback, 'feedback text does not exist for first answer'
    assert_equal 'Great age!', feedback.text
  end


  def test_it_creates_item_xml_for_short_answer_question
    short_answer_question!

    question = Moodle2CC::CC::Question.new @question_instance
    node = Builder::XmlMarkup.new
    xml = Nokogiri::XML(question.create_item_xml(node))

    response = xml.root.xpath('presentation/response_str').first
    assert_equal 'Single', response.attributes['rcardinality'].value
    assert_equal 'response1', response.attributes['ident'].value
    assert_equal 'No', response.xpath('render_fib/response_label').first.attributes['rshuffle'].value
    assert_equal 'answer1', response.xpath('render_fib/response_label').first.attributes['ident'].value


    condition = xml.root.xpath('resprocessing/respcondition[@continue="No"]/conditionvar/varequal[@respident="response1" and text()="Ruby"]/../..').first
    assert condition, 'condition does not exist for first answer'
    feedback = condition.xpath('displayfeedback[@feedbacktype="Response" and @linkrefid="40_fb"]').first
    assert feedback, 'displayfeedback does not exist for first answer'
    setvar = condition.xpath('setvar[@varname="SCORE" and @action="Set" and text()="100"]').first
    assert setvar, 'setvar does not exist for first answer'

    condition = xml.root.xpath('resprocessing/respcondition[@continue="No"]/conditionvar/varequal[@respident="response1" and text()="JavaScript"]/../..').first
    assert condition, 'condition does not exist for second answer'
    feedback = condition.xpath('displayfeedback[@feedbacktype="Response" and @linkrefid="41_fb"]').first
    assert feedback, 'displayfeedback does not exist for second answer'
    setvar = condition.xpath('setvar[@varname="SCORE" and @action="Set" and text()="50"]').first
    assert setvar, 'setvar does not exist for second answer'

    condition = xml.root.xpath('resprocessing/respcondition[@continue="No"]/conditionvar/varequal[@respident="response1" and text()="Java"]/../..').first
    assert condition, 'condition does not exist for third answer'
    feedback = condition.xpath('displayfeedback[@feedbacktype="Response" and @linkrefid="42_fb"]').first
    assert feedback, 'displayfeedback does not exist for third answer'
    setvar = condition.xpath('setvar[@varname="SCORE" and @action="Set" and text()="10"]').first
    assert setvar, 'setvar does not exist for third answer'

    feedback = xml.root.xpath('itemfeedback[@ident="40_fb"]/flow_mat/material/mattext[@texttype="text/plain"]').first
    assert feedback, 'feedback text does not exist for first answer'
    assert_equal 'Good choice!', feedback.text
    feedback = xml.root.xpath('itemfeedback[@ident="41_fb"]/flow_mat/material/mattext[@texttype="text/plain"]').first
    assert feedback, 'feedback text does not exist for second answer'
    assert_equal 'Not what I would have chosen...', feedback.text
    feedback = xml.root.xpath('itemfeedback[@ident="42_fb"]/flow_mat/material/mattext[@texttype="text/plain"]').first
    assert feedback, 'feedback text does not exist for third answer'
    assert_equal "You're kidding, right?", feedback.text
  end

  def test_it_creates_item_xml_for_true_false_question
    true_false_question!

    question = Moodle2CC::CC::Question.new @question_instance
    node = Builder::XmlMarkup.new
    xml = Nokogiri::XML(question.create_item_xml(node))

    response = xml.root.xpath('presentation/response_lid').first
    assert_equal 'Single', response.attributes['rcardinality'].value
    assert_equal 'response1', response.attributes['ident'].value
    assert response.xpath('render_choice/response_label[@ident="44"]/material/mattext[@texttype="text/plain" and text()="True"]').first, 'true response choice does not exist'
    assert response.xpath('render_choice/response_label[@ident="45"]/material/mattext[@texttype="text/plain" and text()="False"]').first, 'false response choice does not exist'

    condition = xml.root.xpath('resprocessing/respcondition[@continue="No"]/conditionvar/varequal[@respident="response1" and text()="44"]/../..').first
    assert condition, 'condition does not exist for first answer'
    feedback = condition.xpath('displayfeedback[@feedbacktype="Response" and @linkrefid="44_fb"]').first
    assert feedback, 'displayfeedback does not exist for first answer'
    setvar = condition.xpath('setvar[@varname="SCORE" and @action="Set" and text()="100"]').first
    assert setvar, 'setvar does not exist for first answer'

    condition = xml.root.xpath('resprocessing/respcondition[@continue="No"]/conditionvar/varequal[@respident="response1" and text()="45"]/../..').first
    assert condition, 'condition does not exist for second answer'
    feedback = condition.xpath('displayfeedback[@feedbacktype="Response" and @linkrefid="45_fb"]').first
    assert feedback, 'displayfeedback does not exist for second answer'
    setvar = condition.xpath('setvar[@varname="SCORE" and @action="Set" and text()="0"]').first
    assert setvar, 'setvar does not exist for second answer'

    feedback = xml.root.xpath('itemfeedback[@ident="44_fb"]/flow_mat/material/mattext[@texttype="text/plain"]').first
    assert feedback, 'feedback text does not exist for first answer'
    assert_equal 'Smarty pants!', feedback.text
    feedback = xml.root.xpath('itemfeedback[@ident="45_fb"]/flow_mat/material/mattext[@texttype="text/plain"]').first
    assert feedback, 'feedback text does not exist for second answer'
    assert_equal 'What exactly are you doing?', feedback.text
  end

end
