require 'glimmer-dsl-libui'

module Glimmer
  module View
    # General-Purpose Bar Chart Custom Control
    class BarChart
      class << self
        def interpret_color(color_object)
          # TODO refactor move this method to somewhere common like Glimmer module
          @color_cache ||= {}
          @color_cache[color_object] ||= Glimmer::LibUI.interpret_color(color_object)
        end
      end
    
      include Glimmer::LibUI::CustomControl
      
      DEFAULT_CHART_PADDING_WIDTH = 5.0
      DEFAULT_CHART_PADDING_HEIGHT = 5.0
      DEFAULT_CHART_GRID_MARKER_PADDING_WIDTH = 37.0
      DEFAULT_CHART_BAR_PADDING_WIDTH_PERCENTAGE = 30.0
      
      DEFAULT_CHART_STROKE_GRID = [185, 184, 185]
      DEFAULT_CHART_STROKE_MARKER = [185, 184, 185]
      DEFAULT_CHART_STROKE_MARKER_LINE = [217, 217, 217, thickness: 1, dashes: [1, 1]]
      
      DEFAULT_CHART_COLOR_BAR = [92, 122, 190]
      DEFAULT_CHART_COLOR_MARKER_TEXT = [96, 96, 96]
      
      DEFAULT_CHART_FONT_MARKER_TEXT = {family: "Arial", size: 14}
      
      option :width, default: 600
      option :height, default: 200
      
      option :chart_padding_width, default: DEFAULT_CHART_PADDING_WIDTH
      option :chart_padding_height, default: DEFAULT_CHART_PADDING_HEIGHT
      option :chart_grid_marker_padding_width, default: DEFAULT_CHART_GRID_MARKER_PADDING_WIDTH
      option :chart_bar_padding_width_percentage, default: DEFAULT_CHART_BAR_PADDING_WIDTH_PERCENTAGE
      
      option :chart_stroke_grid, default: DEFAULT_CHART_STROKE_GRID
      option :chart_stroke_marker, default: DEFAULT_CHART_STROKE_MARKER
      option :chart_stroke_marker_line, default: DEFAULT_CHART_STROKE_MARKER_LINE
      
      option :chart_color_bar, default: DEFAULT_CHART_COLOR_BAR
      option :chart_color_marker_text, default: DEFAULT_CHART_COLOR_MARKER_TEXT
      
      option :chart_font_marker_text, default: DEFAULT_CHART_FONT_MARKER_TEXT
      
      # Hash map of x-axis values (String) to y-axis values (Numeric)
      # Example:
      # {
      #   '1' => 38,
      #   '2' => 83,
      #   '3' => 48,
      #   '4' => 83,
      #   '5' => 92,
      #   '6' => 13,
      #   '7' => 03,
      # }
      option :values, default: {}
      
      attr_reader :bar_width_including_padding
      
      after_body do
        observe(self, :values) do
          clear_drawing_cache
          body_root.queue_redraw_all
        end
        observe(self, :width) do
          clear_drawing_cache
        end
        observe(self, :height) do
          clear_drawing_cache
        end
      end
  
      body {
        area { |chart_area|
          on_draw do
            calculate_dynamic_options
            chart_background
            grid_lines
            bars
          end
        }
      }
      
      private
      
      def clear_drawing_cache
        @y_resolution = nil
        @bar_width_including_padding = nil
        @grid_marker_points = nil
        @grid_marker_number_values = nil
        @grid_marker_numbers = nil
        @chart_stroke_marker_values = nil
        @mod_values = nil
      end
      
      def calculate_dynamic_options
        calculate_bar_width_including_padding
      end
      
      def calculate_bar_width_including_padding
        return if values.empty?
        
        @bar_width_including_padding ||= begin
          value = width_drawable / (values.size - 1).to_f
          [value, width_drawable].min
        end
      end
      
      def bar_width
        @bar_width_including_padding*((100.0 - chart_bar_padding_width_percentage)/100.0)
      end
      
      def bar_padding_width
        @bar_width_including_padding*(chart_bar_padding_width_percentage/100.0)
      end
      
      def width_drawable
        width - 2.0*chart_padding_width - chart_grid_marker_padding_width
      end
      
      def height_drawable
        height - 2.0*chart_padding_height
      end
      
      def chart_background
        rectangle(0, 0, width, height) {
          fill 255, 255, 255
        }
      end
  
      def grid_lines
        line(chart_padding_width, chart_padding_height, chart_padding_width, height - chart_padding_height) {
          stroke chart_stroke_grid
        }
        line(chart_padding_width, height - chart_padding_height, width - chart_padding_width, height - chart_padding_height) {
          stroke chart_stroke_grid
        }
        grid_marker_number_font = chart_font_marker_text.merge(size: 11)
        @grid_marker_number_values ||= []
        @grid_marker_numbers ||= []
        @chart_stroke_marker_values ||= []
        @mod_values ||= []
        grid_marker_points.each_with_index do |marker_point, index|
          @grid_marker_number_values[index] ||= begin
            value = (grid_marker_points.size - index).to_i
            value = y_value_max if !y_value_max.nil? && y_value_max.to_i != y_value_max && index == 0
            value
          end
          grid_marker_number_value = @grid_marker_number_values[index]
          @grid_marker_numbers[index] ||= (grid_marker_number_value >= 1000) ? "#{grid_marker_number_value / 1000}K" : grid_marker_number_value.to_s
          grid_marker_number = @grid_marker_numbers[index]
          @chart_stroke_marker_values[index] ||= BarChart.interpret_color(chart_stroke_marker).tap do |color_hash|
            color_hash[:thickness] = (index != grid_marker_points.size - 1 ? 2 : 1) if color_hash[:thickness].nil?
          end
          chart_stroke_marker_value = @chart_stroke_marker_values[index]
          @mod_values[index] ||= begin
            mod_value_multiplier = ((grid_marker_points.size / max_marker_count) + 1)
            [(5 * mod_value_multiplier), 1].max
          end
          mod_value = @mod_values[index]
          comparison_value = (mod_value > 2) ? 0 : 1
          if mod_value > 2
            if grid_marker_number_value % mod_value == comparison_value
              line(marker_point[:x], marker_point[:y], marker_point[:x] + 4, marker_point[:y]) {
                stroke chart_stroke_marker_value
              }
            end
          else
            line(marker_point[:x], marker_point[:y], marker_point[:x] + 4, marker_point[:y]) {
              stroke chart_stroke_marker_value
            }
          end
          if grid_marker_number_value % mod_value == comparison_value && grid_marker_number_value != grid_marker_points.size
            line(marker_point[:x], marker_point[:y], marker_point[:x] + width - chart_padding_width, marker_point[:y]) {
              stroke chart_stroke_marker_line
            }
          end
          if grid_marker_number_value % mod_value == comparison_value || grid_marker_number_value != grid_marker_number_value.to_i
            grid_marker_number_width = estimate_width_of_text(grid_marker_number, grid_marker_number_font)
            text(marker_point[:x] + 4 + 3, marker_point[:y] - 6, grid_marker_number_width) {
              string(grid_marker_number) {
                font grid_marker_number_font
                color chart_color_marker_text
              }
            }
          end
        end
      end
      
      def grid_marker_points
        if @grid_marker_points.nil?
          if values.any?
            chart_y_max = [y_value_max, 1].max
            current_chart_height = (height - chart_padding_height * 2)
            y_value_count = chart_y_max.ceil
            @grid_marker_points = chart_y_max.to_i.times.map do |marker_index|
              x = chart_padding_width
              y_value = y_value_count - marker_index
              scaled_y_value = y_value.to_f * y_resolution.to_f
              y = height - chart_padding_height - scaled_y_value
              {x: x, y: y}
            end
          end
        end

        @grid_marker_points
      end
      
      def max_marker_count
        [(0.15*height).to_i, 1].max
      end
      
      def bars
        values.each_with_index do |(x_value, y_value), index|
          x = chart_grid_marker_padding_width + chart_padding_width + (index * bar_width_including_padding) + bar_padding_width
          bar_height = y_value * y_resolution
          y = height - chart_padding_height - bar_height
          rectangle(x, y, bar_width, bar_height) {
            fill chart_color_bar
          }
        end
      end
      
      # this is the multiplier that we must multiply by the relative y value
      def y_resolution
        # TODO in the future, we will use the y range, but today, we assume it starts at 0
        @y_resolution ||= height_drawable.to_f / y_value_max.to_f
      end
      
      def y_value_max
        if @y_value_max.nil?
          @y_value_max = values.values.max.to_f
        end
        @y_value_max
      end
      
      def estimate_width_of_text(text_string, font_properties)
        # TODO refactor move this method to somewhere common like Glimmer module
        font_size = font_properties[:size] || 16
        estimated_font_width = 0.6 * font_size
        text_string.chars.size * estimated_font_width
      end
      
    end
  end
end
