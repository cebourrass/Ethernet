/*
 * "Hello World" example.
 *
 * This example prints 'Hello from Nios II' to the STDOUT stream. It runs on
 * the Nios II 'standard', 'full_featured', 'fast', and 'low_cost' example
 * designs. It runs with or without the MicroC/OS-II RTOS and requires a STDOUT
 * device in your system's hardware.
 * The memory footprint of this hosted application is ~69 kbytes by default
 * using the standard reference design.
 *
 * For a reduced footprint version of this template, and an explanation of how
 * to reduce the memory footprint for a given application, see the
 * "small_hello_world" template.
 *
 */

#include <stdio.h>
#include <io.h>
#include <stdint.h>
#include <system.h>
#include "IP.h"
#include "priv/alt_legacy_irq.h"
#include "sys/alt_irq.h"

#define DELAY_CYCLE		1000


void delay_ms(int ms)
{
	int i,j;
	for( i = 0; i < ms; i++ )
	{
		for( j = 0; j < DELAY_CYCLE; j++ );
	}
}

static void receiveUDP_interrupt(void* context, alt_u32 id)
{
	uint32_t packet[8];
	uint16_t cpt;

	IOWR(AV_CONFIG_REG_0_BASE, 0x0, 0x0004);

	/*
	packet[0]=IORD(AV_CONFIG_REG_0_BASE,0x01);
	packet[1]=IORD(AV_CONFIG_REG_0_BASE,0x02);
	packet[2]=IORD(AV_CONFIG_REG_0_BASE,0x03);
	packet[3]=IORD(AV_CONFIG_REG_0_BASE,0x04);
	packet[4]=IORD(AV_CONFIG_REG_0_BASE,0x05);
	packet[5]=IORD(AV_CONFIG_REG_0_BASE,0x06);
	packet[6]=IORD(AV_CONFIG_REG_0_BASE,0x07);
	packet[7]=IORD(AV_CONFIG_REG_0_BASE,0x08);
	*/

	// Packet Reception
	 for (cpt=0;cpt<8;cpt++)
	 	  packet[cpt] = IORD(AV_CONFIG_REG_0_BASE, cpt+1);


	#ifdef DEBUG_REC_PKT
	printf("[DEBUG REC PKT] ");
	for (cpt=0;cpt<8;cpt++)
		printf("packet[%d]:%lx ",cpt,packet[cpt]);
	printf("\n");
	#endif

	sendCommandPacket_UDP(packet,32);

	SendCommandPacket(packet, 32, 0xc0a8000A, MAC_BROADCAST,0x0000fde2);

	SendCommandPacket(packet, 32, 0xc0a8001F, MAC_BROADCAST,0x0000fde5);


	IOWR(AV_CONFIG_REG_0_BASE, 0x0, 0x0000);
}

int main()
{
		uint16_t Checksum;
		uint32_t LocalMACAddrLSB=0;
		uint32_t LocalMACAddrMSB=0;
		struct ETH_struct EthConf;
		int cpt;

		uint32_t packet[8] ={0x1A3C202A,0x00C0D2F0,0x00B22000,0x25D10010,0xD00020D0,0x00D0AAC5,0x20000405,0x08194200};
		uint32_t packet2[8]={0x00C0D2F0,0xC0000405,0xD00020FE,0x1A3C202A,0x00FF2000,0xFFD10010,0x081942C0,0x00D0AAC5};
		uint32_t packet3[8]={0xD00020D0,0x00B22000,0x1A3C202A,0xFF3C202A,0x25D10010,0x08194200,0x081942C0,0x00D0AAC5};


		printf("Hello from Nios II!\n");

		EthConf.LocalPort = 0x0000AAAA;
		EthConf.RemotePort = 0x0000fde2;

		EthConf.LocalIP = 0xc0a80004;
		EthConf.RemoteIP = 0xAC1B01EB;

		EthConf.LocalMACAddr  =  0x74ea3a851bd7ull;
		EthConf.RemoteMACAddr  = 0xD4BED93049D0ull;


		EthConf.Checksum = CalcCheck(32,EthConf.LocalIP,EthConf.RemoteIP);


		WriteIPConf(&EthConf);

		ReadIPConf(&EthConf);
		PrintIPConf(&EthConf);

		alt_irq_register( AV_CONFIG_REG_0_IRQ, NULL, (alt_isr_func) receiveUDP_interrupt );

		 // Write Video Config
		// IP local save in AV_ETH_config + 0x03
		Checksum =  CalcCheck((uint32_t)512, IORD(AV_ETH_CONFIG_0_BASE, 0x03), 0xAC1B01EB);
		IOWR(AV_SENDPACKET_0_BASE, 0x00, (0x200<<16));
		IOWR(AV_SENDPACKET_0_BASE, 0x01, Checksum);
		IOWR(AV_SENDPACKET_0_BASE, 0x02, 0x0000BBBB);
		IOWR(AV_SENDPACKET_0_BASE, 0x03, 0x0000fde9);
		IOWR(AV_SENDPACKET_0_BASE, 0x04, 0xAC1B01EB );

		LocalMACAddrLSB = (uint32_t)(0xD4BED93049D0ull & 0x00000000FFFFFFFF);
		LocalMACAddrMSB = 0xD4BED93049D0ull>> 32;

		IOWR(AV_SENDPACKET_0_BASE, 0x05, LocalMACAddrLSB);
		IOWR(AV_SENDPACKET_0_BASE, 0x06, LocalMACAddrMSB);


		while (1)
		{

	/*		sendCommandPacket_UDP(packet2,32);
			delay_ms(500);
			SendCommandPacket(packet, 32, 0xAC1B01EB,  0xD4BED93049D0ull,0x0000fde9);
			delay_ms(500);
	 */

		}

  return 0;
}



