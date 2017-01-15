
#include <iostream>
#include <string>

#include "test-driver.hpp"

int main(int argc, char **argv) {
	int ret = 0;
	test_driver driver;
	for(int i = 1; i < argc; i++) {
		if(argv[i] == std::string("-p")) {
			driver.trace_parsing = true;
		} else if (argv[i] == std::string("-s")) {
			driver.trace_scanning = true;
		} else if (!driver.parse(argv[i])) {
			// std::cout << driver.result << std::endl;
		} else {
			ret = 1;
		}
	}
	return ret;
}
