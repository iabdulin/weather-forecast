module AddressSuggestions
  class Error < StandardError
    attr_reader :response

    def initialize(message = nil, response = nil)
      @response = response
      @message = message
      @message += " - #{@response&.body}" if @response
      Rails.logger.error(@message)
      super(@message)
    end
  end
end
