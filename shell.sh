#! /bin/bash
# 判断用户名文件的行数是否大于25，
# 如果大于25，提示 row above 25.  一行实现
# awk 命令详解
# https://www.cnblogs.com/xudong-bupt/p/3721210.html

if [ `wc -l /etc/passwd|awk '{print $1}'` -gt 25 ]; then echo "row above 25"; fi

# 截取系统一分钟的平均负载，只取整数部分 $NF指向最后一个字段
uptime | awk '{print $(NF-2)}' | cut -d. -f1;

#截取 ip 地址
ifconfig | head -n 2 | grep "inet addr"|awk -F: '{print $2}'|awk '{print $1}'

#统计连接状态 established 和 listen 的数量
netstat | awk '{/^tcp/} BEGIN{ii=0} 
{if( ($6 == "ESTABLISHED") || ($6 == "LISTEN")) ii++}; END{print ii}'

#判断用户名文件是否是20行，如果是，输出ok

if [ `wc -l /etc/hostname | awk '{print $1}' ` -eq 20 ];then echo ok; fi

#统计 logfile 中每个IP的访问量有多少s 


#继续上一题，找出访问量超过15的IP

#统计所有进程占用的内存大小，并计算总和

ps -axu | awk '{sum = sum + $4}  END{print sum}'

#删除文件前五行包含字母的行
head -n5 < ./a | sed '/[a-Z]/d'

#bash for循环打印下面这句话中字母数不大于6的单词。
#Bash also interprets a number of multi-character options.


for i in Bash also interprets a number of multi-character options
do 
	n=`echo $i | wc -m`
 	if [ ! $n -gt 6 ]
 		then 
 			echo $i
 	fi 
done


# 11、用户输入数字，如果输入的是非数字，提示 “Include nunumbers, retry please!”
# 并结束,如果是纯数字，返回数字结果。

read -p "please input number: " a

m=`echo $a | sed 's/[0-9]//g'`

if [ ! $m ]
	then echo $a
else
	echo "Include nunumbers, retry please!"
fi


# # 12、按照这样的日期格式（xxxx-xx-xx）每日生成一个文件，
# 例如今天生成的文件为2013-09-23.log， 并且把磁盘的使用情况写到到这个文件中。
df -h > `date +20%y-%m-%d.log`


# 13、设计一个脚本，监控远程的一台机器(假设ip为123.23.11.21)的存活状态，
# 当发现宕机时发一封邮件给你自己。

ip=127.0.0.1
mymail=weikean@163.com

while:
do
	stat = `ping -c 10 $ip | grep "received" | awk -F',' '{print $2}' | awk '{print $1}' `

	if [ -n $stat ]
		then echo "Host $ip is die" | mail -s "mail title" $mymail
	fi

	sleep 60
done

# 14、写一个脚本，查看80端口是否开放，如果开放，什么也不做，如果不开放，
# 重启 httpd 服务，并发送邮件给自己。 建立一个计划任务，每1分钟执行一次。

mymail=weikean@163.com
stat=`netstat -lnp | awk '{print $4}' | grep ':80'`

if [! $stat ]
then `/etc/init.d/httpd start` 
	mail -s "80 port is down" $mymail
fi

sleep 60

# 15、输入一个数字，然后运行对应的一个命令。显示命令如下：
# *cmd meau** 1---date 2--ls 3--who 4--pwd 当输入1时，会运行date, 输入2时运行ls, 依此类推。

read -p "please select num 1---date 2--ls 3--who 4--pwd " n

case $n in
	1)
	date
	;;

	2)
	ls
	;;

	3)
	who
	;;

	4)
	pwd
	;;

	*)
	echo "num is fault"
	;;
esac
#  16、添加user_00 - user_09 10个用户，并且给他们设置一个随机密码，
#  密码要求10位包含大小写字母以及数字，注意需要把每个用户的密码记录到一个日志文件里。
# >: 会重写文件，如果文件里面有内容会覆盖
# >>这个是将输出内容追加到目标文件中。如果文件不存在，就创建文件
for i in `seq -w 00 09`
do
useradd user_$i 
passwd=`mkpasswd -s 0`
echo $passwd | mkpasswd --stdin user_$i
echo "user_&i &passwd" >> /home/ubuntu/password.txt
done



