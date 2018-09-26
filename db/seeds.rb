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
  { nickname: 'Berna', email: 'bernardo@habitica.com', password: '12341234' }
])

User.all.each do |user|
  UserCharacter.create(user_id: user.id, character_id: Character.order("RANDOM()").limit(1).first.id, creation_date: Time.zone.now, is_alive: true)
end
