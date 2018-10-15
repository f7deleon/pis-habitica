# frozen_string_literal: true

require 'test_helper'

class AppControllerTest < ActionDispatch::IntegrationTest
  test 'enviroment' do
    assert_not ENV['EXP_BASE'].nil?
    assert_not ENV['EXP_INCREMENT'].nil?
    assert_not ENV['HEALTH_BASE'].nil?
    assert_not ENV['HEALTH_INCREMENT'].nil?
  end
end
