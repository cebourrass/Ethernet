

#include <stdio.h>
#include <io.h>
#include <stdint.h>
#include <system.h>
#include "IP.h"
//#define DEBUG_SND_PKT

void PrintIPConf(struct ETH_struct* conf){

		printf("========= IP config ============\n");
		printf("Checksum: %x\n",conf->Checksum);
		printf("Local Port: %x\n",conf->LocalPort);
		printf("Remote Port: %x\n",conf->RemotePort);
		printf("Local  IP: %lx\n",conf->LocalIP);
		printf("Remote IP: %lx\n",conf->RemoteIP);
		printf("Local_MAC_ADDRESS: %llx\n",conf->LocalMACAddr);
		printf("Remote_MAC_ADDRESS: %llx\n",conf->RemoteMACAddr);
		printf("==============================\n");

}



void ReadIPConf(struct ETH_struct* conf)
{
	uint64_t LocalMACAddrLSB;
	uint64_t LocalMACAddrMSB;
	uint64_t RemoteMACAddrLSB;
	uint64_t RemoteMACAddrMSB;

	conf-> Checksum  = IORD(AV_ETH_CONFIG_0_BASE, 0x00);
	conf-> LocalPort = IORD(AV_ETH_CONFIG_0_BASE, 0x01);
	conf-> RemotePort = IORD(AV_ETH_CONFIG_0_BASE, 0x02);
	conf-> LocalIP = IORD(AV_ETH_CONFIG_0_BASE, 0x03);
	conf-> RemoteIP = IORD(AV_ETH_CONFIG_0_BASE, 0x04);

	LocalMACAddrLSB = IORD(AV_ETH_CONFIG_0_BASE, 0x05);
	LocalMACAddrMSB = IORD(AV_ETH_CONFIG_0_BASE, 0x06);

	conf->LocalMACAddr = (LocalMACAddrMSB << 32) + LocalMACAddrLSB;

	#ifdef DEBUG_IPCONF
	printf("\nReadIPConf Function\n");
	printf("LocalMACAddr:  %llx\n",conf->LocalMACAddr);
	#if (DEBUG_IPCONF > 1)
		printf("LocalMACAddrLSB Register: %llx\n",LocalMACAddrLSB);
		printf("LocalMACAddrMSB Register: %llx\n",LocalMACAddrMSB);
	#endif

	#endif

	RemoteMACAddrLSB = IORD(AV_ETH_CONFIG_0_BASE, 0x07);
	RemoteMACAddrMSB = IORD(AV_ETH_CONFIG_0_BASE, 0x08);

	conf-> RemoteMACAddr = (RemoteMACAddrMSB << 32) +RemoteMACAddrLSB;

	#ifdef DEBUG_IPCONF
	printf("RemoteMACAddr: %llx\n",conf-> RemoteMACAddr);
	#if (DEBUG_IPCONF > 1)
			printf("RemoteMACAddrLSB Register: %llx\n",RemoteMACAddrLSB);
			printf("RemoteMACAddrMSB Register: %llx\n",RemoteMACAddrMSB);
		#endif
	#endif

}

void WriteIPConf(struct ETH_struct * conf)
{

	uint32_t LocalMACAddrLSB;
	uint32_t LocalMACAddrMSB;
	uint32_t RemoteMACAddrLSB;
	uint32_t RemoteMACAddrMSB;



	 IOWR(AV_ETH_CONFIG_0_BASE, 0x00,conf-> Checksum);
	 IOWR(AV_ETH_CONFIG_0_BASE, 0x01,conf-> LocalPort);
	 IOWR(AV_ETH_CONFIG_0_BASE, 0x02,conf-> RemotePort);
	 IOWR(AV_ETH_CONFIG_0_BASE, 0x03,conf-> LocalIP);
	 IOWR(AV_ETH_CONFIG_0_BASE, 0x04,conf-> RemoteIP);

	 LocalMACAddrLSB = (uint32_t)(conf->LocalMACAddr & 0x00000000FFFFFFFF);

	 #ifdef DEBUG_IPCONF
	 printf("\nWriteIPConf Function\n");
	 printf("LocalMACAddrLSB :%llx\n",LocalMACAddrLSB);
	 #endif

	 LocalMACAddrMSB = conf->LocalMACAddr>> 32;

	 #ifdef DEBUG_IPCONF
	 printf("LocalMACAddrMSB :%llx\n",LocalMACAddrMSB);
	 #endif

	 IOWR(AV_ETH_CONFIG_0_BASE, 0x05, LocalMACAddrLSB);
	 IOWR(AV_ETH_CONFIG_0_BASE, 0x06, LocalMACAddrMSB);

	 RemoteMACAddrLSB = (uint32_t)(conf->RemoteMACAddr & 0x00000000FFFFFFFF);

	 #ifdef DEBUG_IPCONF
	 printf("RemoteMACAddrLSB :%llx\n",RemoteMACAddrLSB);
	 #endif

	 RemoteMACAddrMSB = conf->RemoteMACAddr>> 32;

	 #ifdef DEBUG_IPCONF
	 printf("RemoteMACAddrMSB :%llx\n",RemoteMACAddrMSB);
	 #endif

	 IOWR(AV_ETH_CONFIG_0_BASE, 0x07, RemoteMACAddrLSB);
	 IOWR(AV_ETH_CONFIG_0_BASE, 0x08, RemoteMACAddrMSB);

}


