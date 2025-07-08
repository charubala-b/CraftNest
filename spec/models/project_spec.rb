require 'rails_helper'

RSpec.describe Project, type: :model do
  describe "associations" do
    it "belongs to client" do
      assoc = described_class.reflect_on_association(:client)
      expect(assoc.macro).to eq(:belongs_to)
    end

    it "client association has class_name 'User'" do
      assoc = described_class.reflect_on_association(:client)
      expect(assoc.class_name).to eq("User")
    end

    it "client association has inverse_of :projects" do
      assoc = described_class.reflect_on_association(:client)
      expect(assoc.options[:inverse_of]).to eq(:projects)
    end

    it "has many bids" do
      assoc = described_class.reflect_on_association(:bids)
      expect(assoc.macro).to eq(:has_many)
    end

    it "bids are dependent destroy" do
      assoc = described_class.reflect_on_association(:bids)
      expect(assoc.options[:dependent]).to eq(:destroy)
    end

    it "has many comments" do
      assoc = described_class.reflect_on_association(:comments)
      expect(assoc.macro).to eq(:has_many)
    end

    it "comments are dependent destroy" do
      assoc = described_class.reflect_on_association(:comments)
      expect(assoc.options[:dependent]).to eq(:destroy)
    end

    it "has many contracts" do
      assoc = described_class.reflect_on_association(:contracts)
      expect(assoc.macro).to eq(:has_many)
    end

    it "contracts are dependent destroy" do
      assoc = described_class.reflect_on_association(:contracts)
      expect(assoc.options[:dependent]).to eq(:destroy)
    end

    it "has many messages" do
      assoc = described_class.reflect_on_association(:messages)
      expect(assoc.macro).to eq(:has_many)
    end

    it "messages are dependent destroy" do
      assoc = described_class.reflect_on_association(:messages)
      expect(assoc.options[:dependent]).to eq(:destroy)
    end

    it "has many reviews" do
      assoc = described_class.reflect_on_association(:reviews)
      expect(assoc.macro).to eq(:has_many)
    end

    it "reviews are dependent destroy" do
      assoc = described_class.reflect_on_association(:reviews)
      expect(assoc.options[:dependent]).to eq(:destroy)
    end

    it "has many skill_assignments" do
      assoc = described_class.reflect_on_association(:skill_assignments)
      expect(assoc.macro).to eq(:has_many)
    end

    it "skill_assignments are dependent destroy" do
      assoc = described_class.reflect_on_association(:skill_assignments)
      expect(assoc.options[:dependent]).to eq(:destroy)
    end

    it "has a has_many association with skills" do
      assoc = described_class.reflect_on_association(:skills)
      expect(assoc.macro).to eq(:has_many)
    end

    it "has a through association with skill_assignments for skills" do
      assoc = described_class.reflect_on_association(:skills)
      expect(assoc.options[:through]).to eq(:skill_assignments)
    end

    it "has a has_many association with freelancers" do
      assoc = described_class.reflect_on_association(:freelancers)
      expect(assoc.macro).to eq(:has_many)
    end

    it "has a through association with bids for freelancers" do
      assoc = described_class.reflect_on_association(:freelancers)
      expect(assoc.options[:through]).to eq(:bids)
    end

    it "has a source association :user for freelancers" do
      assoc = described_class.reflect_on_association(:freelancers)
      expect(assoc.options[:source]).to eq(:user)
    end
  end

  describe "validations" do
    subject { FactoryBot.create(:project) }

    it "validates presence of title" do
      project = Project.new(title: nil)
      project.validate
      expect(project.errors[:title]).to include("can't be blank")
    end

    it "validates uniqueness of title (case insensitive)" do
      FactoryBot.create(:project, title: "Unique Project is created")
      duplicate = FactoryBot.build(:project, title: "UNIQUE PROJECT IS CREATED")
      duplicate.validate
      expect(duplicate.errors[:title]).to include("has already been taken")
    end

    it "validates length of title is at least 20" do
      project = FactoryBot.build(:project, title: "Too short")
      project.validate
      expect(project.errors[:title]).to include("is too short (minimum is 20 characters)")
    end

    it "validates length of title is at most 100" do
      long_title = "A" * 101
      project = FactoryBot.build(:project, title: long_title)
      project.validate
      expect(project.errors[:title]).to include("is too long (maximum is 100 characters)")
    end

    it "validates presence of description" do
      project = Project.new(description: nil)
      project.validate
      expect(project.errors[:description]).to include("can't be blank")
    end

    it "validates presence of budget" do
      project = Project.new(budget: nil)
      project.validate
      expect(project.errors[:budget]).to include("can't be blank")
    end

    it "validates presence of deadline" do
      project = Project.new(deadline: nil)
      project.validate
      expect(project.errors[:deadline]).to include("can't be blank")
    end

    it "validates numericality of budget >= 0" do
      project = Project.new(budget: -100)
      project.validate
      expect(project.errors[:budget]).to include("must be a non-negative number")
    end
  end

describe "custom validations" do
  context "when deadline is in the past" do
    let(:project) { build(:project, deadline: Date.yesterday) }

    before { project.validate }

    it "is not valid" do
      expect(project).to_not be_valid
    end

    it "adds an error on deadline" do
      expect(project.errors[:deadline]).to include("can't be in the past.")
    end
  end

  context "when deadline is today" do
    it "is valid" do
      project = build(:project, deadline: Date.today)
      expect(project).to be_valid
    end
  end

  context "when deadline is in the future" do
    it "is valid" do
      project = build(:project, deadline: Date.tomorrow)
      expect(project).to be_valid
    end
  end
end

describe "scopes" do
  let(:client) { create(:user, role: :client) }
  let!(:active_project) { create(:project, deadline: Date.tomorrow, client: client) }

  let!(:completed_project) do
    build(:project, deadline: Date.yesterday, client: client).tap { |p| p.save(validate: false) }
  end

  it "returns active projects" do
    expect(Project.active).to include(active_project)
  end

  it "does not include completed projects in active scope" do
    expect(Project.active).not_to include(completed_project)
  end

  it "returns completed projects" do
    expect(Project.completed).to include(completed_project)
  end

  it "does not include active projects in completed scope" do
    expect(Project.completed).not_to include(active_project)
  end

  it "orders projects by deadline ascending" do
    ordered = Project.ordered_by_deadline
    expect(ordered.first.deadline).to be <= ordered.last.deadline
  end
end
describe "callbacks" do
  it "logs a message before destruction" do
    project = create(:project, title: "Important Project to be done")
    expect(Rails.logger).to receive(:info).with("Project 'Important Project to be done' is being deleted.")
    project.destroy
  end
end

end
