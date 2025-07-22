require 'rails_helper'

RSpec.describe Project, type: :model do
  let(:client) { create(:user, role: :client) }
  let(:project) { create(:project, client: client, title: "Important Project to be done") }


  describe "associations" do
    let(:assoc) { |example| described_class.reflect_on_association(example.metadata[:association]) }

    it "belongs to client", association: :client do
      expect(assoc.macro).to eq(:belongs_to)
    end

    it "client association has class_name 'User'", association: :client do
      expect(assoc.class_name).to eq("User")
    end

    it "client association has inverse_of :projects", association: :client do
      expect(assoc.options[:inverse_of]).to eq(:projects)
    end

    it "has many bids", association: :bids do
      expect(assoc.macro).to eq(:has_many)
    end

    it "bids are dependent destroy", association: :bids do
      expect(assoc.options[:dependent]).to eq(:destroy)
    end

    it "has many comments", association: :comments do
      expect(assoc.macro).to eq(:has_many)
    end

    it "comments are dependent destroy", association: :comments do
      expect(assoc.options[:dependent]).to eq(:destroy)
    end

    it "has many contracts", association: :contracts do
      expect(assoc.macro).to eq(:has_many)
    end

    it "contracts are dependent destroy", association: :contracts do
      expect(assoc.options[:dependent]).to eq(:destroy)
    end

    it "has many messages", association: :messages do
      expect(assoc.macro).to eq(:has_many)
    end

    it "messages are dependent destroy", association: :messages do
      expect(assoc.options[:dependent]).to eq(:destroy)
    end

  it 'has many review' do
    assoc = described_class.reflect_on_association(:reviews)
    expect(assoc.macro).to eq(:has_many)
  end

  it 'review is dependent destroy' do
    assoc = described_class.reflect_on_association(:reviews)
    expect(assoc.options[:dependent]).to eq(:destroy)
  end

    it "has many skill_assignments", association: :skill_assignments do
      expect(assoc.macro).to eq(:has_many)
    end

    it "skill_assignments are dependent destroy", association: :skill_assignments do
      expect(assoc.options[:dependent]).to eq(:destroy)
    end

    it "has a has_many association with skills", association: :skills do
      expect(assoc.macro).to eq(:has_many)
    end

    it "has a through association with skill_assignments for skills", association: :skills do
      expect(assoc.options[:through]).to eq(:skill_assignments)
    end

    it "has a has_many association with freelancers", association: :freelancers do
      expect(assoc.macro).to eq(:has_many)
    end

    it "has a through association with bids for freelancers", association: :freelancers do
      expect(assoc.options[:through]).to eq(:bids)
    end

    it "has a source association :user for freelancers", association: :freelancers do
      expect(assoc.options[:source]).to eq(:user)
    end
  end

  describe "validations" do
    subject { build(:project) }

    it "validates presence of title" do
      subject.title = nil
      subject.validate
      expect(subject.errors[:title]).to include("can't be blank")
    end

    it "validates uniqueness of title (case insensitive)" do
      create(:project, title: "Unique Project is created")
      duplicate = build(:project, title: "UNIQUE PROJECT IS CREATED")
      duplicate.validate
      expect(duplicate.errors[:title]).to include("has already been taken")
    end

    it "validates length of title is at least 20" do
      subject.title = "Too short"
      subject.validate
      expect(subject.errors[:title]).to include("is too short (minimum is 20 characters)")
    end

    it "validates length of title is at most 100" do
      subject.title = "A" * 101
      subject.validate
      expect(subject.errors[:title]).to include("is too long (maximum is 100 characters)")
    end

    it "validates presence of description" do
      subject.description = nil
      subject.validate
      expect(subject.errors[:description]).to include("can't be blank")
    end

    it "validates presence of budget" do
      subject.budget = nil
      subject.validate
      expect(subject.errors[:budget]).to include("can't be blank")
    end

    it "validates presence of deadline" do
      subject.deadline = nil
      subject.validate
      expect(subject.errors[:deadline]).to include("can't be blank")
    end

    it "validates numericality of budget >= 0" do
      subject.budget = -100
      subject.validate
      expect(subject.errors[:budget]).to include("must be a non-negative number")
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
  let(:project) { build(:project, deadline: Time.zone.today.end_of_day) }

  it "is valid" do
    expect(project).to be_valid
  end
end

context "when deadline is in the future" do
  let(:project) { build(:project, deadline: Time.zone.today + 1.day) }

  it "is valid" do
    expect(project).to be_valid
  end
end
end

  describe "scopes" do
  let!(:active_project) do
    create(:project, deadline: Time.zone.today + 1.day, client: client)
  end

  let!(:completed_project) do
    build(:project, deadline: Time.zone.today - 1.day, client: client).tap { |p| p.save(validate: false) }
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
      expect(Rails.logger).to receive(:info).with("Project 'Important Project to be done' is being deleted.")
      project.destroy
    end
  end
end
