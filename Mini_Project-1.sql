use ipl;
show tables; -- 12 tables

desc IPL_BIDDER_DETAILS; -- pri (bidder_id), mul (user_id)
desc IPL_BIDDER_POINTS;
desc IPL_BIDDING_DETAILS; -- pri (bidder_id,schedule_id,bid_date,bid_status)
desc IPL_MATCH; -- pri (match_id)
desc IPL_MATCH_SCHEDULE; -- pri (schedule_id)
desc IPL_PLAYER; -- pri (primary_id)
desc IPL_STADIUM; -- pri (stadium_id)
desc IPL_TEAM; -- pri (team_id)
desc IPL_TEAM_PLAYERS; -- pri (team_id,player_id)
desc IPL_TEAM_STANDINGS; -- pri (team_id,tournmt_id)
desc IPL_TOURNAMENT; -- pri (tournmt_id)
desc IPL_USER; -- pri (user_id)

select * from IPL_BIDDER_DETAILS;
select * from IPL_BIDDER_POINTS;
select * from IPL_BIDDING_DETAILS;
select * from IPL_MATCH; 
select * from IPL_MATCH_SCHEDULE; 
select * from IPL_PLAYER; 
select * from IPL_STADIUM; 
select * from IPL_TEAM; 
select * from IPL_TEAM_PLAYERS; 
select * from IPL_TEAM_STANDINGS; 
select * from IPL_TOURNAMENT; 
select * from IPL_USER; 

####################################################################################
-- Questions – Write SQL queries to get data for following requirements:
####################################################################################

-- ---------------------------------------------------------------------------------------------------------------
-- 1.	Show the percentage of wins of each bidder in the order of highest to lowest percentage.
-- ---------------------------------------------------------------------------------------------------------------

select bp.bidder_id as bidder_id, b.bidder_name as bidder_name,bp.NO_OF_BIDS as 'No_of_bids', count(bd.bid_status) as 'no_of_wins',
(count(bd.bid_status)/(bp.NO_OF_BIDS))*100 as '%_of_wins'
from IPL_BIDDING_DETAILS bd
right join IPL_BIDDER_POINTS bp
on bp.bidder_id = bd.bidder_id and bid_status = 'Won'
join IPL_BIDDER_DETAILS b
on bp.bidder_id = b.bidder_id
group by bp.bidder_id,bp.NO_OF_BIDS,b.bidder_name
order by (count(bd.bid_status)/(bp.NO_OF_BIDS))*100 desc;

###################### ########### ########### ########### ########### ########### ########### ########### ########### ########### 
-- If we consider, incomplete match and on-going match (where actual win not declared), then below query satisfies the conditions
########### ########### ########### ########### ########### ########### ########### ########### ########### ########### ########### 

select  t1.BIDDER_ID, t2.BIDDER_NAME, ifnull(round((join_won.win_cnt/count(t1.BIDDER_ID))*100,2),0) as win_percent
from ipl_bidding_details as t1
left join
	(select BIDDER_ID,count(BIDDER_ID) as win_cnt
	from ipl_bidding_details
	where BID_STATUS = 'won'
	group by BIDDER_ID) as join_won
on 
	t1.BIDDER_ID = join_won.BIDDER_ID
inner join
	ipl_bidder_details as t2 
on 
	t1.BIDDER_ID = t2.BIDDER_ID
where t1.BID_STATUS in ('won','Lost')
group by 
	BIDDER_ID
order by 
	win_percent desc, 
    t2.BIDDER_NAME;
    
 
-- ---------------------------------------------------------------------------------------------------------------
-- 2.	Display the number of matches conducted at each stadium with stadium name, city from the database.
-- ---------------------------------------------------------------------------------------------------------------

select * from IPL_STADIUM; -- stadium id, stadium name, city
select * from IPL_MATCH_SCHEDULE; -- stadium id

select stadium_id, stadium_name, city, count(match_id) as no_of_matches_conducted
from IPL_STADIUM
join IPL_MATCH_SCHEDULE
using(stadium_id)
group by stadium_id, stadium_name, city
order by stadium_id, stadium_name, city;

-- ---------------------------------------------------------------------------------------------------------------
-- 3.	In a given stadium, what is the percentage of wins by a team which has won the toss?
-- ---------------------------------------------------------------------------------------------------------------

