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
      DEFAULT_CHART_BAR_PADDING_WIDTH_PERCENTAGE = 30.0
      
      # This is y-axis grid marker padding that is to the left of the bar chart
      DEFAULT_CHART_GRID_MARKER_PADDING_WIDTH = 37.0
      # This is x-axis grid marker padding that is below the bar chart
      DEFAULT_CHART_GRID_MARKER_PADDING_HEIGHT = 30.0
      
      # This is y-axis label padding that is to the left of the bar chart
      DEFAULT_CHART_Y_AXIS_LABEL_PADDING_WIDTH = 25.0
      
      # This is x-axis label padding that is below the bar chart
      DEFAULT_CHART_X_AXIS_LABEL_PADDING_HEIGHT = 25.0
      
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
      option :chart_bar_padding_width_percentage, default: DEFAULT_CHART_BAR_PADDING_WIDTH_PERCENTAGE
      
      # This is y-axis grid marker padding that is to the left of the bar chart
      option :chart_grid_marker_padding_width, default: DEFAULT_CHART_GRID_MARKER_PADDING_WIDTH
      
      # This is x-axis grid marker padding that is below the bar chart
      option :chart_grid_marker_padding_height, default: DEFAULT_CHART_GRID_MARKER_PADDING_HEIGHT
      
      # This is y-axis label padding that is to the left of the bar chart
      option :chart_y_axis_label_padding_width, default: DEFAULT_CHART_Y_AXIS_LABEL_PADDING_WIDTH
      
      # This is x-axis label padding that is below the bar chart
      option :chart_x_axis_label_padding_height, default: DEFAULT_CHART_X_AXIS_LABEL_PADDING_HEIGHT
      
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
      option :x_axis_label, default: nil
      option :y_axis_label, default: nil
      
      attr_reader :bar_width_including_padding
      
      before_body do
        self.chart_y_axis_label_padding_width = 0 if y_axis_label.to_s.empty?
        self.chart_x_axis_label_padding_height = 0 if x_axis_label.to_s.empty?
      end
      
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
        @y_axis_grid_marker_points = nil
        @grid_marker_number_values = nil
        @grid_marker_numbers = nil
        @chart_stroke_marker_values = nil
        @y_axis_mod_values = nil
        @y_value_max = nil
        @bars_data = nil
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
        width - 2.0*chart_padding_width - chart_grid_marker_padding_width - chart_y_axis_label_padding_width
      end
      
      def height_drawable
        height - 2.0*chart_padding_height - chart_grid_marker_padding_height - chart_x_axis_label_padding_height
      end
      
      def chart_background
        rectangle(0, 0, width, height) {
          fill 255, 255, 255
        }
      end
      
      def grid_lines
        x_axis_grid_lines
        y_axis_grid_lines
        x_axis_label_text
        y_axis_label_text
      end
  
      def x_axis_grid_lines
        line_y = height - chart_padding_height - chart_grid_marker_padding_height - chart_x_axis_label_padding_height
        line(chart_x_axis_label_padding_height + chart_padding_width, line_y, width - chart_padding_width, line_y) {
          stroke chart_stroke_grid
        }
      end
  
      def y_axis_grid_lines
        line_x = chart_y_axis_label_padding_width + chart_padding_width
        line(line_x, chart_padding_height, line_x, height - chart_padding_height - chart_grid_marker_padding_height - chart_x_axis_label_padding_height) {
          stroke chart_stroke_grid
        }
        grid_marker_number_font = marker_font
        @grid_marker_number_values ||= []
#         @grid_marker_numbers ||= []
        @chart_stroke_marker_values ||= []
        @y_axis_mod_values ||= []
        y_axis_grid_marker_points.each_with_index do |marker_point, index|
          @grid_marker_number_values[index] ||= begin
            value = (y_axis_grid_marker_points.size - index).to_i
            value = y_value_max if !y_value_max.nil? && y_value_max.to_i != y_value_max && index == 0
            value
          end
          grid_marker_number_value = @grid_marker_number_values[index]
