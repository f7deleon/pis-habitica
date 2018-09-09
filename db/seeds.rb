# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples

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

Type.create([
	{name: 'Ejercicio', description: 'Hacer ejercicio'},
	{name: 'Nutricion', description: 'Seguir determinada dieta'},
	{name: 'Estudio', description: 'Estudiar por mas de 1 hora'},
	{name: 'Social', description: 'Ir al bar'},
	{name: 'Ocio', description: 'Jugar a la switch'}
])

@user = User.create(
  nickname: 'Example_seed',
  mail: 'example_seed@example.com',
  password: 'Example123_seed'
)
@user2 = User.create(
  nickname: 'Example12_seed',
  mail: 'example12_seed@example.com',
  password: 'Example123_seed'
)
@user_type = Type.create(name: 'Example_seed', description: 'Example_seed')
@user_type2 = Type.create(name: '2_seed', description: '2_seed')
@individual_type = IndividualType.create(
  user_id: @user.id,
  type_id: @user_type.id
)
@individual_type2 = IndividualType.create(
  user_id: @user.id,
  type_id: @user_type2.id
)

@user.individual_types << @individual_type
@user.individual_types << @individual_type2

#asign character to user
@character = Character.create(name: 'Elfa', description: 'Descripcion Elfa')
@character2 = Character.create(name: 'Bruja', description: 'Descripcion Bruja')
@user_character = UserCharacter.create(user_id: @user.id, character_id: @character.id, creation_date: '2018-09-07T12:00:00Z', is_alive: true)
@user_character2 = UserCharacter.create(user_id: @user.id, character_id: @character2.id, creation_date: '2018-09-07T12:00:00Z', is_alive: false)
@user.user_characters << @user_character
@user.user_characters << @user_character2

#assign habits to user
@individual_habit = IndividualHabit.create(
  user_id: @user.id,
  name: 'Example',
  description: 'Example desc',
  difficulty: 3,
  privacy: 1,
  frequency: 1
)
@individual_habit2 = IndividualHabit.create(
  user_id: @user.id,
  name: 'Example2',
  description: 'Example2 desc',
  difficulty: 2,
  privacy: 2,
  frequency: 2
)
@habit_type = IndividualHabitHasType.create(individual_habit_id: @individual_habit.id, type_id: @user_type.id)

@user.individual_types << @individual_type
@individual_habit.individual_habit_has_types << @habit_type
@individual_habit2.individual_habit_has_types << @habit_type
@user.individual_habits << @individual_habit2
@user.individual_habits << @individual_habit


Character.create([
                     { name: 'Humano', description: 'Descripcion humano' },
                     { name: 'Brujo', description: 'Descripcion brujo' },
                     { name: 'Elfo', description: 'Descripcion elfo' },
                     { name: 'Enano', description: 'Descripcion Enano' },
                     { name: 'Orco', description: 'Descripcion Orco' },
                     { name: 'Llama de Fortnite', description: 'Descripcion Llama' },
                     { name: 'Castor', description: 'Descripcion Castors' },
                 ])

