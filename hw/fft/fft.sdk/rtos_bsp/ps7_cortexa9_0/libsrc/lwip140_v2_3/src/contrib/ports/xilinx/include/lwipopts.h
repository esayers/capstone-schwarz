#ifndef __LWIPOPTS_H_
#define __LWIPOPTS_H_

#ifndef PROCESSOR_LITTLE_ENDIAN
#define PROCESSOR_LITTLE_ENDIAN
#endif

#define SYS_LIGHTWEIGHT_PROT 1


#define OS_IS_FREERTOS
#define DEFAULT_THREAD_PRIO 2
#define TCPIP_THREAD_PRIO (DEFAULT_THREAD_PRIO+1)
#define TCPIP_THREAD_STACKSIZE 32768
#define DEFAULT_TCP_RECVMBOX_SIZE 	300
#define DEFAULT_ACCEPTMBOX_SIZE 	5
#define TCPIP_MBOX_SIZE		30
#define DEFAULT_UDP_RECVMBOX_SIZE 	100
#define DEFAULT_RAW_RECVMBOX_SIZE	100

#define MEM_ALIGNMENT 64
#define MEM_SIZE 1048576
#define MEMP_NUM_PBUF 2048
#define MEMP_NUM_UDP_PCB 256
#define MEMP_NUM_TCP_PCB 1024
#define MEMP_NUM_TCP_PCB_LISTEN 8
#define MEMP_NUM_TCP_SEG 1024
#define MEMP_NUM_SYS_TIMEOUT 8
#define MEMP_NUM_NETBUF 8
#define MEMP_NUM_NETCONN 16
#define MEMP_NUM_TCPIP_MSG_API 16
#define MEMP_NUM_TCPIP_MSG_INPKT 64

#define MEMP_NUM_NETBUF     8
#define MEMP_NUM_NETCONN    16
#define LWIP_PROVIDE_ERRNO  1
#define MEMP_NUM_SYS_TIMEOUT 8
#define PBUF_POOL_SIZE 4096
#define PBUF_POOL_BUFSIZE 1700
#define PBUF_LINK_HLEN 16

#define ARP_TABLE_SIZE 10
#define ARP_QUEUEING 1

#define ICMP_TTL 255

#define IP_OPTIONS 0
#define IP_FORWARD 0
#define IP_REASSEMBLY 1
#define IP_FRAG 1
#define IP_REASS_MAX_PBUFS 5760
#define IP_FRAG_MAX_MTU 1500
#define IP_DEFAULT_TTL 255
#define LWIP_CHKSUM_ALGORITHM 3

#define LWIP_UDP 1
#define UDP_TTL 255

#define LWIP_TCP 1
#define TCP_MSS 1460
#define TCP_SND_BUF 65535
#define TCP_WND 65535
#define TCP_TTL 255
#define TCP_MAXRTX 12
#define TCP_SYNMAXRTX 4
#define TCP_QUEUE_OOSEQ 1
#define TCP_SND_QUEUELEN   16 * TCP_SND_BUF/TCP_MSS
#define CHECKSUM_GEN_TCP 	0
#define CHECKSUM_GEN_UDP 	0
#define CHECKSUM_GEN_IP  	0
#define CHECKSUM_CHECK_TCP  0
#define CHECKSUM_CHECK_UDP  0
#define CHECKSUM_CHECK_IP 	0

#define NO_SYS_NO_TIMERS 1
#define MEMP_SEPARATE_POOLS 1
#define MEMP_NUM_FRAG_PBUF 256
#define IP_OPTIONS_ALLOWED 0
#define TCP_OVERSIZE TCP_MSS
#define LWIP_COMPAT_MUTEX 0
#define LWIP_ALLOW_MEM_FREE_FROM_OTHER_CONTEXT 1

#define LWIP_DHCP 1
#define DHCP_DOES_ARP_CHECK 0

#define CONFIG_LINKSPEED_AUTODETECT 1

#endif
