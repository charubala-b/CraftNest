class Skill < ApplicationRecord
  enum skill_name: { ai: 0, ml: 1, ds: 2, react: 3 }

  has_many :project_skills, dependent: :destroy
  has_many :projects, through: :project_skills
end
