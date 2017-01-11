
int main(array args) {
	bool yesOrNo;
	int intVal = 5;
	float floatVal = 4.2;
	someValue = giveMeABoolPlease(args[0], intVal, floatVal);
	return 0;
}

bool giveMeABoolPlease(string stringVal, int intVal, float floatVal) {
	char charVal = 'b';
	return stringVal == "hello" && intVal == 5 && floatVal == 4.2 && charVal == 'b';
}