uint16_t CalcCheck(uint32_t length, uint32_t IPsrc, uint32_t IPdst)
{


	uint32_t ipv4_header_precomputed_sum;

	ipv4_header_precomputed_sum = (IPV4_CHECKSUM_FIRSTHALFWORD)\
								 + IPV4_HEADER_LENGTH\
								 + UDP_HEADER_LENGTH\
								 + length\
								 + IPV4_ID\
								 + IPV4_FRAG_OFFSET\
								 + (IPV4_CHECKSUM_TIMEUDP)\
								 + ((IPsrc >> 16) & 0xFFFF)\
								 + (IPsrc & 0x0000FFFF)\
								 + ((IPdst >> 16) & 0xFFFF)\
								 + (IPdst & 0x0000FFFF);

	return (uint16_t) ~((ipv4_header_precomputed_sum & 0xFFFF) + ((ipv4_header_precomputed_sum >>16) & 0xFFFF));
}


// Packet size = 8 32bits registers
void SendCommandPacket(uint32_t* packet, int length, uint32_t IPdst, uint64_t MACdst, uint16_t UDPPort)
{
	int cpt;

	#ifdef DEBUG_SND_PKT
	int i;
	#endif

	struct ETH_struct OldEthConf;
	struct ETH_struct EthConf;

	ReadIPConf(&EthConf);
	OldEthConf = EthConf;

	// Write New conf
	EthConf.Checksum = CalcCheck(32,EthConf.LocalIP, IPdst);
	EthConf.RemoteIP = IPdst;
	EthConf.RemoteMACAddr = MACdst;
	EthConf.RemotePort = UDPPort;

	WriteIPConf(&EthConf);
	PrintIPConf(&EthConf);

	/*	Software routine to send UDP packet	*/
	//TODO: configurable length


	/*	Resetting send bit	*/
	//TODO: use a read-write operation to overwrite only the bit0
	IOWR(AV_STATUS_REG_0_BASE, 0x00, 0x00000000);

	/*	Loading packet payload	*/
	/*
	IOWR(AV_STATUS_REG_0_BASE, 0x01, packet[0]);
	IOWR(AV_STATUS_REG_0_BASE, 0x02, packet[1]);
	IOWR(AV_STATUS_REG_0_BASE, 0x03, packet[2]);
	IOWR(AV_STATUS_REG_0_BASE, 0x04, packet[3]);
	IOWR(AV_STATUS_REG_0_BASE, 0x05, packet[4]);
	IOWR(AV_STATUS_REG_0_BASE, 0x06, packet[5]);
	IOWR(AV_STATUS_REG_0_BASE, 0x07, packet[6]);
	IOWR(AV_STATUS_REG_0_BASE, 0x08, packet[7]);
	 */

	 for (cpt=0;cpt<8;cpt++)
	 	  IOWR(AV_STATUS_REG_0_BASE, cpt+1, packet[cpt]);


	/*	Generate pulse on the UDP send	*/
	//TODO: use a read-write operation to set only the bit0
	IOWR(AV_STATUS_REG_0_BASE, 0x00, 0xFFFFFFFF);

	#ifdef DEBUG_SND_PKT
	printf("[DEBUG SND PKT] ");
	for (i=0;i<8;i++)
		printf("packet[%d]:%lx ",i,packet[i]);
	printf("\n");
	#endif

	WriteIPConf(&OldEthConf);
}



