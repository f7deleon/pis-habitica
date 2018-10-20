# frozen_string_literal: true

task penalize_habits: :environment do
  puts 'Starting penalizing habits ...'
  yesterday_date = Date.yesterday
  habits_to_penalize = IndividualHabit
                       .select { |habit| habit.active == true && habit.frequency == 2 }
                       .reject do |habit|
    habit.track_individual_habits.find_by(date: yesterday_date) || habit.user.dead?
  end

  habits_to_penalize.each do |habit|
    track_individual_habit = TrackIndividualHabit.new(
      habit_id: habit.id,
      date: yesterday_date
    )
    track_individual_habit.experience_difference = 0
    track_individual_habit.health_difference = habit.user.penalize(habit.difficulty)
    track_individual_habit.save!
    notification = PenalizeNotification.new(receiver: habit.user, track_individual_habit: track_individual_habit)
    notification.save!
  end
  puts 'done.'
end
