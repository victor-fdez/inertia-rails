# frozen_string_literal: true

require_relative 'test_helper'

module InertiaRails
  module Minitest
    # Configuration
    mattr_accessor :skip_missing_renderer_warnings, default: false

    module Helpers
      # Access the inertia render wrapper
      def inertia
        unless @_inertia_testing_enabled
          raise "Inertia test helpers aren't set up! " \
                "Make sure you call `inertia_test!` in your test setup."
        end

        if @_inertia_render_wrapper.nil? && !InertiaRails::Minitest.skip_missing_renderer_warnings
          warn "WARNING: the test never created an Inertia renderer. " \
               "Maybe the code wasn't able to reach a `render inertia:` call?"
        end

        @_inertia_render_wrapper
      end

      # Enable inertia testing for this test
      def inertia_test!
        @_inertia_testing_enabled = true
        InertiaRails.test_context = self
      end

      def inertia_testing_enabled?
        @_inertia_testing_enabled
      end

      def inertia_wrap_render(render)
        @_inertia_render_wrapper = TestHelper::RenderWrapper.new(self).wrap_render(render)
      end
    end
  end
end

# Install the interceptor when loaded
InertiaRails::TestHelper.install!

# Auto-include in integration tests
ActiveSupport.on_load(:action_dispatch_integration_test) do
  include InertiaRails::Minitest::Helpers

  # Clean up test context after each test
  teardown do
    InertiaRails.test_context = nil
    @_inertia_testing_enabled = false
    @_inertia_render_wrapper = nil
  end
end