select stadium_id,stadium_name,count(m1.match_id) as no_of_matches,count(m2.match_id) as no_of_wins,
(count(m2.match_id)/count(m1.match_id))* 100 as percentage_wins
from ipl_match m1 join ipl_match_schedule ms 
on m1.match_id=ms.match_id 
left join ipl_match m2 
on m1.match_id = m2.match_id and m2.toss_winner=m2.match_winner
join IPL_STADIUM s
using (stadium_id)
group by stadium_id 
order by stadium_id;

-- ---------------------------------------------------------------------------------------------------------------
-- 4.	Show the total bids along with bid team and team name.
-- ---------------------------------------------------------------------------------------------------------------

select * from IPL_BIDDING_DETAILS;
select * from IPL_team;
select * from IPL_BIDDER_POINTS;

select bid_team, team_name, count(no_of_bids) as total_no_of_bids
from IPL_BIDDING_DETAILS bd 
join IPL_team t
on bd.bid_team = t.team_id
join IPL_BIDDER_POINTS
using(bidder_id)
group by bid_team, team_name
order by bid_team, team_name;
    
  
-- ---------------------------------------------------------------------------------------------------------------
-- 5.	Show the team id who won the match as per the win details.
-- ---------------------------------------------------------------------------------------------------------------
select * from IPL_MATCH;
select * from ipl_team;


SELECT match_id, team_id,TEAM_NAME, SUBSTRING_INDEX(SUBSTRING_INDEX(win_details, ' ',  2), ' ', -1) as winning_team, win_details
FROM IPL_MATCH m
join ipl_team t
on SUBSTRING_INDEX(SUBSTRING_INDEX(win_details, ' ',  2), ' ', -1) = t.remarks;

-- select TEAM_ID,TEAM_NAME,MATCH_ID,WIN_DETAILS
-- from ipl_team as t1
-- inner join 
-- 	(select MATCH_ID,WIN_DETAILS,trim(substring(WIN_DETAILS,6,LOCATE('won', WIN_DETAILS)-6)) as remarks 
--     from ipl_match) as t2
-- 	on t2.remarks = t1.REMARKS;

-- select match_id,m.team_id1,m.TEAM_ID2,WIN_DETAILS
-- from ipl_match m
-- left join ipl_team t
-- on substr(win_details,6,3) = t.REMARKS;

-- ---------------------------------------------------------------------------------------------------------------
-- 6.	Display total matches played, total matches won and total matches lost by team along with its team name.
-- ---------------------------------------------------------------------------------------------------------------
select * from IPL_TEAM;
select * from IPL_TEAM_STANDINGS;

select team_id, team_name, sum(matches_played) as total_matches_played, 
sum(matches_won) as total_matches_won, sum(matches_lost) as total_matches_lost
from IPL_TEAM_STANDINGS
join IPL_TEAM
using (team_id)
group by team_id,team_name;


-- ---------------------------------------------------------------------------------------------------------------
-- 7.	Display the bowlers for Mumbai Indians team.
-- ---------------------------------------------------------------------------------------------------------------
select * from IPL_TEAM_PLAYERS;
select * from IPL_TEAM;
select * from IPL_PLAYER;

select player_id,PLAYER_NAME,team_id,team_name,PLAYER_ROLE
from IPL_TEAM_PLAYERS
join IPL_TEAM
using (team_id)
join IPL_PLAYER
using (player_id)
where player_role = 'Bowler' and team_name = 'Mumbai Indians';

-- ---------------------------------------------------------------------------------------------------------------
-- 8.	How many all-rounders are there in each team, 
--       Display the teams with more than 4 
--      all-rounder in descending order.
-- ---------------------------------------------------------------------------------------------------------------

##### Query to display no.of All-Rounders in each team ######

-- select team_id, team_name, count(player_id) as 'no_of_all-rounders'
-- from IPL_TEAM_PLAYERS
-- join IPL_TEAM
-- using (team_id)
-- where PLAYER_ROLE = 'All-Rounder'
-- group by team_id,team_name; 

##### Query to Display the teams with more than 4 all-rounder in descending order. ######

select team_id,team_name, count(player_id) 
from IPL_TEAM_PLAYERS
join IPL_TEAM
using (team_id)
where PLAYER_ROLE = 'All-Rounder'
group by team_id,team_name
having count(player_id) > 4
order by count(player_id) desc;

