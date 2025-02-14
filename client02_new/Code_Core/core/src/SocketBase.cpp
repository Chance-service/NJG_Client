
#include "stdafx.h"

#include "SocketBase.h"

#include <stdio.h>

#include <string>
#ifdef WIN32
#include <winsock2.h>    
#include <mstcpip.h> 
#include <WS2tcpip.h>
#else
#include <sys/socket.h>
#include <netinet/tcp.h>
#include <netinet/in.h>
#include <netdb.h>
#include <errno.h>
#endif

namespace GameCommon
{
	bool isIPV6Net(const char* domain)
	{
		bool isIPV6Net = false;

		struct addrinfo *curr, *result = NULL;

		struct addrinfo dest;
		memset(&dest,0,sizeof(dest));

		dest.ai_family = AF_UNSPEC;

		int ret = getaddrinfo(domain,NULL,&dest,&result);
		if (ret == 0)
		{
			for (curr = result; curr != NULL; curr = curr->ai_next)
			{
				switch (curr->ai_family)
				{
				case AF_INET6:
					{
						isIPV6Net = true;
						break;
					}
				case AF_INET:

					break;

				default:
					break;
				}
			}
		}

		freeaddrinfo(result);

		return isIPV6Net;
	}

	char* domainToIP(bool isIpv6,const char* pDomain)
	{
		if (isIpv6)
		{
			struct addrinfo hint;
			memset(&hint, 0x0, sizeof(hint));
			hint.ai_family = AF_INET6;
			hint.ai_flags = AI_V4MAPPED;

			addrinfo* answer = NULL;
			getaddrinfo(pDomain, NULL, &hint, &answer);

			if (answer != NULL)
			{
				char hostname[1025] = "";

				getnameinfo(answer->ai_addr,answer->ai_addrlen,hostname,1025,NULL,0,0);

				char* ipv6 = new char[128];
				memcpy(ipv6,hostname,128);

				return ipv6;
			}

			freeaddrinfo(answer);
		}
		else
		{
			struct hostent* h = gethostbyname(pDomain);
			if( h != NULL )
			{
				unsigned char* p = (unsigned char *)(h->h_addr_list)[0];
				if( p != NULL )
				{
					char* ip = new char[16];
					sprintf(ip, "%u.%u.%u.%u", p[0], p[1], p[2], p[3]);
					return ip;
				}
			}
		}
		return "";
	}

	SOCKET udpsocket(const char *ipaddr, int port, int reuseaddr /* = 0 */)
	{
		SOCKET sock = socket(AF_INET, SOCK_DGRAM, 0);
		if(sock < 0)
		{
			fprintf(stderr,"socket() error!\n");
			return INVALID_SOCKET;
		}

		if(reuseaddr)
		{
			int opt = 1;
			setreuseaddr(sock, opt);
		}

		struct sockaddr_in addr;
		int len = sizeof(addr);
		memset(&addr, 0, len);
		addr.sin_family = AF_INET;
		addr.sin_port = htons(port);
		if(ipaddr)
		{
			addr.sin_addr.s_addr = inet_addr(ipaddr);
		}
		else 
		{
			addr.sin_addr.s_addr = htonl(0);
			//addr.sin_addr.s_addr = INADDR_ANY;
		}

		int status = bind(sock, (struct sockaddr*)&addr, len);
		if(status < 0)
		{
			fprintf(stderr, "bind address err!\n");
			closesocket(sock);	
			return INVALID_SOCKET;
		}

		return sock;
	}

	int udpsendto(SOCKET sock, const char *ipaddr, int port, const char *buf, int len, int flag)
	{
		struct sockaddr_in remote_sin;

		memset(&remote_sin, 0, sizeof(remote_sin));
		remote_sin.sin_family = AF_INET;
		remote_sin.sin_port = htons((short)port);
		if(ipaddr)
		{
			remote_sin.sin_addr.s_addr = inet_addr(ipaddr);
		}
		else
		{
			remote_sin.sin_addr.s_addr = htonl(0);
		}

		return sendto(sock, buf, len, flag, (struct sockaddr*)&remote_sin, sizeof(remote_sin));
	}

	int udprecvfrom(SOCKET sock,char *ipaddr,unsigned int *port,char *buf,int len,int flag)
	{
		struct sockaddr_in remote_sin;

#ifdef CC_TARGET_OS_IPHONE
		unsigned int addlen = sizeof(remote_sin);
#else
		socklen_t addlen = sizeof(remote_sin);
#endif
		memset(&remote_sin, 0, addlen);

		int ret = recvfrom(sock, buf, len, flag, (struct sockaddr*)&remote_sin, &addlen);
		if(port)
		{
			*port = ntohs(remote_sin.sin_port);
		}
		if(ipaddr)
		{
			strcpy(ipaddr, inet_ntoa(remote_sin.sin_addr));
		}

		return ret;
	}

