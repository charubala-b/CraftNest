class MessagesController < ApplicationController
  def create
  @message = Message.new(message_params.merge(sender_id: current_user.id))
  if @message.save
    redirect_to dashboard_path
  else
    render :new
  end
end

def update
  @message = Message.find(params[:id])
  @message.update(message_params)
  redirect_to dashboard_path
end

private

def message_params
  params.require(:message).permit(:receiver_id, :body)
end

end
