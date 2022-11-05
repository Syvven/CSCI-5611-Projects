#include "Matrix.h"

Matrix::Matrix() {
	this->rows = 0;
	this->cols = 0;
	this->mat = new float[0];
}

Matrix::Matrix(const Matrix& o) {
	this->rows = o.rows;
	this->cols = o.cols;
	this->mat = new float[this->rows * this->cols];
	for (int i = 0; i < this->rows; i++) {
		for (int j = 0; j < this->cols; j++) {
			this->mat[i * this->cols + j] = o.mat[i*o.cols+j];
		}
	}
}

Matrix::Matrix(int _rows, int _cols) {
	this->mat = new float[_rows * _cols]{ 0 };
	this->rows = _rows;
	this->cols = _cols;
}

Matrix::Matrix(float* _mat, int _rows, int _cols) {
	this->rows = _rows;
	this->cols = _cols;
	this->mat = new float[_rows * _cols];
	for (int i = 0; i < this->rows; i++) {
		for (int j = 0; j < this->cols; j++) {
			this->mat[i * _cols + j] = *((_mat + i * this->cols) + j);
		}
	}
}

Matrix::~Matrix() {
	delete this->mat;
}

int Matrix::getRows() { return this->rows; }
int Matrix::getCols() { return this->cols; }
float& Matrix::getMat() { return *this->mat; }

string Matrix::toString() {
	string retMsg;

	for (int i = 0; i < this->rows; i++) {
		retMsg += "| ";
		for (int j = 0; j < this->cols; j++) {
			retMsg += to_string(this->mat[i * this->cols + j]) + " ";
		}
		retMsg += "|\n";
	}

	return retMsg;
}

Matrix& Matrix::operator=(const Matrix& o) {
	if (&o == this) {
		return *this;
	}
	delete this->mat;
	this->mat = new float[o.cols*o.rows];
	for (int i = 0; i < o.rows; i++) {
		for (int j = 0; j < o.cols; j++) {
			this->mat[i*o.cols+j] = o.mat[i*o.cols+ j];
		}
	}
	this->cols = o.cols;
	this->rows = o.rows;
	return *this;
}

float& Matrix::operator[](loc const& p) {
	return this->mat[p.x * this->cols + p.y];
}

Matrix& Matrix::operator+(Matrix& o) {
	if (this->rows == 1 && this->cols == 1) {
		Matrix* ret = new Matrix(o.rows, o.cols);
		for (int i = 0; i < o.rows; i++) {
			for (int j = 0; j < o.cols; j++) {
				(*ret)[loc(i, j)] = (*this)[loc(0, 0)] + o[loc(i, j)];
			}
		}
		return *ret;
	}
	if (o.rows == 1 && o.cols == 1) {
		Matrix* ret = new Matrix(this->rows, this->cols);
		for (int i = 0; i < this->rows; i++) {
			for (int j = 0; j < this->cols; j++) {
				(*ret)[loc(i, j)] = (*this)[loc(i, j)] + o[loc(0, 0)];
			}
		}
		return *ret;
	}
	if (this->rows != o.rows) {
		cerr << "Matrix dimensions incompatible for addition." << endl;
		exit(EXIT_FAILURE);
	}
	if (this->cols != o.cols) {
		if (o.cols != 1 && this->cols != 1) {
			cerr << "Matrix dimensions incompatible for addition." << endl;
			exit(EXIT_FAILURE);
		}
		if (o.cols == 1) {
			Matrix* ret = new Matrix(this->rows, this->cols);
			for (int i = 0; i < this->rows; i++) {
				for (int j = 0; j < this->cols; j++) {
					(*ret)[loc(i, j)] = (*this)[loc(i, j)] + o[loc(i, 0)];
				}
			}
			return *ret;
		}
		if (this->cols == 1) {
			Matrix* ret = new Matrix(o.rows, o.cols);
			for (int i = 0; i < o.rows; i++) {
				for (int j = 0; j < o.cols; j++) {
					(*ret)[loc(i, j)] = (*this)[loc(i, 0)] + o[loc(i, j)];
				}
			}
			return *ret;
		}
	}
	else {
		Matrix* ret = new Matrix(this->rows, this->cols);
		for (int i = 0; i < this->rows; i++) {
			for (int j = 0; j < this->cols; j++) {
				(*ret)[loc(i, j)] = (*this)[loc(i, j)] + o[loc(i, j)];
			}
		}
		return *ret;
	}
}