#  17、请详细查看如下几个数字的规律，并使用shell脚本输出后面的十个数字。
#  10 31 53 77 105 141 .......
#  10 31 53 77 105 141
#  21 22 24 28 36
#  1  2  4  8

a=10
echo $a
for n in `seq 0 9`
do
    b=$[20+(2**$n)]
    a=$[$a+$b]
    echo $a
done


#  18、查看Linux系统中是否有自定义用户(普通用户)，若是有，一共几个 $3 >= 500

awk -F ':' '$3 >= 500' /etc/passwd | wc -l

# 19、写一个shell脚本，检测所有磁盘分区使用率和inode使用率
# 并记录到以当天日期为命名的日志文件里，
# 当发现某个分区容量或者inode使用量大于85%时，发邮件通知你自己。
# 思路：就是先df -h 然后过滤出已使用的那一列，然后再想办法过滤出百分比的整数部分，然后和85去比较，同理，inode也是一样的思路。发邮件通知你自己，需要你的系统有smtp服务，可以安装 sendmail或者postfix，安装好后不用修改配置，启动服务就可以运行，发邮件使用命令：mail -s "主题" mailer < file.txt （这个文件就是邮件内容）。mail这个命令是安装mailx包得到的。

mymail=weikean@163.com
df -h >> /home/ubuntu/`date +20%y%m%d.log`
for n in `df -h | awk '{print $5}' |sed '/[a-Z]/d' | awk -F '%' '{print $1}' |cut -f 1 -d '.'`
do
if [ $n -gt 85 ]
	then mail -s "disk use > 85" $mymail
fi
done 

# 20、写一个shell脚本来看看你最喜欢敲的命令是哪个？
# 然后列出你最喜欢敲的命令top10。

cat ~/.bash_history | sort |uniq -c | sort -rn | head -n 10


# 21、计算a.txt中每行中出现的数字个数并计算一下整个文档中一共出现了几个数字。
# 例如内容如下：
# 12aa*lkjskdj
# alskdflkskdjflkjj
#[^ ] 匹配不在指定范围内的字符
sum=0
for line in `cat $1`
do
	r=echo -n $line | sed 's/[^0-9]//g'| wc -m
	echo $r
	sum=$[$sum+$r]
done
	echo $sum


# 22、写一个shell脚本，先判断一下你linux的版本和bash版本，然后看看是否需要升级，
# 若是升级，则使用yum直接升级，否则输出一条日志，告之不需要升级。
# 参考信息：我们要保证对应版本的CentOS里的bash版本不低于以下版本。
# 假设我们只判断centos5和centos6两种系统。
# - Red Hat Enterprise Linux 7 - bash-4.2.45-5.el7_0.2
# - Red Hat Enterprise Linux 6 - bash-4.1.2-15.el6_5.1
# - Red Hat Enterprise Linux 5 - bash-3.2-33.el5.1



# 23、写一个脚本,检测你的网络流量，并记录到一个日志里。需要按照如下格式，
# 并且一分钟统计一次：
# 2014-09-29 10:11
# eth0 input: 1000bps
# eth0 output : 200000bps
# ################
# 2014-09-29 10:12
# eth0 input: 1000bps
# eth0 output : 200000bps

log=/home/ubuntu/mynet.log

while :
do
echo `date +'%F %T'` >> $log
sar -n DEV 1 3 > ./tmp.log

a=`grep "Average" ./tmp.log | grep "eth0" | awk '{print $5*8000}'`
b=`grep "Average" ./tmp.log | grep "eth0" | awk '{print $6*8000}'`
echo "eth0 input: $a bps" >> $log 
echo "eth0 output: $b bps" >> $log
sleep 60 
done

# 24、统计当前通过 80 端口建立连接的进程数量

netstat -an | grep ":80" |grep "ESTABLISHED"| wc -l

# 25、统计当前有多少ip 访问量，包括tcp和udp 协议

netstat -anp | egrep 'tcp|udp' | awk '{print $5}'| wc -l

