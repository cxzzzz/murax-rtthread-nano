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

	rt_thread_init(&static_thread1, "static1",
		hello_cxzzzz,RT_NULL, 
		&thread1_stack[0],                 //线程栈地址
		sizeof(thread1_stack),             //线程栈大小
		6,10
		);
	rt_thread_startup( &static_thread1);

	rt_thread_init(&static_thread2, "static2",
		hello_murax,RT_NULL, 
		&thread2_stack[0],                 //线程栈地址
		sizeof(thread2_stack),             //线程栈大小
		6,5
		);

	rt_thread_startup( &static_thread2);
}

