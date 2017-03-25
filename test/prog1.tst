
int main() {
	int answer = 234;
	bool t = 1;
	answer = -calculateAnswer();
	t = !answer;
	t = -answer;
	return -answer + 1;
}

int calculateAnswer() {
	int answer = getBaseValue() + -2;
	return answer;
}

int getBaseValue() {
	int a = 25, b = 18, c = a + b;
	return c;
}
