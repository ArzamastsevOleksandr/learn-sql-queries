select *
from member_name_and_team;

select m.lastname, m.firstname, m.handicap
from member m
order by(case when m.handicap is null then 1 else 0 end), m.handicap;

select count(m.handicap) as having_handicap, count(m) as total, count(distinct m.firstname) as distinct_first_names
from member m;
-- ====================================================================================================================
-- cartesian product
select *
from member m
         cross join type_fee tf;

-- custom join optimization (smaller intermediate tables)
select *
from (select * from tour_entry te where te.year = 2014) te_2014
         inner join tour t
                    on t.id = te_2014.tour_id
                        and te_2014.year = 2014
                        and t.name = 'Leeston';

-- will not include Beck Sarah, because her type is NULL
select *
from member m
         inner join type_fee tf
                    on m.member_type = tf.type;

-- will include 'Beck Sarah' with NULL value for the tf.fee column
select concat(m.lastname, ' ', m.firstname) as fullname, tf.fee
from member m
         left outer join type_fee tf
                         on m.member_type = tf.type;

-- right outer join is the same as left outer join, the tables are swapped
select *
from type_fee tf
         right outer join member m
                          on tf.type = m.member_type;

-- full outer join will retain rows with a NULL in the join field in either table
select *
from member m
         full outer join type_fee tf
                         on m.member_type = tf.type;
-- ====================================================================================================================
select te.member_id
from tour_entry te
where te.tour_id in (select t.id
                     from tour t
                     where t.type = 'open'
);

-- will return the same result as the query with a subquery above
select te.member_id
from tour_entry te
         inner join tour t
                    on t.type = 'open'
                        and te.tour_id = t.id;

-- get all members who have entered ANY tours
select concat(m.lastname, ' ', m.firstname)
from member m
where exists(select * from tour_entry te where te.member_id = m.id);

-- is the same as the query above
select distinct concat(m.lastname, ' ', m.firstname)
from member m
         inner join tour_entry te on m.id = te.member_id;

-- get all members who have NOT entered ANY tours
select concat(m.lastname, ' ', m.firstname)
from member m
where not exists(select * from tour_entry te where te.member_id = m.id);

select *
from member m
where not exists(select *
                 from tour_entry te,
                      tour t
                 where te.member_id = m.id
                   and te.tour_id = t.id
                   and t.type = 'open');

select *
from member m
where m.handicap < (select handicap from member where id = 119);

select *
from member m
where m.handicap < (select avg(handicap) from member);

select *
from member m
where m.member_type = 'junior'
  and m.handicap < (select avg(handicap) from member where member_type = 'senior');

-- insert a record for every JUNIOR member
insert into tour_entry
    (member_id, tour_id, year)
select m.id, 40, 2017
from member m
where m.member_type = 'junior';

delete
from tour_entry te
where te.tour_id = 25
  and te.year = 2019
  and te.member_id in (select m.id from member m where m.handicap > 100);
-- ====================================================================================================================
-- members who have a coach
select 'has coach', m.firstname
from member m
         inner join member c
                    on m.coach_id = c.id;

-- coach names
select distinct concat(c.firstname, ' ', c.lastname)
from member m
         join member c
              on m.coach_id = c.id;

-- who is being coached with a lower handicap?
select m.firstname
from member m
         join member c
              on m.coach_id = c.id
where m.handicap > c.handicap;

-- list the names of all members and the names of their coaches
select m.firstname as m_first, m.lastname as m_last, c.firstname as c_first, c.lastname as c_last
from member m
         left join member c
                   on m.coach_id = c.id;

-- show all members that have entered BOTH tours 24 AND 36
select m.id
from member m
where exists(select * from tour_entry where tour_id = 24 and member_id = m.id)
  and exists(select * from tour_entry where tour_id = 36 and member_id = m.id);

select te.member_id
from tour_entry te
where te.tour_id = 24
  and exists(select * from tour_entry te2 where te2.tour_id = 36 and te2.member_id = te.member_id);

select e1.member_id
from tour_entry e1
inner join tour_entry e2
on e1.member_id = e2.member_id
and e1.tour_id = 24 and e2.tour_id = 36;
