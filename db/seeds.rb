# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
User.create([
{ nickname: 'Feli', mail: 'felipe@habitica.com', password: "1234" }, 
{ nickname: 'Pai', mail: 'paiadmin@habitica.com', password: "1234" }, 
{ nickname: 'Lala', mail: 'lala@habitica.com', password: "1234" }, 
{ nickname: 'Seba', mail: 'sebastian@habitica.com', password: "1234" }, 
{ nickname: 'Leo', mail: 'Leosqa@habitica.com', password: "1234" }, 
{ nickname: 'Santos', mail: 'santos@habitica.com', password: "1234" }, 
{ nickname: 'Marco', mail: 'marcopablo@habitica.com', password: "1234" }, 
{ nickname: 'Berna', mail: 'bernardo@habitica.com', password: "1234" }
])

Habit.create([
{ name: 'Correr', frecuency: 1, difficulty: "easy", hasEnd: true , privacy: "public", endDate: DateTime.parse("03/11/2018 8:00") },
{ name: 'Caminar', frecuency: 0, difficulty: "hard", hasEnd: false , privacy: "private" },
{ name: 'Sentadillas', frecuency: 5, difficulty: "medium", hasEnd: true , privacy: "protected" },
{ name: 'Tomar agua', frecuency: 10, difficulty: "hard", hasEnd: false , privacy: "public" },
{ name: 'Ir al gym', frecuency: 0, difficulty: "easy", hasEnd: false , privacy: "public", endDate: DateTime.parse("04/3/2019 8:00") },
{ name: 'Andar en bicicleta', frecuency: 0, difficulty: "easy", hasEnd: true , privacy: "protected" },
{ name: 'Correr', frecuency: 0, difficulty: "medium", hasEnd: false , privacy: "protected", endDate: DateTime.parse("12/2/2018 8:00") },
{ name: 'Comida sana', frecuency: 2, difficulty: "easy", hasEnd: true , privacy: "protected" }, 
])
