//#define _CRTDBG_MAP_ALLOC
//#include <stdlib.h>
//#include <crtdbg.h>
//#ifdef _DEBUG
//#ifndef DBG_NEW
//#define DBG_NEW new ( _NORMAL_BLOCK , __FILE__ , __LINE__ )
//#define new DBG_NEW
//#endif
//#endif  // _DEBUG

#ifndef LAYER_H_
#define LAYER_H_

#include <vector>
#include <iostream>
#include <string>

#include "utils.h"
#include "Matrix.h"

using namespace std;

class Layer {
public:
	Layer(int _rows, int _cols, bool _relu, bool _sigmoid,
		float* _weights, float* _biases);
	Layer(int _rows, int _cols, bool _relu, bool _sigmoid,
		Matrix* _weights, Matrix* _biases);
	~Layer();

	// getters
	bool usesRelu();
	bool usesSigmoid();
	Matrix& getWeights();
	Matrix& getBiases();

	// printing
	string toString();

private:
	bool relu;
	bool sigmoid;
	Matrix *weights;
	Matrix *biases;
};

#endif