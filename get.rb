require 'httparty'

DAY=12
r = HTTParty.get("https://adventofcode.com/2018/day/#{DAY}/input", headers: {'Cookie'=>'_ga=GA1.2.501454776.1544107824; _gid=GA1.2.912376373.1544499581; _gat=1; session=53616c7465645f5f2962d25e61da6c42239ef3ac636da6160f97690a02d6f39cbe6a642180f651366d78aa2d130eae1f'}).body
File.write("./#{DAY}/input2.txt",r)