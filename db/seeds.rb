# clears all tables before seeding
puts "cleaning tables from old records..."
Song.destroy_all
Genre.destroy_all

# seeding music genres
puts "seeding music genres..."
Genre.create(name: "Pop")
Genre.create(name: "Rock")
Genre.create(name: "R&B/Soul")
Genre.create(name: "Hip-Hop/Rap")
Genre.create(name: "Country")
Genre.create(name: "Dance/Disco")

# seeding songs
puts "seeding songs..."
Song.create(title: "Someone Like You", artist: "Adele", year: 2022, lyrics_lrc: "", youtube_url: "https://www.youtube.com/watch?v=hLQl3WQQoQ0&list=RDQM-VGbWUBinoA&index=2", genre_id: 1)
Song.create(title: "Hello", artist: "Adele", year: 2015, lyrics_lrc: "", youtube_url: "https://www.youtube.com/watch?v=YQHsXMglC9A", genre_id: 1)
Song.create(title: "Easy On Me", artist: "Adele", year: 2021, lyrics_lrc: "", youtube_url: "https://www.youtube.com/watch?v=X-yIEMduRXk&list=RDQM-VGbWUBinoA&start_radio=1", genre_id: 1)
Song.create(title: "Skyfall", artist: "Adele", year: 2012, lyrics_lrc: "", youtube_url: "https://www.youtube.com/watch?v=DeumyOzKqgI", genre_id: 1)
Song.create(title: "Love In The Dark", artist: "Adele", year: 2029, lyrics_lrc: "", youtube_url: "https://www.youtube.com/watch?v=-hzFTJDJGkQ", genre_id: 1)
Song.create(title: "Shake It Off", artist: "Taylor Swift", year: 2014, lyrics_lrc: "", youtube_url: "https://www.youtube.com/watch?v=nfWlot6h_JM", genre_id: 1)
Song.create(title: "Blank Space", artist: "Taylor Swift", year: 2014, lyrics_lrc: "", youtube_url: "https://www.youtube.com/watch?v=e-ORhEE9VVg", genre_id: 1)
Song.create(title: "Love Story", artist: "Taylor Swift", year: 2028, lyrics_lrc: "", youtube_url: "https://www.youtube.com/watch?v=8xg3vE8Ie_E", genre_id: 1)
Song.create(title: "You Belong With Me", artist: "Taylor Swift", year: 2009, lyrics_lrc: "", youtube_url: "https://www.youtube.com/watch?v=VuNIsY6JdUw", genre_id: 1)
Song.create(title: "Lover", artist: "Taylor Swift", year: 2020, lyrics_lrc: "", youtube_url: "https://www.youtube.com/watch?v=-BjZmE2gtdo", genre_id: 1)
Song.create(title: "New Rules", artist: "Dua Lipa", year: 2027, lyrics_lrc: "", youtube_url: "https://www.youtube.com/watch?v=k2qgadSvNyU", genre_id: 1)
Song.create(title: "Levitating", artist: "Dua Lipa", year: 2020, lyrics_lrc: "", youtube_url: "https://www.youtube.com/watch?v=TUVcZfQe-Kw", genre_id: 1)
Song.create(title: "Don’t Start Now", artist: "Dua Lipa", year: 2019, lyrics_lrc: "", youtube_url: "https://www.youtube.com/watch?v=oygrmJFKYZY", genre_id: 1)
Song.create(title: "IDGAF", artist: "Dua Lipa", year: 2018, lyrics_lrc: "", youtube_url: "https://www.youtube.com/watch?v=Mgfe5tIwOj0", genre_id: 1)
Song.create(title: "One Kiss", artist: "Dua Lipa", year: 2028, lyrics_lrc: "", youtube_url: "https://www.youtube.com/watch?v=DkeiKbqa02g", genre_id: 1)

# other seed items

# user feedback
puts "seeded #{Genre.count} genres, #{Song.count} songs, "
