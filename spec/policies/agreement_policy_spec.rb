# frozen_string_literal: true

RSpec.describe AgreementPolicy do
  subject { described_class }

  let(:admin) { users(:admin) }
  let(:volunteer) { users(:volunteer) }
  let(:member) { users(:member) }

  permissions :create? do
    it { is_expected.not_to permit(member) }

    it { is_expected.to permit(admin) }

    it { is_expected.to permit(volunteer) }
  end

  permissions :update? do
    it { is_expected.not_to permit(member) }

    it { is_expected.to permit(admin) }

    it { is_expected.to permit(volunteer) }
  end

  permissions :destroy? do
    it { is_expected.not_to permit(member) }

    it { is_expected.to permit(admin) }

    it { is_expected.to permit(volunteer) }
  end
end
