Create TABLE [dbo].[netflix_raw](
	[show_id] [varchar](10) primary key,
	[type] [varchar](10) NULL,
	[title] [nvarchar](200) NULL,
	[director] [varchar](250) NULL,
	[cast] [varchar](1000) NULL,
	[country] [varchar](150) NULL,
	[date_added] [varchar](20) NULL,
	[release_year] [int] NULL,
	[rating] [varchar](10) NULL,
	[duration] [varchar](10) NULL,
	[listed_in] [varchar](100) NULL,
	[description] [varchar](500) NULL
) 

select * from netflix_raw
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/* Generated a Cleaned table for netflix_table */
with cte as 
(
select *
,ROW_NUMBER() over(partition by title,type order by show_id) as rn
from netflix_raw
)
select show_id,type,title,cast(date_added as date) as date_added ,release_year,rating ,case when duration is null then rating else duration end as duration,description 
into netflix_final 
from cte 

select * from netflix_final
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/* Generate a new table for directors columns */

select show_id, TRIM(value) as director
into netflix_directors
from netflix_raw 
cross apply string_split(director,',')
order by show_id

select * from netflix_directors

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/* Generate a new table for country columns */

select show_id, TRIM(value) as country
into netflix_country
from netflix_raw 
cross apply string_split(country,',')
order by show_id

select * from netflix_country order by show_id

 sp_rename 'netflix_country.director', 'country'

 ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/* Generate a new table for cast columns */

select show_id, TRIM(value) as cast
into netflix_cast
from netflix_raw 
cross apply string_split(cast,',')
order by show_id

 sp_rename 'netflix_cast.director', 'cast'

select * from netflix_cast order by show_id
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/* Generate a new table for Genre columns */

select show_id, TRIM(value) as listed_in
into netflix_genre
from netflix_raw 
cross apply string_split(listed_in,',')
order by show_id

select * from netflix_genre order by show_id

 sp_rename 'netflix_genre.director', 'listed_in'
---------------------------------------------------------------------------------------------
/* populate the missing values in country , duration columns */

select *
from netflix_raw
where country is null

select *-- show_id, country
from netflix_raw
where country is null
---------------------------------------------------------------------------------------------
insert into netflix_country 
select  show_id,m.country 
from netflix_raw nr 
inner join(
select  director,country
from netflix_country nc inner join 
netflix_directors nd on nc.show_id=nd.show_id
group by director,country
) m on nr.director =m.director
where nr.country is null
---------------------------------------------------------------------------------------------
select * from netflix_raw where duration is null;


----------------------------------netflix data analysis question-----------------------------------------
/* for each director count the number of movies and tv shows created by them in separate columns fro director	who have created tv shows and movies both*/

select  nd.director ,count( distinct nf.type) as distinct_count
,count(distinct case when nf.type='Movie' then nf.show_id end ) as no_of_Movies
,count(distinct case when nf.type='TV Show' then nf.show_id end )as no_of_TV_Show
from netflix_final nf 
inner join netflix_directors nd 
on nf.show_id=nd.show_id
group by nd.director 
having count( distinct nf.type)>1

/* which country has the highest number of comedie movies*/
select top 1 nc.country,count( distinct ng.show_id) as no_of_Comedie_movies
from netflix_genre ng
inner join netflix_country nc on ng.show_id=nc.show_id
inner join netflix_final nf on ng.show_id=nc.show_id
where ng.listed_in='Comedies' and nf.type='Movie'
group by nc.country
order by  no_of_Comedie_movies desc

/* for each year(as per date added to netflix ),which director has the maximum number of movies released */

with cte as 
(
select nd.director,year(nf.date_added) as date_year ,count(nf.show_id) as no_of_movies
from netflix_final nf inner join
netflix_directors nd on nf.show_id=nd.show_id
where nf.type='Movie'
group by  nd.director,year(nf.date_added)
--order by  no_of_movies desc
),cte2 as 
(
select *,
ROW_NUMBER() over(partition by date_year order by no_of_movies desc,director) as rn
from cte
--order by date_year, no_of_movies desc
)
select * from cte2 where rn=1

/* what is the average duration of movies in each genre */

select ng.listed_in, Avg(cast(REPLACE(duration,' min','') as int)) as average_duration
from netflix_final nf
inner join netflix_genre ng on nf.show_id=ng.show_id
where nf.type='Movie'
group by ng.listed_in
order by average_duration desc

/* find the list of directors who have created horror and comedy movies both.
display director name along with number of comedy and horror movies directed by them */

select nd.director
,count(distinct case when ng.listed_in='Comedies' then nf.show_id end ) as no_of_comedy
,count(distinct case when ng.listed_in='Horror Movies' then nf.show_id end ) as no_of_Horror_Movies
from netflix_final nf
inner join netflix_genre ng on nf.show_id=ng.show_id
inner join netflix_directors nd on nf.show_id=nd.show_id
where nf. type='Movie' and ng.listed_in in('Comedies','Horror Movies')
group by nd.director
having count(distinct ng.listed_in)=2


