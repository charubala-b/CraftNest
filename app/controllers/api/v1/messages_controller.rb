class Api::V1::MessagesController < Api::V1::BaseController
  before_action :set_conversation, only: [:index]
  before_action :build_message, only: [:create]

  def index
    render :index
  end

  def create
    @message.sender = current_user

    if @message.save
      render :show, status: :created
    else
      render json: { errors: @message.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_conversation
    if params[:project_id].present? && params[:receiver_id].present?
      @messages = Message
        .where(project_id: params[:project_id])
        .where(
          "(sender_id = :current AND receiver_id = :other) OR (sender_id = :other AND receiver_id = :current)",
          current: current_user.id, other: params[:receiver_id]
        )
        .order(:created_at)
    else
      @messages = Message
        .where(sender_id: current_user.id)
        .or(Message.where(receiver_id: current_user.id))
        .order(:created_at)
    end
  end

  def build_message
    @message = Message.new(message_params)
  end

  def message_params
    params.require(:message).permit(:receiver_id, :project_id, :content)
  end
end
