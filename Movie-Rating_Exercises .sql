/* Q1
Find the titles of all movies directed by Steven Spielberg. */

select title
from Movie
where director = 'Steven Spielberg';

/* Q2
Find all years that have a movie that received a rating of 4 or 5, 
and sort them in increasing order. */

select distinct year
from Movie, Rating
where Movie.mID = Rating.mID 
and stars >= 4
order by year asc;


/*Q3
Find the titles of all movies that have no ratings. */

select title
from Movie
where mID not in (select mID from Rating);


/*Q4
Some reviewers didn't provide a date with their rating. Find the names 
of all reviewers who have ratings with a NULL value for the date. */

select name
from Reviewer
where rID in (select rID from Rating
			  where ratingDate is null);


/*Q5
Write a query to return the ratings data in a more readable format: reviewer name, 
movie title, stars, and ratingDate. Also, sort the data, first by reviewer name, 
then by movie title, and lastly by number of stars. */

select name, title, stars, ratingDate
from Movie, Reviewer, Rating
where Movie.mID = Rating.mID
and Reviewer.rID = Rating.rID
order by name, title, stars;


/*Q6
For all cases where the same reviewer rated the same movie twice and gave it a higher 
rating the second time, return the reviewer's name and the title of the movie. */

select name, title
from Reviewer, Movie, Rating R1, Rating R2
	where R1.rID = R2.rID and Reviewer.rID = R1.rID
	and R1.mID = R2.mID and Movie.mId = R1.mID
	and R1.stars < R2.stars 
	and R1.ratingDate < R2.ratingDate;


/* Q7
For each movie that has at least one rating, find the highest number of stars that 
movie received. Return the movie title and number of stars. Sort by movie title.*/

select title, max(stars)
from Movie, Rating
where Movie.mID = Rating.mID
group by Movie.mID
order by title;


/* Q8
For each movie, return the title and the 'rating spread', that is, the difference 
between highest and lowest ratings given to that movie. Sort by rating spread from highest 
to lowest, then by movie title. */

select title, (max(stars) - min(stars)) as Spread
from Movie M, Rating R
where M.mID = R.mID
group by title
order by Spread desc;


/* Q9
Find the difference between the average rating of movies released before 1980 and the 
average rating of movies released after 1980. (Make sure to calculate the average rating 
for each movie, then the average of those averages for movies before 1980 and movies after. 
Don't just calculate the overall average rating before and after 1980.) */

select avg(pre80.groupAvg) - avg(post80.groupAvg) as Difference
from (
  select Movie.mID, avg(stars) as groupAvg
  from Rating, Movie
  where Rating.mID = Movie.mID
  and year <= 1980
  group by Rating.mID
) as pre80,
(
  select Movie.mID, avg(stars) as groupAvg
  from Rating, Movie
  where Rating.mID = Movie.mID
  and year > 1980
  group by Rating.mID
) as post80
;


/*** PART 2 Extras ***/

/*Q1
Find the names of all reviewers who rated Gone with the Wind. */

select name
from Reviewer
where rID in 
	(select rID from Rating 
	where mID in
		(select mId from Movie
		where title = 'Gone with the Wind')
	);

/*Q2
For any rating where the reviewer is the same as the director of the movie, 
return the reviewer name, movie title, and number of stars. */

select name, title, stars
from (Movie join Rating using (mID)) join Reviewer using (rID)
where name = director;


/* Q3
Return all reviewer names and movie names together in a single list, alphabetized. 
(Sorting by the first name of the reviewer and first word in the title is fine; 
no need for special processing on last names or removing "The".) */

select name as Names
from Reviewer
UNION
select title as Names
from Movie
order by Names;


/* Q4 
Find the titles of all movies not reviewed by Chris Jackson. */

select title
from Movie
where mID not in 
	(select mID from Rating
	where rID in
		(select rID 
		from Reviewer
		where name = 'Chris Jackson')
	);

/* OR */

select title
from (select title from Movie
	 where mID not in 
		(select mID from Rating
		where rID in
			(select rID 
			from Reviewer
			where name = 'Chris Jackson')
		)
	 ) M;


/* Q5
For all pairs of reviewers such that both reviewers gave a rating to the same movie, 
return the names of both reviewers. Eliminate duplicates, don't pair reviewers with 
themselves, and include each pair only once. For each pair, return the names in the 
pair in alphabetical order. */

