class SkillAssignmentsController < ApplicationController
  def create
  skill_id = params[:skill_id]
  new_skill_name = params[:new_skill_name].to_s.strip

  if skill_id.present?
    skill = Skill.find_by(id: skill_id)
  elsif new_skill_name.present?
    skill = Skill.where('LOWER(skill_name) = ?', new_skill_name.downcase).first_or_create(skill_name: new_skill_name)
  end

  if skill
    assignment = SkillAssignment.new(skill: skill, skillable_type: params[:skillable_type], skillable_id: params[:skillable_id])
    if assignment.save
      redirect_back fallback_location: freelancer_dashboard_path, notice: "Skill added successfully."
    else
      redirect_back fallback_location: freelancer_dashboard_path, alert: "Skill already exists or failed to save."
    end
  else
    redirect_back fallback_location: freelancer_dashboard_path, alert: "Please select or enter a skill."
  end
end


  def destroy
    @assignment = SkillAssignment.find(params[:id])
    @assignment.destroy
    redirect_back fallback_location: freelancer_dashboard_path, notice: "Skill removed."
  end
end
