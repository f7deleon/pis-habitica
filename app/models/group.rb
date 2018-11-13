# frozen_string_literal: true

class Group < ApplicationRecord
  has_many :group_types

  has_many :group_habits
  has_many :track_group_habits, through: :group_habits

  has_many :memberships
  has_many :users, through: :memberships, class_name: 'User', foreign_key: :user_id

  validates :privacy, inclusion: [true, false] # true = private, false = public

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
    # check if all members exist
    members_ids = []
    members.each do |member|
      unless User.exists?(member[:id])
        raise Error::CustomError.new(I18n.t(:bad_request), '404', I18n.t('errors.messages.member_not_exist'))
      end

      members_ids << member[:id].to_i
    end
    old_members = []
    memberships.each do |membership|
      old_members << membership.user_id
    end
    new_members = members_ids - old_members
    new_members.uniq! # Remueve elementos duplicados (dejando solo uno)
    deleted_members = old_members - members_ids

    # Borrar viejos miembros
    memberships.each do |membership|
      membership.delete if membership.user_id.in?(deleted_members) && !membership.user_id.eql?(admin.id)
    end
    # Agregar nuevos
    new_members.each do |member|
      next if memberships.find_by_user_id(member)

      Membership.create(user_id: member, group_id: id, admin: false)
      friend_request_notification = GroupNotification.new(user_id: member, group_id: id)
      friend_request_notification.save!
    end
  end
end
