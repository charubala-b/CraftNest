require 'rails_helper'

RSpec.describe Bid, type: :model do
  let(:project) { create(:project) }
  let(:user) { create(:user) }

  describe 'validations' do
    let(:valid_bid) { build(:bid) }

    it 'is valid with valid attributes' do
      expect(valid_bid).to be_valid
    end

    it 'is invalid without a cover_letter' do
      valid_bid.cover_letter = nil
      expect(valid_bid).not_to be_valid
    end

    it 'is invalid with a short cover_letter' do
      valid_bid.cover_letter = "Too short"
      expect(valid_bid).not_to be_valid
    end

    it 'is invalid with a long cover_letter' do
      valid_bid.cover_letter = "a" * 101
      expect(valid_bid).not_to be_valid
    end

    it 'is invalid without proposed_price' do
      valid_bid.proposed_price = nil
      expect(valid_bid).not_to be_valid
    end

    it 'is invalid with a negative proposed_price' do
      valid_bid.proposed_price = -10
      expect(valid_bid).not_to be_valid
    end
  end

  describe 'associations' do
    it 'belongs to project' do
      association = described_class.reflect_on_association(:project)
      expect(association.macro).to eq(:belongs_to)
    end

    it 'belongs to user' do
      association = described_class.reflect_on_association(:user)
      expect(association.macro).to eq(:belongs_to)
    end
  end

  describe 'scopes' do
    let!(:accepted_bid) { create(:bid, accepted: true) }
    let!(:pending_bid) { create(:bid, accepted: nil) }
    let!(:rejected_bid) { create(:bid, accepted: false) }

    it 'returns only accepted bids' do
      expect(Bid.accepted).to contain_exactly(accepted_bid)
    end

    it 'returns only pending bids (nil or false)' do
      expect(Bid.pending).to contain_exactly(pending_bid, rejected_bid)
    end

    describe 'ransacker :price_above_100' do
      let!(:cheap_bid) { create(:bid, proposed_price: 80) }
      let!(:expensive_bid) { create(:bid, proposed_price: 150) }

      it 'includes bids with proposed_price > 100' do
        result = Bid.ransack(price_above_100_eq: true).result
        expect(result).to include(expensive_bid)
      end

      it 'excludes bids with proposed_price <= 100' do
        result = Bid.ransack(price_above_100_eq: true).result
        expect(result).not_to include(cheap_bid)
      end
    end

    describe '.ordered_by_price_asc' do
      let!(:cheap_bid) { create(:bid, proposed_price: 100) }
      let!(:expensive_bid) { create(:bid, proposed_price: 500) }

      it 'orders bids by proposed_price ascending' do
        result = Bid.where(id: [ cheap_bid.id, expensive_bid.id ]).ordered_by_price_asc
        expect(result).to eq([ cheap_bid, expensive_bid ])
      end
    end
  end

  describe 'callback: create_contract_if_accepted' do
    let!(:bid) { create(:bid, accepted: false, project: project, user: user) }

    context 'when bid is accepted' do
      before { bid.update(accepted: true) }

      it 'creates a contract' do
        expect(Contract.exists?(project: project, freelancer: user)).to be true
      end

      it 'assigns the correct project to the created contract' do
        expect(Contract.last.project).to eq(project)
      end

      it 'assigns the correct client to the created contract' do
        expect(Contract.last.client).to eq(project.client)
      end

      it 'assigns the correct freelancer to the created contract' do
        expect(Contract.last.freelancer).to eq(user)
      end

      it 'assigns status as active to the created contract' do
        expect(Contract.last.status).to eq('active')
      end
    end

    context 'when contract already exists' do
      before do
        create(:contract, project: project, freelancer: user)
      end

      it 'does not create duplicate contracts for the same project and freelancer' do
        expect {
          bid.update(accepted: true)
        }.not_to change(Contract, :count)
      end
    end
  end
end
