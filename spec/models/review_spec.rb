require 'rails_helper'

RSpec.describe Review, type: :model do
  let(:reviewer) { create(:user) }
  let(:reviewee) { create(:user) }
  let(:project)  { create(:project) }

  subject do
    build(:review, reviewer: reviewer, reviewee: reviewee, project: project)
  end

  describe "associations" do
    it "belongs to reviewer" do
      expect(subject.reviewer).to eq(reviewer)
    end

    it "belongs to reviewee" do
      expect(subject.reviewee).to eq(reviewee)
    end

    it "belongs to project" do
      expect(subject.project).to eq(project)
    end
  end

  describe "validations" do
    it "is valid with valid attributes" do
      expect(subject).to be_valid
    end

    context "ratings validations" do
      it "adds error when ratings are nil" do
        subject.ratings = nil
        subject.validate
        expect(subject.errors[:ratings]).to include("can't be blank")
      end

      it "is invalid when ratings are not between 1 and 5" do
        subject.ratings = 6
        subject.validate
        expect(subject.errors[:ratings]).to include("is not included in the list")
      end
    end

    context "review text validations" do
      it "is invalid without review text" do
        subject.review = ""
        subject.validate
        expect(subject.errors[:review]).to include("can't be blank")
      end

      it "is invalid if review is too short" do
        subject.review = "Too short"
        subject.validate
        expect(subject.errors[:review]).to include("is too short (minimum is 20 characters)")
      end

      it "is invalid if review is too long" do
        subject.review = "A" * 101
        subject.validate
        expect(subject.errors[:review]).to include("is too long (maximum is 100 characters)")
      end
    end

    context "uniqueness of reviewer per project" do
      before { create(:review, reviewer: reviewer, reviewee: reviewee, project: project) }

      it "is not valid if reviewer already reviewed this project" do
        duplicate = build(:review, reviewer: reviewer, reviewee: reviewee, project: project)
        duplicate.validate
        expect(duplicate.errors[:reviewer_id]).to include("has already reviewed this project.")
      end
    end
  end

  describe "callbacks" do
    it "calls notify_reviewee after create" do
      expect_any_instance_of(Review).to receive(:notify_reviewee)
      create(:review)
    end
  end

  describe "#ransackable_associations" do
    it "returns configured associations from YAML" do
      expect(Review.ransackable_associations).to eq({
        "belongs_to" => {
          "project" => "Project",
          "reviewee" => "User",
          "reviewer" => "User"
        }
      })
    end
  end
end
