require 'rails_helper'

RSpec.describe Message, type: :model do
  let(:sender)   { create(:user) }
  let(:receiver) { create(:user) }
  let(:project)  { create(:project) }

  subject do
    build(:message, sender: sender, receiver: receiver, project: project)
  end

  describe "associations" do
    it "belongs to sender" do
      expect(subject.sender).to eq(sender)
    end

    it "belongs to receiver" do
      expect(subject.receiver).to eq(receiver)
    end

    it "belongs to project" do
      expect(subject.project).to eq(project)
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
      subject.body = "A"
      subject.validate
      expect(subject.errors[:body]).to include("is too short (minimum is 2 characters)")
    end

    it "is invalid if body is too long" do
      subject.body = "A" * 101
      subject.validate
      expect(subject.errors[:body]).to include("is too long (maximum is 100 characters)")
    end
  end

  describe "callbacks" do
    it "runs notify_receiver callback after create" do
      message = create(:message, sender: sender, receiver: receiver, project: project)
      expect(message).to be_persisted
    end
  end
end
