#ifndef UTILS_H_
#define UTILS_H_

//#define _CRTDBG_MAP_ALLOC
//#include <stdlib.h>
//#include <crtdbg.h>
//#ifdef _DEBUG
//#ifndef DBG_NEW
//#define DBG_NEW new ( _NORMAL_BLOCK , __FILE__ , __LINE__ )
//#define new DBG_NEW
//#endif
//#endif  // _DEBUG

#include <iostream>
#include <vector>
#include <cmath>
#include <string>
#include <cstring>

#include "Matrix.h"

using namespace std;

static string eraseFromString(string str, char delim) {
	string my_str(str);
	my_str.erase(remove(my_str.begin(), my_str.end(), delim), my_str.end());
	return my_str;
}

static vector<string> split(string str, string delim) {
	vector<string> tokens;

	size_t pos = 0;
	std::string token;
	while ((pos = str.find(delim)) != std::string::npos) {
		token = str.substr(0, pos);
		
		tokens.push_back(token);

		str.erase(0, pos + delim.length());
	}

	tokens.push_back(str);
	
	return tokens;
}

static float vectorMean(Matrix* vec) {
	float total = 0;
	for (int i = 0; i < vec->getRows(); i++) {
		for (int j = 0; j < vec->getCols(); j++) {
			total += (*vec)[loc(i, j)];
		}
	}
	total /= (vec->getRows() * vec->getCols());
	return total;
}

static bool PairCompare(pair<Matrix*, float> p1, pair<Matrix*, float> p2) {
	return (p1.second < p2.second);
}

static float magnitude(Matrix* mat) {
	float mag = 0;

	for (int i = 0; i < mat->getRows(); i++) {
		for (int j = 0; j < mat->getCols(); j++) {
			mag += abs((*mat)[loc(i, j)]);
		}
	}

	return mag;
}

static float arbitraryRand(float low, float high) {
	return (low + static_cast <float> (rand()) / (static_cast <float> (RAND_MAX / (high - low))));
}

static float dot(Matrix& m1, Matrix& m2) {
	return 0;
}

// order of multiplication matters
static Matrix matMul(Matrix& m1, Matrix& m2) {
	// only matrices with dimensions MxN, NxK can be multiplied
	if (m1.getCols() != m2.getRows()) {
		cerr << "Matrix dimensions incompatible for matrix multiplication." << endl;
		exit(EXIT_FAILURE);
	}

	Matrix ret(m1.getRows(), m2.getCols());

	for (int m = 0; m < ret.getRows(); m++) {
		for (int n = 0; n < ret.getCols(); n++) {
			for (int k = 0; k < m1.getCols(); k++) {
				ret[loc(m,n)] += m1[loc(m, k)] * m2[loc(k, n)];
			}
		}
	}

	return ret;
}

static float sigmoid(float val) {
	return 1 / (1 + exp(-val));
}

static float relu(float val) {
	return (val < 0) ? 0 : val;
}

#endif