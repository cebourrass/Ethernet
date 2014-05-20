/*
 * IP.h
 *
 *  Created on: 23 sept. 2013
 *      Author: cedric
 */

#ifndef IP_H_
#define IP_H_

#define MAC_BROADCAST 0xffffffffffffll

#define IPV4_VERSION 0x4
#define IPV4_IHL 0x5
#define IPV4_SERVICE_TYPE 0x00
#define IPV4_CHECKSUM_FIRSTHALFWORD 0x4500

#define IPV4_HEADER_LENGTH 20
#define UDP_HEADER_LENGTH 8
#define UDP_DATA_BYTE_LENGTH 32
#define IPV4_PACKET_LENGTH 0x003c

#define IPV4_ID 0x0000
#define IPV4_FRAG_OFFSET 0x0000
#define IPV4_TIME_TO_LIVE 0x40

#define IPV4_PROTOCOL_UDP 0x11
#define IPV4_CHECKSUM_TIMEUDP 0x4011

//#define DEBUG_IPCONF
//#define DEBUG_REC_PKT
//#define DEBUG_SND_PKT

struct ETH_struct{

	uint16_t Checksum;
	uint16_t LocalPort;
	uint16_t RemotePort;
	uint32_t LocalIP;
	uint32_t RemoteIP;
	uint64_t LocalMACAddr;
	uint64_t RemoteMACAddr;
};


void ReadIPConf(struct ETH_struct* conf);
void WriteIPConf(struct ETH_struct * conf);
void PrintIPConf(struct ETH_struct* conf);

uint16_t CalcCheck(uint32_t length, uint32_t IPsrc, uint32_t IPdst);

/*
Both function send a Packet via status IP, but one use Avalon register configuration
and the other one use call arguments for MAC and IP destination
*/
void sendCommandPacket_UDP(uint32_t packet[8], int length );
void SendCommandPacket(uint32_t* packet, int length, uint32_t IPdst, uint64_t MACdst, uint16_t UDPPort);

/*
SendPacketFifo is a function to send a variable length packet trough av_sendpacket IP
*/
void SendPacketFifo(uint16_t length, uint32_t IPdst, uint64_t MACdst, uint16_t UDPSrcPort , uint16_t UDPDestPort);


#endif /* IP_H_ */
