#!/usr/bin/env ruby

require 'pg'
require 'psych'

@config = Psych.load_file('config.yml')

def with_db
	args = Psych.load_file('db.yml')
	db = PG.connect(args)

	begin
		yield db
	ensure
		db.close
	end
end

def query(db, filename, query)
	open(filename, 'w+') do |f|
		db.copy_data %Q{COPY (#{query}) TO STDOUT CSV HEADER} do
			while row = db.get_copy_data
				f.write(row)
			end
		end
	end
end

NAME_JOIN_QUERY = <<~Q.strip
	LEFT OUTER JOIN (SELECT DISTINCT ON (unh."UserId") * FROM "UsernameHistory" AS unh WHERE unh."Discriminator" = 'UsernameHistoryModel' ORDER BY unh."UserId", unh."DateAdded" DESC) AS unh ON unh."UserId" = subject."UserId"
Q
GUILD_CONDITION = <<~Q.strip
	subject."GuildId" = #{@config[:guild_id]}
Q

with_db do |db|
	query db, 'data/dailymoney.csv', <<~Q
		SELECT subject.*, unh."Name" FROM (SELECT count(*) AS times_received_dailymoney, subject."UserId" FROM "DailyMoneyStats" AS subject WHERE #{GUILD_CONDITION} GROUP BY subject."UserId") AS subject #{NAME_JOIN_QUERY} ORDER BY subject.times_received_dailymoney DESC
	Q

	query db, 'data/dailymoney_sum.csv', <<~Q
		SELECT subject.*, unh."Name" FROM (SELECT sum(subject."MoneyReceived") AS dailymoney_received, subject."UserId" FROM "DailyMoneyStats" AS subject WHERE #{GUILD_CONDITION} GROUP BY subject."UserId") AS subject #{NAME_JOIN_QUERY} ORDER BY subject.dailymoney_received DESC
	Q

	query db, 'data/total_daily_money.csv', <<~Q
		SELECT sum(subject."MoneyReceived") AS total_dailymoney_received, count(*) AS total_times_dailymoney_collected FROM "DailyMoneyStats" AS subject WHERE #{GUILD_CONDITION}
	Q
	
	query db, 'data/total_money.csv', <<~Q
		SELECT sum(subject."Amount") AS total_money FROM "Currency" AS subject WHERE #{GUILD_CONDITION}
	Q
	
	query db, 'data/voicestats.csv', <<~Q
		SELECT subject."TimeInVoiceChannel", subject."UserId", unh."Name" FROM "VoiceChannelStats" AS subject #{NAME_JOIN_QUERY} WHERE #{GUILD_CONDITION} ORDER BY subject."TimeInVoiceChannel" DESC
	Q

	query db, 'data/nickname_changes.csv', <<~Q
		SELECT subject.*, unh."Name" FROM (SELECT count(*) AS amount_nickname_changes, subject."UserId" FROM "UsernameHistory" AS subject WHERE subject."Discriminator" = 'NicknameHistoryModel' AND #{GUILD_CONDITION} GROUP BY subject."UserId") AS subject #{NAME_JOIN_QUERY} ORDER BY subject.amount_nickname_changes DESC
	Q

	query db, 'data/dailymoney_per_week.csv', <<~Q
		SELECT to_char(date_trunc('week', "DateAdded"), 'YYYY-MM-DD') AS time, count(*) AS collected_dailymoney FROM "DailyMoneyStats" AS subject WHERE #{GUILD_CONDITION} GROUP BY time ORDER BY time
	Q

	query db, 'data/dailymoney_per_month.csv', <<~Q
		SELECT to_char(date_trunc('month', "DateAdded"), 'YYYY-MM') AS time, count(*) AS collected_dailymoney FROM "DailyMoneyStats" AS subject WHERE #{GUILD_CONDITION} GROUP BY time ORDER BY time
	Q
end