	SOCKET tcpsocket(bool isIpv6,const char *ipaddr, int port, int reuseaddr /* = 0 */)
	{
		SOCKET sock;
		if (isIpv6)
		{
			struct sockaddr_in6 local_sin6;
			sock = socket(AF_INET6, SOCK_STREAM, 0);
			if(sock < 0)
			{
				fprintf(stderr,"socket() error!\n");
				return INVALID_SOCKET;
			}
			if(reuseaddr)
			{
				int opt = 1;
				setreuseaddr(sock, opt);
			}
			memset(&local_sin6, 0, sizeof(local_sin6));
			local_sin6.sin6_family = AF_INET6;
			local_sin6.sin6_port = htons((short)port);
			if(ipaddr)
			{
				inet_pton(AF_INET6,ipaddr,&local_sin6.sin6_addr);
			}
			else
			{
				local_sin6.sin6_addr = in6addr_any;
			}

			int ret = bind(sock, (struct sockaddr *)&local_sin6, sizeof(local_sin6));
			if(ret < 0)
			{
				fprintf(stderr, "bind address err! ret = %d \n", ret);
				closesocket(sock);
				return INVALID_SOCKET;
			}
		}
		else
		{
			struct sockaddr_in local_sin;

			sock = socket(AF_INET, SOCK_STREAM, 0);
			if(sock < 0)
			{
				fprintf(stderr,"socket() error!\n");
				return INVALID_SOCKET;
			}

			if(reuseaddr)
			{
				int opt = 1;
				setreuseaddr(sock, opt);
			}

			memset(&local_sin, 0, sizeof(local_sin));
			local_sin.sin_family = AF_INET;
			local_sin.sin_port = htons((short)port);
			if(ipaddr)
			{
				local_sin.sin_addr.s_addr = inet_addr(ipaddr);
			}
			else
			{
				local_sin.sin_addr.s_addr = htonl(0);
			}

			int ret = bind(sock, (struct sockaddr *)&local_sin, sizeof(local_sin));
			if(ret < 0)
			{
				fprintf(stderr, "bind address err! ret = %d \n", ret);
				closesocket(sock);
				return INVALID_SOCKET;
			}
		}
		return sock;
	}

	int tcpconnect(bool isIpv6,SOCKET sock, const char *ipaddr, int port)
	{
		int ret = -1;
		if(sock == INVALID_SOCKET)
		{
			return -1;
		}

		struct addrinfo *result, hints;
		memset(&hints, 0, sizeof(struct addrinfo));
		hints.ai_family = AF_UNSPEC;
		hints.ai_socktype = SOCK_STREAM;
		//hints.ai_flags = 0;
		//hints.ai_protocol = 0;

		char port_str[16];
		sprintf(port_str, "%d", port);
		char* ip = domainToIP(isIpv6,ipaddr);
	
		ret = getaddrinfo(ip, port_str, &hints, &result);
		if (ret != 0) {

			fprintf(stderr, "getaddrinfo: %s\n", gai_strerror(ret));

			return INVALID_SOCKET;
		}
		if (result->ai_family == AF_INET)
		{
			struct sockaddr_in *sin = (struct sockaddr_in*) result->ai_addr;
			inet_pton(result->ai_family, port_str, (void*)&sin->sin_addr);
		}
		else if (result->ai_family == AF_INET6)
		{
			struct sockaddr_in6 *sin = (struct sockaddr_in6*) result->ai_addr;
			inet_pton(result->ai_family, port_str, (void*)&sin->sin6_addr);
		}
		//bind(sock, result->ai_addr, result->ai_addrlen);

		ret = connect(sock, result->ai_addr, result->ai_addrlen);
			
		freeaddrinfo(result);

		if (ret < 0)
		{
#ifdef WIN32
			fprintf(stderr, "socket connect failed: %d\n", GetLastError());
#else
			//extern int errno;
			//fprintf(stderr, "socket connect failed: %d	%s\n", errno, strerror(errno));
			fprintf(stderr, "socket connect failed\n");
#endif
		}
        if(ip != "")
        {
            delete ip;
        }
		return ret;

// 		struct sockaddr_in remote_sin;
// 
// 		memset(&remote_sin, 0, sizeof(remote_sin));
// 		remote_sin.sin_family = AF_INET;
// 		remote_sin.sin_port = htons((short)port);
// 		if(ipaddr)
// 		{
// 			remote_sin.sin_addr.s_addr = inet_addr(ipaddr);
// 		}
// 		else
// 		{
// 			remote_sin.sin_addr.s_addr = htonl(0);
// 		}

//		return connect(sock, (struct sockaddr*)&remote_sin, sizeof(remote_sin));
	}

	SOCKET tcpaccept(SOCKET sock, char *ipaddr, int *port)
	{
		if(sock == INVALID_SOCKET)
		{
			return INVALID_SOCKET;
		}
		int newsock;
		struct sockaddr_in remote_sin;
#ifdef CC_TARGET_OS_IPHONE
		unsigned int len = sizeof(remote_sin);
#else
		socklen_t len = sizeof(remote_sin);
#endif

		memset(&remote_sin, 0, len);
		newsock = accept(sock, (struct sockaddr*)&remote_sin, &len);
		if(newsock < 0)
		{
			return INVALID_SOCKET;
		}
		if(port)
		{
			*port = ntohs(remote_sin.sin_port);
		}
		if(ipaddr)
		{
			strcpy(ipaddr, inet_ntoa(remote_sin.sin_addr));
		}

		return newsock;
	}

