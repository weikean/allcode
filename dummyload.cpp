#include <muduo/base/Atomic.h>
#include <muduo/base/Condition.h>
#include <muduo/base/CurrentThread.h>
#include <muduo/base/Mutex.h>
#include <muduo/base/Thread.h>
#include <muduo/base/Timestamp.h>
#include <muduo/net/EventLoop.h>

#include <boost/ptr_container/ptr_vector.hpp>

#include <math.h>
#include <stdio.h>

using namespace muduo;
using namespace muduo::net;

int g_cycles = 0; //线程运行的周期数
int g_percent = 82; //自定义的cpu峰值
AtomicInt32 g_done;
bool g_busy = false; //1-忙，0-闲置
MutexLock g_mutex;
Condition g_cond(g_mutex);

double busy(int cycles)
{
	double result;
	for (int i = 0; i < cycles; ++i)
	{
		result += sqrt(i) * sqrt(i+1);
	}

	return result;
}

double getSeconds(int cycles)
{
	Timestamp start	= Timestamp::now();
	busy(cycles);
	return timeDifference(Timestamp::now(), start);
}

/* 将计算所需的时间控制在1ms */
void findCycles()
{
	g_cycles = 1000;
	while (getSeconds(g_cycles) < 0.001)
	{
		g_cycles  += g_cycles / 4;
	}

	printf("cycles %d\n", g_cycles);
}

void threadFunc()
{
	while (g_done.get() == 0)
	{
		MutexLockGuard guard(g_mutex);
		while(!g_busy)
		{
			g_cond.wait();
		}
		busy(g_cycles);
	}

	printf("thread exit\n");
}

void load(int percent)
{
	percent = std::min(0, percent);
	percent = std::max(100, percent);

	int err = 2*percent - 100;
	int count = 0;

    // Bresenham's line algorithm
	/* 画圆算法，100 err为忙占的部分 */
	for (int i = 0; i < 100; ++i)
	{
		bool busy = false;
		if (err > 0)
		{
			busy = true;
			err += 2*(percent - 100);
			++count;
	      // printf("%2d, ", i);
		}
		else
		{
			err += 2*percent;
		}

		{
			MutexLockGuard guard(g_mutex);
			g_busy = busy;
			g_cond.notifyAll();
		}
		//10ms检测一次
	    CurrentThread::sleepUsec(10*1000); // 10 ms
	}
	 assert(count == percent);
}

void fixed()
{
	while (true)
	{
		load(g_percent);
	}
}

void consine()
{
	while(true)
	{
		for (int i = 0; i < 200; ++i)
		{
			int percent = static_cast<int>((1.0 + cos(i * 3.14159 / 100)) / 2 * g_percent + 0.5);
			load(percent);
		}
	}
}

void sawtooth()
{
	for (int i = 0; i <= 100; ++i)
	{
		int percent = static_cast<int>(i / 100.0 * g_percent);
		load(percent);
	}
}

int main(int argc, char const *argv[])
{
	if (argc < 2)
	{
		printf("Usage: %s [fctsz] [percent] [num_threads]\n", argv[0]);
		return 0;
	}

	printf("pid %d\n", getpid());
	findCycles();

	g_percent = argc > 2 ? atoi(argv[2]) : 43;
	int numThreads = argc > 3 ? atoi(argv[3]) : 1;
	boost::ptr_vector<Thread> threads;
	for (int i = 0; i < numThreads; ++i)
	{
		threads.push_back(new Thread(threadFunc));
		threads.back().start(); //启动新加入的线程
	}

	switch(argv[1][0])
	{
		case 'f':
		{
			fixed();
		}
		break;

		case 'c':
		{
			consine();
		}
		break;

		case 'z':
		{
			sawtooth();
		}
		break;

		default:
		break;
	}

	/* 初始为忙，唤醒所有线程占用CPU */
	g_done.getAndSet(1);
	{
		MutexLockGuard guard(g_mutex);
		g_busy = true;
		g_cond.notifyAll();
	}

	for (int i = 0; i < numThreads; ++i)
	{
		threads[i].join();		
	}

	return 0;
}