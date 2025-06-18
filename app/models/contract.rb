class Contract < ApplicationRecord
  enum status: { draft: 0, inprogress: 1, completed: 2 }

  belongs_to :project
  belongs_to :freelancer, class_name: "User"
  belongs_to :client, class_name: "User"
end
