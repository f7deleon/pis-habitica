# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:

movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
Character.create(name: 'Luke', movie: movies.first)
User.create([
  { nickname: 'Feli', mail: 'felipe@habitica.com', password: '12341234' },
  { nickname: 'Pai', mail: 'paiadmin@habitica.com', password: '12341234' },
  { nickname: 'Lala', mail: 'lala@habitica.com', password: '12341234' },
  { nickname: 'Seba', mail: 'sebastian@habitica.com', password: '12341234' },
  { nickname: 'Leo', mail: 'Leosqa@habitica.com', password: '12341234' },
  { nickname: 'Santos', mail: 'santos@habitica.com', password: '12341234' },
  { nickname: 'Marco', mail: 'marcopablo@habitica.com', password: '12341234' },
  { nickname: 'Berna', mail: 'bernardo@habitica.com', password: '12341234' }
])