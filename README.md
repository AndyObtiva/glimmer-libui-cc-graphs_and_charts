# Graphs and Charts 0.1.3 (Alpha)
## [Glimmer DSL for LibUI](https://github.com/AndyObtiva/glimmer-dsl-libui) Custom Controls
[![Gem Version](https://badge.fury.io/rb/glimmer-libui-cc-graphs_and_charts.svg)](http://badge.fury.io/rb/glimmer-libui-cc-graphs_and_charts)
[![Join the chat at https://gitter.im/AndyObtiva/glimmer](https://badges.gitter.im/AndyObtiva/glimmer.svg)](https://gitter.im/AndyObtiva/glimmer?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Graphs and Charts (Custom Controls) for [Glimmer DSL for LibUI](https://github.com/AndyObtiva/glimmer-dsl-libui)

![line graph](/screenshots/glimmer-libui-cc-graphs_and_charts-mac-basic-line-graph.png)

## Setup

Add this line to Bundler `Gemfile`:

```ruby
gem 'glimmer-libui-cc-graphs_and_charts', '~> 0.1.3'
```

Run:

```
bundle
```

## Usage

It is preferred that you only load the graphs/charts that you need to use as per the instructions in the sub-sections below to conserve memory and startup time.

However, if you prefer to load all graphs and charts, add this line to your Ruby file:

```ruby
require 'glimmer-libui-cc-graphs_and_charts'
```

### Line Graph

To load the `line_graph` custom control, add this line to your Ruby file:

```ruby
require 'glimmer/view/line_graph'
```

This makes the `line_graph` [Glimmer DSL for LibUI Custom Control](https://github.com/AndyObtiva/glimmer-dsl-libui#custom-components) available in the Glimmer GUI DSL.
You can then nest `line_graph` under `window` or some container like `vertical_box`. By the way, `line_graph` is implemented on top of the [`area` Glimmer DSL for LibUI control](https://github.com/AndyObtiva/glimmer-dsl-libui#area-api).

```ruby
line_graph(
  width: 900,
  height: 300,
  graph_point_distance: :width_divided_by_point_count,
  lines: [
    {
      name: 'Feature A',
      stroke: [163, 40, 39, thickness: 2],
      x_value_start: Time.now,
      x_interval_in_seconds: 8,
      x_value_format: -> (time) {time.strftime("%a %d %b %Y %T GMT")},
      y_values: [80, 36, 10, 60, 20, 110, 16, 5, 36, 1, 77, 15, 3, 34, 8, 63, 12, 17, 90, 28, 70]
    },
    {
      name: 'Feature B',
      stroke: [47, 109, 104, thickness: 2],
      x_value_start: Time.now,
      x_interval_in_seconds: 8,
      x_value_format: -> (time) {time.strftime("%a %d %b %Y %T GMT")},
      y_values: [62, 0, 90, 0, 0, 27, 0, 56, 0, 0, 24, 0, 60, 0, 30, 0, 47, 0, 38, 90, 0]
    },
  ],
  display_attributes_on_hover: true,
)
```

![basic line graph](/screenshots/glimmer-libui-cc-graphs_and_charts-mac-basic-line-graph.png)

Basic Line Graph Example:

[examples/graphs_and_charts/basic_line_graph.rb](/examples/graphs_and_charts/basic_line_graph.rb)

```ruby
require 'glimmer-dsl-libui'
require 'glimmer/view/line_graph'

class BasicLineGraph
  include Glimmer::LibUI::Application
  
  before_body do
    @start_time = Time.now
  end
  
  body {
    window('Basic Line Graph', 900, 330) {
      line_graph(
        width: 900,
        height: 300,
        graph_point_distance: :width_divided_by_point_count,
        lines: [
          {
            name: 'Feature A',
            stroke: [163, 40, 39, thickness: 2],
            x_value_start: @start_time,
            x_interval_in_seconds: 8,
            x_value_format: -> (time) {time.strftime("%a %d %b %Y %T GMT")},
            y_values: [80, 36, 10, 60, 20, 110, 16, 5, 36, 1, 77, 15, 3, 34, 8, 63, 12, 17, 90, 28, 70]
          },
          {
            name: 'Feature B',
            stroke: [47, 109, 104, thickness: 2],
            x_value_start: @start_time,
            x_interval_in_seconds: 8,
            x_value_format: -> (time) {time.strftime("%a %d %b %Y %T GMT")},
            y_values: [62, 0, 90, 0, 0, 27, 0, 56, 0, 0, 24, 0, 60, 0, 30, 0, 47, 0, 38, 90, 0]
          },
        ],
        display_attributes_on_hover: true,
      )
    }
  }
end

BasicLineGraph.launch
```

![basic line graph](/screenshots/glimmer-libui-cc-graphs_and_charts-mac-basic-line-graph.png)

Contributing to glimmer-libui-cc-graphs_and_charts
------------------------------------------

-   Check out the latest master to make sure the feature hasn't been
    implemented or the bug hasn't been fixed yet.
-   Check out the issue tracker to make sure someone already hasn't
    requested it and/or contributed it.
-   Fork the project.
-   Start a feature/bugfix branch.
-   Commit and push until you are happy with your contribution.
-   Make sure to add tests for it. This is important so I don't break it
    in a future version unintentionally.
-   Please try not to mess with the Rakefile, version, or history. If
    you want to have your own version, or is otherwise necessary, that
    is fine, but please isolate to its own commit so I can cherry-pick
    around it.

Copyright
---------

[MIT](LICENSE.txt)

Copyright (c) 2023 Andy Maleh. See
[LICENSE.txt](LICENSE.txt) for further details.
