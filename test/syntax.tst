
/* this thing here
 * is
 a block comment */

// With this line comment you can do something
// Oh yeah
int fn1(float floatArg, bool boolArg) {
	a = b - 1 == c + 5;
	return a + b - c * d / e % f << g >> h & i ^ j | k && l || m < n > o
		<= p >= q == r != s = (t + u);
}

string whatsTheWeather(char c /* Whoa! You can put comments really anywhere */, char blub) {
	return "It'll be cloudy with a chance of parser errors" * 'h' - '\0' % !(+-blub);
}

bool functionWithVars(int a) {
	int b;
	int c, d;
	int e = 9;
	int f, g = '\0';
	e = e + g = a;
	return e;
}

float collectData(int intArray) {
	float values = intArray | "iknowthismakesnosense";
	values = !-+!notExisting;
	values = whatsTheWeather() + whatsTheWeather(5) + whatsTheWeather(i, j, whatsTheWeather(whatsTheWeather));
	return values;
}

void noMorePlusEquals() {
	i = i + 1;
	j = i = i - 1;
	k = i = i - 1;
	return !(i = i + 1);
}