# 26、系统负载很高，通过top以及 ps 查看，
# 因为cron计划任务在运行一个 cleanmem.sh 的脚本，
# 导致很多 sh 命令在运行，写个脚本，杀死所有的 sh 命令。

for pid in `ps -aux |grep 'clearman.sh'| awk '{print $2}'`
do 
	kill -9 $pid
	echo "$pid has been killed"
done


# 27、写脚本，判断Linux服务器是否开启了 web 服务，
# 如果开启了，判断跑的是什么服务，httpd? 还是 nginx？或者其他的服务。

service=`netstat -lnp | grep ":80" | awk	-F '/' '{print $2}'`
if [ ! service ]
then
	echo $service is running
else
	echo "No WEB service"
fi
# 28、加入服务器上跑的是 httpd，写个脚本，每分钟检测一次 httpd 服务是否存在，
# 如果不存在，就启动它。

while :
do
stat=`ps -aux | grep "httpd" | grep "grep httpd"`
if [ -n stat ]
then 
	/usr/local/apache2/bin/apachectl start
else
	echo "httpd is running"
sleep 60	
done 
fi

# 29、创建一个带删除和添加选项的用户的脚本
# - 只支持三个选项 ‘--del’ ‘--add’ --help输入其他选项报错。
# - 使用‘--add’需要验证用户名是否存在，存在则反馈存在。且不添加。 
#   不存在则创建该用户，切添加与该用户名相同的密码。并且反馈。
# - 使用‘--del’ 需要验证用户名是否存在，存在则删除用户及其家目录。
#   不存在则反馈该用户不存在。
# - --help 选项反馈出使用方法
# - 支持以，分隔   一次删除多个或者添加多个用户。
# - 能用echo $?  检测脚本执行情况  成功删除或者添加为0,报错信息为其他数字。
# - 能以，分割。一次性添加或者 删除多个用户。  
#   例如 adddel.sh --add user1,user2,user3.......
# - 不允许存在明显bug。

# 太麻烦了


# 30、计算 100 以内能被 3 整除的数的总和。

sum=0
for i in `seq 1 100`
do
if [ `expr $i % 3` -eq 0 ]
	then
		sum=$(($i+$sum))
fi
done
echo "sum is $sum"

# 31、写一个交互脚本，直接运行脚本，出现提示，选择一个数字：
# 1：重启 httpd 服务，2：重启 mysqld 服务 3：重启vsftpd服务，
# 加选项--httpd重启 httpd 服务，加 --myslq 会重启 myslqd 服务，
# 加 --ftp 会重启vsftpd服务。




# 32、猜数字的小游戏；
# 运行程序后，提示用户输入一个0-9的数字，如果是非数字，那么就提示用户输入数字；
# 如果用户猜中，提示用户猜对了；如果用户没有猜中，那么就提示用户重新输入一个数字；
# 如果，用户连续五次都没有猜中，则提示用户，24小时后再来玩这个游戏；



# 33、提示用户输入网卡的名字，然后我们用脚本输出网卡的ip。
# 34、脚本可以带参数也可以不带，参数可以有多个，每个参数必须是一个目录，
#  脚本检查参数个数，若等于0，则列出当前目录本身；否则，显示每个参数包含的子目录。
# 35、

#     第一个参数为URL，即可下载的文件；第二个参数为目录，即下载后保存的位置；
#     如果用户给的目录不存在，则提示用户是否创建；如果创建就继续执行，否则，函数返回一个51的错误值给调用脚本；
#     如果给的目录存在，则下载文件；下载命令执行结束后测试文件下载成功与否；如果成功，则返回0给调用脚本，否则，返回52给调用脚本；

# 36、用 for 循环列出当前目录的一级子目录，不要用 find 命令
# 37、打印乘法口诀
# 38、写一个脚本，让用户输入一个数字，然后判断是否是数字，如果是数字，则打印数字，否则一直让用户输入，直到是数字为止。参考第16题。16题没有循环。
# 39、while 循环实现每隔 10s 执行一次 w 命令
# 40、while 循环求数字1 到 10 相加的和





