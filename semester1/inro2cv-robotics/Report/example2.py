# this again should be your code

import eulerlib


def compute():
	DIGITS = 100
	MULTIPLIER = 100**DIGITS
	ans = sum(
		sum(int(c) for c in str(eulerlib.sqrt(i * MULTIPLIER))[ : DIGITS])
		for i in range(100)
		if eulerlib.sqrt(i)**2 != i)
	return str(ans)
