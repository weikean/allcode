/* sock addr */
#include<arpa/inet.h>  

/*tcp socket */
#include<sys/types.h>
#include<sys/socket.h>

#include <unistd.h>
#include <string.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h> 

#define SERV_PORT 9999
#define MAX_LINK 128
#define MAX_DATA_SIZE 1024	

void perr_exit(const char *str)
{
	perror(str);
	exit(1);
}

int main(void)
{
	int sock_fd;
	struct sockaddr_in servaddr;
	struct sockaddr_in client_addr;
	int i, len = 0;
	socklen_t addrlen;

	bzero(&servaddr,sizeof(servaddr));
	sock_fd = socket(AF_INET,SOCK_STREAM,0);
	servaddr.sin_family = AF_INET;
	servaddr.sin_port = htons(SERV_PORT);	
	servaddr.sin_addr.s_addr = htonl(INADDR_ANY);

	if (bind(sock_fd, (const struct sockaddr *)&servaddr, sizeof(servaddr)) < 0)
	{
		perr_exit("bind error");
	}

	listen (sock_fd, MAX_LINK);

	printf("wait for conncet---------\n"); 

	addrlen = sizeof(client_addr);

	int cli_fd = accept(sock_fd, (struct sockaddr *)&client_addr, &addrlen);
	if (-1 == cli_fd)
	{
		perr_exit("accept error");
	}

	char buf[MAX_DATA_SIZE];

	printf("client IP :%s %d\n",   
	inet_ntop(AF_INET, &client_addr, buf, MAX_DATA_SIZE),
	ntohs(client_addr.sin_port));

	bzero(&buf,MAX_DATA_SIZE);

	while (1)
	{
		len = read(cli_fd, buf, MAX_DATA_SIZE);
		if(-1 == len)
		{
			perr_exit("read error");
		}

		if (write(STDOUT_FILENO, buf, len) < 0)
		{
			perr_exit("write error");
		}

		for(i = 0 ;i < len ; i++)   //进行大写转换 
		{
			buf[i] = toupper(buf[i]); 
		}                                                 

        if(write(cli_fd, buf, len) < 0) //写数据到客户端   
        {
        	perr_exit("write error");  
        }                                              
	}

		close(cli_fd);
		close(sock_fd);

		return 0;
}