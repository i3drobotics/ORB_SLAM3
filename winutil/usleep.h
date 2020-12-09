#ifndef USLEEP_H
#define USLEEP_H

#define NOMINMAX
#include <windows.h>
#include <chrono>
#include <thread>

void usleep(DWORD waittime) {
	std::this_thread::sleep_for(std::chrono::microseconds(waittime));
}
#endif // USLEEP_H