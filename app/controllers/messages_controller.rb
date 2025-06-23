class MessagesController < ApplicationController
  def create
    @message = Message.new(message_params)

    if @message.save
      if current_user.client?
        redirect_to chat_room_path(@message.receiver_id, @message.project_id), notice: "Message sent"
      else
        redirect_to freelancer_chat_room_path(@message.receiver_id, @message.project_id), notice: "Message sent"
      end
    else
      puts @message.errors.full_messages
      fallback = current_user.client? ? dashboard_path : freelancer_dashboard_path
      redirect_back fallback_location: fallback, alert: "Message failed to send."
    end
  end

  private

  def message_params
    params.require(:message).permit(:sender_id, :receiver_id, :project_id, :body)
  end
end
