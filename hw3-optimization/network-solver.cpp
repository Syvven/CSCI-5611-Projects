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
#include <string>
#include <iomanip>
#include <cstdlib>
#include <ctime>
#include <fstream>

#include "Network.h"
#include "utils.h"
#include "Matrix.h"
#include "Layer.h"

using namespace std;

int main(int argc, char** argv) {
	srand(static_cast <unsigned> (time(0)));
	cout << "Starting NN Solver\n" << endl;

	ifstream inf{ "./networks.txt" };
	if (!inf) {
		std::cerr << "networks.txt could not be opened for reading." << endl;
		exit(EXIT_FAILURE);
	}

	ifstream inf2{ "./solutions.txt" };
	if (!inf2) {
		std::cerr << "solutions.txt could not be opened for reading." << endl;
		exit(EXIT_FAILURE);
	}

	ofstream outf{ "netout.txt", ios_base::app };
	if (!outf) {
		cerr << "netout.txt could not be opened for writing." << endl;
		exit(EXIT_FAILURE);
	}

	string layer, row, col, weight, bias, rel, empty;
	string inp;
	int count = 0;
	while (inf) {
		getline(inf, layer);
		vector<string> l = split(layer, " ");
		const int numLayers = stoi(l[l.size() - 1]);

		Layer** layers = new Layer * [numLayers];

		for (int l = 0; l < numLayers; l++) {
			getline(inf, row);
			getline(inf, col);
			getline(inf, weight);
			getline(inf, bias);
			getline(inf, rel);

			vector<string> r = split(row, " ");
			vector<string> c = split(col, " ");

			const int rows = stoi(r[r.size() - 1]);
			const int cols = stoi(c[c.size() - 1]);

			bool relu;
			vector<string> rell = split(rel, " ");
			if (rell[rell.size()-1] == "true") relu = true;
			else relu = false;

			// first get rid of any [ and ]
			weight = eraseFromString(weight, '[');
			weight = eraseFromString(weight, ']');
			weight = eraseFromString(weight, ',');

			bias = eraseFromString(bias, '[');
			bias = eraseFromString(bias, ']');
			bias = eraseFromString(bias, ',');

			// then split at the commas
			vector<string> weightvec = split(weight, " ");

			vector<string> biasvec = split(bias, " ");

			weightvec.erase(weightvec.begin());
			weightvec.erase(weightvec.begin());

			biasvec.erase(biasvec.begin());
			biasvec.erase(biasvec.begin());

			// now construct weight array based on this
			Matrix w(rows, cols);
			Matrix b(rows, 1);

			for (int i = 0; i < rows; i++) {
				for (int j = 0; j < cols; j++) {
					int ind = i * cols + j;
					w[loc(i, j)] = stof(weightvec[ind]);
				}
				b[loc(i, 0)] = stof(biasvec[i]);
			}

			layers[l] = new Layer(rows, cols, relu, false, &w, &b);
		}

		// skip the example input, example output, and empty space
		getline(inf, empty);
		getline(inf, empty);
		getline(inf, empty);
		
		// split some of the strings

		Network n(numLayers, layers);

		if (true) {
			for (int i = 0; i < 1; i++) {
				cout << "Evaluating Network " << count << " With Cross Entropy : " << endl;
				Matrix* out = n.CrossEntropy(1000, false);

				outf << "Network " << count << endl;
				outf << *out;
				Matrix c = n.predict(*out);
				outf << magnitude(&c) << endl;
			}
		}

		
		if (false) {
			getline(inf2, inp);
			vector<string> inpvec = split(inp, ",");

			Matrix in(n.getLayers()[0]->getWeights().getCols(), 1);
			for (int i = 0; i < in.getRows(); i++) {
				in[loc(i, 0)] = stof(inpvec[i]);
			}

			Matrix c = n.predict(in);
			cout << "Network " << count << ":" << endl;
			cout << "Output" << endl;
			cout << c << endl << endl;
			cout << "Magnitude" << endl;
			cout << magnitude(&c) << endl;
		}

		for (int i = 0; i < numLayers; i++) {
			delete layers[i];
		}
		delete[] layers;

		count++;
	}

	outf << "---------------------------------------" << endl;
	outf << "---------------------------------------" << endl;
	outf << "---------------------------------------" << endl;
	outf << "---------------------------------------" << endl;

	/*cout << "Dumping Leak Report" << endl;

	_CrtMemDumpAllObjectsSince(NULL);*/

	return 0;
}
