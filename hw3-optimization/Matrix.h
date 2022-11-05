#ifndef MATRIX_H_
#define MATRIX_H_

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
#include <string>

using namespace std;

struct loc {
	loc(int _x, int _y) : x(_x), y(_y) {}
	int x;
	int y;
};

class Matrix {
public:
	Matrix();
	Matrix(const Matrix& o);
	Matrix(int rows, int cols);
	Matrix(float* _mat, int _rows, int _cols);
	~Matrix();
	int getCols();
	int getRows();
	float& getMat();
	
	Matrix& operator=(const Matrix& o);
	float& operator[](loc const& p);

	Matrix& operator+(Matrix& o);
	void operator+=(Matrix& o);

	Matrix& operator*(Matrix& o);
	Matrix& operator*(float o);
	void operator*=(Matrix& o);
	void operator*=(float o);

	string toString();
	friend ostream& operator<<(ostream& s, Matrix& mat) {
		s << mat.toString();

		return s;
	}
private:
	float* mat;
	int rows;
	int cols;
};

#endif