select distinct Re1.name, Re2.name
from Reviewer Re1, Reviewer Re2, Rating R1, Rating R2
where R1.mID = R2.mID
and Re1.rID = R1.rID
and Re2.rID = R2.rID
and Re1.name < Re2.name 
order by Re1.name;


/* Q6
For each rating that is the lowest (fewest stars) currently in the database, return 
the reviewer name, movie title, and number of stars. */

select name, title, stars
from (Reviewer join Rating using(rID)) join Movie using (mID)
where stars <= all(select stars from Rating);
/*sqlite doesn't support ALL*/

/* for SQLite: */
select name, title, stars
from (Reviewer join Rating R1 using(rID)) join Movie using (mID)
where not exists (select * from Rating R2 where R2.stars < R1.stars);


/* Q7
List movie titles and average ratings, from highest-rated to lowest-rated. 
If two or more movies have the same average rating, list them in alphabetical order. */

/*First do query to picture grouping*/
	select title, stars
	from Movie join Rating using(mID)
	order by title;

/* Now back to query we want */
select title, avg(stars) as AVGstars
from Movie join Rating using(mID)
group by title
order by AVGstars desc, title;


/* Q8
Find the names of all reviewers who have contributed three or more ratings. 
(As an extra challenge, try writing the query without HAVING or without COUNT. */

/*First do query to picture grouping*/
	select name, ratingDate
	from Reviewer join Rating using(rID)
	order by Reviewer.rID;

select name
from Reviewer join Rating using(rID)
group by rID
having count(*) >= 3;

/* without having */ 

select name 
from Reviewer
where 3<=(select count(*) 
          from Rating 
          where Rating.rid = Reviewer.rid);


/*Q9
Some directors directed more than one movie. For all such directors, return the titles
of all movies directed by them, along with the director name. Sort by director name, 
then movie title. (As an extra challenge, try writing the query both with and without COUNT.) */

select title, director
from Movie M1
where director in 
	(select director
	from Movie M2
	where M2.director = M1.director
	and M2.mID <> M1.mID)
order by 2,1;

select title, director
from Movie
where director in 
	(select director from Movie
	group by director
	having count(*) >= 2)
order by 2,1;



/* Q10
Find the movie(s) with the highest average rating. Return the movie title(s) and average rating. 
(Hint: This query is more difficult to write in SQLite than other systems; you might think of it 
as finding the highest average rating and then choosing the movie(s) with that average rating.) */ 

/* for mysql that supports all */

select title, avg(stars) as AVGstars
from Movie M join Rating R using(mID)
group by mID
having AVGstars >= all (select avg(stars)
					   from Rating
					   group by mID);	


/* for sqlite */

select title, avg(stars) as AVGstars
from Movie M join Rating R using(mID)
group by mID
having AVGstars = (select max(AVGstars) 
				  from (select avg(stars) as AVGstars
					   from Rating
					   group by mID) as R);

/* for sqlite #2 */
select title, AVGstars
from movie M,
	(select mID, avg(stars) as AVGstars
	from Rating
	group by mID) as R
where M.mID = R.mID
and AVGstars in (select max(AVGstars) 
				from (select mID, avg(stars) as AVGstars
					  from Rating
					  group by mID) as R);


/*Q11
Find the movie(s) with the lowest average rating. Return the movie title(s) and average rating. 
(Hint: This query may be more difficult to write in SQLite than other systems; you might think of
it as finding the lowest average rating and then choosing the movie(s) with that average rating.) */

/*mysql*/
select title, avg(stars) as AVGstars
from Movie M join Rating R using(mID)
group by mID
having AVGstars <= all (select avg(stars) 
						from Rating
						group by mID);

/*sqlite*/
select title, avg(stars) as AVGstars
from Movie M join Rating R using(mID)
group by mID
having AVGstars = (select min(AVGstars)
				   from (select avg(stars) as AVGstars
						from Rating
						group by mID) as S);


/* Q12
For each director, return the director's name together with the title(s) of the movie(s) they 
directed that received the highest rating among all of their movies, and the value of that rating. 
Ignore movies whose director is NULL. */

	/*First do query to picture grouping*/
	select director, title, stars
	from Movie M join Rating R using(mID)
	where director is not null			  
	order by director;

/* Now back to query we want */


select distinct director, title, stars
from (select * from Movie M join Rating R using(mID)) MR
where director is not null
and not exists (select *
			 from (select * from Movie M join Rating R using(mID)) MR2 
			 where MR.director = MR2.director
			 and MR.stars < MR2.stars)
order by director;