#include <usleep.h>

void usleep(DWORD waittime) {
	std::this_thread::sleep_for(std::chrono::microseconds(waittime));
}