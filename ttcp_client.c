#include<arpa/inet.h> 
#include<sys/types.h>
#include<sys/socket.h>
#include<sys/time.h>
#include<sys/epoll.h>
#include<pthread.h>
#include<fcntl.h>

#include<unistd.h>
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<stdbool.h>
#include<error.h>

#include<iostream>
#include<memory>

#include<errno.h>
#include<assert.h>

/* 发的包数量以及每个包的长度 */
struct SessionMessage
{
	int32_t number;
	int32_t length;
}__attribute__((__packed__));

struct PayloadMessage
{
	int32_t length;
	char data[0];
};

static double now()
{
	struct timeval tv = {0, 0};
	gettimeofday(&tv, NULL);

	return tv.tv_sec + tv.tv_usec / 1000000.0;
}

static int write_n(int sockfd, const void *buf, int length)
{
	int written = 0;

	while (written < length)
	{
		size_t nw = ::write(sockfd, static_cast<const char*>(buf) + written, length - written);
		if (nw > 0)
		{
			written += static_cast<int>(nw); 
		}
		else if (0 == nw)
		{
			break; //EOF
		}
		else if (errno != EINTR)
		{
			perror("write");
			break;
		}
	}

	return written;
}

static int read_n(int sockfd, void *buf, int length)
{
	int readn = 0;

	while (readn < length)
	{
		size_t nr = ::read(sockfd, static_cast<char*>(buf) + readn, length - readn);
		if (nr > 0)
		{
			readn += static_cast<int>(nr); 
		}
		else if (0 == nr)
		{
			break; //EOF
		}
		else if (errno != EINTR)
		{
			perror("readn");
			break;
		}
	}

	return readn;
}

int main(int argc, char const *argv[])
{
	if (argc < 2)
	{
		fprintf(stderr, "./usage");
		return 1;
	}

	struct sockaddr_in addr; //IPV4
	addr.sin_family = AF_INET;
	const char *ip = argv[1];
	inet_aton(ip, &(addr.sin_addr));
	addr.sin_port = htons(12345);

	int sockfd = ::socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
	if (-1 == sockfd)
	{
		perror("socket");
		exit (1);
	}

	int ret = ::connect(sockfd, (struct sockaddr *)&addr, sizeof(addr));
	if (ret)
	{
		perror("connect");
		::close(sockfd);
		exit(1);
	}

	printf("client connected\n");

	// 设置默认值
	int length = 65536;
	int number = 8192;

	if (3 == argc)
	{
		length = atoi(argv[2]);
	}

	if (4 == argc)
	{
		length = atoi(argv[2]);
		number= atoi(argv[3]);
	}

	double start = now();

	struct SessionMessage sessionmessage = {0, 0};
	sessionmessage.length = htonl(length);
	sessionmessage.number = htonl(number);

	if (write_n(sockfd, &sessionmessage, sizeof(sessionmessage)) 
		!= sizeof(sessionmessage))
	{
		perror("write sessionmessage");
		exit(1);
	}

	const int total_len = static_cast<int>(sizeof(int32_t) + length);
	PayloadMessage *payloadmessage = static_cast<PayloadMessage *>
	(::malloc(total_len));

	assert(payloadmessage);

	// fill in payloadmessage

	payloadmessage->length = htonl(length);
	for (int i = 0; i < length; ++i)
	{
		payloadmessage->data[i] = "0123456789ABCDEF"[i % 16];
	}

	double total_mb = 1.0 * length * number / 1024 / 1024;
	printf("%.3f Mb in total\n", total_mb);

	for (int i = 0; i < number; ++i)
	{
		//send length  这里加个取地址符，定位好久
		if (write_n(sockfd, payloadmessage, total_len) != total_len)
		{
			perror("write payloadmessage");
			exit(1);
		}

		int32_t ack;
		int ret = 0;
		if ((ret = read_n(sockfd, &ack, sizeof(ack))) != sizeof(ack))
		{
			printf("ret= %d, sizeof(ack)= %ld\n", ret, sizeof(ack));
			perror("read ack");
			exit(1);
		}

		ack = ntohl(ack);
		printf("ack ok= %d\n", ack);
		assert(ack == length);
	} 

	::free(payloadmessage);
	::close(sockfd);

	double elapsed = now() - start;
    printf("%.3f seconds\n%.3f MB/s\n", elapsed, total_mb / elapsed);

	return 0;
}
