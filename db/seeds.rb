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
  { nickname: 'Lala', email: 'lalah@abitica.com', password: '12341234' },
  { nickname: 'Seba', email: 'sebastian@habitica.com', password: '12341234' },
  { nickname: 'Leo', email: 'Leosqa@habitica.com', password: '12341234' },
  { nickname: 'Santos', email: 'santos@habitica.com', password: '12341234' },
  { nickname: 'Marco', email: 'marcopablo@habitica.com', password: '12341234' },
  { nickname: 'Berna', email: 'bernardo@habitica.com', password: '12341234' }
])

User.all.each do |user|
  character_id = Character.order("RANDOM()").limit(1).first.id
  character = Character.find(character_id)
  user_character = user.add_character(character_id, Time.zone.now)
  character.user_characters << user_character
end

friends = User.all.limit(3).first

user.friends << friends


from_date = Date.new(2018, 9, 1)
to_date   = Date.new(2018, 9, 30)

IndividualHabit.create([
  {user_id: user.id, name: 'habito diario', description: 'diario', difficulty: 2, privacy: 1, frequency: 2,created_at: from_date},
  {user_id: user.id, name: 'habito', description: 'habito', difficulty: 3, privacy: 1, frequency: 1, created_at: from_date},
  {user_id: user.id, name: 'publico', description: 'publico', difficulty: 1, privacy: 1, frequency: 1},
  {user_id: user.id, name: 'protegido', description: 'protegido', difficulty: 2, privacy: 2, frequency: 1},
  {user_id: user.id, name: 'privado', description: 'privado', difficulty: 3, privacy: 3, frequency: 1},
])

habit = IndividualHabit.first
habit2 = IndividualHabit.second

(from_date..to_date).each { |date| 
  TrackIndividualHabit.create( habit_id: habit.id, date: date, health_difference: habit.increment_of_health(user))
  TrackIndividualHabit.create( habit_id: habit2.id, date: date, health_difference: habit2.increment_of_health(user)) if date.day % 3 == 0

}

