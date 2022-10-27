-- Check whole dataset
select *
from netflix

-- Number of Movies and TV shows made by countries
with Movies as 
(select country, count(*) as 'no_of_Movies'
from netflix
where type = 'Movie'
group by country),
TV_Shows as 
(select country, count(*) as 'no_of_TV_Shows'
from netflix
where type = 'TV Show'
group by country),
Movies_TV as
(select coalesce(m.country, TV.country) as country , coalesce(no_of_Movies,0) as movies_count, coalesce(no_of_TV_Shows,0) as tv_count
from Movies m full outer join TV_Shows TV on m.country = TV.country)
select country, movies_count, tv_count, movies_count+tv_count as 'Total_count'
from Movies_TV
order by Total_count desc

-- Number of Movies and TV shows added over the years
with movies_year as
(select year(date_added) as 'Year', count(*) as count_movies
from netflix
where type = 'Movie'
group by year(date_added)),
tv_year as
(select year(date_added) as 'Year', count(*) as count_tv_shows
from netflix
where type = 'TV Show'
group by year(date_added))
select coalesce(my.Year,ty.Year) as Year, count_movies, coalesce(count_tv_shows,0) as count_tv_shows
from movies_year my full outer join tv_year ty on my.Year = ty.Year
order by Year desc

-- Top 10 countries producing TV Shows
select b.country, b.count_tv_shows, rnk as Position
From
(select a.country, a.count_tv_shows, ROW_NUMBER() over (order by count_tv_shows desc) as rnk
From
(select country, count(*) as count_tv_shows  
from netflix
where type = 'TV Show'
group by country)a)b
where rnk < 11

-- Top 10 countries producing Movies
With movies as
(select country, count(*) as count_movies  
from netflix
where type = 'Movie'
group by country),
rnk_movies as
(select country, count_movies, ROW_NUMBER() over (order by count_movies desc) as rnk
from movies
where country <> 'Not Given')
select country, count_movies, rnk as Position
from rnk_movies
where rnk < 11 

-- Number of TV shows of every rating produced by countries
with TVrating as
(select country, rating, count(*) as count_rating 
from netflix
where type = 'TV Show' and rating <> 'NR' and country <> 'Not Given'
group by country, rating),
TVrating_pivot as
(select country, coalesce(max(case when rating = 'TV-MA' then count_rating end),0) as 'TV_MA',
coalesce(max(case when rating = 'TV-14' then count_rating end),0) as 'TV_14',
coalesce(max(case when rating = 'TV-PG' then count_rating end),0) as 'TV_PG',
coalesce(max(case when rating = 'TV-G' then count_rating end),0) as 'TV_G',
coalesce(max(case when rating = 'R' then count_rating end),0) as 'R',
coalesce(max(case when rating = 'TV-Y' then count_rating end),0) as 'TV_Y',
coalesce(max(case when rating = 'TV-Y7' then count_rating end),0) as 'TV_Y7',
coalesce(max(case when rating = 'TV-Y7-FV' then count_rating end),0) as 'TV_Y7_FV'
from TVrating
group by country)
select *, TV_MA+TV_14+TV_PG+TV_G+R+TV_Y+TV_Y7+TV_Y7_FV as Total_count
from TVrating_pivot
order by Total_count desc

-- Number of Movies of every rating produced by countries
with Movierating as
(select country, rating, count(*) as count_rating 
from netflix
where type = 'Movie' and rating not in ('NR', 'UR') and country <> 'Not Given'
group by country, rating),
Movierating_pivot as
(select country, coalesce(max(case when rating = 'TV-MA' then count_rating end),0) as 'TV_MA',
coalesce(max(case when rating = 'TV-14' then count_rating end),0) as 'TV_14',
coalesce(max(case when rating = 'TV-PG' then count_rating end),0) as 'TV_PG',
coalesce(max(case when rating = 'TV-G' then count_rating end),0) as 'TV_G',
coalesce(max(case when rating = 'R' then count_rating end),0) as 'R',
coalesce(max(case when rating = 'NC-17' then count_rating end),0) as 'NC_17',
coalesce(max(case when rating = 'PG' then count_rating end),0) as 'PG',
coalesce(max(case when rating = 'PG-13' then count_rating end),0) as 'PG_13',
coalesce(max(case when rating = 'G' then count_rating end),0) as 'G',
coalesce(max(case when rating = 'TV-Y' then count_rating end),0) as 'TV_Y',
coalesce(max(case when rating = 'TV-Y7' then count_rating end),0) as 'TV_Y7',
coalesce(max(case when rating = 'TV-Y7-FV' then count_rating end),0) as 'TV_Y7_FV'
from Movierating
group by country)
select *, TV_MA+TV_14+TV_PG+TV_G+R+NC_17+PG+PG_13+G+TV_Y+TV_Y7+TV_Y7_FV as Total_count
from Movierating_pivot
order by Total_count desc

