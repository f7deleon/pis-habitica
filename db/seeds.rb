# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples

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

DefaultType.create([
	{name: 'Ejercicio', description: 'Hacer ejercicio'},
	{name: 'Nutricion', description: 'Seguir determinada dieta'},
	{name: 'Estudio', description: 'Estudiar por mas de 1 hora'},
	{name: 'Social', description: 'Ir al bar'},
	{name: 'Ocio', description: 'Jugar a la switch'}
])

Character.create([
  { name: 'Mago', description: 'Hace magia para cumplir sus habitos, nadie le cree ni saben como hace.' },
  { name: 'Elfa', description: 'Ser fantástico con figura de enana y poderes mágicos; vive en los bosques, las aguas y
                                en las proximidades de las casas y trabaja como herrera.' },
  { name: 'Fantasma', description: 'Dice que siempre cumple sus habitos pero en realidad no lo hace.' },
  { name: 'No muerto', description: 'Nadie sabe como sigue con vida, pero consigue energias de algun
                                     lugar oculto y cumple sus habitos' },
  { name: 'Cazador', description: 'Siempre se acerca a su presa, la rodea y lanza el ataque.
                                   No titubea al momento de cumplir sus habitos.' }
])
