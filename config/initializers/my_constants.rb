# frozen_string_literal: true

EXP_BASE = ENV['EXP_BASE'].to_i.freeze
EXP_INCREMENT = ENV['EXP_INCREMENT'].to_i.freeze
HEALTH_BASE = ENV['HEALTH_BASE'].to_i.freeze
HEALTH_INCREMENT = ENV['HEALTH_INCREMENT'].to_i.freeze
UTC_HOURS = 0
HEALTH_DIFFICULTY_INCREMENT = ENV['HEALTH_DIFFICULTY_INCREMENT'].to_i.freeze
EXP_DIFFICULTY_INCREMENT = ENV['EXP_DIFFICULTY_INCREMENT'].to_i.freeze
SCORE_DIFFICULTY_INCREMENT = ENV['SCORE_DIFFICULTY_INCREMENT'].to_i.freeze
STATUS_NO_RELATIONSHIP = 0
STATUS_REQUEST_SENT = 1
STATUS_REQUEST_RECEIVED = 2
STATUS_FRIENDS = 3
GROUP_REQUEST_NO_SEND = 0
GROUP_REQUEST_SEND = 1
GROUP_IS_MEMBER = 2
GROUP_IS_ADMIN = 3
