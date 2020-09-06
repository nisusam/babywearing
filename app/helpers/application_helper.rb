# frozen_string_literal: true

module ApplicationHelper
  def boolean_display(item)
    item ? 'Yes' : 'No'
  end

  def flash_class(level)
    case level.to_sym
    when :notice then 'alert alert-info'
    when :success then 'alert alert-success'
    when :error then 'alert alert-error'
    when :alert then 'alert alert-error'
    end
  end

  def show_membership_links?
    !request.path.match(%r{/users/})
  end

  def show_quick_access?(_user)
    policy(Location).index? || policy(Agreement).new? || policy(FeeType).index? || policy(MembershipType).index?
  end
end
