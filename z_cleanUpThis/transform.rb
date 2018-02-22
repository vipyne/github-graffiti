heartstr_in = "111119111911111*1111*1*****1*****1*111111111*1111111111199919991111*1111*111*11111*111*11111111***111111111199999991111*1111*111*11111*111*1111***********11111199999991111*1111*111*11111*111*111111*******1111111119999911111*1111*111*11111*111*1111111**1**11111111111999111111*1111*111*11111*111*111111**111**1111111111191111111****1*111*11111*111****11*1111111*111"

num_squares = heartstr_in.length

second_year = {}

all_second = []

52.times do |d|
  second_year[d%52] = []
end

num_squares.times do |i|
  second_year[i%52].push(heartstr_in[i])
end

second_year.each do |k, v|
  all_second.push(v)
end

final_str = all_second.flatten.join

final_str