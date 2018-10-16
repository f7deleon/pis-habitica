# frozen_string_literal: true

class TrackIndividualHabit < ApplicationRecord
  belongs_to :individual_habit, foreign_key: :habit_id
  # (Es importante pasarle la diferencia post ver la maxima.
  # Ej, tenes 90/100hp, ganas 20 por cumplir, aca pasamos 10 directamente)

  # Agregarle experiencia ganada/perdida (experience_difference)

  scope :created_between, lambda { |start_date, end_date|
    where('date >= ? AND date <= ?', start_date, end_date)
  }
  # Agregarle una flag de si es suma o perdida??
  # Puede ser perdida si es habito positivo (por la penalizacion a las 00:00)

  # Serializar estos booleanos solo si son true:
  # Agregarle booleano si subiste de nivel
  # Agregarle booleano si moriste
  # Si subiste de nivel:
  # Vida actual (que sera la nueva maxima)
  # Experiencia actual.
end
