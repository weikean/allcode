-- 建表
-- Student(S#,Sname,Sage,Ssex) 　　 学生表 
-- Course(C#,Cname,T#) 　　　　　　  课程表 
-- SC(S#,C#,score) 　　　　　　　　　 成绩表 
-- Teacher(T#,Tname) 　　　　　　　   教师表

--学生表

-- mysql
create table Student
	(
    	S int,
    	Sname nvarchar(20),
    	Sage int,
    	Ssex  nvarchar(8)
	);


create table Course 
	(
		C int,
		Cname nvarchar(32),
		T int
	);

create table SC
	(
		S int,
		C int,
		score int
	);

create table Teacher
	(
		T int,
		Tname nvarchar(32)
	);

-- Oracle


create table Student
	(
    	S int,
    	Sname varchar(20),
    	Sage int,
    	Ssex  varchar(8)
	);


create table Course 
	(
		C int,
		Cname varchar(32),
		T int
	);

create table SC
	(
		S int,
		C int,
		score int
	);

create table Teacher
	(
		T int,
		Tname varchar(32)
	);


-- 测试数据

insert into Student 
	select 1,'刘一',18,'男' union all
	select 2,'钱二',19,'男' union all
	select 3,'张三',17,N'男' union all
 	select 4,'李四',18,N'女' union all
 	select 5,'王五',17,N'男' union all
 	select 6,'赵六',19,N'女' 

 insert into Teacher 
 	select 1,'叶平' union all
 	select 2,'贺高' union all
 	select 3,'杨艳' union all
 	select 4,'周磊'

 insert into Course 
 	select 1,N'语文',1 union all
 	select 2,N'数学',2 union all
 	select 3,N'英语',3 union all
 	select 4,N'物理',4
 
 insert into SC 
 select 1,1,56 union all 
 select 1,2,78 union all 
 select 1,3,67 union all 
 select 1,4,58 union all 
 select 2,1,79 union all 
 select 2,2,81 union all 
 select 2,3,92 union all 
 select 2,4,68 union all 
 select 3,1,91 union all 
 select 3,2,47 union all 
 select 3,3,88 union all 
 select 3,4,56 union all 
 select 4,2,88 union all 
 select 4,3,90 union all 
 select 4,4,93 union all 
 select 5,1,46 union all 
 select 5,3,78 union all 
 select 5,4,53 union all 
 select 6,1,35 union all 
 select 6,2,68 union all 
 select 6,4,71


-- oracle 

insert into Student values ( 1,'刘一',18,'男' ); 
insert into Student values ( 2,'钱二',19,'男' );
insert into Student values ( 3,'张三',17,N'男' );
insert into Student values ( 4,'李四',18,N'女' );
insert into Student values ( 5,'王五',17,N'男' );
insert into Student values ( 6,'赵六',19,N'女' );

insert into Teacher values (1,'叶平');
insert into Teacher values (2,'贺高');
insert into Teacher values (3,'杨艳');
insert into Teacher values (4,'周磊');

insert into Course values (1,N'语文',1);
insert into Course values (2,N'数学',2);
insert into Course values (3,N'英语',3);
insert into Course values (4,N'物理',4);


insert into SC values (1,1,56);
insert into SC values (1,2,78);
insert into SC values (1,3,67);
insert into SC values (1,4,58);
insert into SC values (2,1,79);
insert into SC values (2,2,81);
insert into SC values (2,3,92);
insert into SC values (2,4,68);
insert into SC values (3,1,91);
insert into SC values (3,2,47);
insert into SC values (3,3,88);
insert into SC values (3,4,56);
insert into SC values (4,2,88);
insert into SC values (4,3,90);
insert into SC values (4,4,93);
insert into SC values (5,1,46);
insert into SC values (5,3,78);
insert into SC values (5,4,53);
insert into SC values (6,1,35);
insert into SC values (6,2,68);
insert into SC values (6,4,71);



--查询“001”课程比“002”课程成绩高的所有学生的学号；




select s1.S  from  
	(select S,score from SC where C = 001) s1, 
	(select S,score from SC where C = 002) s2 
	where s1.s = s2.s and s1.score > s2.score;


-- 查询平均成绩大于60分的同学的学号和平均成绩；





select S,avg(score) from SC group by S having avg(score) > 60;     

-- 查询所有同学的学号、姓名、选课数、总成绩；




select s.S,s.Sname,COUNT(c),SUM(score) 
from Student s left join SC sc on s.S = sc.S 
group BY s.S, s.Sname;


-- 查询姓“李”的老师的个数；




select COUNT(distinct Tname) from Teacher where Tname like '李*';

-- 查询没学过“叶平”老师课的同学的学号、姓名；






select s.S, s.Sname from Student s where s.S not in 
(select distinct (sc.s) from SC sc where sc.c =  
(select c from Teacher t,Course c 
where t.T = c.t and t.Tname = '叶平')); 

--解法二
select s.S,s.Sname
from Student s
where s.S not in
(
    select distinct(sc.S) from SC sc,Course c,Teacher t
    where sc.C=c.C and c.T=t.T and t.Tname='叶平'
)


-- 查询学过“001”并且也学过编号“002”课程的同学的学号、姓名；





select s.S, s.Sname from Student s where s.S in 
(
	select distinct(sc1.S) from SC sc1, SC sc2 
	where sc1.C = 001 and sc2.C = 002 and sc1.S = sc2.S
);

-- 解法二 exists

select s.S, s.Sname from Student s, SC sc 
where sc.s = s.s and sc.c = 001 and exists 
(
	select sc2.s from SC sc2 where sc.s = sc2.s and sc2.c = 002
) ;

-- 查询学过“叶平”老师所教的所有课的同学的学号、姓名 






select s.S, s.Sname from Student s where s.S in 
(
	select distinct(sc.s) from Course co, SC sc, Teacher t 
	where sc.c = co.c and t.T = co.T and t.Tname = '叶平' group by sc.S
);


-- 查询课程编号“002”的成绩比课程编号“001”课程低的所有同学的学号、姓名；




select s.S, s.Sname from Student s,
(select sc1.s,sc1.score from SC sc1 where sc1.c = 001) a,
(select sc1.s,sc1.score from SC sc1 where sc1.c = 002) b
where a.S = b.s and a.S = s.S and b.score < a.score;



-- 查询有课程成绩小于60分的同学的学号、姓名



select s.S, s.Sname from Student s,
(select distinct (sc.s) from SC sc where score < 60) a
where a.S = s.S; 


-- 查询没有学全所有课的同学的学号、姓名；




select s.S, s.Sname from Student s where s.S in 
(
	select distinct(sc.s) from SC sc group by sc.s 
	having COUNT(sc.c) < (select COUNT(cou.c)from Course cou)
);

-- 查询至少有一门课与学号为“001”的同学所学相同的同学的学号和姓名；






select s.S, s.Sname from Student s where s.S in 
(
   select distinct (sc.s) from SC sc where sc.c in 
   (select sc1.c from SC sc1 where sc1.S = 001)
);

-- 查询至少学过学号为“001”同学所有一门课的其他同学学号和姓名；(同上) 

-- 把“SC”表中“叶平”老师教的课的成绩都更改为此课程的平均成绩；

update SC set score = (select AVG(score) from SC sc,Course c,Teacher t
    where sc.C =c.C and c.T=t.T and t.Tname='叶平' )
	where c in (select co.c from Teacher t,Course co where t.T = co.T and t.Tname = '叶平');


update SC set Score=
(
    select AVG(score) from SC sc,Course c,Teacher t
    where sc.C=c.C and c.T=t.T and t.Tname='叶平' 
)
where C in 
(
    select distinct(sc.C) from SC sc,Course c,Teacher t
    where sc.C=c.C and c.T=t.T and t.Tname='叶平'
);

--不能运行 需要修改

-- 查询和“002”号的同学学习的课程完全相同的其他同学学号和姓名






select s.S, s.Sname from Student s where s.S in 
(
   select distinct (sc.s) from SC sc where sc.c in 
   (
   	select sc1.c from SC sc1 where sc1.S = 002) 
   and (select COUNT(sc2.c) from SC sc2 where sc2.S = sc.S) = 
   (select COUNT(sc3.c) from SC sc3 where sc3.S = 002)
) and s.S != 002;



-- 删除学习“叶平”老师课的SC表记录；




delete from  SC where c = 
	(select co.c from Course co, Teacher t 
		where t.T = co.T and t.Tname = '叶平');

-- （16）向SC表中插入一些记录，这些记录要求符合以下条件：
--  ①没有上过编号“002”课程的同学学号；②插入“002”号课程的平均成绩；




insert into SC select S,2,(select AVG(score) from SC sc where sc.c = 002)
	from Student s where s.S not in (select sc2.S from SC sc2 where sc2.c = 002);

-- 按平均成绩从低到高显示所有学生的“语文”、“数学”、“英语”三门的课程成绩，
-- 按如下形式显示： 学生ID,语文,数学,英语,有效课程数,有效平均分


select sc.S, 
(select sc1.score from SC sc1 where sc1.S = sc.S and sc1.c = 
	(select co.c from Course co where co.Cname = '语文')) '语文',
(select sc2.score  from SC sc2, Course co2 where sc2.S = sc.S and sc2.C = co2.C and co2.Cname = '数学') '数学',
(select sc3.score  from SC sc3, Course co3 where sc3.S = sc.S and sc3.C = co3.C and co3.Cname = '英语') '英语',
COUNT(sc.C) '有效课程数',
AVG(sc.score) '有效平均分' from SC sc group by sc.S  order by AVG(sc.score);


-- 查询各科成绩最高和最低的分：以如下形式显示：课程ID，最高分，最低分；






select sc.c '课程ID', MAX(sc.score) '最高分', MIN(sc.score) '最低分' from SC sc group by sc.c;

-- 按各科平均成绩从低到高和及格率的百分数从高到低顺序；



select sc.c, AVG(sc.score) '平均成绩', 
(select COUNT(sc1.S) from SC sc1 where sc1.score > 60 and sc1.c = sc.c)/
(
	select COUNT(sc2.s) from SC sc2 where sc2.c = sc.c
) * 100 as Percent
from SC sc group by sc.c order by Percent;


-- 查询不同老师所教不同课程平均分从高到低显示




select t.Tname, c.Cname, avg(sc.score) from SC sc, Teacher t, Course c 
 where sc.C = c.C and c.T = t.T  group by t.Tname, c.Cname order by avg(sc.score) desc;


 -- 统计列印各科成绩,各分数段人数:课程ID,课程名称,[100-85],[85-70],[70-60],[ <60] 
 



 -- SUM后不能有空格
 select c.C, c.Cname,
 SUM(CASE WHEN sc.score between 85 and 100 THEN 1 ELSE 0 END) '100-85',
 SUM(CASE WHEN sc.score between 70 and 85 THEN 1 ELSE 0 END) '85-70',
 SUM(CASE WHEN sc.score between 60 and 70 THEN 1 ELSE 0 END) '70-60',
 SUM(CASE WHEN sc.score < 60 THEN 1 ELSE 0 END) '<60'
 from Course c, SC sc where sc.C = c.C group by c.C, c.Cname;


 -- 查询学生平均成绩及其名次



 select s.S, MAX(s.Sname),avg(sc.score) '平均成绩',
 aaa.rownum '名次'
 from Student s, SC sc,
 (select @rownum:=@rownum+1 as rownum, fff from (SELECT @rownum:=0) r, 
 (select sc2.S as fff,avg(sc2.score) a from SC sc2 group by sc2.S ) d order by a desc) aaa
 where sc.S = s.S and fff = s.S group by s.S, aaa.rownum order by avg(sc.score) desc;



 -- 查询各科成绩前三名的记录:(不考虑成绩并列情况) 



 select sc.C, c.Cname, s.S, s.Sname, sc.score from Course c, Student s, SC sc 
 where c.c = sc.c and sc.s = s.s and sc.score in
 (
 	select sc2.c, sc2.score ccc from SC sc2 where sc2.c = sc.C
 	group by sc2.c, sc2.score order by sc2.score desc limit 3
 );
 -- 未实现


 -- 查询每门课程被选修的学生数



 select sc.C, MAX(c.Cname), COUNT(sc.s) from SC sc, Course c where sc.C = c.C group by sc.C;


 -- 查询出只选修了一门课程的全部学生的学号和姓名

 select s.S, s.Sname from Student s where s.S in 
 (
 	select distinct(sc.S) from SC sc group by sc.S having count(sc.S) = 1
 );

 --  查询男生、女生的人数；




 select 
 (
 	select count(s1.S) from Student s1 where Ssex like '男'
 ) '男生人数',

 (
 	select count(s2.S) from Student s2 where Ssex like '女'
 ) '女生人数' from dual;


 -- 查询姓“张”的学生名单；

 select S,Sname from Student  where Sname like '张%';


 -- 查询同名同姓学生名单，并统计同名人数；


 select  s.Sname,count(s.S) from Student s group by s.Sname
 having COUNT(s.Sname) >1 ;


-- 查询每门课程的平均成绩，结果按平均成绩升序排列，平均成绩相同时，按课程号降序排列；



select sc.C, MAX(c.Cname), avg(sc.score) from SC sc, Course c
where c.C = sc.C group by sc.C order by avg(sc.score) asc,c.C desc;

-- 查询平均成绩大于85的所有学生的学号、姓名和平均成绩；



select sc.S, s.Sname, avg(sc.score) from SC sc, Student s where 
sc.S = s.S group by sc.S, s.Sname having avg(sc.score) > 85;

-- 查询课程名称为“数学”，且分数低于60的学生姓名和分数；





select distinct(sc.S),s.Sname from Student s, SC sc, Course c 
where s.S = sc.S and sc.C = c.C and c.Cname = '数学' and sc.score < 60;


-- 查询所有学生的选课情况；




select sc.S, s.Sname, sc.C, c.Cname from Student s, SC sc, Course c 
where s.S = sc.S and sc.C = c.C; 


-- 查询任何一门课程成绩在70分以上的姓名、课程名称和分数；



select s.Sname, c.Cname, sc.score from Student s, SC sc, Course c 
where s.S = sc.S and sc.C = c.C and sc.score > 70; 


-- 查询不及格的课程，并按课程号从大到小排列；



select distinct(c.Cname) from SC sc, Course c where sc.C = c.C and sc.score < 60;

-- 查询课程编号为003且课程成绩在80分以上的学生的学号和姓名； 


select sc.S, s.Sname from SC sc, Student s where sc.S = s.S and sc.C = 003 and sc.score > 80;


-- 求选了课程的学生人数

select COUNT(distinct(S)) from SC;

-- 查询选修“杨艳”老师所授课程的学生中，成绩最高的学生姓名及其成绩




SELECT sc.S, s.Sname, sc.score from SC sc,Student s where s.S = sc.S and sc.c in 
(
	select sc1.c from SC sc1, Course c, Teacher t where sc.C = c.C and
	t.T = c.T and t.Tname = '杨艳' 
) order by sc.score desc limit 1;


-- 查询各个课程及相应的选修人数；


select sc.C, MAX(c.Cname), COUNT(distinct(sc.S)) as aaa from SC sc,Course c where sc.C = c.C group by sc.C;

-- 查询不同课程但成绩相同的学生的学号、课程号、学生成绩




select sc.S, sc.C, sc1.C, sc.score, sc1.score from SC sc,SC sc1
where sc.C != sc1.C and sc.score = sc1.score order by sc.S asc;


-- 查询每门课程成绩最好的前两名；
-- oracle

select sc.C,  c.Cname aa, sc.S bb, s.Sname cc , sc.score from SC sc, Student s, Course C where
sc.S = s.S and sc.C = c.C and sc.score in 
(
	select r.score from  
	(	
		select * from SC sc2 order by sc2.score desc
	) r where r.C = sc.C and rownum <= 2
) order by sc.C asc, sc.score desc;


--mysql
select sc.C,  max(c.Cname) aa, max(sc.S) bb,max(s.Sname) cc from SC sc, Student s, Course C where
sc.S = s.S and sc.C = c.C and sc.score in 
(
	select top 2 sc1.score from SC sc1 where sc1.C = sc.C order by sc1.score desc 
) order by sc.C;


-- 统计每门课程的学生选修人数。要求输出课程号和选修人数，
-- 查询结果按人数降序排列，若人数相同，按课程号升序排列

select sc.C,COUNT(sc.S) from SC sc group by sc.C order by COUNT(sc.S) desc, sc.C asc; 


-- 检索至少选修两门课程的学生学号；

select S from SC group by S having count(C) >= 2;

-- 查询全部学生都选修的课程的课程号和课程名；


select distinct sc.C, c.Cname from SC sc, Course c where sc.C = c.C and sc.C in
(
	select sc1.c from SC sc1 group by sc1.c having count(sc.S) = 
	(
		select COUNT(distinct(s.S)) from Student s 
	)
)


-- 查询没学过“叶平”老师讲授的任一门课程的学生姓名

select distinct s.Sname from Student s where s.S not in
(
	select sc.S from SC sc, Course c, Teacher t where
	sc.C = c.C and c.T = t.T and t.Tname = '叶平'
);

-- 查询两门以上不及格课程的同学的学号及其平均成绩

select distinct sc.S,avg(NVL(sc.score, 0)) from SC sc where sc.S in 

	select distinct sc1.S from SC sc1  where sc1.score < 60 group by sc1.S
	having count(sc1.C) > 2
)group by sc.S;


-- 检索“004”课程分数小于60，按分数降序排列的同学学号


select S from SC where score < 60 and C = 004 order by score desc;

-- SELECT语句中含有DISTINCT关键字或者有运算符时，
-- 排序用字段必须与SELECT语句中的字段相对应。


-- 删除“002”同学的“001”课程的成绩

delete from SC where S = 002 and C = 001;




