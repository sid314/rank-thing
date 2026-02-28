class ApiController < ApplicationController
  skip_before_action :verify_authenticity_token

  private

  def json_request!
    json_content = request.content_type&.include?("application/json")
    json_accept = request.headers["Accept"]&.include?("application/json")

    return if json_content || json_accept || request.get?

    render json: {
      success: false,
      error: "invalid_content_type",
      message: "Content-Type must be application/json"
    }, status: :bad_request
  end

  def render_success(data: nil, message: nil, status: :ok)
    response = { success: true }
    response[:data] = data if data.present?
    response[:message] = message if message.present?
    render json: response, status: status
  end

  def render_error(message, error_type: "error", status: :unprocessable_entity)
    render json: {
      success: false,
      error: error_type,
      message: message
    }, status: status
  end
end