-- Yearly Production of TV Shows in each rating over the years
with tv_show_rating_year as 
(select Year(date_added) as Year, rating, count(*) as count_tv_shows
from netflix
where type = 'TV Show' and rating <> 'NR'
group by Year(date_added), rating),
tv_show_rating_year_pivot as
(select Year, coalesce(max(case when rating = 'TV-MA' then count_tv_shows end),0) as 'TV_MA',
coalesce(max(case when rating = 'TV-14' then count_tv_shows end),0) as 'TV_14',
coalesce(max(case when rating = 'TV-PG' then count_tv_shows end),0) as 'TV_PG',
coalesce(max(case when rating = 'TV-G' then count_tv_shows end),0) as 'TV_G',
coalesce(max(case when rating = 'R' then count_tv_shows end),0) as 'R',
coalesce(max(case when rating = 'TV-Y' then count_tv_shows end),0) as 'TV_Y',
coalesce(max(case when rating = 'TV-Y7' then count_tv_shows end),0) as 'TV_Y7',
coalesce(max(case when rating = 'TV-Y7-FV' then count_tv_shows end),0) as 'TV_Y7_FV'
from tv_show_rating_year
group by Year)
select *, TV_MA+TV_14+TV_PG+TV_G+R+TV_Y+TV_Y7+TV_Y7_FV as Total_count
from tv_show_rating_year_pivot
order by Total_count desc

-- Yearly Production of Movies in each rating over the years
with movie_rating_year as 
(select Year(date_added) as Year, rating, count(*) as count_movies
from netflix
where type = 'Movie' and rating not in ('NR','UR')
group by Year(date_added), rating),
movie_rating_year_pivot as
(select Year, coalesce(max(case when rating = 'TV-MA' then count_movies end),0) as 'TV_MA',
coalesce(max(case when rating = 'TV-14' then count_movies end),0) as 'TV_14',
coalesce(max(case when rating = 'TV-PG' then count_movies end),0) as 'TV_PG',
coalesce(max(case when rating = 'TV-G' then count_movies end),0) as 'TV_G',
coalesce(max(case when rating = 'R' then count_movies end),0) as 'R',
coalesce(max(case when rating = 'NC-17' then count_movies end),0) as 'NC_17',
coalesce(max(case when rating = 'PG' then count_movies end),0) as 'PG',
coalesce(max(case when rating = 'PG-13' then count_movies end),0) as 'PG_13',
coalesce(max(case when rating = 'G' then count_movies end),0) as 'G',
coalesce(max(case when rating = 'TV-Y' then count_movies end),0) as 'TV_Y',
coalesce(max(case when rating = 'TV-Y7' then count_movies end),0) as 'TV_Y7',
coalesce(max(case when rating = 'TV-Y7-FV' then count_movies end),0) as 'TV_Y7_FV'
from movie_rating_year
group by Year)
select *, TV_MA+TV_14+TV_PG+TV_G+R+NC_17+PG+PG_13+G+TV_Y+TV_Y7+TV_Y7_FV as Total_count
from movie_rating_year_pivot
order by Total_count desc

-- Which TV show has maximum seasons made?
with season_table as
(select title, country, rating, value as seasons
from netflix cross apply string_split(duration, ' ')
where type = 'TV Show' and ISNUMERIC(value) = 1)
select title, country, rating, seasons
from season_table
where seasons = (select max(cast(seasons as int))
                 from season_table)

