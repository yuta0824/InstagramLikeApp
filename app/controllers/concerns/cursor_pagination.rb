module CursorPagination
  extend ActiveSupport::Concern

  private

  def validate_cursor!
    return true if params[:cursor].blank? || cursor

    render json: { errors: ['cursor is invalid'] }, status: :bad_request
    false
  end

  def cursor
    return nil if params[:cursor].blank?

    value = Integer(params[:cursor], exception: false)
    value if value&.positive?
  end
end
