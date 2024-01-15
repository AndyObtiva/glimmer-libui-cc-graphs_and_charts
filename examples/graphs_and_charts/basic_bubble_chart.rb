# This line is only needed when running the example from inside the project directory
$LOAD_PATH.prepend(File.expand_path(File.join(__dir__, '..', '..', 'lib'))) if File.exist?(File.join(__dir__, '..', '..', 'lib'))

require 'glimmer-dsl-libui'
require 'glimmer/view/bubble_chart'

class BasicBubbleChart
  include Glimmer::LibUI::Application
  
  body {
    window('Basic Line Graph', 900, 300) { |main_window|
      @bubble_chart = bubble_chart(
        width: 900,
        height: 300,
        fill: [163, 40, 39],
        values: {
          Time.new(2030, 12, 1, 13, 0, 0) => {
            1: 14,
            2: 15,
            3: 7
          },
          Time.new(2030, 12, 1, 13, 0, 2) => {
            1: 14,
            2: 15,
            3: 7
          },
          Time.new(2030, 12, 1, 13, 0, 4) => {
            1: 14,
            2: 15,
            3: 7
          },
          Time.new(2030, 12, 1, 13, 0, 6) => {
            1: 14,
            2: 15,
            3: 7
          },
          Time.new(2030, 12, 1, 13, 0, 8) => {
            1: 14,
            2: 15,
            3: 7
          },
          Time.new(2030, 12, 1, 13, 0, 10) => {
            1: 14,
            2: 15,
            3: 7
          },
          Time.new(2030, 12, 1, 13, 0, 12) => {
            1: 14,
            2: 15,
            3: 7
          },
          Time.new(2030, 12, 1, 13, 0, 14) => {
            1: 14,
            2: 15,
            3: 7
          },
          Time.new(2030, 12, 1, 13, 0, 16) => {
            1: 14,
            2: 15,
            3: 7
          },
          Time.new(2030, 12, 1, 13, 0, 18) => {
            1: 14,
            2: 15,
            3: 7
          },
          Time.new(2030, 12, 1, 13, 0, 20) => {
            1: 14,
            2: 15,
            3: 7
          },
        },
        x_value_format: -> (time) {time.strftime('%M:%S')},
      )
      
      on_content_size_changed do
        @bubble_chart.width = main_window.content_size[0]
        @bubble_chart.height = main_window.content_size[1]
      end
    }
  }
end

BasicBubbleChart.launch
