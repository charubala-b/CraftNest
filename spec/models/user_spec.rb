require 'rails_helper'

RSpec.describe User, type: :model do
  describe "devise modules" do
    it "is an instance of User" do
      user = build(:user)
      expect(user).to be_an_instance_of(User)
    end

    it "responds to valid_password?" do
      user = build(:user)
      expect(user).to respond_to(:valid_password?)
    end
  end

  describe "enums" do
    it "defines enum value freelancer for role" do
      expect(User.defined_enums["role"]["freelancer"]).to eq(0)
    end

    it "defines enum value client for role" do
      expect(User.defined_enums["role"]["client"]).to eq(1)
    end
  end

  describe "associations" do
    it "has many projects with foreign_key client_id" do
      assoc = described_class.reflect_on_association(:projects)
      expect(assoc.macro).to eq(:has_many)
    end

    it "projects association has inverse_of :client" do
      assoc = described_class.reflect_on_association(:projects)
      expect(assoc.options[:inverse_of]).to eq(:client)
    end

    it "projects association has foreign_key :client_id" do
      assoc = described_class.reflect_on_association(:projects)
      expect(assoc.options[:foreign_key]).to eq(:client_id)
    end

    it "projects are dependent destroy" do
      assoc = described_class.reflect_on_association(:projects)
      expect(assoc.options[:dependent]).to eq(:destroy)
    end

    it "has many bids" do
      assoc = described_class.reflect_on_association(:bids)
      expect(assoc.macro).to eq(:has_many)
    end

    it "bids are dependent destroy" do
      assoc = described_class.reflect_on_association(:bids)
      expect(assoc.options[:dependent]).to eq(:destroy)
    end

    it "has many id_projects" do
      assoc = described_class.reflect_on_association(:bid_projects)
      expect(assoc.macro).to eq(:has_many)
    end

    it "has many bid_projects through projects" do
      assoc = described_class.reflect_on_association(:bid_projects)
      expect(assoc.options[:source]).to eq(:project)
    end

    it "has many bid_projects through bids" do
      assoc = described_class.reflect_on_association(:bid_projects)
      expect(assoc.options[:through]).to eq(:bids)
    end



    it "has many contracts_as_freelancer with class_name Contract" do
      assoc = described_class.reflect_on_association(:contracts_as_freelancer)
      expect(assoc.class_name).to eq("Contract")
    end

    it "contracts_as_freelancer has foreign_key freelancer_id" do
      assoc = described_class.reflect_on_association(:contracts_as_freelancer)
      expect(assoc.options[:foreign_key]).to eq("freelancer_id")
    end

    it "contracts_as_freelancer are dependent destroy" do
      assoc = described_class.reflect_on_association(:contracts_as_freelancer)
      expect(assoc.options[:dependent]).to eq(:destroy)
    end

    it "has many contracts_as_client with class_name Contract" do
      assoc = described_class.reflect_on_association(:contracts_as_client)
      expect(assoc.class_name).to eq("Contract")
    end

    it "contracts_as_client has foreign_key client_id" do
      assoc = described_class.reflect_on_association(:contracts_as_client)
      expect(assoc.options[:foreign_key]).to eq(:client_id)
    end

    it "contracts_as_client are dependent destroy" do
      assoc = described_class.reflect_on_association(:contracts_as_client)
      expect(assoc.options[:dependent]).to eq(:destroy)
    end

    it "has many sent_messages with class_name Message" do
      assoc = described_class.reflect_on_association(:sent_messages)
      expect(assoc.class_name).to eq("Message")
    end

    it "sent_messages has foreign_key sender_id" do
      assoc = described_class.reflect_on_association(:sent_messages)
      expect(assoc.options[:foreign_key]).to eq(:sender_id)
    end

    it "sent_messages are dependent destroy" do
      assoc = described_class.reflect_on_association(:sent_messages)
      expect(assoc.options[:dependent]).to eq(:destroy)
    end

    it "has many received_messages with class_name Message" do
      assoc = described_class.reflect_on_association(:received_messages)
      expect(assoc.class_name).to eq("Message")
    end

    it "received_messages has foreign_key receiver_id" do
      assoc = described_class.reflect_on_association(:received_messages)
      expect(assoc.options[:foreign_key]).to eq(:receiver_id)
    end

    it "received_messages are dependent destroy" do
      assoc = described_class.reflect_on_association(:received_messages)
      expect(assoc.options[:dependent]).to eq(:destroy)
    end

    it "has many reviews_written with class_name Review" do
      assoc = described_class.reflect_on_association(:reviews_written)
      expect(assoc.class_name).to eq("Review")
    end

    it "reviews_written has foreign_key reviewer_id" do
      assoc = described_class.reflect_on_association(:reviews_written)
      expect(assoc.options[:foreign_key]).to eq(:reviewer_id)
    end

    it "reviews_written are dependent destroy" do
      assoc = described_class.reflect_on_association(:reviews_written)
      expect(assoc.options[:dependent]).to eq(:destroy)
    end

    it "has many reviews_received with class_name Review" do
      assoc = described_class.reflect_on_association(:reviews_received)
      expect(assoc.class_name).to eq("Review")
    end

    it "reviews_received has foreign_key reviewee_id" do
      assoc = described_class.reflect_on_association(:reviews_received)
      expect(assoc.options[:foreign_key]).to eq(:reviewee_id)
    end

    it "reviews_received are dependent destroy" do
      assoc = described_class.reflect_on_association(:reviews_received)
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

    it "has many skill_assignments" do
      assoc = described_class.reflect_on_association(:skill_assignments)
      expect(assoc.macro).to eq(:has_many)
    end

    it "skill_assignments are dependent destroy" do
      assoc = described_class.reflect_on_association(:skill_assignments)
      expect(assoc.options[:dependent]).to eq(:destroy)
    end

    it "has many skills through skill_assignments" do
      assoc = described_class.reflect_on_association(:skills)
      expect(assoc.options[:through]).to eq(:skill_assignments)
    end
  end

  describe "validations" do
    subject { FactoryBot.create(:user) }

    it "validates presence of email" do
      user = User.new(email: nil)
      user.validate
      expect(user.errors[:email]).to include("can't be blank")
    end

    it "validates uniqueness of email (case insensitive)" do
      FactoryBot.create(:user, email: "user@example.com")
      duplicate = FactoryBot.build(:user, email: "USER@example.com")
      duplicate.validate
      expect(duplicate.errors[:email]).to include("is already registered")
    end
  end

  describe "callbacks" do
    it "downcases email before save" do
      user = FactoryBot.create(:user, email: "TEST@Example.COM")
      expect(user.email).to eq("test@example.com")
    end
  end

  describe "ransackers" do
    let!(:user) { create(:user, created_at: Date.new(2022, 5, 15)) }

    it "filters users by created_year" do
        result = User.ransack(created_year_eq: 2022).result
        expect(result).to include(user)
    end

    it "filters users by created_month" do
        result = User.ransack(created_month_eq: 5).result
        expect(result).to include(user)
    end
  end
end
