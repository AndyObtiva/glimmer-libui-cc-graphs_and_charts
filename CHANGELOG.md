# Change Log

## 0.1.5

- Render circles for every point in addition to the lines connecting all the points
- Render a single point if there is only 1 value in `lines` `y_values` instead of rendering nothing until 2 values exist at least
- Support `graph_point_radius`, `graph_selected_point_radius`, and `graph_fill_selected_point` options for custimizing the circle of every rendered point and selected point.
- Avoid rendering on top of the grid markers on the left side
- Optimize performance of rendering grid markers and showing mouse hover selection stats of a point

## 0.1.4

- Fix issue with crashing at `lib/glimmer/view/line_graph.rb:243:in y_value_max_for_all_lines': undefined method max for nil:NilClass`

## 0.1.3

- Fix issue with crashing if lines had points that did not share the same x-axis values as opposed to all points in all lines falling on the same x-axis values

## 0.1.2

- Fix issue with crashing if the mouse hovers over a graph without any points yet

## 0.1.1

- Ensure that `line_graph` max `y_value` is taken into account in visible points only (excluding points outside the visible area)
- Support ability to load entire `'glimmer-libui-cc-graphs_and_charts'` library instead of individual graphs/charts if preferred
- New `examples/graphs_and_charts/basic_line_graph.rb`

## 0.1.0

- Initial implementation of `line_graph` custom control
