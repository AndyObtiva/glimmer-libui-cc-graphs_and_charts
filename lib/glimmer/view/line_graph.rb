require 'glimmer-dsl-libui'

module Glimmer
  module View
    # General-Purpose Line Graph Custom Control
    class LineGraph
      class << self
        def interpret_color(color_object)
          @color_cache ||= {}
          @color_cache[color_object] ||= Glimmer::LibUI.interpret_color(color_object)
        end
      end
    
      include Glimmer::LibUI::CustomControl
      
      DEFAULT_GRAPH_PADDING_WIDTH = 5.0
      DEFAULT_GRAPH_PADDING_HEIGHT = 5.0
      DEFAULT_GRAPH_GRID_MARKER_PADDING_WIDTH = 37.0
      DEFAULT_GRAPH_POINT_DISTANCE = 15.0
      DEFAULT_GRAPH_POINT_RADIUS = 1.0
      DEFAULT_GRAPH_SELECTED_POINT_RADIUS = 3.0
      
      DEFAULT_GRAPH_STROKE_GRID = [185, 184, 185]
      DEFAULT_GRAPH_STROKE_MARKER = [185, 184, 185]
      DEFAULT_GRAPH_STROKE_MARKER_LINE = [217, 217, 217, thickness: 1, dashes: [1, 1]]
      DEFAULT_GRAPH_STROKE_PERIODIC_LINE = [121, 121, 121, thickness: 1, dashes: [1, 1]]
      DEFAULT_GRAPH_STROKE_HOVER_LINE = [133, 133, 133]
      
      DEFAULT_GRAPH_FILL_SELECTED_POINT = :white
      
      DEFAULT_GRAPH_COLOR_MARKER_TEXT = [96, 96, 96]
      DEFAULT_GRAPH_COLOR_PERIOD_TEXT = [163, 40, 39]
      
      DEFAULT_GRAPH_FONT_MARKER_TEXT = {family: "Arial", size: 14}
      
      DEFAULT_GRAPH_STATUS_HEIGHT = 30.0
      
      DAY_IN_SECONDS = 60*60*24
  
      option :width, default: 600
      option :height, default: 200
      
      # Hash or Array of Hash's like:
      # {
      #   name: 'Attribute Name',
      #   stroke: [28, 34, 89, thickness: 3],
      #   x_value_start: Time.now,
      #   x_interval_in_seconds: 2,
      #   x_value_format: ->(time) {time.strftime('%s')},
      #   y_values: [...]
      # }
      option :lines, default: []
      
      option :graph_padding_width, default: DEFAULT_GRAPH_PADDING_WIDTH
      option :graph_padding_height, default: DEFAULT_GRAPH_PADDING_HEIGHT
      option :graph_grid_marker_padding_width, default: DEFAULT_GRAPH_GRID_MARKER_PADDING_WIDTH
      option :graph_point_distance, default: DEFAULT_GRAPH_POINT_DISTANCE
      option :graph_point_radius, default: DEFAULT_GRAPH_POINT_RADIUS
      option :graph_selected_point_radius, default: DEFAULT_GRAPH_SELECTED_POINT_RADIUS
      
      option :graph_stroke_grid, default: DEFAULT_GRAPH_STROKE_GRID
      option :graph_stroke_marker, default: DEFAULT_GRAPH_STROKE_MARKER
      option :graph_stroke_marker_line, default: DEFAULT_GRAPH_STROKE_MARKER_LINE
      option :graph_stroke_periodic_line, default: DEFAULT_GRAPH_STROKE_PERIODIC_LINE
      option :graph_stroke_hover_line, default: DEFAULT_GRAPH_STROKE_HOVER_LINE
      
      option :graph_fill_selected_point, default: DEFAULT_GRAPH_FILL_SELECTED_POINT
      
      option :graph_color_marker_text, default: DEFAULT_GRAPH_COLOR_MARKER_TEXT
      option :graph_color_period_text, default: DEFAULT_GRAPH_COLOR_PERIOD_TEXT
      
      option :graph_font_marker_text, default: DEFAULT_GRAPH_FONT_MARKER_TEXT
      
      option :graph_status_height, default: DEFAULT_GRAPH_STATUS_HEIGHT
      
      option :display_attributes_on_hover, default: false
      option :reverse_x, default: false
      
      before_body do
        self.lines = [lines] if lines.is_a?(Hash)
      end
      
      after_body do
        observe(self, :lines) do
          if lines.is_a?(Hash)
            self.lines = [lines]
          else
            clear_drawing_cache
            body_root.queue_redraw_all
          end
        end
        observe(self, :width) do
          clear_drawing_cache
        end
        observe(self, :height) do
          clear_drawing_cache
        end
      end
  
      body {
        area { |graph_area|
          on_draw do
            calculate_dynamic_options
            graph_background
            grid_lines
            all_line_graphs
            periodic_lines
            hover_stats
          end

          on_mouse_moved do |event|
            @hover_point = {x: event[:x], y: event[:y]}
        
            if @hover_point && lines && lines[0] && @points && @points[lines[0]] && !@points[lines[0]].empty?
              x = @hover_point[:x]
              if lines[0][:x_interval_in_seconds]
                closest_point_index = ((width - graph_padding_width - x) / graph_point_distance_for_line(lines[0])).round
              else
                closest_point_index = :absolute
              end
              if closest_point_index == :absolute || closest_point_index != @closest_point_index
                # TODO look into optimizing this for absolute mode
                @closest_point_index = closest_point_index
                graph_area.queue_redraw_all
              end
            end
          end

          on_mouse_exited do |outside|
            if !@hover_point.nil?
              @hover_point = nil
              @closest_point_index = nil
              graph_area.queue_redraw_all
            end
          end
        }
      }
      
      private
      
      def clear_drawing_cache
        @graph_point_distance_per_line = nil
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
        @graph_stroke_marker_values = nil
        @mod_values = nil
      end
      
      def calculate_dynamic_options
        calculate_graph_point_distance_per_line
      end
      
      def calculate_graph_point_distance_per_line
        return unless lines[0]&.[](:y_values) && graph_point_distance == :width_divided_by_point_count
        
        @graph_point_distance_per_line ||= lines.inject({}) do |hash, line|
          value = (width - 2.0*graph_padding_width - graph_grid_marker_padding_width) / (line[:y_values].size - 1).to_f
          value = [value, width_drawable].min
          hash.merge(line => value)
        end
      end
      
      def width_drawable
        width - 2.0*graph_padding_width - graph_grid_marker_padding_width
      end
      
      def height_drawable
        height - 2.0*graph_padding_height
      end
      
      def graph_point_distance_for_line(line)
        @graph_point_distance_per_line&.[](line) || graph_point_distance
      end
      
      def graph_background
        rectangle(0, 0, width, height + (display_attributes_on_hover ? graph_status_height : 0)) {
          fill 255, 255, 255
        }
      end
  
      def grid_lines
        line(graph_padding_width, graph_padding_height, graph_padding_width, height - graph_padding_height) {
          stroke graph_stroke_grid
        }
        line(graph_padding_width, height - graph_padding_height, width - graph_padding_width, height - graph_padding_height) {
          stroke graph_stroke_grid
        }
        grid_marker_number_font = graph_font_marker_text.merge(size: 11)
        @grid_marker_number_values ||= []
        @grid_marker_numbers ||= []
        @graph_stroke_marker_values ||= []
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
          @graph_stroke_marker_values[index] ||= LineGraph.interpret_color(graph_stroke_marker).tap do |color_hash|
            color_hash[:thickness] = (index != grid_marker_points.size - 1 ? 2 : 1) if color_hash[:thickness].nil?
          end
          graph_stroke_marker_value = @graph_stroke_marker_values[index]
          @mod_values[index] ||= begin
            mod_value_multiplier = ((grid_marker_points.size / max_marker_count) + 1)
            [((mod_value_multiplier <= 2 ? 2 : 5) * mod_value_multiplier), 1].max
          end
          mod_value = @mod_values[index]
          comparison_value = (mod_value > 2) ? 0 : 1
          if mod_value > 2
            if grid_marker_number_value % mod_value == comparison_value
              line(marker_point[:x], marker_point[:y], marker_point[:x] + 4, marker_point[:y]) {
                stroke graph_stroke_marker_value
              }
            end
          else
            line(marker_point[:x], marker_point[:y], marker_point[:x] + 4, marker_point[:y]) {
              stroke graph_stroke_marker_value
            }
          end
          if grid_marker_number_value % mod_value == comparison_value && grid_marker_number_value != grid_marker_points.size
            line(marker_point[:x], marker_point[:y], marker_point[:x] + width - graph_padding_width, marker_point[:y]) {
              stroke graph_stroke_marker_line
            }
          end
          if grid_marker_number_value % mod_value == comparison_value || grid_marker_number_value != grid_marker_number_value.to_i
            grid_marker_number_width = estimate_width_of_text(grid_marker_number, grid_marker_number_font)
            text(marker_point[:x] + 4 + 3, marker_point[:y] - 6, grid_marker_number_width) {
              string(grid_marker_number) {
                font grid_marker_number_font
                color graph_color_marker_text
              }
            }
          end
        end
      end
      
      def grid_marker_points
        if @grid_marker_points.nil?
          if lines[0]&.[](:y_values)
            graph_y_max = [y_value_max_for_all_lines, 1].max
            current_graph_height = (height - graph_padding_height * 2)
            division_height = current_graph_height / graph_y_max
            @grid_marker_points = graph_y_max.to_i.times.map do |marker_index|
              x = graph_padding_width
              y = graph_padding_height + marker_index * division_height
              {x: x, y: y}
            end
          else
            graph_y_max = y_value_max_for_all_lines
            y_value_count = graph_y_max.ceil
            @grid_marker_points = y_value_count.times.map do |marker_index|
              x = graph_padding_width
              y_value = y_value_count - marker_index
              if marker_index == 0 && graph_y_max.ceil != graph_y_max.to_i
                y_value = graph_y_max
              end
              scaled_y_value = y_value.to_f * y_resolution.to_f
              y = height - graph_padding_height - scaled_y_value
              {x: x, y: y}
            end
          end
        end

        @grid_marker_points
      end
      
      def max_marker_count
        [(0.15*height).to_i, 1].max
      end
      
      def all_line_graphs
        lines.each(&method(:single_line_graph))
      end

      def single_line_graph(graph_line)
        last_point = nil
        points = calculate_points(graph_line)
        # points are already calculated as reversed before here, so here we reverse again if needed
        points = reverse_x_in_points(points) if !reverse_x
        points.to_a.each do |point|
          if last_point
            line(last_point[:x], last_point[:y], point[:x], point[:y]) {
              stroke graph_line[:stroke]
            }
          end
          if last_point.nil? || graph_point_radius > 1
            circle(point[:x], point[:y], graph_point_radius) {
              fill graph_line[:stroke]
            }
          end
          last_point = point
        end
      end
      
      def calculate_points(graph_line)
        if lines[0]&.[](:y_values)
          calculate_points_relative(graph_line)
        else
          calculate_points_absolute(graph_line)
        end
      end
      
      def calculate_points_relative(graph_line)
        @points ||= {}
        if @points[graph_line].nil?
          y_values = graph_line[:y_values] || []
          y_values = y_values[0, max_visible_point_count(graph_line)]
          graph_y_max = [y_value_max_for_all_lines, 1].max
          points = y_values.each_with_index.map do |y_value, index|
            x = width - graph_padding_width - (index * graph_point_distance_for_line(graph_line))
            y = ((height - graph_padding_height) - y_value * ((height - graph_padding_height * 2) / graph_y_max))
            {x: x, y: y, index: index, y_value: y_value}
          end
          @points[graph_line] = translate_points(graph_line, points)
        end
        @points[graph_line]
      end
      
      def calculate_points_absolute(graph_line)
        @points ||= {}
        if @points[graph_line].nil?
          values = graph_line[:values] || []
          # all points are visible when :values is supplied because we stretch the graph to show them all
          graph_y_max = [y_value_max_for_all_lines, 1].max
          x_value_range_for_all_lines
          points = values.each_with_index.map do |(x_value, y_value), index|
            relative_x_value = x_value - x_value_min_for_all_lines
            scaled_x_value = x_value_range_for_all_lines == 0 ? 0 : relative_x_value.to_f * x_resolution.to_f
            scaled_y_value = y_value_max_for_all_lines == 0 ? 0 : y_value.to_f * y_resolution.to_f
            x = width - graph_padding_width - scaled_x_value
            y = height - graph_padding_height - scaled_y_value
            {x: x, y: y, index: index, x_value: x_value, y_value: y_value}
          end
          # Translation is not supported today
          # TODO consider supporting in the future