	int setnonblocking(SOCKET sock, int nonblock)
	{
		if(sock == INVALID_SOCKET)
		{
			return -1;
		}

#ifdef WIN32
		unsigned long opt = nonblock;
		if(SOCKET_ERROR == ioctlsocket(sock, FIONBIO, &opt))
		{
			return -1;
		}
		else
		{
			return 0;
		}
#else
		int opts = fcntl(sock, F_GETFL);
		if(opts < 0) 
		{
			return -1;
		}

		if(nonblock)
		{
			opts |= O_NONBLOCK;
		}
		else
		{
			opts &= ~O_NONBLOCK;
		}

		if(fcntl(sock,F_SETFL,opts) < 0)
		{
			return -1;
		}
		else
		{
			return 0;
		}
#endif
	}

	int setreuseaddr(SOCKET sock, int opt)
	{
		if(sock == INVALID_SOCKET)
		{
			return -1;
		}
		return setsockopt(sock, SOL_SOCKET, SO_REUSEADDR, (const char*)&opt, sizeof(opt));
	}

	int getpeeraddr(SOCKET sock, char* ip, int* port)
	{
		if(sock == INVALID_SOCKET)
		{
			return -1;
		}

		struct sockaddr addr;
#ifdef CC_TARGET_OS_IPHONE
		unsigned int addrlen = sizeof(addr);
#else
		socklen_t addrlen = sizeof(addr);
#endif
		int ret = getpeername(sock, &addr, &addrlen);
		if(ret < 0)
		{
			return ret;
		}

		unsigned char *pp = (unsigned char*)(addr.sa_data);
		if(port)
		{
			*port = ((unsigned int)pp[0]<<8)|(pp[1]);
		}
		if(ip)
		{
			sprintf(ip,"%d.%d.%d.%d",pp[2],pp[3],pp[4],pp[5]);
		}

		return 0;
	}

	int getlocaladdr(SOCKET sock, char* ip, int* port)
	{
		if(sock == INVALID_SOCKET)
		{
			return -1;
		}

		struct sockaddr addr;
#ifdef CC_TARGET_OS_IPHONE
		unsigned int addrlen = sizeof(addr);
#else
		socklen_t addrlen = sizeof(addr);
#endif
		int ret = getsockname(sock, &addr, &addrlen);
		if(ret < 0)
		{
			return ret;
		}

		unsigned char *pp = (unsigned char*)(addr.sa_data);
		if(port)
		{
			*port = ((unsigned int)pp[0]<<8)|(pp[1]);
		}
		if(ip)
		{
			sprintf(ip,"%d.%d.%d.%d",pp[2],pp[3],pp[4],pp[5]);
		}

		return 0;
	}

	int geterror(SOCKET sock)
	{
		int so_error = 0;
#ifdef CC_TARGET_OS_IPHONE
		unsigned int len = sizeof(so_error);
#else
		socklen_t len = sizeof(so_error);
#endif
		getsockopt(sock, SOL_SOCKET, SO_ERROR, reinterpret_cast<char*>(&so_error), &len);
		return so_error;
	}

	int setkeepalive( SOCKET sock, int keepalive /*= 1*/, int keepidle /*= 30*/, int keepinterval /*= 1*/, int keepcount /*= 5*/ )
	{
		if(sock == INVALID_SOCKET)
		{
			return -1;
		}

		if(setsockopt(sock, SOL_SOCKET, SO_KEEPALIVE, (const char*)&keepalive, sizeof(keepalive)) != 0)
		{
			return -1;
		}

#ifdef WIN32
		struct tcp_keepalive kavars = {    
			keepalive,    
			keepidle * 1000,
			keepinterval * 1000    
		};
		DWORD dwReturn(0);
		DWORD dwTransBytes(0);
		if (WSAIoctl(sock, SIO_KEEPALIVE_VALS, &kavars, sizeof(kavars), &dwReturn, sizeof(dwReturn), &dwTransBytes, NULL,NULL) == SOCKET_ERROR)
		{
			return -1;
		}
#else
// 		if(setsockopt(sock, IPPROTO_TCP, TCP_KEEPALIVE, (const char*)&keepidle, sizeof(keepidle)) != 0)
// 		{
// 			return -1;
// 		}
// 		if(setsockopt(sock, IPPROTO_TCP, TCP_KEEPINTVL, (const char *)&keepinterval, sizeof(keepinterval)) != 0)
// 		{
// 			return -1;
// 		}
// 		if(setsockopt(sock, IPPROTO_TCP, TCP_KEEPCNT, (const char *)&keepcount, sizeof(keepcount)) != 0)
// 		{
// 			return -1;
// 		}

#endif
		return 0;
	}

}

