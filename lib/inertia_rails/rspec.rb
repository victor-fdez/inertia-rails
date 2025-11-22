# frozen_string_literal: true

require 'rspec/core'
require 'rspec/matchers'
require_relative 'test_helper'

module InertiaRails
  module RSpec
    # Backwards compatibility alias
    InertiaRenderWrapper = TestHelper::RenderWrapper

    module Helpers
      def inertia
        unless inertia_tests_setup?
          raise "Inertia test helpers aren't set up! " \
                'Make sure you add `inertia: true` to describe blocks using inertia tests.'
        end

        if @_inertia_render_wrapper.nil? && !::RSpec.configuration.inertia[:skip_missing_renderer_warnings]
          warn 'WARNING: the test never created an Inertia renderer. ' \
               "Maybe the code wasn't able to reach a `render inertia:` call? If this was intended, " \
               "or you don't want to see this message, " \
               'set ::RSpec.configuration.inertia[:skip_missing_renderer_warnings] = true'
        end
        @_inertia_render_wrapper
      end

      def expect_inertia
        expect(inertia)
      end

      def inertia_wrap_render(render)
        @_inertia_render_wrapper = TestHelper::RenderWrapper.new(self).wrap_render(render)
      end

      def inertia_testing_enabled?
        inertia_tests_setup?
      end

      protected

      def inertia_tests_setup?
        ::RSpec.current_example.metadata.fetch(:inertia, false)
      end
    end
  end
end

# Install the shared interceptor
InertiaRails::TestHelper.install!

RSpec.configure do |config|
  config.include InertiaRails::RSpec::Helpers
  config.add_setting :inertia, default: {
    skip_missing_renderer_warnings: false,
  }

  config.before(:each, inertia: true) do
    InertiaRails.test_context = self
  end

  config.after(:each, inertia: true) do
    InertiaRails.test_context = nil
  end
end

RSpec::Matchers.define :have_exact_props do |expected_props|
  match do |inertia|
    expect(inertia.props).to eq expected_props
  end

  failure_message do |inertia|
    "expected inertia props to receive #{expected_props}, instead received #{inertia.props || 'nothing'}"
  end
end

RSpec::Matchers.define :include_props do |expected_props|
  match do |inertia|
    expect(inertia.props).to include expected_props
  end

  failure_message do |inertia|
    "expected inertia props to include #{expected_props}, instead received #{inertia.props || 'nothing'}"
  end
end

RSpec::Matchers.define :render_component do |expected_component|
  match do |inertia|
    expect(inertia.component).to eq expected_component
  end

  failure_message do |inertia|
    "expected rendered inertia component to be #{expected_component}, " \
      "instead received #{inertia.component || 'nothing'}"
  end
end

RSpec::Matchers.define :have_exact_view_data do |expected_view_data|
  match do |inertia|
    expect(inertia.view_data).to eq expected_view_data
  end

  failure_message do |inertia|
    "expected inertia view data to receive #{expected_view_data}, instead received #{inertia.view_data || 'nothing'}"
  end
end

RSpec::Matchers.define :include_view_data do |expected_view_data|
  match do |inertia|
    expect(inertia.view_data).to include expected_view_data
  end

  failure_message do |inertia|
    "expected inertia view data to include #{expected_view_data}, instead received #{inertia.view_data || 'nothing'}"
  end
end
