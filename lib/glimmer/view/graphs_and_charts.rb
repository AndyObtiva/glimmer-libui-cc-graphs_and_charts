module Glimmer
  module View
    class GraphsAndCharts
      include Glimmer::LibUI::CustomControl
  
      ## Add options like the following to configure CustomControl by outside consumers
      #
      # options :custom_text, :background_color
      # option :foreground_color, default: :red
      
      # Replace example options with your own options
      option :model
      option :attributes
  
      ## Use before_body block to pre-initialize variables to use in body
      #
      #
      before_body do
        # Replace example code with your own before_body code
        default_model_attributes = [:first_name, :last_name, :email]
        default_model_class = Struct.new(*default_model_attributes)
        self.model ||= default_model_class.new
        self.attributes ||= default_model_attributes
      end
  
      ## Use after_body block to setup observers for controls in body
      #
      # after_body do
      #
      # end
  
      ## Add control content under custom control body
      ##
      ## If you want to add a window as the top-most control,
      ## consider creating a custom window instead
      ## (Glimmer::LibUI::CustomWindow offers window convenience methods, like show and hide)
      #
      body {
        # Replace example content (model_form custom control) with your own custom control content.
        form {
          attributes.each do |attribute|
            entry { |e|
              label attribute.to_s.underscore.split('_').map(&:capitalize).join(' ')
              text <=> [model, attribute]
            }
          end
        }
      }
  
    end
  end
end
