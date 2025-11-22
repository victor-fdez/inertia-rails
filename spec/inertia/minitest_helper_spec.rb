# frozen_string_literal: true

# Load the actual Minitest test class
require_relative '../../test/inertia_minitest_test'

RSpec.describe InertiaRails::Minitest, type: :request do
  # Get test methods without using runnable_methods (which requires Minitest initialization)
  test_methods = InertiaMinitestTest.public_instance_methods(false).select { |m| m.to_s.start_with?('test_') }

  # Programmatically create RSpec examples for each Minitest test method
  test_methods.each do |method_name|
    description = method_name.to_s.sub(/^test_/, '').tr('_', ' ')

    it description do
      test_instance = InertiaMinitestTest.new(method_name)
      test_instance.run

      if test_instance.failure
        raise test_instance.failure.exception
      end
    end
  end
end
