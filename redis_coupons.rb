require 'redis'

redis = Redis.new


def gen_redis_proto(*cmd)
    proto = ""
    proto << "*"+cmd.length.to_s+"\r\n"
    cmd.each { |arg|
        proto << "$"+arg.to_s.bytesize.to_s+"\r\n"
        proto << arg.to_s+"\r\n"
    }
    proto
end


def create_code(excluded_chars, length)
	chars = (('A'..'Z').to_a + (0..9).to_a) - excluded_chars
	chars.sample(length).join
end



new_codes = false
prefix = "nesquik"
excluded_chars = ['X', 'Z', 'K', 'O', 'I', 0, 1, 3]
length = 6
ttl = (Time.local(2013, 8, 22, 23, 59, 59) - Time.now).to_i
count = 100

if ttl < 1
	puts "Enddatum liegt in der Vergangenheit!"
	exit
end

(0...count).each { |n|
	
	code = create_code(excluded_chars, length)
	key  = "#{prefix}:#{code}"
	unless new_codes
		while redis.exists(key) do
			code = create_code(excluded_chars, length)
			key  = "#{prefix}:#{code}"
		end
	end
	
    STDOUT.write(gen_redis_proto("SETEX", key, ttl.to_s, '{"used":0, "date":null}'))
}