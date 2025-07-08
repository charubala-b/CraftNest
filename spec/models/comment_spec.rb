require 'rails_helper'

RSpec.describe Comment, type: :model do
  let(:user)    { create(:user) }
  let(:client)  { create(:user, role: :client) }
  let(:project) { create(:project, client: client) }

  subject do
    build(:comment, user: user, project: project)
  end

  describe "associations" do
    it "belongs to user" do
      expect(subject.user).to eq(user)
    end

    it "belongs to project" do
      expect(subject.project).to eq(project)
    end

    it "can belong to a parent comment" do
      parent = create(:comment, user: user, project: project)
      comment = build(:comment, parent: parent, user: user, project: project)
      expect(comment.parent).to eq(parent)
    end

    it "can have replies" do
      parent = create(:comment, user: user, project: project)
      reply1 = create(:comment, parent: parent, user: user, project: project)
      reply2 = create(:comment, parent: parent, user: user, project: project)

      expect(parent.replies).to include(reply1, reply2)
    end
  end

  describe "validations" do
    it "is valid with valid attributes" do
      expect(subject).to be_valid
    end

    it "is invalid without body" do
      subject.body = ""
      subject.validate
      expect(subject.errors[:body]).to include("can't be blank")
    end

    it "is invalid if body is too short" do
      subject.body = "short"
      subject.validate
      expect(subject.errors[:body]).to include("is too short (minimum is 20 characters)")
    end

    it "is invalid if body is too long" do
      subject.body = "A" * 101
      subject.validate
      expect(subject.errors[:body]).to include("is too long (maximum is 100 characters)")
    end
  end

describe "callbacks" do
  it "calls notify_project_owner after create if user is freelancer" do
    user.update(role: :freelancer)
    expect_any_instance_of(Comment).to receive(:notify_project_owner)
    create(:comment, user: user, project: project)
  end

  it "calls log_deletion before destroy" do
    comment = create(:comment)
    comment.destroy
  end
end

end