void sendCommandPacket_UDP(uint32_t packet[8], int length )
{
	#ifdef DEBUG_SND_PKT
	int i;
	#endif

	/*	Software routine to send UDP packet	*/
	//TODO: configurable length


	/*	Resetting send bit	*/
	//TODO: use a read-write operation to overwrite only the bit0
	IOWR(AV_STATUS_REG_0_BASE, 0x00, 0x00000000);

	/*	Loading packet payload	*/
	IOWR(AV_STATUS_REG_0_BASE, 0x01, packet[0]);
	IOWR(AV_STATUS_REG_0_BASE, 0x02, packet[1]);
	IOWR(AV_STATUS_REG_0_BASE, 0x03, packet[2]);
	IOWR(AV_STATUS_REG_0_BASE, 0x04, packet[3]);
	IOWR(AV_STATUS_REG_0_BASE, 0x05, packet[4]);
	IOWR(AV_STATUS_REG_0_BASE, 0x06, packet[5]);
	IOWR(AV_STATUS_REG_0_BASE, 0x07, packet[6]);
	IOWR(AV_STATUS_REG_0_BASE, 0x08, packet[7]);

	/*
	 * for (cpt=0;cpt<8;cpt++)
	 	  IOWR(AV_STATUS_REG_0_BASE, cpt+1, packet[cpt]);
	 */

	/*	Generate pulse on the UDP send	*/
	//TODO: use a read-write operation to set only the bit0
	IOWR(AV_STATUS_REG_0_BASE, 0x00, 0xFFFFFFFF);

	#ifdef DEBUG_SND_PKT
	printf("[DEBUG SND PKT] ");
	for (i=0;i<8;i++)
		printf("packet[%d]:%lx ",i,packet[i]);
	printf("\n");
	#endif

}


void SendPacketFifo(uint16_t length, uint32_t IPdst, uint64_t MACdst, uint16_t UDPSrcPort , uint16_t UDPDestPort)
{

	uint32_t LocalIP;
	uint32_t LocalMACAddrLSB=0;
	uint32_t LocalMACAddrMSB=0;
	uint16_t Checksum;


	/*	Resetting send bit	*/
	//TODO: use a read-write operation to overwrite only the bit0
	IOWR(AV_SENDPACKET_0_BASE, 0x00, 0x00000000);


	// Read Local IP from AV_ETH_CONFGi register
	 LocalIP = IORD(AV_ETH_CONFIG_0_BASE, 0x03);

	 // Recalculate checksum
	 Checksum =  CalcCheck((uint32_t)length,LocalIP, IPdst);

	 // Write Ethernet Config
	 IOWR(AV_SENDPACKET_0_BASE, 0x01, Checksum);
	 IOWR(AV_SENDPACKET_0_BASE, 0x02, UDPSrcPort);
	 IOWR(AV_SENDPACKET_0_BASE, 0x03, UDPDestPort);
	 IOWR(AV_SENDPACKET_0_BASE, 0x04, IPdst );


	 LocalMACAddrLSB = (uint32_t)(MACdst & 0x00000000FFFFFFFF);

	 #ifdef DEBUG_SND_PKT
	 printf("\nWriteIPConf Function\n");
	 printf("LocalMACAddrLSB :%x\n",LocalMACAddrLSB);
	 #endif

	 LocalMACAddrMSB = MACdst>> 32;

	 #ifdef DEBUG_SND_PKT
	 printf("LocalMACAddrMSB :%x\n",LocalMACAddrMSB);
	 #endif

	 IOWR(AV_SENDPACKET_0_BASE, 0x05, LocalMACAddrLSB);
	 IOWR(AV_SENDPACKET_0_BASE, 0x06, LocalMACAddrMSB);


		/*	Generate pulse on the UDP send	*/
		//TODO: use a read-write operation to set only the bit0
 	IOWR(AV_SENDPACKET_0_BASE, 0x00, (length<<15)|0x00000001);

	 	//	IOWR(AV_SENDPACKET_0_BASE, 0x00, 0xFFFFFFFF);


}

