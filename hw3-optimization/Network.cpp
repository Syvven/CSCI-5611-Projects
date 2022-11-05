#include "Network.h"

Network::Network(int _numLayers, Layer** _layers) {
	this->numLayers = _numLayers;
	this->layers = _layers;
}

Network::~Network() {}

// getters
Layer** Network::getLayers() { return this->layers; }
int Network::getNumLayers() { return this->numLayers; }

Matrix* Network::Random(int maxIter, bool inf) {
	Matrix* inputs = new Matrix(this->layers[0]->getWeights().getCols(), 1);
	Matrix* ogInputs = new Matrix(this->layers[0]->getWeights().getCols(), 1);

	float low = -10000.0; float high = 10000.0;
	for (int i = 0; i < inputs->getRows(); i++) {
		float r = arbitraryRand(low, high);
		(*inputs)[loc(i, 0)] = r;
		(*ogInputs)[loc(i, 0)] = r;
	}

	Matrix* outputs = new Matrix(predict(*inputs));
	float best = magnitude(outputs);
	Matrix* bestInput = new Matrix(inputs->getRows(), inputs->getCols());

	for (int i = 0; i < inputs->getRows(); i++) {
		for (int j = 0; j < inputs->getCols(); j++) {
			(*bestInput)[loc(i, j)] = (*inputs)[loc(i, j)];
		}
	}

	Matrix bestOut(*outputs);

	int currIter = 0;
	while (inf || currIter != maxIter) {
		if (best < 0.000001) {
			cout << "Original Inputs:\n" << *ogInputs << endl;
			cout << "Optimal Inputs:\n" << *bestInput << endl;
			cout << "Optimal Output:\n" << bestOut << endl;
			cout << "Magnitude of Optimal: " << best << endl;
			cout << "Iterations: " << currIter << endl;

			delete inputs;
			delete ogInputs;

			return outputs;
		}

		if (currIter % 1000000 == 0 && currIter != 0) cout << currIter << endl;

		for (int i = 0; i < inputs->getRows(); i++) {
			for (int j = 0; j < inputs->getCols(); j++) {
				float d = arbitraryRand(low, high);
				(*inputs)[loc(i, j)] += d;
			}
		}

		outputs = new Matrix(predict(*inputs));

		float n = magnitude(outputs);
		if (n < best) {
			for (int i = 0; i < inputs->getRows(); i++) {
				for (int j = 0; j < inputs->getCols(); j++) {
					(*bestInput)[loc(i, j)] = (*inputs)[loc(i, j)];
				}
			}

			best = n;
		}

		currIter++;
	}

	cout << "Original Inputs:\n" << *ogInputs << endl;
	cout << "Optimal Inputs:\n" << *bestInput << endl;
	cout << "Optimal Output:\n" << bestOut << endl;
	cout << "Magnitude of Optimal: " << best << endl;
	cout << "Iterations: " << currIter << endl;

	delete inputs;
	delete ogInputs;

	return bestInput;
}

Matrix* Network::RandomSearch(int maxIter, bool inf) {
	Matrix *inputs = new Matrix(this->layers[0]->getWeights().getCols(), 1);
	Matrix *ogInputs = new Matrix(this->layers[0]->getWeights().getCols(), 1);

	float low = -100; float high = 100;
	for (int i = 0; i < inputs->getRows(); i++) {
		float r = arbitraryRand(low, high);
		(*inputs)[loc(i, 0)] = r;
		(*ogInputs)[loc(i, 0)] = r;
	}

	Matrix *outputs = new Matrix(predict(*inputs));

	float best = magnitude(outputs);
	Matrix *bestInput = new Matrix(inputs->getRows(), inputs->getCols());

	for (int i = 0; i < inputs->getRows(); i++) {
		for (int j = 0; j < inputs->getCols(); j++) {
			(*bestInput)[loc(i, j)] = (*inputs)[loc(i, j)];
		}
	}

	Matrix bestOut(*outputs);

	int currIter = 0; float d;
	while (inf || currIter != maxIter) {
		if (best < 0.000001) {
			cout << "Original Inputs:\n" << *ogInputs << endl;
			cout << "Optimal Inputs:\n" << *bestInput << endl;
			cout << "Optimal Output:\n" << bestOut << endl;
			cout << "Magnitude of Optimal: " << best << endl;
			cout << "Iterations: " << currIter << endl;

			delete inputs;
			delete ogInputs;

			return bestInput;
		}

		if (currIter % 1000000 == 0 && currIter != 0) cout << currIter << endl;

		Matrix temp(*inputs);
		for (int i = 0; i < inputs->getRows(); i++) {
			for (int j = 0; j < inputs->getCols(); j++) {
				d = arbitraryRand(-2, 2);
				temp[loc(i, j)] += d;
			}
		}

		outputs = new Matrix(predict(temp));

		float n = magnitude(outputs);
		/*cout << "n: " << n << ", Best: " << best << endl;*/
		if (n < best) {
			*inputs = temp;

			for (int i = 0; i < inputs->getRows(); i++) {
				for (int j = 0; j < inputs->getCols(); j++) {
					(*bestInput)[loc(i, j)] = (*inputs)[loc(i, j)];
				}
			}

			bestOut = *outputs;
			best = n;
		}

		currIter++;
	}

	cout << "Original Inputs:\n" << *ogInputs << endl;
	cout << "Optimal Inputs:\n" << *bestInput << endl;
	cout << "Optimal Output:\n" << bestOut << endl;
	cout << "Magnitude of Optimal: " << best << endl;
	cout << "Iterations: " << currIter << endl;

	delete inputs;
	delete ogInputs;

	return bestInput;
}

