
/*Students at your hometown high school have decided to organize their social network using databases. So far, 
they have collected information about sixteen students in four grades, 9-12. Here's the schema: 

Highschooler ( ID, name, grade ) 
English: There is a high school student with unique ID and a given first name in a certain grade. 

Friend ( ID1, ID2 ) 
English: The student with ID1 is friends with the student with ID2. Friendship is mutual, so if (123, 456) is 
in the Friend table, so is (456, 123). 

Likes ( ID1, ID2 ) 
English: The student with ID1 likes the student with ID2. Liking someone is not necessarily mutual, so if (123, 456)
is in the Likes table, there is no guarantee that (456, 123) is also present. */


use DB5social;

/*Q1  (1 point possible)
Find the names of all students who are friends with someone named Gabriel*/

select name
from Highschooler
where ID in 
	(select ID1 from Friend where ID2 in
		(select ID from Highschooler where name = "Gabriel"));


/* Q2
For every student who likes someone 2 or more grades younger than themselves, return that student's 
name and grade, and the name and grade of the student they like. */

select sName, sGrade, yName, yGrade
from (select H1.name as sName, H1.grade as sGrade, H2.name as yName, H2.grade as yGrade, H1.grade - H2.grade as GradeDiff
	  from Highschooler H1, Highschooler H2, Likes
	  where H1.ID = ID1
	  and H2.ID = ID2) L
where GradeDiff >= 2;
/* run the subquery first to picture the students and the grade differences */


/* Q3
For every pair of students who both like each other, return the name and grade of both students. 
Include each pair only once, with the two names in alphabetical order. */

	/* The first line in the where clause, indicate that a student 1 appears in both 
	cases of liking someone and being liked by somenone
	The second line indicates that a student 2 appears in both  cases of liking someone 
	and being liked by somenone */
	select L1.ID1, L1.ID2, L2.ID1, L2.ID2
	from Likes L1, Likes L2
	where L1.ID1 = L2.ID2
	and L2.ID1 = L1.ID2;
	

select H1.name, H1.grade, H2.name, H2.grade
from Highschooler H1, Likes L1, Highschooler H2, Likes L2
where L1.ID1 = L2.ID2
and L2.ID1 = L1.ID2  
and L1.ID1 = H1.ID
and L1.ID2 = H2.ID /*watch the query above to understand why I used these L1 conditions.
					I could have used L2.ID2 = H2.ID and L2.ID1 = H1.ID insted even both L1 and L2 conditions*/
and H1.name < H2.name;


/* Q4 
Find all students who do not appear in the Likes table (as a student who likes or is liked)
and return their names and grades. Sort by grade, then by name within each grade. */

select H.name, H.grade
From Highschooler H
where H.ID not in (
	select L.ID1
	from Likes L)
and H.ID not in (
	select L.ID2
	from Likes L)
order by H.grade, H.name;


/* Q5
For every situation where student A likes student B, but we have no information about whom B likes 
(that is, B does not appear as an ID1 in the Likes table), return A and B's names and grades. */

	select L.ID1, L.ID2
	from Likes L
	where L.ID2 not in (
		select L.ID1 from Likes L);


select H1.name, H1.grade, H2.name, H2.grade
from Highschooler H1, Highschooler H2, Likes L
where H1.ID in (
	select L.ID1
	from Likes L
	where L.ID2 not in (
		select L.ID1 from Likes L)
	)	
and H1.ID = L.ID1 
and H2.ID = L.ID2;


/* Q6
Find names and grades of students who ONLY have friends in the same grade. Return the result 
sorted by grade, then by name within each grade. */

select name, grade
from Highschooler
where ID not in (
	select ID1 from 
	Friend F, Highschooler H1, Highschooler H2
	where F.ID1 = H1.ID
	and F.ID2 = H2.ID
	and H1.grade <> H2.grade
	)
order by grade, name;


/* Q7
For each student A who likes a student B where the two are not friends, find if they have a friend C 
in common (who can introduce them!). For all such trios, return the name and grade of A, B, and C. */

