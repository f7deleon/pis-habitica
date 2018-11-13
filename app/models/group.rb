# frozen_string_literal: true

class Group < ApplicationRecord
  has_many :group_types

  has_many :group_habits
  has_many :track_group_habits, through: :group_habits

  has_many :memberships
  has_many :users, through: :memberships, class_name: 'User', foreign_key: :user_id

  validates :privacy, inclusion: [true, false]

  self.primary_key = :id
  validates :name, presence: true # string

  def member_in_group(member_id)
    !memberships.find_by_user_id(member_id).nil?
  end

  def erase_member(user_id)
    memberships.find_by_user_id(user_id).delete
    return true if memberships.length.zero?
    return false if memberships.find_by_admin(true)

    new_admin = memberships.order('created_at ASC').first
    new_admin.admin = true
    new_admin.save
    false
  end

  def update_members(members, admin)
    # check if new members have a friendship with the admin user and if user exists
    members.each do |member|
      unless User.exists?(member[:id])
        raise Error::CustomError.new(I18n.t(:bad_request), '404', I18n.t('errors.messages.member_not_exist'))
      end
    end
    memberships.each do |membership|
      membership.delete unless membership.user_id == admin.id
    end
    members.each do |member|
      unless memberships.find_by_user_id(member[:id])
        Membership.create(user_id: member[:id], group_id: id, admin: false)
      end
    end
  end
end
