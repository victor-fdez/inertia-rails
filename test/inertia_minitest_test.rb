# frozen_string_literal: true

require_relative '../spec/dummy/config/environment'
require 'minitest'
require_relative '../lib/inertia_rails/minitest'

class InertiaMinitestTest < ActionDispatch::IntegrationTest
  include InertiaRails::Minitest::Helpers

  def setup
    inertia_test!
  end

  def teardown
    InertiaRails.test_context = nil
    @_inertia_testing_enabled = false
    @_inertia_render_wrapper = nil
  end

  # Component tests
  def test_asserts_correct_component
    get component_path
    inertia.assert_component 'TestComponent'
  end

  def test_can_access_component_directly
    get component_path
    assert_equal 'TestComponent', inertia.component
  end

  # Props tests
  def test_asserts_exact_props
    get props_path
    inertia.assert_props({ name: 'Brandon', sport: 'hockey' })
  end

  def test_asserts_props_inclusion
    get props_path
    inertia.assert_includes_props({ sport: 'hockey' })
  end

  def test_can_access_props_directly
    get props_path
    assert_equal 'Brandon', inertia.props[:name]
  end

  # Sequential request tests
  def test_asserts_props_on_sequential_request
    get props_path, headers: { 'X-Inertia': true }
    inertia.assert_props({ 'name' => 'Brandon', 'sport' => 'hockey' })
  end

  def test_asserts_props_inclusion_on_sequential_request
    get props_path, headers: { 'X-Inertia': true }
    inertia.assert_includes_props({ 'sport' => 'hockey' })
  end

  # View data tests
  def test_asserts_exact_view_data
    get view_data_path
    inertia.assert_view_data({ name: 'Brian', sport: 'basketball' })
  end

  def test_asserts_view_data_inclusion
    get view_data_path
    inertia.assert_includes_view_data({ sport: 'basketball' })
  end

  def test_can_access_view_data_directly
    get view_data_path
    assert_equal 'Brian', inertia.view_data[:name]
  end

  # Lambda shared props
  def test_asserts_props_with_lambda_shared_props
    get lamda_shared_props_path
    inertia.assert_props({
                           someProperty: {
                             property_a: 'some value',
                             property_b: 'this value',
                           },
                           property_c: 'some other value',
                         })
  end
end
