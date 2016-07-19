SELECT FilmTitle, RevenueDate, datename(dw,RevenueDate) DayofWeek, datepart(dw,RevenueDate) DayofNum, sum(TotalSeats) TotalSeats, cast(OpeningDate as date) OpeningDate, 
datediff(d,cast(OpeningDate as date),RevenueDate)+1 DaysRunning, sum(ScreenCapacity) ScreenCapacity, sum(tot) Revenue, 
bb.Film_strCensor Censor, bb.Film_strDescription Genre from 
(
SELECT  'T' trans,
	Sess.Cinema_strCode,	
	Sess.Screen_bytNum ScreenId,
	Tick.Session_lngSessionId SessionId,
	Sess.Film_strCode FilmId,
	Film.Film_strTitle FilmTitle,
	cast(Sess.Session_dtmRevenueDateTime as date)RevenueDate,
	Sum( Tick.TransT_intNoOfSeats) TotalSeats,
	Tick.TransT_strType,
	Tick.PGroup_strCode,
	Tick.Price_strCode,
	Pr.Price_strDescription,
	Film.Film_dtmOpeningDate OpeningDate,
	Sum(Tick.TransT_intNoOfSeats* (CASE Tick.TransT_curRedempValueEach WHEN 0 
	THEN Tick.TransT_curValueEach ELSE Tick.TransT_curRedempValueEach END)) tot,
	Tick.TransT_strStatus,
	SL.Screen_intSeats ScreenCapacity
FROM	tblTrans_Ticket Tick WITH (INDEX = indSessionId), tblSession Sess WITH (INDEX = indRealDateTime), 
tblFilm Film, tblPrice Pr,	/* Force Hint on index for SQL 7	*/
tblScreen_Layout SL
/* FROM	tblTrans_Ticket Tick WITH (INDEX = indSessionId), tblSession Sess WITH (INDEX = indRealDateTime), 
tblFilm Film, tblPrice Pr */ WHERE	
Session_dtmRevenueDateTime BETWEEN '2012-01-01 00:00:00' AND '2013-01-01 00:00:00' 	
/*Session_dtmRevenueDateTime BETWEEN '2012-01-26 00:00:00' AND '2013-01-27 00:00:00' 	
AND Session_dtmRevenueDateTime BETWEEN '2012-04-06 00:00:00' AND '2013-04-07 00:00:00' 	
AND Session_dtmRevenueDateTime BETWEEN '2012-04-13 00:00:00' AND '2013-04-14 00:00:00' 	
AND Session_dtmRevenueDateTime BETWEEN '2012-05-01 00:00:00' AND '2013-05-02 00:00:00' 	
AND Session_dtmRevenueDateTime BETWEEN '2012-08-15 00:00:00' AND '2013-08-16 00:00:00' 	
AND Session_dtmRevenueDateTime BETWEEN '2012-08-20 00:00:00' AND '2013-08-21 00:00:00' 	
AND Session_dtmRevenueDateTime BETWEEN '2012-09-19 00:00:00' AND '2013-09-20 00:00:00' 	
AND Session_dtmRevenueDateTime BETWEEN '2012-10-02 00:00:00' AND '2013-10-03 00:00:00' 	
AND Session_dtmRevenueDateTime BETWEEN '2012-10-23 00:00:00' AND '2013-10-24 00:00:00' 	
AND Session_dtmRevenueDateTime BETWEEN '2012-11-13 00:00:00' AND '2013-11-14 00:00:00' 	
AND Session_dtmRevenueDateTime BETWEEN '2012-12-25 00:00:00' AND '2013-12-26 00:00:00' 	*/
AND	Tick.Session_lngSessionId = Sess.Session_lngSessionId
AND 	Sess.Film_strCode = Film.Film_strCode
AND 	Tick.Price_strCode = Pr.Price_strCode 
AND 	Tick.PGroup_strCode = Pr.PGroup_strCode
AND   Sess.ScreenL_intId = SL.ScreenL_intId
GROUP BY  Sess.Cinema_strCode, 
	Sess.Screen_bytNum,
	Tick.Session_lngSessionId,
	Sess.Film_strCode,
	Film.Film_strTitle, 
	Sess.Session_dtmRevenueDateTime,
	Tick.TransT_strType,
	Tick.Price_strCode,
	Tick.PGroup_strCode, 
	Pr.Price_strDescription, 
	TransT_strStatus,
	Film.Film_dtmOpeningDate,
	SL.Screen_intSeats	
	) aa
	inner join tblFilm bb
	on aa.FilmTitle = bb.Film_strTitle
	group by FilmTitle,RevenueDate, OpeningDate, bb.Film_strCensor, bb.Film_strDescription
	order by FilmTitle,RevenueDate