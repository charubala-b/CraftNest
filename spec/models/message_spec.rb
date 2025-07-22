require 'rails_helper'

RSpec.describe Message, type: :model do
  let(:sender)   { create(:user) }
  let(:receiver) { create(:user) }
  let(:project)  { create(:project) }

  subject { build(:message, sender: sender, receiver: receiver, project: project) }

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

    context "when body is missing" do
      before { subject.body = "" }

      it "is invalid" do
        subject.validate
        expect(subject.errors[:body]).to include("can't be blank")
      end
    end

    context "when body is too short" do
      before { subject.body = "A" }

      it "is invalid" do
        subject.validate
        expect(subject.errors[:body]).to include("is too short (minimum is 2 characters)")
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
    context "after create" do
      it "calls notify_receiver" do
        expect_any_instance_of(Message).to receive(:notify_receiver)
        create(:message, sender: sender, receiver: receiver, project: project)
      end

      it "logs notification info" do
        logger_double = double("Logger")
        allow(Rails).to receive(:logger).and_return(logger_double)
        expect(logger_double).to receive(:info).with(/Notified User ##{receiver.id} about new message #\d+/)

        create(:message, sender: sender, receiver: receiver, project: project)
      end
    end
  end
end
