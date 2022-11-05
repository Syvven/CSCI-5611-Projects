#include "Layer.h"

Layer::Layer(int _rows, int _cols, bool _relu, bool _sigmoid,
		float* _weights, float* _biases) {
	this->relu = _relu;
	this->sigmoid = _sigmoid;
	
	this->weights = new Matrix(_weights, _rows, _cols);
	this->biases = new Matrix(_biases, _rows, 1);
}

Layer::Layer(int _rows, int _cols, bool _relu, bool _sigmoid,
		Matrix* _weights, Matrix* _biases) {
	this->relu = _relu;
	this->sigmoid = _sigmoid;

	this->weights = new Matrix(*_weights);
	this->biases = new Matrix(*_biases);
}

Layer::~Layer() {
	delete this->weights;
	delete this->biases;
}

bool Layer::usesRelu() { return this->relu; }
bool Layer::usesSigmoid() { return this->sigmoid; }
Matrix& Layer::getWeights() { return *this->weights; }
Matrix& Layer::getBiases() { return *this->biases; }

string Layer::toString() {
	string weightMsg;
	string biasMsg;

	string reluMsg = "Relu: ";
	if (this->relu) reluMsg += "True";
	else reluMsg += "False";

	weightMsg = "Weights:" +
		to_string(this->weights->getRows()) + "x" +
		to_string(this->weights->getCols()) + "\n";
	biasMsg = "Biases: " +
		to_string(this->weights->getRows()) + "x" +
		to_string(1) + "\n";

	weightMsg += this->weights->toString();
	biasMsg += this->biases->toString();
	return ("\n" + weightMsg + "\n" + biasMsg + "\n" + reluMsg + "\n");
}