-- Which movie is the longest?
with longest_movie as
(select title, country, rating, value as time_in_min
from netflix cross apply string_split(duration, ' ')
where type = 'Movie' and ISNUMERIC(value) = 1)
select *
from longest_movie
where time_in_min = (select max(cast(time_in_min as int))
                     from longest_movie)

-- Which movie is the shortest?
with shortest_movie as
(select title, country, rating, value as time_in_min
from netflix cross apply string_split(duration, ' ')
where type = 'Movie' and ISNUMERIC(value) = 1)
select *
from shortest_movie
where time_in_min = (select min(cast(time_in_min as int))
                     from shortest_movie)

-- # Which TV Show has been added to netflix after being released for the longest?
with gap as
(select title, country, rating, date_added, release_year, Year(date_added)-release_year as Gap_Year 
from netflix
where type = 'TV Show') 
select *
from gap
where Gap_Year = (select max(Gap_Year) from gap)

-- Which Movie has been added to netflix after being released for the longest?
with gap as
(select title, country, rating, date_added, release_year, Year(date_added)-release_year as Gap_Year 
from netflix
where type = 'Movie') 
select *
from gap
where Gap_Year = (select max(Gap_Year) from gap)

-- Which category has maximum number of TV Shows?
select trim(value) as Category, count(*) as count_category
from netflix cross apply string_split(listed_in, ',')
where type = 'TV Show'
group by trim(value)
order by count_category desc

-- Which category has maximum number of Movies?
select trim(value) as Category, count(*) as count_category
from netflix cross apply string_split(listed_in, ',')
where type = 'Movie'
group by trim(value)
order by count_category desc

-- Yearly TV Show produced in each category
with year_category as
(select Year(date_added) as Year, trim(value) as Category, count(*) as count_category 
from netflix cross apply string_split(listed_in,',')
where type = 'TV Show'
group by Year(date_added), trim(value))
select *
from year_category 
PIVOT
(max(count_category) for Category in ([TV Horror], [British TV Shows], [Stand-Up Comedy & Talk Shows], [TV Dramas], [TV Sci-Fi & Fantasy], [Romantic TV Shows],
                                      [Crime TV Shows], [International TV Shows], [TV Comedies], [Science & Nature TV], [TV Thrillers], [Teen TV Shows], [Kids' TV], 
									  [Docuseries], [TV Shows], [TV Action & Adventure], [Anime Series], [Spanish-Language TV Shows], [Reality TV], [TV Mysteries], 
									  [Classic & Cult TV], [Korean TV Shows])) d

-- Yearly Movies produced in each category
with year_category as
(select Year(date_added) as Year, trim(value) as Category, count(*) as count_category 
from netflix cross apply string_split(listed_in,',')
where type = 'Movie'
group by Year(date_added), trim(value))
select *
from year_category 
PIVOT
(max(count_category) for Category in ([Children & Family Movies], [Anime Features], [Thrillers], [Comedies], [Music & Musicals], [International Movies],
                                      [Independent Movies], [Dramas], [Classic Movies], [Horror Movies], [Cult Movies], [Sports Movies], [Movies], 
									  [Romantic Movies], [Stand-Up Comedy], [Faith & Spirituality], [Sci-Fi & Fantasy], [Action & Adventure], [Documentaries], [LGBTQ Movies])) d

-- Average mins of movie duration in each year
with mins as
(select Year(date_added) as Year_, value as time_in_min
from netflix cross apply string_split(duration, ' ')
where type = 'Movie' and ISNUMERIC(value) = 1)
select Year_, avg(cast(time_in_min as int)) as Average_duration
from mins
group by Year_

-- Movie addition to netflix in each month according to the year
select *
from
(select Year(date_added) as Year_, MONTH(date_added) as Month_, count(*) as count_movies
from netflix
where type = 'Movie'
group by Year(date_added), MONTH(date_added)) a
PIVOT
(max(count_movies) for Month_ in ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12])) b

--TV Show addition to netflix in each month according to the year
select *
from
(select Year(date_added) as Year_, MONTH(date_added) as Month_, count(*) as count_tvshows
from netflix
where type = 'TV Show'
group by Year(date_added), MONTH(date_added)) a
PIVOT
(max(count_tvshows) for Month_ in ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12])) b



 







