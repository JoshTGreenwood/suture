require "suture/reset"
require "suture/verify/prescribes_test_plan"

class PrescribesTestPlanTest < UnitTest
  def setup
    super
    @subject = Suture::PrescribesTestPlan.new
  end

  def teardown
    super
    ENV.delete_if { |(k,v)| k.start_with?("SUTURE_") }
    Suture.reset!
  end

  def test_defaults
    result = @subject.prescribe(:foo)

    assert_equal :foo, result.name
    assert_equal false, result.fail_fast
    assert_equal nil, result.call_limit
    assert_equal nil, result.time_limit
    assert_equal nil, result.error_message_limit
    assert_equal "db/suture.sqlite3", result.database_path
    assert_kind_of Suture::Comparator, result.comparator
    assert_includes 0..99999, result.random_seed
    assert_equal nil, result.verify_only
  end

  def test_global_overrides
    Suture.config(
      :database_path => "other.db",
      :comparator => :lolcompare,
      :random_seed => nil
    )

    result = @subject.prescribe(:foo)

    assert_equal "other.db", result.database_path
    assert_equal :lolcompare, result.comparator
    assert_equal nil, result.random_seed
  end

  def test_options
    some_subject = lambda {}
    some_after_subject = lambda {}

    result = @subject.prescribe(:foo,
      :database_path => "db",
      :subject => some_subject,
      :fail_fast => true,
      :call_limit => 11,
      :time_limit => 99,
      :error_message_limit => 83,
      :comparator => :lol_compare,
      :verify_only => 42,
      :random_seed => 1337,
      :after_subject => some_after_subject
    )

    assert_equal :foo, result.name
    assert_equal some_subject, result.subject
    assert_equal true, result.fail_fast
    assert_equal 11, result.call_limit
    assert_equal 99, result.time_limit
    assert_equal 83, result.error_message_limit
    assert_equal "db", result.database_path
    assert_equal :lol_compare, result.comparator
    assert_equal 42, result.verify_only
    assert_equal 1337, result.random_seed
    assert_equal some_after_subject, result.after_subject
  end

  def test_env_vars
    ENV['SUTURE_NAME'] = 'bad name'
    ENV['SUTURE_SUBJECT'] = 'sub'
    ENV['SUTURE_DATABASE_PATH'] = 'd'
    ENV['SUTURE_COMPARATOR'] = 'e'
    ENV['SUTURE_FAIL_FAST'] = 'true'
    ENV['SUTURE_CALL_LIMIT'] = '91'
    ENV['SUTURE_TIME_LIMIT'] = '20'
    ENV['SUTURE_ERROR_MESSAGE_LIMIT'] = '999'
    ENV['SUTURE_VERIFY_ONLY'] = '42'
    ENV['SUTURE_RANDOM_SEED'] = '9922'
    ENV['SUTURE_AFTER_SUBJECT'] = 'lol'

    result = @subject.prescribe(:a_name)

    assert_equal "d", result.database_path
    assert_equal true, result.fail_fast
    assert_equal 91, result.call_limit
    assert_equal 20, result.time_limit
    assert_equal 42, result.verify_only
    assert_equal 999, result.error_message_limit
    assert_equal 9922, result.random_seed
    # options that can't be set with ENV vars:
    assert_equal :a_name, result.name
    assert_equal nil, result.subject
    assert_kind_of Suture::Comparator, result.comparator
    assert_equal nil, result.after_subject
  end

  def test_special_env_vars
    ENV['SUTURE_RANDOM_SEED'] = 'nil'

    result = @subject.prescribe(:a_name)

    assert_equal nil, result.random_seed
  end
end
