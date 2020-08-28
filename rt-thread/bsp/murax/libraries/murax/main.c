//#include "stddefs.h"
#include <stdint.h>
#include "murax.h"
#include "rtthread.h"

static rt_thread_t dynamic_thread = RT_NULL;
static struct rt_thread static_thread1,static_thread2 ;

void print(const char*str){
	while(*str){
		uart_write(UART,*str);
		str++;
	}
}
void println(const char*str){
	print(str);
	uart_write(UART,'\n');
}

void delay(uint32_t loops){
	for(int i=0;i<loops;i++){
		int tmp = GPIO_A->OUTPUT;
	}
}

void hello_murax(){
	while(1){
		println("hello world muraxxx");
		rt_thread_mdelay(100);
	}

}

void hello_cxzzzz(){

	while(1){
		println("hello world cxzzzz");
		rt_thread_delay(5);
	}

}

static int thread1_stack[1024],thread2_stack[1024];

void main(){

	int ii=0;
	println("hello world murax");
	//rt_thread_delay(1);
	//rt_thread_mdelay(500);
	//println("hello world murax1");
	/*
	dynamic_thread = rt_thread_create("hello murax",
		hello_cxzzzz,
		RT_NULL, 512, 2, 10);
	println("hello world murax1");
	rt_thread_startup(dynamic_thread);
	*/
	/*
	while(ii< 1000){
		println("hello world murax");
		ii = ii + 1;
		rt_thread_delay(1);
	}
	return ;
	*/
	rt_thread_init(&static_thread1, "static1",
		hello_cxzzzz,RT_NULL, 
		&thread1_stack[0],                 //线程栈地址
		sizeof(thread1_stack),             //线程栈大小
		6,10
		);
	println("hello world murax0");
	rt_thread_startup( &static_thread1);
	println("hello world murax1");
	//while(1);

	rt_thread_init(&static_thread2, "static2",
		hello_murax,RT_NULL, 
		&thread2_stack[0],                 //线程栈地址
		sizeof(thread2_stack),             //线程栈大小
		6,5
		);
	println("hello world murax2");

	rt_thread_startup( &static_thread2);
	/*

	println("hello world murax2");
	while(1){
		println("hello world murax3");
		rt_thread_delay(1);
	}
	*/

	/*
	dynamic_thread = rt_thread_create("hello murax",
		uart_test,
		RT_NULL, 512, 2, 10);
	rt_thread_startup(dynamic_thread);
	*/

	/*
    GPIO_A->OUTPUT_ENABLE = 0x0000000F;
	GPIO_A->OUTPUT = 0x00000001;
    println("hello world cxzzzz");
    const int nleds = 4;
	const int nloops = 2000000;
    while(1){
    	for(unsigned int i=0;i<nleds-1;i++){
    		GPIO_A->OUTPUT = 1<<i;
    		delay(nloops);
    	}
    	for(unsigned int i=0;i<nleds-1;i++){
			GPIO_A->OUTPUT = (1<<(nleds-1))>>i;
			delay(nloops);
		}
    }
	*/
}

void main_test(){
	GPIO_A->OUTPUT_ENABLE = 0x0000000F;
	GPIO_A->OUTPUT = 0x00000001;
    println("hello world cxzzzz");
    const int nleds = 4;
	const int nloops = 2000000;
    while(1){
    	for(unsigned int i=0;i<nleds-1;i++){
    		GPIO_A->OUTPUT = 1<<i;
    		delay(nloops);
    	}
    	for(unsigned int i=0;i<nleds-1;i++){
			GPIO_A->OUTPUT = (1<<(nleds-1))>>i;
			delay(nloops);
		}
    }
}

/*
void irqCallback(){

}

*/