Matrix* Network::Gradient(int maxIter, bool inf) {
	Matrix* inputs = new Matrix(this->layers[0]->getWeights().getCols(), 1);
	Matrix* ogInputs = new Matrix(this->layers[0]->getWeights().getCols(), 1);

	for (int i = 0; i < inputs->getRows(); i++) {
		(*inputs)[loc(i, 0)] = 0;
		(*ogInputs)[loc(i, 0)] = 0;
	}

	Matrix outputs = predict(*inputs);

	float best = magnitude(&outputs);
	Matrix bestInput(*inputs);
	Matrix bestOut(outputs);

	int currIter = 0;

	// how to find gradient of the network


	while (inf || currIter != maxIter) {
		currIter++;
	}

	cout << "Original Inputs:\n" << *ogInputs << endl;
	cout << "Optimal Inputs:\n" << bestInput << endl;
	cout << "Optimal Output:\n" << bestOut << endl;
	cout << "Magnitude of Optimal: " << best << endl;
	cout << "Iterations: " << currIter << endl;

	delete inputs;
	delete ogInputs;

	return &outputs;
	return nullptr;
}

Matrix* Network::GradientMomentum(int maxIter, float beta, bool inf) {
	return nullptr;
}

Matrix* Network::GradientMomentumScale(int maxIter, float beta, float alpha, bool inf) {
	return nullptr;
}

Matrix* Network::CrossEntropy(int maxIter, bool inf) {
	int input_rows = this->layers[0]->getWeights().getCols();
	int input_cols = 1;

	int N = 1000;
	int Ne = 2;

	float newSum = 1e9;
	float oldSum = 0;

	// need a couple things:
	// -> vector of standard deviations for each element of input
	// -> vector of means for each element of input
	// -> vector of sample inputs and their magnitudes

	vector<float> std_devs(input_rows);
	vector<float> means(input_rows);

	vector<pair<Matrix*, float>> samplePairs;

	// first thing is to initialize everything that will be needed going forward
	for (int i = 0; i < N; i++) {
		for (int j = 0; j < input_rows; j++) {
			std_devs[j] = 0.4;
			means[j] = 1.0;
		}

		pair<Matrix*, float> p(new Matrix(input_rows, input_cols), (float)0.0);
		for (int j = 0; j < input_rows; j++) {
			for (int k = 0; k < input_cols; k++) {
				(*p.first)[loc(j, k)] = arbitraryRand(-3, 3);
			}
		}
		samplePairs.push_back(p);
	}

	int currIter = 0;
	while ((inf || (currIter < maxIter))) {
		// sample the input vectors
		/*default_random_engine gen;*/

		for (int i = 0; i < N; i++) {
			for (int a = 0; a < input_rows; a++) {
				random_device gen;
				normal_distribution<float> gaussian(means[a], std_devs[a]+1e-9);
				for (int b = 0; b < input_cols; b++) {
					(*(samplePairs[i].first))[loc(a, b)] = gaussian(gen);
				}
			}

			// run each sampled input vector through the objective function
			Matrix out = predict(*(samplePairs[i].first));
			samplePairs[i].second = magnitude(&out);
		}

		// sort the results in decreasing order using predefined function
		sort(samplePairs.begin(), samplePairs.end(), PairCompare);

		// find new mean (magnitude of vector formed by finding mean of each input vector index)
		// also find new variance (sum of sample - mean)^2 / N
		for (int i = 0; i < input_rows; i++) {
			for (int j = 0; j < input_cols; j++) {
				means[i] = 0.0; std_devs[i] = 0.0;
				for (int k = 0; k < Ne; k++) {
					means[i] += (*(samplePairs[k].first))[loc(i, j)];
				}
				means[i] /= Ne;
				
				for (int k = 0; k < Ne; k++) {
					std_devs[i] += pow((*(samplePairs[k].first))[loc(i, j)] - means[i], 2);
				}
				std_devs[i] /= Ne;
				std_devs[i] = sqrt(std_devs[i]);

				std_devs[i] += 1.0 / (currIter + 1);
			}
		}

		currIter++;
	}

	Matrix *output = new Matrix(input_rows, input_cols);
	for (int i = 0; i < input_rows; i++) {
		for (int j = 0; j < input_cols; j++) {
			(*output)[loc(i, j)] = means[i];
		}
	}

	cout << "Optimal Input " << endl << *output << endl;
	Matrix pred = predict(*output);
	cout << "Output: " << endl << pred << endl;
	cout << "Magnitude of output: " << magnitude(&pred) << endl;

	return output;
}

Matrix Network::predict(Matrix& inputs) {
	Matrix out(inputs);

	for (int i = 0; i < this->numLayers; i++) {
		// xn = Wi*xi + Bi
		out = matMul(this->layers[i]->getWeights(), out);
		out += this->layers[i]->getBiases();

		// apply Relu activation function if needed
		if (this->layers[i]->usesRelu()) {
			for (int m = 0; m < out.getRows(); m++) {
				for (int n = 0; n < out.getCols(); n++) {
					out[loc(m, n)] = relu(out[loc(m,n)]);
				}
			}
		}
		if (this->layers[i]->usesSigmoid()) {
			for (int m = 0; m < out.getRows(); m++) {
				for (int n = 0; n < out.getCols(); n++) {
					out[loc(m, n)] = sigmoid(out[loc(m, n)]);
				}
			}
		}
	}

	return out;
}

string Network::toString() {
	string retMsg;
	string biasMsg;
	string weightMsg;

	int i = 0;
	for (; i < this->numLayers-1; i++) {
		retMsg += "------ Layer: " + to_string(i + 1) + " ------\n";

		retMsg += this->layers[i]->toString() + "\n";
	}
	retMsg += "------ Layer: " + to_string(i + 1) + " ------\n";
	retMsg += this->layers[i]->toString();

	return retMsg;
}