#           @points[graph_line] = translate_points(graph_line, points)
          @points[graph_line] = points
        end
        @points[graph_line]
      end
      
      def reverse_x_in_points(points)
        # TODO consider caching results based on points
        # TODO look into optimizing operations below by not iterating 3 times (perhaps one iteration could do everything)
        points = points.map do |point|
          point.merge(x: width_drawable.to_f - point[:x])
        end
        min_point = points.min_by {|point| point[:x]}
        min_point_x = min_point[:x]
        if min_point_x < 0
          points.each do |point|
            point[:x] = point[:x] - min_point_x
          end
        end
        points.each do |point|
          point[:x] = point[:x] + graph_padding_width.to_f
        end
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
            # When using :values , we always stretch the graph so that all points are visible
            line_visible_y_values = lines.map { |line| line[:values].to_h.values }
          end
          all_visible_y_values = line_visible_y_values.reduce(:+) || []
          @y_value_max_for_all_lines = all_visible_y_values.max.to_f
        end
        @y_value_max_for_all_lines
      end
      
      def translate_points(graph_line, points)
        max_job_count_before_translation = ((width / graph_point_distance_for_line(graph_line)).to_i + 1)
        x_translation = [(points.size - max_job_count_before_translation) * graph_point_distance_for_line(graph_line), 0].max
        if x_translation > 0
          points.each do |point|
            # need to check if point[:x] is present because if the user shrinks the window, we drop points
            point[:x] = point[:x] - x_translation if point[:x]
          end
        end
        points
      end
      
      def max_visible_point_count(graph_line) = ((width - graph_grid_marker_padding_width) / graph_point_distance_for_line(graph_line)).to_i + 1

      def periodic_lines
        return unless lines && lines[0] && lines[0][:x_interval_in_seconds] && lines[0][:x_interval_in_seconds] == DAY_IN_SECONDS
        day_count = lines[0][:y_values].size
        case day_count
        when ..7
          @points[lines[0]].each_with_index do |point, index|
            next if index == 0
            
            line(point[:x], graph_padding_height, point[:x], height - graph_padding_height) {
              stroke graph_stroke_periodic_line
            }
            day = calculated_x_value(point[:index]).strftime("%e")
            font_size = graph_font_marker_text[:size]
            text(point[:x], height - graph_padding_height - font_size*1.4, font_size*2) {
              string(day) {
                font graph_font_marker_text
                color graph_color_period_text
              }
            }
          end
        when ..30
          @points[lines[0]].each_with_index do |point, index|
            day_number = index + 1
            if day_number % 7 == 0
              line(point[:x], graph_padding_height, point[:x], height - graph_padding_height) {
                stroke graph_stroke_periodic_line
              }
              date = calculated_x_value(point[:index]).strftime("%b %e")
              font_size = graph_font_marker_text[:size]
              text(point[:x] + 4, height - graph_padding_height - font_size*1.4, font_size*6) {
                string(date) {
                  font graph_font_marker_text
                  color graph_color_period_text
                }
              }
            end
          end
        else
          @points[lines[0]].each do |point|
            if calculated_x_value(point[:index]).strftime("%d") == "01"
              line(point[:x], graph_padding_height, point[:x], height - graph_padding_height) {
                stroke graph_stroke_periodic_line
              }
              date = calculated_x_value(point[:index]).strftime("%b")
              font_size = graph_font_marker_text[:size]
              text(point[:x] + 4, height - graph_padding_height - font_size*1.4, font_size*6) {
                string(date) {
                  font graph_font_marker_text
                  color graph_color_period_text
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
          if @closest_point_index == :absolute # used in absolute mode
            # TODO this is making a wrong assumption that there will be a point for every line
            # some lines might end up with no points, so we need to filter them out
            # we should start with the point across all lines that is closest to the mouse hover point
            # and then pick up points that match its X value
            closest_points = lines.map do |line|
              line_points = @points[line]
              point_distances_from_hover_point = line_points.map { |point| [point, PerfectShape::Point.point_distance(point[:x], point[:y], @hover_point[:x], @hover_point[:y])] }
              closest_point = point_distances_from_hover_point.min_by(&:last).first
            end
          else
            closest_points = lines.map { |line|
              line_points = @points[line]
              if !reverse_x
                line_points = reverse_x_in_points(line_points)
                line_points[line_points.size - @closest_point_index]
              else
                line_points[@closest_point_index]
              end
            }
          end
          closest_x = closest_points[0]&.[](:x)
          line(closest_x, graph_padding_height, closest_x, height - graph_padding_height) {
            stroke graph_stroke_hover_line
          }
          closest_points.each_with_index do |closest_point, index|
            next unless closest_point && closest_point[:x] && closest_point[:y]
            
            circle(closest_point[:x], closest_point[:y], graph_selected_point_radius) {
              fill graph_fill_selected_point == :line_stroke ? lines[index][:stroke] : graph_fill_selected_point
              stroke_value = lines[index][:stroke].dup
              stroke_value << {} unless stroke_value.last.is_a?(Hash)
              stroke_value.last[:thickness] = 2
              stroke stroke_value
            }
          end
          if !reverse_x
            text_label = formatted_x_value(@closest_point_index, closest_points)
          else
            text_label = formatted_x_value(@closest_point_index, closest_points)
          end
          text_label_width = estimate_width_of_text(text_label, DEFAULT_GRAPH_FONT_MARKER_TEXT)
          lines_with_closest_points = lines.each_with_index.map do |line, index|
            next if closest_points[index].nil?
            
            line
          end.compact
          closest_point_texts = lines_with_closest_points.each_with_index.map do |line, index|
            if @closest_point_index == :absolute
              line_point = closest_points[index]
              "#{line[:name]}: #{line_point[:y_value]}"
            else
              if !reverse_x
                "#{line[:name]}: #{line[:y_values][closest_points.size - 2 - @closest_point_index]}"
              else
                "#{line[:name]}: #{line[:y_values][@closest_point_index]}"
              end
            end
          end
          closest_point_text_widths = closest_point_texts.map do |text|
            estimate_width_of_text(text, graph_font_marker_text)
          end
          square_size = 12.0
          square_to_label_padding = 10.0
          label_padding = 10.0
          text_label_x = width - graph_padding_width - text_label_width - label_padding -
            (lines_with_closest_points.size*(square_size + square_to_label_padding) + (lines_with_closest_points.size - 1)*label_padding + closest_point_text_widths.sum)
          text_label_y = height + graph_padding_height

          text(text_label_x, text_label_y, text_label_width) {
            string(text_label) {
              font DEFAULT_GRAPH_FONT_MARKER_TEXT
              color graph_color_marker_text
            }
          }

          relative_x = text_label_x + text_label_width
          lines_with_closest_points.size.times do |index|
            square_x = relative_x + label_padding

            square(square_x, text_label_y + 2, square_size) {
              fill lines_with_closest_points[index][:stroke]
            }

            attribute_label_x = square_x + square_size + square_to_label_padding
            attribute_text = closest_point_texts[index]
            attribute_text_width = closest_point_text_widths[index]
            relative_x = attribute_label_x + attribute_text_width

            text(attribute_label_x, text_label_y, attribute_text_width) {
              string(attribute_text) {
                font graph_font_marker_text
                color graph_color_marker_text
              }
            }
          end
        end
      end
      
      def formatted_x_value(x_value_index, closest_points)
        graph_line = lines[0]
        x_value_format = graph_line[:x_value_format] || :to_s
        x_value = calculated_x_value(x_value_index, closest_points)
        if (x_value_format.is_a?(Symbol) || x_value_format.is_a?(String))
          x_value.send(x_value_format)
        else
          x_value_format.call(x_value)
        end
      end
      
      def calculated_x_value(x_value_index, closest_points = nil)
        if x_value_index == :absolute # absolute mode
          closest_points.first[:x_value]
        else # relative mode
          graph_line = lines[0]
          graph_line[:x_value_start] - (graph_line[:x_interval_in_seconds] * x_value_index)
        end
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
