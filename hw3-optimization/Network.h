#ifndef NETWORK_H_
#define NETWORK_H_

//#define _CRTDBG_MAP_ALLOC
//#include <stdlib.h>
//#include <crtdbg.h>
//#ifdef _DEBUG
//#ifndef DBG_NEW
//#define DBG_NEW new ( _NORMAL_BLOCK , __FILE__ , __LINE__ )
//#define new DBG_NEW
//#endif
//#endif  // _DEBUG

#include <vector>
#include <iostream>
#include <string>
#include <random>

#include "Matrix.h"
#include "Layer.h"
#include "utils.h"

using namespace std;

class Network {
public:
	Network(int _numLayers, Layer** _layers);
	~Network();
	Layer** getLayers();
	int getNumLayers();

	Matrix* Random(int maxIter, bool inf);
	Matrix* RandomSearch(int maxIter, bool inf);
	Matrix* Gradient(int maxIter, bool inf);
	Matrix* GradientMomentum(int maxIter, float beta, bool inf);
	Matrix* GradientMomentumScale(int maxIter, float beta, float alpha, bool inf);
	Matrix* CrossEntropy(int maxIter, bool inf);
	Matrix predict(Matrix& input);

	// Printing stuff
	string toString();
	friend ostream& operator<<(ostream& s, Network& net) {
		s << net.toString();

		return s;
	}

private:
	int numLayers;
	Layer** layers;
};

#endif