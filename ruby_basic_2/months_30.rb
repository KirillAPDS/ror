=begin
	
1. Сделать хеш, содержащий месяцы и количество дней в месяце. 
В цикле выводить те месяцы, у которых количество дней ровно 30
	
=end

# создаем хэш
months = {
	"january" => 31,
	"february" => 28,
	"march" => 31,
	"april" => 30,
	"may" => 31,
	"june" => 30,
	"july" => 31,
	"august" => 31,
	"september" => 30,
	"october" => 31,
	"november" => 30,
	"december" => 31

}

puts "В этих месяцах ровно по 30 дней: "

# цикл для выделения 30-дневных месяцев
  months.each do |month, days|
    puts month if days == 30
	end


  # months.each do |month, days|
	# if days == 30
	#   puts month
  #   end
  # end

  
