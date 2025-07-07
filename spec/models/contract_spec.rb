require 'rails_helper'

RSpec.describe Contract, type: :model do
  describe "associations" do
    it "belongs to project" do
      association = described_class.reflect_on_association(:project)
      expect(association.macro).to eq(:belongs_to)
    end

    it "belongs to freelancer" do
      association = described_class.reflect_on_association(:freelancer)
      expect(association.macro).to eq(:belongs_to)
    end

    it "freelancer association has class_name 'User'" do
      association = described_class.reflect_on_association(:freelancer)
      expect(association.class_name).to eq("User")
    end

    it "belongs to client" do
      association = described_class.reflect_on_association(:client)
      expect(association.macro).to eq(:belongs_to)
    end

    it "client association has class_name 'User'" do
      association = described_class.reflect_on_association(:client)
      expect(association.class_name).to eq("User")
    end
  end

  describe "enums" do
    it "defines enum value 'active' for status" do
      expect(Contract.defined_enums["status"]["active"]).to eq(1)
    end

    it "defines enum value 'completed' for status" do
      expect(Contract.defined_enums["status"]["completed"]).to eq(2)
    end
  end

  describe "callbacks" do
    it "sets default status to active before validation" do
      contract = FactoryBot.create(:contract, status: nil)
      expect(contract.status).to eq("active")
    end
  end
end
