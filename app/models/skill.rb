class Skill < ApplicationRecord
  include Ransackable
  has_many :skill_assignments, dependent: :destroy
  has_many :users, through: :skill_assignments, source: :skillable, source_type: "User"
  has_many :projects, through: :skill_assignments, source: :skillable, source_type: "Project"
end
