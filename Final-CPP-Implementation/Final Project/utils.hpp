#ifndef UTILS_H_
#define UTILS_H_

#include <iostream>

#include "glad/include/glad/glad.h"
#include "SDL.h"
#include "SDL_opengl.h"
#include "glm/vec2.hpp"

void loadShader(GLuint shaderID, const GLchar* shaderSource) {
	glShaderSource(shaderID, 1, &shaderSource, nullptr);
	glCompileShader(shaderID);

	GLint status;
	glGetShaderiv(shaderID, GL_COMPILE_STATUS, &status);
	if (!status) {
		char buffer[512]; glGetShaderInfoLog(shaderID, 512, nullptr, buffer);
		printf("Shader Compile Failed. Info:\n\n%s\n", buffer);
	}
}

#endif