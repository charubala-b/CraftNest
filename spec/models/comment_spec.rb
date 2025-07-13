require 'rails_helper'

RSpec.describe Comment, type: :model do
  let(:user)    { create(:user) }
  let(:client)  { create(:user, role: :client) }
  let(:project) { create(:project, client: client) }

  subject { build(:comment, user: user, project: project) }

  describe "associations" do
    it "belongs to user" do
      expect(subject.user).to eq(user)
    end

    it "belongs to project" do
      expect(subject.project).to eq(project)
    end

    context "when comment has a parent" do
      let!(:parent) { create(:comment, user: user, project: project) }
      let!(:child)  { build(:comment, parent: parent, user: user, project: project) }

      it "can belong to a parent comment" do
        expect(child.parent).to eq(parent)
      end
    end

    context "when comment has replies" do
      let!(:parent) { create(:comment, user: user, project: project) }
      let!(:reply1) { create(:comment, parent: parent, user: user, project: project) }
      let!(:reply2) { create(:comment, parent: parent, user: user, project: project) }

      it "has many replies" do
        expect(parent.replies).to include(reply1, reply2)
      end
    end
  end

  describe "validations" do
    it "is valid with valid attributes" do
      expect(subject).to be_valid
    end

    context "when body is missing" do
      before { subject.body = "" }

      it "is invalid without body" do
        subject.validate
        expect(subject.errors[:body]).to include("can't be blank")
      end
    end

    context "when body is too short" do
      before { subject.body = "short" }

      it "is invalid" do
        subject.validate
        expect(subject.errors[:body]).to include("is too short (minimum is 20 characters)")
      end
    end

    context "when body is too long" do
      before { subject.body = "A" * 101 }

      it "is invalid" do
        subject.validate
        expect(subject.errors[:body]).to include("is too long (maximum is 100 characters)")
      end
    end
  end

  describe "callbacks" do
    context "when user is a freelancer" do
      before { user.update(role: :freelancer) }

      it "calls notify_project_owner after create" do
        expect_any_instance_of(Comment).to receive(:notify_project_owner)
        create(:comment, user: user, project: project)
      end
    end

    context "when comment is destroyed" do
      let!(:comment) { create(:comment, user: user, project: project) }

      it "calls log_deletion before destroy" do
        expect(comment).to receive(:log_deletion)
        comment.destroy
      end
    end
  end
end