select H1.name, H1.grade, H2.name, H2.grade, H3.name, H3.grade
from Highschooler H1, Highschooler H2, Highschooler H3, Likes L, Friend F1, Friend F2
where H1.ID = L.ID1
and H2.ID = L.ID2
and H1.ID not in (select F.ID1 from Friend F
				  where  F.ID2 = H2.ID)
and F1.ID1 = H1.ID 	/*Join*/
and F2.ID1 = H2.ID	/*Join*/
and H3.ID = F1.ID2	/*H3 friend with H1*/
and H3.ID = F2.ID2; /*H3 friends with H2*/


/* Q8 
Find the difference between the number of students in the school and the number of
different first names. */

select NuStudents - NuNames as diff
from (select count(*) as NuStudents from Highschooler) S,
	 (select count(distinct name) as NuNames from Highschooler) N;


/* Q9
Find the name and grade of all students who are liked by more than one other student. */

select name, grade
from Highschooler
where ID in (select ID2 from Likes
			 group by ID2
			 having count(*)>1);



/*** EXTRAS ***/

/*Q1
For every situation where student A likes student B, but student B likes a DIFFERENT student C, 
return the names and grades of A, B, and C. */

select H1.name, H1.grade, H2.name, H2.grade, H3.name, H3.grade
from Highschooler H1, Highschooler H2, Highschooler H3, Likes L1, Likes L2
where H1.ID = L1.ID1
and H2.ID = L1.ID2
and H1.ID <> L2.ID2
and H3.ID = L2.ID2
and H2.ID = L2.ID1; 


/* Q2
Find those students for whom all of their friends are in different grades from themselves. 
Return the students' names and grades. */


select distinct(name), grade
from Highschooler H, Friend F
where F.ID1 = H.ID
and F.ID1 not in (
		select F.ID1
		from Friend F, Highschooler H1, Highschooler H2
		where F.ID1 = H1.ID and F.ID2 = H2.ID
		and H1.grade = H2.grade);


/* Q3 
What is the average number of friends per student? (Your result should be just one number.) */

select avg(NuPerStudent)
from (select count(*) as NuPerStudent 
	  from Friend
	  group by ID1) T;


/* Q4
Find the number of students who are either friends with Cassandra or are friends of friends of Cassandra. 
Do not count Cassandra, even though technically she is a friend of a friend. */

			  select H1.name, H2.name
			  from Highschooler H1, Highschooler H2, Friend F
			  where H1.ID = F.ID1
			  and H2.ID = F.ID2
			  and H2.name = 'Cassandra'
			  and H1.name <> 'Casandra';

select count(*)
from Friend
where ID1 in (select H1.ID 
			  from Highschooler H1, Highschooler H2, Friend F
			  where H1.ID = F.ID1
			  and H2.ID = F.ID2
			  and H2.name = 'Cassandra'
			  and H1.name <> 'Casandra');


/* Q5 
Find the name and grade of the student(s) with the greatest number of friends. */

select name, grade
from Highschooler H, Friend F
where H.ID = F.ID1
group by F.ID1
having count(*) = (select max(NuFriendsEach) 
					from (select count(*) as NuFriendsEach, ID1 from Friend group by ID1) N);



/*** MODIFICATION EXERCISES ***/

/*Q1
It's time for the seniors to graduate. Remove all 12th graders from Highschooler. */

delete 
from Highschooler
where grade = 12;


/* Q2
If two students A and B are friends, and A likes B but not vice-versa, remove the Likes tuple. */

delete 
from Likes
where ID2 in (
	select ID2 from Friend F
	where  Likes.ID1 = F.ID1) 
and ID2 not in (
	select L.ID1 from Likes L
	where Likes.ID1 = L.ID2);
	

	select ID1, ID2
	from Likes
	where ID2 in (
		select ID2 from Friend F	/*Likes.ID1 appears in Friend and we take the ID from the other Friend (ID2)*/
		where  Likes.ID1 = F.ID1)   /*with this we know that Likes.ID1 and Likes.ID2 are friends.*/
	and ID2 not in (
		select L.ID1 from Likes	L	/* o Likes.ID1 pou epileksame */
		where Likes.ID1 = L.ID2);								   





