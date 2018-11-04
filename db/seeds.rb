# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples

DefaultType.create([
  {name: 'Ejercicio', description: 'Hacer ejercicio'},
  {name: 'Nutricion', description: 'Seguir determinada dieta'},
  {name: 'Estudio', description: 'Estudiar por mas de 1 hora'},
  {name: 'Social', description: 'Ir al bar'},
  {name: 'Ocio', description: 'Jugar a la switch'}
])

user = User.create(nickname: "Demogorgon", email: "demo@demo.com", password: "12341234")

Character.create([
  { name: 'Mago', description: I18n.t('mage_description') },
  { name: 'Elfa', description: I18n.t('elf_description') },
  { name: 'Fantasma', description: I18n.t('gost_description') },
  { name: 'No muerto', description: I18n.t('dead_description') },
  { name: 'Cazador', description: I18n.t('hunter_description') }
])


User.create([
  { nickname: 'Feli', email: 'felipe@habitica.com', password: '12341234' },
  { nickname: 'Pai', email: 'paiadmin@habitica.com', password: '12341234' },
  { nickname: 'Lala', email: 'lala@habitica.com', password: '12341234' },
  { nickname: 'Seba', email: 'sebastian@habitica.com', password: '12341234' },
  { nickname: 'Leo', email: 'Leosqa@habitica.com', password: '12341234' },
  { nickname: 'Santos', email: 'santos@habitica.com', password: '12341234' },
  { nickname: 'Marco', email: 'marcopablo@habitica.com', password: '12341234' },
  { nickname: 'Berna', email: 'bernardo@habitica.com', password: '12341234' },
  { nickname: 'ElRodra', email: 'rodra@habitica.com', password: '12341234' },
  { nickname: 'Mufasa', email: 'mufasa@habitica.com', password: '12341234'}
])

User.all.each do |user|
  character_id = Character.order("RANDOM()").limit(1).first.id
  character = Character.find(character_id)
  user_character = user.add_character(character_id, Time.zone.now)
  character.user_characters << user_character
  friends = User.where.not(id: user.id).shuffle.first(3)
  friends.each do |friend|
    _friend = Friendship.new(user: user, friend: friend)
    if _friend.valid? 
      _friend.save
    end
  end
end

from_date = Date.new(2018, 9, 1)
to_date   = Date.new(2018, 9, 30)

user3 = User.find_by!(nickname: 'ElRodra')

IndividualHabit.create([
  {user_id: user.id, name: 'habito diario', description: 'diario', difficulty: 2, privacy: 1, frequency: 2,created_at: from_date},
  {user_id: user.id, name: 'habito', description: 'habito', difficulty: 3, privacy: 1, frequency: 1, created_at: from_date},
  {user_id: user.id, name: 'publico', description: 'publico', difficulty: 1, privacy: 1, frequency: 1},
  {user_id: user.id, name: 'protegido', description: 'protegido', difficulty: 2, privacy: 2, frequency: 1},
  {user_id: user.id, name: 'privado', description: 'privado', difficulty: 3, privacy: 3, frequency: 1},
  {user_id: user3.id, name: 'habito diario', description: 'diario', difficulty: 2, privacy: 1, frequency: 2,created_at: from_date},
  {user_id: user3.id, name: 'habito', description: 'habito', difficulty: 3, privacy: 1, frequency: 1, created_at: from_date},
  {user_id: user3.id, name: 'publico', description: 'publico', difficulty: 1, privacy: 1, frequency: 1},
  {user_id: user3.id, name: 'protegido', description: 'protegido', difficulty: 2, privacy: 2, frequency: 1},
  {user_id: user3.id, name: 'privado', description: 'privado', difficulty: 3, privacy: 3, frequency: 1},
])

habit = IndividualHabit.first
habit2 = IndividualHabit.second

(from_date..to_date).each { |date| 
  TrackIndividualHabit.create( habit_id: habit.id, date: date, health_difference: habit.increment_of_health(user))
  TrackIndividualHabit.create( habit_id: habit2.id, date: date, health_difference: habit2.increment_of_health(user)) if date.day % 3 == 0

}

user2 = User.find_by!(nickname: 'Berna')

group = Group.create(name: 'Propio', description: 'Propio Grupo', privacy: false)
group2 = Group.create(name: 'Grupo de lectura', description: 'Esto es un grupo de lectura', privacy: false)
group3 = Group.create(name: 'Grupo deamigas', description: '', privacy: false)

membership = Membership.create(user_id: user.id, group_id: group.id, admin: true)
membership2 = Membership.create(user_id: user2.id , group_id: group.id, admin: false)

Membership.create(user: User.find_by_nickname('Pai'), group_id: group3.id, admin: true)
Membership.create(user: User.find_by_nickname('ElRodra'), group_id: group3.id, admin: false)
Membership.create(user: User.find_by_nickname('Berna'), group_id: group3.id, admin: false)
Membership.create(user: user, group_id: group3.id, admin: false)

Membership.create(user: User.find_by_nickname('ElRodra'), group_id: group2.id, admin: true)
Membership.create(user: User.find_by_nickname('Lala'), group_id: group2.id, admin: false)
Membership.create(user: User.find_by_nickname('Seba'), group_id: group2.id, admin: false)
Membership.create(user: user, group_id: group2.id, admin: false)

group_habit = GroupHabit.create(group_id: group.id, name: 'habito diario', description: 'diario', difficulty: 2, privacy: 1, frequency: 1,created_at: from_date)

GroupHabit.create(group_id: group2.id, name: 'habito', description: 'diario', difficulty: 2, privacy: 1, frequency: 2,created_at: from_date)

TrackGroupHabit.create(
  user_id: user.id,
  habit_id: group_habit.id,
  date: Date.new(2018,11,4),
  experience_difference: user.modify_experience(20),
  health_difference: user.modify_health(100)
)

TrackGroupHabit.create(
  user_id: user.id,
  habit_id: group_habit.id,
  date: Date.new(2018,11,4),
  experience_difference: user.modify_experience(20),
  health_difference: user.modify_health(100)
)

TrackGroupHabit.create(
  user_id: user.id,
  habit_id: group_habit.id,
  date: Date.new(2018,11,1),
  experience_difference: user.modify_experience(20),
  health_difference: user.modify_health(100)
)

TrackGroupHabit.create(
  user_id: user2.id,
  habit_id: group_habit.id,
  date: Date.new(2018,11,4),
  experience_difference: user2.modify_experience(20),
  health_difference: user2.modify_health(100)
)
