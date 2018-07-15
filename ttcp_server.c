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

static int acceptOrDie(uint16_t port)
{
	int listenfd = ::socket(AF_INET, SOCK_STREAM, 0);
	assert(listenfd);

	int yes = 1;
	if (setsockopt(listenfd, SOL_SOCKET, SO_REUSEADDR, &yes, sizeof(yes)))
	{
		perror("setsockopt");
		exit(1);
	}

	struct sockaddr_in addr;
	bzero(&addr, sizeof(addr));
	addr.sin_family = AF_INET;
	addr.sin_port = htons(port);
	addr.sin_addr.s_addr = htonl(INADDR_ANY);

	if (bind(listenfd, reinterpret_cast<const struct sockaddr *>(&addr), sizeof(addr)) < 0)
	{
		perror("bind");
		exit(1);
	}

	if (listen(listenfd, 5) < 0)
	{
		perror("listen");
		exit(1);
	}

	struct sockaddr_in peeraddr;
	bzero(&peeraddr, sizeof(peeraddr));
	socklen_t len = 0;

	int sockfd = ::accept(listenfd, reinterpret_cast<struct sockaddr *>(&peeraddr), &len);
	if (sockfd < 0)
	{
		perror("accept");
		exit(1);
	}

	::close(listenfd);
	return sockfd;
}

int main(int argc, char const *argv[])
{
	int sockfd = acceptOrDie(12345);
	struct SessionMessage sessionmessage = {0, 0};
	if (read_n(sockfd, &sessionmessage, sizeof(sessionmessage)) != sizeof(sessionmessage))
	{
		perror("read message");
		return 1;
	}

	sessionmessage.length = ntohl(sessionmessage.length);
	sessionmessage.number = ntohl(sessionmessage.number);
	printf("receive number = %d, receive length = %d\n", sessionmessage.number, sessionmessage.length);

	const int total_len = static_cast<int> (sizeof(uint32_t) + sessionmessage.length);
	PayloadMessage *payloadMessage = static_cast<PayloadMessage *> 
	(::malloc(total_len));
	assert(payloadMessage);

	for (int i = 0; i < sessionmessage.number; ++i)
	{
		payloadMessage->length = 0;
		if (read_n(sockfd, &(payloadMessage->length), sizeof(payloadMessage->length)) != 
			sizeof(payloadMessage->length))
		{
			perror("read payloadMessage length");
			return 1;
		}

		payloadMessage->length = ntohl(payloadMessage->length);
		assert(payloadMessage->length == sessionmessage.length);
		int32_t ret = 0;
		if ((ret = read_n(sockfd, payloadMessage->data, payloadMessage->length)) !=  payloadMessage->length)
		{
			perror("read payloadMessage data\n");
			printf("ret = %d", ret);
			exit(1);
		}

		int32_t ack = htonl(payloadMessage->length);
		if (write_n(sockfd, &ack, sizeof(ack)) != sizeof(ack))
		{
			perror("ack");
			exit(1);
		}

	}

	::free(payloadMessage);
	::close(sockfd);

	return 0;
}
