class DashboardController < ApplicationController
  def home
    @current_user = User.find(session[:user_id])

    # Auto-complete contracts if deadline passed
    auto_complete_contracts

    # Split projects
    @active_projects = @current_user.projects.where("deadline >= ?", Date.today)
    @completed_projects = @current_user.projects.where("deadline < ?", Date.today)

    # Load contracts
    @contracts = Contract.where(client_id: @current_user.id).includes(:project, :freelancer)

    # Messages
    @messages = Message.where("sender_id = ? OR receiver_id = ?", @current_user.id, @current_user.id)
  end

  private

  def auto_complete_contracts
    Contract.joins(:project)
            .where(status: :inprogress)
            .where("end_date < ?", Date.today)
            .find_each do |contract|
      contract.update(status: :completed)
    end
  end
end
