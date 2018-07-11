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
#include <errno.h>

#define MAX_DATA_SIZE 1024
#define CLI_PORT 9999
void perr_exit(const char *str)
{
	perror(str);
	fprintf(stderr, "%s\n", strerror(errno));
	exit(1);
}

int main(int argc, char **argv)
{
	int sock_fd,len;
	char buf[MAX_DATA_SIZE];
	struct sockaddr_in cliaddr;

	bzero(&cliaddr, sizeof(cliaddr));

	sock_fd = socket(AF_INET, SOCK_STREAM, 0);
	cliaddr.sin_family = AF_INET;
	cliaddr.sin_port = htons(CLI_PORT);
	inet_pton(AF_INET, argv[1], &cliaddr.sin_addr.s_addr);

	if (connect(sock_fd, (struct sockaddr *)&cliaddr, sizeof(cliaddr)) < 0)
	{
		perr_exit("connect error");
	}

	while (fgets(buf, MAX_DATA_SIZE, stdin))
	{
		if (write(sock_fd, buf, strlen(buf)) < 0)
		{
			perr_exit("write error");
		}

		len = read(sock_fd, buf, MAX_DATA_SIZE);
		if (len < 0)
		{
			perr_exit("read error");
		}

		if (0 == len)
		{
			printf("serv is closed\n");
			close(sock_fd);
			exit(1);
		}

		if (write(STDOUT_FILENO, buf, len) < 0)
		{
			perr_exit("write error");
		}
	}

	return 0;

}