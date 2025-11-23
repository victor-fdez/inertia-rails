# frozen_string_literal: true

module InertiaRails
  module TestHelper
    class RenderWrapper
      attr_reader :view_data, :props, :component

      def initialize(test_context = nil)
        @test_context = test_context
        @view_data = nil
        @props = nil
        @component = nil
      end

      def call(params)
        assign_locals(params)
        @render_method&.call(params)
      end

      def wrap_render(render_method)
        @render_method = render_method
        self
      end

      # Assertions (for Minitest)
      def assert_component(expected, message = nil)
        msg = message || "Expected component '#{expected}', got '#{component}'"
        @test_context.assert_equal expected, component, msg
      end

      def assert_props(expected, message = nil)
        msg = message || "Expected props to equal #{expected}, got #{props}"
        @test_context.assert_equal expected, props, msg
      end

      def assert_includes_props(expected, message = nil)
        msg = message || "Expected props to include #{expected}"
        @test_context.assert props, "No props found"
        expected.each do |key, value|
          @test_context.assert_equal value, props[key], "#{msg} - key: #{key}"
        end
      end

      def assert_view_data(expected, message = nil)
        msg = message || "Expected view_data to equal #{expected}, got #{view_data}"
        @test_context.assert_equal expected, view_data, msg
      end

      def assert_includes_view_data(expected, message = nil)
        msg = message || "Expected view_data to include #{expected}"
        @test_context.assert view_data, "No view_data found"
        expected.each do |key, value|
          @test_context.assert_equal value, view_data[key], "#{msg} - key: #{key}"
        end
      end

      protected

      def assign_locals(params)
        if params[:locals].present?
          @view_data = params[:locals].except(:page)
          @props = params[:locals][:page][:props]
          @component = params[:locals][:page][:component]
        else
          # Sequential Inertia request
          @view_data = {}
          json = JSON.parse(params[:json])
          @props = json['props']
          @component = json['component']
        end
      end
    end

    # Module prepended to Renderer's singleton class to intercept .new calls
    module RendererInterceptor
      def new(component, controller, request, response, render_method, **options)
        context = InertiaRails.test_context

        if context&.inertia_testing_enabled?
          wrapped_render = context.inertia_wrap_render(render_method)
          super(component, controller, request, response, wrapped_render, **options)
        else
          super
        end
      end
    end

    class << self
      def install!
        return if @installed

        InertiaRails::Renderer.singleton_class.prepend(RendererInterceptor)
        @installed = true
      end

      def installed?
        @installed
      end
    end
  end

  # Thread-local test context management
  class << self
    def test_context
      Thread.current[:inertia_test_context]
    end

    def test_context=(context)
      Thread.current[:inertia_test_context] = context
    end
  end
end
