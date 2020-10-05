require 'garage'



def run!
  # Fixture
  responder_class = Class.new(ActionController::Responder) do
    include Garage::HypermediaResponder
  end

  controller =

  responder = responder_class.new(controller, resource)
  responder.transform(resource)
end