# figuring out how to setup 1K numbers without repeating a number twice is more complicated than just enabling this code
# disabling for now
#           @grid_marker_numbers[index] ||= (grid_marker_number_value >= 1000) ? "#{grid_marker_number_value / 1000}K" : grid_marker_number_value.to_s
          grid_marker_number = grid_marker_number_value.to_s
          @chart_stroke_marker_values[index] ||= BarChart.interpret_color(chart_stroke_marker).tap do |color_hash|
            color_hash[:thickness] = (index != y_axis_grid_marker_points.size - 1 ? 2 : 1) if color_hash[:thickness].nil?
          end
          chart_stroke_marker_value = @chart_stroke_marker_values[index]
          @y_axis_mod_values[index] ||= begin
            mod_value_multiplier = ((y_axis_grid_marker_points.size / y_axis_max_marker_count) + 1)
            [(5 * mod_value_multiplier), 1].max
          end
          mod_value = @y_axis_mod_values[index]
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
          if grid_marker_number_value % mod_value == comparison_value && grid_marker_number_value != y_axis_grid_marker_points.size
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
      
      def y_axis_grid_marker_points
        if @y_axis_grid_marker_points.nil?
          if values.any?
            chart_y_max = [y_value_max, 1].max
            current_chart_height = (height - chart_padding_height * 2 - chart_grid_marker_padding_height - chart_x_axis_label_padding_height)
            y_value_count = chart_y_max.ceil
            @y_axis_grid_marker_points = chart_y_max.to_i.times.map do |marker_index|
              x = chart_y_axis_label_padding_width + chart_padding_width
              y_value = y_value_count - marker_index
              scaled_y_value = y_value.to_f * y_resolution.to_f
              y = height - chart_padding_height - chart_grid_marker_padding_height - chart_x_axis_label_padding_height - scaled_y_value
              {x: x, y: y}
            end
          end
        end

        @y_axis_grid_marker_points
      end
      
      def x_axis_label_text
        x_axis_label_font = marker_font
        x_axis_label_width = estimate_width_of_text(x_axis_label, x_axis_label_font)
        middle_of_x_axis_label_padding_x = chart_y_axis_label_padding_width + (width - chart_y_axis_label_padding_width)/2.0
        x_axis_label_x = middle_of_x_axis_label_padding_x - x_axis_label_width/2.0
        middle_of_x_axis_label_padding_y = height - (chart_x_axis_label_padding_height/2.0)
        x_axis_label_y = middle_of_x_axis_label_padding_y - x_axis_label_font[:size]/2.0 - 7.0
        text(x_axis_label_x, x_axis_label_y, x_axis_label_width) {
          string(x_axis_label) {
            font x_axis_label_font
            color chart_color_marker_text
          }
        }
      end
      
      def y_axis_label_text
        y_axis_label_font = marker_font
        y_axis_label_width = estimate_width_of_text(y_axis_label, y_axis_label_font)
        middle_of_y_axis_label_padding_x = chart_y_axis_label_padding_width/2.0
        y_axis_label_x = middle_of_y_axis_label_padding_x - y_axis_label_width/2.0
        middle_of_y_axis_label_padding_y = (height - chart_x_axis_label_padding_height)/2.0
        y_axis_label_y = middle_of_y_axis_label_padding_y - y_axis_label_font[:size]/2.0
        text(y_axis_label_x, y_axis_label_y, y_axis_label_width) {
          string(y_axis_label) {
            font y_axis_label_font
            color chart_color_marker_text
          }
          transform {
            rotate(middle_of_y_axis_label_padding_x, middle_of_y_axis_label_padding_y, -90)
          }
        }
      end
      
      def y_axis_max_marker_count
        [(0.15*height_drawable).to_i, 1].max
      end
      
      def bars
        @bars_data = calculate_bars_data
        @bars_data.each do |bar_data|
          bar(bar_data)
        end
        x_axis_grid_markers(@bars_data)
      end
      
      def calculate_bars_data
        values.each_with_index.map do |(x_value, y_value), index|
          x = chart_y_axis_label_padding_width + chart_grid_marker_padding_width + chart_padding_width + (index * bar_width_including_padding) + bar_padding_width
          bar_height = y_value * y_resolution
          y = height - chart_grid_marker_padding_height - chart_x_axis_label_padding_height - chart_padding_height - bar_height
          x_axis_grid_marker_text = x_value.to_s
          grid_marker_number_font = marker_font
          x_axis_grid_marker_text_size = estimate_width_of_text(x_axis_grid_marker_text, grid_marker_number_font)
          middle_of_bar_x = x + bar_width/2.0
          x_axis_grid_marker_x = middle_of_bar_x - x_axis_grid_marker_text_size/2.0
          middle_of_x_axis_grid_marker_padding = height - chart_grid_marker_padding_height/2.0 - chart_x_axis_label_padding_height
          x_axis_grid_marker_y = middle_of_x_axis_grid_marker_padding - chart_font_marker_text[:size]/2.0 - 7.0
          {
            index: index,
            x: x,
            y: y,
            bar_width: bar_width,
            bar_height: bar_height,
            x_axis_grid_marker_x: x_axis_grid_marker_x,
            x_axis_grid_marker_y: x_axis_grid_marker_y,
            x_axis_grid_marker_text: x_axis_grid_marker_text,
            x_axis_grid_marker_text_size: x_axis_grid_marker_text_size,
          }
        end
      end
      
      def bar(bar_data)
        rectangle(bar_data[:x], bar_data[:y], bar_data[:bar_width], bar_data[:bar_height]) {
          fill chart_color_bar
        }
      end
      
      def x_axis_grid_markers(bars_data)
        skip_count = 0
        collision_detected = true
        while collision_detected
          collision_detected = bars_data.each_with_index.any? do |bar_data, index|
            next if index == 0
            last_bar_text_data = bars_data[index - 1]
            bar_data[:x_axis_grid_marker_x] < (last_bar_text_data[:x_axis_grid_marker_x] + last_bar_text_data[:x_axis_grid_marker_text_size] + 5)
          end
          if collision_detected
            skip_count += 1
            bars_data = bars_data.each_with_index.select {|bar_data, index| index % (skip_count+1) == 0 }.map(&:first)
          end
        end
        x_axis_grid_marker_font = marker_font
        bars_data.each do |bar_data|
          text(bar_data[:x_axis_grid_marker_x], bar_data[:x_axis_grid_marker_y], bar_data[:x_axis_grid_marker_text_size]) {
            string(bar_data[:x_axis_grid_marker_text]) {
              font x_axis_grid_marker_font
              color chart_color_marker_text
            }
          }
        end
      end
      
      def marker_font
        chart_font_marker_text.merge(size: 11)
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
        return 0 if text_string.to_s.empty?
        # TODO refactor move this method to somewhere common like Glimmer module
        font_size = font_properties[:size] || 16
        estimated_font_width = 0.63 * font_size
        text_string.chars.size * estimated_font_width
      end
      
    end
  end
end