void Matrix::operator+=(Matrix& o) {
	if (this->rows != o.rows) {
		cerr << "Matrix dimensions incompatible for addition." << endl;
		exit(EXIT_FAILURE);
	}
	if (this->cols != o.cols) {
		if (o.cols != 1) {
			cerr << "Matrix dimensions incompatible for addition." << endl;
			exit(EXIT_FAILURE);
		}
		for (int i = 0; i < this->rows; i++) {
			for (int j = 0; j < this->cols; j++) {
				(*this)[loc(i, j)] += o[loc(i, 0)];
			}
		}
	}
	else {
		for (int i = 0; i < this->rows; i++) {
			for (int j = 0; j < this->cols; j++) {
				(*this)[loc(i, j)] += o[loc(i, j)];
			}
		}
	}
}

Matrix& Matrix::operator*(Matrix& o) {
	if (this->rows == 1 && this->cols == 1) {
		Matrix* ret = new Matrix(o.rows, o.cols);
		for (int i = 0; i < o.rows; i++) {
			for (int j = 0; j < o.cols; j++) {
				(*ret)[loc(i, j)] = (*this)[loc(0, 0)] * o[loc(i, j)];
			}
		}
		return *ret;
	}
	if (o.rows == 1 && o.cols == 1) {
		Matrix* ret = new Matrix(this->rows, this->cols);
		for (int i = 0; i < this->rows; i++) {
			for (int j = 0; j < this->cols; j++) {
				(*ret)[loc(i, j)] = (*this)[loc(i, j)] * o[loc(0, 0)];
			}
		}
		return *ret;
	}
	if (this->rows != o.rows) {
		cerr << "Matrix dimensions incompatible for multiplication." << endl;
		cerr << "This: " << this->rows << "x" << this->cols << endl;
		cerr << "Other: " << o.rows << "x" << o.cols << endl;
		exit(EXIT_FAILURE);
	}
	if (this->cols != o.cols) {
		if (o.cols != 1 && this->cols != 1) {
			cerr << "Matrix dimensions incompatible for multiplication." << endl;
			cerr << "This: " << this->rows << "x" << this->cols << endl;
			cerr << "Other: " << o.rows << "x" << o.cols << endl;
			exit(EXIT_FAILURE);
		}
		if (o.cols == 1) {
			Matrix* ret = new Matrix(this->rows, this->cols);
			for (int i = 0; i < this->rows; i++) {
				for (int j = 0; j < this->cols; j++) {
					(*ret)[loc(i, j)] = (*this)[loc(i, j)] * o[loc(i, 0)];
				}
			}
			return *ret;
		}
		if (this->cols == 1) {
			Matrix* ret = new Matrix(o.rows, o.cols);
			for (int i = 0; i < o.rows; i++) {
				for (int j = 0; j < o.cols; j++) {
					(*ret)[loc(i, j)] = (*this)[loc(i, 0)] * o[loc(i, j)];
				}
			}
			return *ret;
		}
	}
	else {
		Matrix* ret = new Matrix(this->rows, this->cols);
		for (int i = 0; i < this->rows; i++) {
			for (int j = 0; j < this->cols; j++) {
				(*ret)[loc(i, j)] = (*this)[loc(i, j)] * o[loc(i, j)];
			}
		}
		return *ret;
	}
}

Matrix& Matrix::operator*(float o) {
	Matrix* ret = new Matrix(this->rows, this->cols);
	for (int i = 0; i < this->rows; i++) {
		for (int j = 0; j < this->cols; j++) {
			(*ret)[loc(i, j)] *= o;
		}
	}
	return *ret;
}

void Matrix::operator*=(Matrix& o) {
	if (this->rows != o.rows) {
		cerr << "Matrix dimensions incompatible for multiplication." << endl;
		exit(EXIT_FAILURE);
	}
	if (this->cols != o.cols) {
		if (o.cols != 1) {
			cerr << "Matrix dimensions incompatible for multiplication." << endl;
			exit(EXIT_FAILURE);
		}
		for (int i = 0; i < this->rows; i++) {
			for (int j = 0; j < this->cols; j++) {
				(*this)[loc(i, j)] *= o[loc(i, 0)];
			}
		}
	}
	else {
		for (int i = 0; i < this->rows; i++) {
			for (int j = 0; j < this->cols; j++) {
				(*this)[loc(i, j)] *= o[loc(i, j)];
			}
		}
	}
}

void Matrix::operator*=(float o) {
	for (int i = 0; i < this->rows; i++) {
		for (int j = 0; j < this->cols; j++) {
			(*this)[loc(i, j)] *= o;
		}
	}
}