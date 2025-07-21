class ReviewRemainderJob < ApplicationJob
  queue_as :default

  def perform(contract_id)
    contract = Contract.find_by(id: contract_id)
    return unless contract&.completed?

    client = contract.project.client
    freelancer = contract.freelancer

    puts "Reminder: #{client.name}, please review freelancer #{freelancer.name} for project #{contract.project.title}"
  end
end
