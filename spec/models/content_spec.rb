require 'rails_helper'

RSpec.describe Content, type: :model do
  describe 'associations' do
    it 'belongs to a user' do
      association = described_class.reflect_on_association(:user)
      expect(association.macro).to eq :belongs_to
    end
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      user = create(:user)
      content = build(:content, user: user)
      expect(content).to be_valid
    end

    it 'is invalid without a title' do
      content = build(:content, title: nil)
      expect(content).not_to be_valid
      expect(content.errors[:title]).to include("can't be blank")
    end

    it 'is invalid without a body' do
      content = build(:content, body: nil)
      expect(content).not_to be_valid
      expect(content.errors[:body]).to include("can't be blank")
    end

    it 'is invalid without an associated user' do
      content = build(:content, user: nil)
      expect(content).not_to be_valid
    end
  end
end
