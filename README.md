# Graphs and Charts 0.1.0
## [Glimmer DSL for LibUI](https://github.com/AndyObtiva/glimmer-dsl-libui) Custom Controls
[![Gem Version](https://badge.fury.io/rb/glimmer-libui.svg)](http://badge.fury.io/rb/glimmer-dsl-libui)
[![Join the chat at https://gitter.im/AndyObtiva/glimmer](https://badges.gitter.im/AndyObtiva/glimmer.svg)](https://gitter.im/AndyObtiva/glimmer?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Graphs and Charts (Custom Controls) for [Glimmer DSL for LibUI](https://github.com/AndyObtiva/glimmer-dsl-libui)

![line graph](/screenshots/glimmer-libui-cc-graphs_and_charts-mac-line-graph.png)

## Setup

Add this line to Bundler `Gemfile`:

```ruby
gem 'glimmer-libui-cc-graphs_and_charts', '~> 0.1.0'
```

Run:

```
bundle
```

## Usage

### Line Graph

Add this line to your Ruby file:

```ruby
require 'glimmer/view/line_graph'
```

Example Glimmer GUI DSL code that can be nested under `window` or some container like `vertical_box`:

```ruby
line_graph(
  width: 900,
  height: 300,
  lines: [
    {
      name: 'Failed',
      stroke: [163, 40, 39, thickness: 2],
      x_value_start: Time.now,
      x_interval_in_seconds: 2,
      x_value_format: -> (time) {time.strftime("%a %d %b %Y %T GMT")},
      y_values: [36, 0, 60, 0, 0, 16, 0, 36, 0, 0]
    },
    {
      name: 'Processed',
      stroke: [47, 109, 104, thickness: 2],
      x_value_start: Time.now,
      x_interval_in_seconds: 2,
      x_value_format: -> (time) {time.strftime("%a %d %b %Y %T GMT")},
      y_values: [62, 0, 90, 0, 0, 27, 0, 56, 0, 0]
    },
  ],
  display_attributes_on_hover: true,
)
```

![line graph](/screenshots/glimmer-libui-cc-graphs_and_charts-mac-line-graph.png)

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
