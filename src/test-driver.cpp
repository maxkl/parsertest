
#include "test-driver.hpp"
#include "test.y.hpp"

test_driver::test_driver() : trace_scanning(false), trace_parsing(false) {

}

test_driver::~test_driver() {

}

int test_driver::parse(const std::string &filename_) {
	filename = filename_;
	scan_begin();
	yy::test_parser parser(*this);
	parser.set_debug_level(trace_parsing);
	int ret = parser.parse();
	scan_end();
	return ret;
}

void test_driver::error(const yy::location &loc, const std::string &message) {
	std::cerr << loc << ": " << message << std::endl;
}

void test_driver::error(const std::string &message) {
	std::cerr << message << std::endl;
}
