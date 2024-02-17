require 'glimmer-dsl-libui'

module Glimmer
  module View
    # General-Purpose Bubble Chart Custom Control
    class BubbleChart
      class << self
        def interpret_color(color_object)
          @color_cache ||= {}
          @color_cache[color_object] ||= Glimmer::LibUI.interpret_color(color_object)
        end
      end
    
      include Glimmer::LibUI::CustomControl
      
      DEFAULT_CHART_PADDING_WIDTH = 5.0
      DEFAULT_CHART_PADDING_HEIGHT = 5.0
      DEFAULT_CHART_GRID_MARKER_PADDING_WIDTH = 37.0
      DEFAULT_CHART_POINT_DISTANCE = 15.0
      DEFAULT_CHART_POINT_RADIUS = 1.0
      DEFAULT_CHART_SELECTED_POINT_RADIUS = 3.0
      
      DEFAULT_CHART_STROKE_GRID = [185, 184, 185]
      DEFAULT_CHART_STROKE_MARKER = [185, 184, 185]
      DEFAULT_CHART_STROKE_MARKER_LINE = [217, 217, 217, thickness: 1, dashes: [1, 1]]
      DEFAULT_CHART_STROKE_PERIODIC_LINE = [121, 121, 121, thickness: 1, dashes: [1, 1]]
      DEFAULT_CHART_STROKE_HOVER_LINE = [133, 133, 133]
      
      DEFAULT_CHART_FILL_SELECTED_POINT = :white
      
      DEFAULT_CHART_COLOR_BUBBLE = [92, 122, 190]
      DEFAULT_CHART_COLOR_MARKER_TEXT = [96, 96, 96]
      DEFAULT_CHART_COLOR_PERIOD_TEXT = [163, 40, 39]
      
      DEFAULT_CHART_FONT_MARKER_TEXT = {family: "Arial", size: 14}
      
      DEFAULT_CHART_STATUS_HEIGHT = 30.0
      
      DAY_IN_SECONDS = 60*60*24
  
      option :width, default: 600
      option :height, default: 200
      
      option :lines, default: [] # TODO remove this once conversion of code to bubble chart is complete
      option :values, default: []
      
      option :chart_padding_width, default: DEFAULT_CHART_PADDING_WIDTH
      option :chart_padding_height, default: DEFAULT_CHART_PADDING_HEIGHT
      option :chart_grid_marker_padding_width, default: DEFAULT_CHART_GRID_MARKER_PADDING_WIDTH
      option :chart_point_distance, default: DEFAULT_CHART_POINT_DISTANCE
      option :chart_point_radius, default: DEFAULT_CHART_POINT_RADIUS
      option :chart_selected_point_radius, default: DEFAULT_CHART_SELECTED_POINT_RADIUS
      
      option :chart_stroke_grid, default: DEFAULT_CHART_STROKE_GRID
      option :chart_stroke_marker, default: DEFAULT_CHART_STROKE_MARKER
      option :chart_stroke_marker_line, default: DEFAULT_CHART_STROKE_MARKER_LINE
      option :chart_stroke_periodic_line, default: DEFAULT_CHART_STROKE_PERIODIC_LINE
      option :chart_stroke_hover_line, default: DEFAULT_CHART_STROKE_HOVER_LINE
      
      option :chart_fill_selected_point, default: DEFAULT_CHART_FILL_SELECTED_POINT
      
      option :chart_color_bubble, default: DEFAULT_CHART_COLOR_BUBBLE
      option :chart_color_marker_text, default: DEFAULT_CHART_COLOR_MARKER_TEXT
      option :chart_color_period_text, default: DEFAULT_CHART_COLOR_PERIOD_TEXT
      
      option :chart_font_marker_text, default: DEFAULT_CHART_FONT_MARKER_TEXT
      
      option :chart_status_height, default: DEFAULT_CHART_STATUS_HEIGHT
      
      option :display_attributes_on_hover, default: false
      
      before_body do
        generate_lines
      end
      
      after_body do
        observe(self, :values) do
          generate_lines
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
            all_bubble_charts
            periodic_lines
            hover_stats
          end

          on_mouse_moved do |event|
            @hover_point = {x: event[:x], y: event[:y]}
        
            if @hover_point && lines && lines[0] && @points && @points[lines[0]] && !@points[lines[0]].empty?
              x = @hover_point[:x]
              closest_point_index = ((width - chart_padding_width - x) / chart_point_distance_for_line(lines[0])).round
              if closest_point_index != @closest_point_index
                @closest_point_index = closest_point_index
                chart_area.queue_redraw_all
              end
            end
          end

          on_mouse_exited do |outside|
            if !@hover_point.nil?
              @hover_point = nil
              @closest_point_index = nil
              chart_area.queue_redraw_all
            end
          end
        }
      }
      
      private
      
      def generate_lines
        normalized_values = []
        values.each do |x_value, y_z_hash|
          y_z_hash.each do |y_value, z_value|
            normalized_values << {x_value: x_value, y_value: y_value, z_value: z_value}
          end
        end
        normalized_lines_values = []
        normalized_values.each do |normalized_value|
          normalized_line_values = normalized_lines_values.detect do |line|
            !line.include?(normalized_value[:x_value])
          end
          if normalized_line_values.nil?
            normalized_line_values = {}
            normalized_lines_values << normalized_line_values
          end
          normalized_line_values[normalized_value[:x_value]] = normalized_value[:y_value]
        end
        self.lines = normalized_lines_values.map do |normalized_line_values|
          # TODO take name from component options/constants
          {name: 'Bubble Chart', values: normalized_line_values}
        end
      end
      
      def clear_drawing_cache
        @chart_point_distance_per_line = nil
        @y_value_max_for_all_lines = nil
        @x_resolution = nil
        @y_resolution = nil
        @x_value_range_for_all_lines = nil
        @x_value_min_for_all_lines = nil
        @x_value_max_for_all_lines = nil
        @grid_marker_points = nil
        @points = nil
        @grid_marker_number_values = nil
        @grid_marker_numbers = nil
        @chart_stroke_marker_values = nil
        @mod_values = nil
      end
      
      def calculate_dynamic_options
        calculate_chart_point_distance_per_line
      end
      
      def calculate_chart_point_distance_per_line
        return unless lines[0]&.[](:y_values) && chart_point_distance == :width_divided_by_point_count
        
        @chart_point_distance_per_line ||= lines.inject({}) do |hash, line|
          value = (width - 2.0*chart_padding_width - chart_grid_marker_padding_width) / (line[:y_values].size - 1).to_f
          value = [value, width_drawable].min
          hash.merge(line => value)
        end
      end
      
      def width_drawable
        width - 2.0*chart_padding_width - chart_grid_marker_padding_width
      end
      
      def height_drawable
        height - 2.0*chart_padding_height
      end
      
      def chart_point_distance_for_line(line)
        @chart_point_distance_per_line&.[](line) || chart_point_distance
      end
      
      def chart_background
        rectangle(0, 0, width, height + (display_attributes_on_hover ? chart_status_height : 0)) {
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
            value = y_value_max_for_all_lines if !y_value_max_for_all_lines.nil? && y_value_max_for_all_lines.to_i != y_value_max_for_all_lines && index == 0
            value
          end
          grid_marker_number_value = @grid_marker_number_values[index]
          # TODO consider not caching the following line as that might save memory and run faster without caching
          @grid_marker_numbers[index] ||= (grid_marker_number_value >= 1000) ? "#{grid_marker_number_value / 1000}K" : grid_marker_number_value.to_s
          grid_marker_number = @grid_marker_numbers[index]
          @chart_stroke_marker_values[index] ||= BubbleChart.interpret_color(chart_stroke_marker).tap do |color_hash|
            color_hash[:thickness] = (index != grid_marker_points.size - 1 ? 2 : 1) if color_hash[:thickness].nil?
          end
          chart_stroke_marker_value = @chart_stroke_marker_values[index]
          @mod_values[index] ||= begin
            mod_value_multiplier = ((grid_marker_points.size / max_marker_count) + 1)
            [((mod_value_multiplier <= 2 ? 2 : 5) * mod_value_multiplier), 1].max
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
          if lines[0]&.[](:y_values)
            chart_y_max = [y_value_max_for_all_lines, 1].max
            current_chart_height = (height - chart_padding_height * 2)
            division_height = current_chart_height / chart_y_max
            @grid_marker_points = chart_y_max.to_i.times.map do |marker_index|
              x = chart_padding_width
              y = chart_padding_height + marker_index * division_height
              {x: x, y: y}
            end
          else
            chart_y_max = y_value_max_for_all_lines
            y_value_count = chart_y_max.ceil
            @grid_marker_points = y_value_count.times.map do |marker_index|
              x = chart_padding_width
              y_value = y_value_count - marker_index
              if marker_index == 0 && chart_y_max.ceil != chart_y_max.to_i
                y_value = chart_y_max
              end
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
      
      def all_bubble_charts
        lines.each { |chart_line| single_bubble_chart(chart_line) }
      end

      def single_bubble_chart(chart_line)
        points = calculate_points(chart_line)
        points.to_a.each do |point|
#           circle(point[:x], point[:y], chart_point_radius) {
          circle(point[:x], point[:y], point[:z]) {
            fill chart_color_bubble
          }
        end
      end
      
      def calculate_points(chart_line)
        if lines[0]&.[](:y_values)
          calculate_points_relative(chart_line)
        else
          calculate_points_absolute(chart_line)
        end
      end
      
      def calculate_points_relative(chart_line)
        @points ||= {}
        if @points[chart_line].nil?
          y_values = chart_line[:y_values] || []
          y_values = y_values[0, max_visible_point_count(chart_line)]
          chart_y_max = [y_value_max_for_all_lines, 1].max
          points = y_values.each_with_index.map do |y_value, index|
            x = width - chart_padding_width - (index * chart_point_distance_for_line(chart_line))
            y = ((height - chart_padding_height) - y_value * ((height - chart_padding_height * 2) / chart_y_max))
            {x: x, y: y, index: index, y_value: y_value}
          end
          @points[chart_line] = translate_points(chart_line, points)
        end
        @points[chart_line]
      end
      
      def calculate_points_absolute(chart_line)
        @points ||= {}
        # and then use them to produce a :z key in the hash below
        if @points[chart_line].nil?
          values = chart_line[:values] || []
          # all points are visible when :values is supplied because we stretch the chart to show them all
          chart_y_max = [y_value_max_for_all_lines, 1].max
          x_value_range_for_all_lines
          points = values.each_with_index.map do |(x_value, y_value), index|
            z_value = self.values[x_value][y_value]
            relative_x_value = x_value - x_value_min_for_all_lines
            scaled_x_value = x_value_range_for_all_lines == 0 ? 0 : relative_x_value.to_f * x_resolution.to_f
            scaled_y_value = y_value_max_for_all_lines == 0 ? 0 : y_value.to_f * y_resolution.to_f
            x = width - chart_padding_width - scaled_x_value
            y = height - chart_padding_height - scaled_y_value
#             z = z_value == 0 ? z_value : z_value + 1 # TODO change 1 with magnification factor or something
            z = z_value
            {x: x, y: y, z: z, index: index, x_value: x_value, y_value: y_value}
          end
          # Translation is not supported today
          # TODO consider supporting in the future
#           @points[chart_line] = translate_points(chart_line, points)
          @points[chart_line] = points
        end
        @points[chart_line]
      end
      
      # this is the multiplier that we must multiply by the relative x value
      def x_resolution
        @x_resolution ||= width_drawable.to_f / x_value_range_for_all_lines.to_f
      end
      
      # this is the multiplier that we must multiply by the relative y value
      def y_resolution
        # TODO in the future, we will use the y range, but today, we assume it starts at 0
        @y_resolution ||= height_drawable.to_f / y_value_max_for_all_lines.to_f
      end
      
      def x_value_range_for_all_lines
        @x_value_range_for_all_lines ||= x_value_max_for_all_lines - x_value_min_for_all_lines
      end
      
      def x_value_min_for_all_lines
        if @x_value_min_for_all_lines.nil?
          line_visible_x_values = lines.map { |line| line[:values].to_h.keys }
          all_visible_x_values = line_visible_x_values.reduce(:+) || []
          # Right now, we assume Time objects
          # TODO support String representations of Time (w/ some auto-detection of format)
          @x_value_min_for_all_lines = all_visible_x_values.min
        end
        @x_value_min_for_all_lines
      end
      
      def x_value_max_for_all_lines
        if @x_value_max_for_all_lines.nil?
          line_visible_x_values = lines.map { |line| line[:values].to_h.keys }
          all_visible_x_values = line_visible_x_values.reduce(:+) || []
          # Right now, we assume Time objects
          # TODO support String representations of Time (w/ some auto-detection of format)
          @x_value_max_for_all_lines = all_visible_x_values.max
        end
        @x_value_max_for_all_lines
      end
      
      def y_value_max_for_all_lines
        if @y_value_max_for_all_lines.nil?
          if lines[0]&.[](:y_values)
            line_visible_y_values = lines.map { |line| line[:y_values][0, max_visible_point_count(line)] }
          else
            # When using :values , we always stretch the chart so that all points are visible
            line_visible_y_values = lines.map { |line| line[:values].to_h.values }
          end
          all_visible_y_values = line_visible_y_values.reduce(:+) || []
          @y_value_max_for_all_lines = all_visible_y_values.max.to_f
        end
        @y_value_max_for_all_lines
      end
      
      def translate_points(chart_line, points)
        max_job_count_before_translation = ((width / chart_point_distance_for_line(chart_line)).to_i + 1)
        x_translation = [(points.size - max_job_count_before_translation) * chart_point_distance_for_line(chart_line), 0].max
        if x_translation > 0
          points.each do |point|
            # need to check if point[:x] is present because if the user shrinks the window, we drop points
            point[:x] = point[:x] - x_translation if point[:x]
          end
        end
        points
      end
      
      def max_visible_point_count(chart_line) = ((width - chart_grid_marker_padding_width) / chart_point_distance_for_line(chart_line)).to_i + 1

      def periodic_lines
        return unless lines && lines[0] && lines[0][:x_interval_in_seconds] && lines[0][:x_interval_in_seconds] == DAY_IN_SECONDS
        day_count = lines[0][:y_values].size
        case day_count
        when ..7
          @points[lines[0]].each_with_index do |point, index|
            next if index == 0
            
            line(point[:x], chart_padding_height, point[:x], height - chart_padding_height) {
              stroke chart_stroke_periodic_line
            }
            day = calculated_x_value(point[:index]).strftime("%e")
            font_size = chart_font_marker_text[:size]
            text(point[:x], height - chart_padding_height - font_size*1.4, font_size*2) {
              string(day) {
                font chart_font_marker_text
                color chart_color_period_text
              }
            }
          end
        when ..30
          @points[lines[0]].each_with_index do |point, index|
            day_number = index + 1
            if day_number % 7 == 0
              line(point[:x], chart_padding_height, point[:x], height - chart_padding_height) {
                stroke chart_stroke_periodic_line
              }
              date = calculated_x_value(point[:index]).strftime("%b %e")
              font_size = chart_font_marker_text[:size]
              text(point[:x] + 4, height - chart_padding_height - font_size*1.4, font_size*6) {
                string(date) {
                  font chart_font_marker_text
                  color chart_color_period_text
                }
              }
            end
          end
        else
          @points[lines[0]].each do |point|
            if calculated_x_value(point[:index]).strftime("%d") == "01"
              line(point[:x], chart_padding_height, point[:x], height - chart_padding_height) {
                stroke chart_stroke_periodic_line
              }
              date = calculated_x_value(point[:index]).strftime("%b")
              font_size = chart_font_marker_text[:size]
              text(point[:x] + 4, height - chart_padding_height - font_size*1.4, font_size*6) {
                string(date) {
                  font chart_font_marker_text
                  color chart_color_period_text
                }
              }
            end
          end
        end
      end
      
      def hover_stats
        return unless display_attributes_on_hover && @closest_point_index
        
        require "bigdecimal"
        require "perfect_shape/point"
        
        if @hover_point && lines && lines[0] && @points && @points[lines[0]] && !@points[lines[0]].empty?
          x = @hover_point[:x]
          closest_points = lines.map { |line| @points[line][@closest_point_index] }
          closest_x = closest_points[0]&.[](:x)
          line(closest_x, chart_padding_height, closest_x, height - chart_padding_height) {
            stroke chart_stroke_hover_line
          }
          closest_points.each_with_index do |closest_point, index|
            next unless closest_point && closest_point[:x] && closest_point[:y]
            
            circle(closest_point[:x], closest_point[:y], chart_selected_point_radius) {
              fill chart_fill_selected_point == :line_stroke ? chart_color_bubble : chart_fill_selected_point
              stroke_value = chart_color_bubble.dup
              stroke_value << {} unless stroke_value.last.is_a?(Hash)
              stroke_value.last[:thickness] = 2
              stroke stroke_value
            }
          end
          text_label = formatted_x_value(@closest_point_index)
          text_label_width = estimate_width_of_text(text_label, DEFAULT_CHART_FONT_MARKER_TEXT)
          lines_with_closest_points = lines.each_with_index.map do |line, index|
            next if closest_points[index].nil?
            
            line
          end.compact
          closest_point_texts = lines_with_closest_points.map { |line| "#{line[:name]}: #{line[:y_values][@closest_point_index]}" }
          closest_point_text_widths = closest_point_texts.map do |text|
            estimate_width_of_text(text, chart_font_marker_text)
          end
          square_size = 12.0
          square_to_label_padding = 10.0
          label_padding = 10.0
          text_label_x = width - chart_padding_width - text_label_width - label_padding -
            (lines_with_closest_points.size*(square_size + square_to_label_padding) + (lines_with_closest_points.size - 1)*label_padding + closest_point_text_widths.sum)
          text_label_y = height + chart_padding_height

          text(text_label_x, text_label_y, text_label_width) {
            string(text_label) {
              font DEFAULT_CHART_FONT_MARKER_TEXT
              color chart_color_marker_text
            }
          }

          relative_x = text_label_x + text_label_width
          lines_with_closest_points.size.times do |index|
            square_x = relative_x + label_padding

            square(square_x, text_label_y + 2, square_size) {
              fill chart_color_bubble
            }

            attribute_label_x = square_x + square_size + square_to_label_padding
            attribute_text = closest_point_texts[index]
            attribute_text_width = closest_point_text_widths[index]
            relative_x = attribute_label_x + attribute_text_width

            text(attribute_label_x, text_label_y, attribute_text_width) {
              string(attribute_text) {
                font chart_font_marker_text
                color chart_color_marker_text
              }
            }
          end
        end
      end
      
      def formatted_x_value(x_value_index)
        # Today, we make the assumption that all lines have points along the same x-axis values
        # TODO In the future, we can support different x values along different lines
        chart_line = lines[0]
        x_value_format = chart_line[:x_value_format] || :to_s
        x_value = calculated_x_value(x_value_index)
        if (x_value_format.is_a?(Symbol) || x_value_format.is_a?(String))
          x_value.send(x_value_format)
        else
          x_value_format.call(x_value)
        end
      end
      
      def calculated_x_value(x_value_index)
        # Today, we make the assumption that all lines have points along the same x-axis values
        # TODO In the future, we can support different x values along different lines
        chart_line = lines[0]
        chart_line[:x_value_start] - (chart_line[:x_interval_in_seconds] * x_value_index)
      end
      
      def estimate_width_of_text(text_string, font_properties)
        return 0 if text_string.to_s.empty?
        font_size = font_properties[:size] || 16
        estimated_font_width = 0.63 * font_size
        text_string.chars.size * estimated_font_width
      end
      
    end
  end
end
