
/* this thing here
 * is
 a block comment */

// With this line comment you can do something
// Oh yeah
int fn1(float floatArg, bool boolArg) {
	a = b - 1 == c + 5;
	return a + b - c * d / e % f << g >> h & i ^ j | k && l || m < n > o
		<= p >= q == r != s = t += u -= v *= w /= x %= y &= z |=
		aa ^= ab <<= ac >>= (ad + ae);
}

string whatsTheWeather(char c /* Whoa! You can put comments really anywhere */, char blub) {
	return "It'll be cloudy with a chance of parser errors" * 'h' - '\0' % !(+-blub);
}

bool functionWithVars(int a) {
	int b;
	int c, d;
	int e = 9;
	int f, g = '\0';
	e += g = a;
	return e;
}

float[] collectData(int[] intArray) {
	float[] values = intArray | "iknowthismakesnosense";
	values[83742 + 1 - intArray[2]] = !-+!notExisting[values[-26 * "asdf"[3]]];
	values[i - j] = whatsTheWeather() + whatsTheWeather(5) + whatsTheWeather(i, j, whatsTheWeather(whatsTheWeather[9]));
	return values[100 / 2];
}

void noMorePlusEquals() {
	i += 1;
	j = i -= 1;
	k = i[3] -= 1;
	return !(i += 1);
}
